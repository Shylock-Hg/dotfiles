#!/usr/bin/env python3
"""Check installer orchestration without downloading workstation dependencies."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("setup.sh")
STUB = r'''
import json, os, pathlib, sys
args = sys.argv[1:]
name = pathlib.Path(sys.argv[0]).name
with open(os.environ["COMMAND_LOG"], "a") as f:
    f.write(json.dumps([name, *args]) + "\n")
if args[:2] == ["-m", "venv"]:
    dest = pathlib.Path(args[2]) / "bin"
    dest.mkdir(parents=True, exist_ok=True)
    if not (dest / "python").exists():
        (dest / "python").symlink_to(os.environ["PYTHON_STUB"])
elif name == "npm" and args == ["view", "remotion", "version"]:
    print("4.0.999")
elif name == "npm" and args[0] == "install":
    dest = pathlib.Path(args[args.index("--prefix") + 1]) / "node_modules/.bin"
    dest.mkdir(parents=True, exist_ok=True)
    if not (dest / "remotion").exists():
        (dest / "remotion").symlink_to(os.environ["PYTHON_STUB"])
elif name == "git" and args[0] == "clone":
    dest = pathlib.Path(args[-1])
    dest.mkdir()
    (dest / "requirements.txt").write_text("example-dependency\n")
elif name == "sudo":
    os.execvp(args[0], args)
'''


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="video tools ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        binaries = self.root / "bin"
        binaries.mkdir()
        for name in ("python3.13", "python3", "npm", "git", "sudo"):
            path = binaries / name
            path.write_text(f"#!{sys.executable}\n" + STUB)
            path.chmod(0o755)
        self.log = self.root / "commands.jsonl"
        self.log.touch()
        self.tools = self.root / "installed tools"
        self.env = dict(os.environ, PATH=f"{binaries}:{os.environ['PATH']}",
                        VIDEO_TOOLS_DIR=str(self.tools), IN_CI="false",
                        VIDEO_TOOLS_BIN_DIR=str(self.root / "shared bin"),
                        COMMAND_LOG=str(self.log), PYTHON_STUB=str(binaries / "python3.13"))
        self.env.pop("COMFYUI_TORCH_INDEX_URL", None)

    def run_setup(self):
        return subprocess.run(["bash", str(SCRIPT)], env=self.env,
                              capture_output=True, text=True)

    def commands(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()]

    def test_ci_does_not_install_or_create_directories(self):
        self.env["IN_CI"] = "true"
        self.assertEqual(self.run_setup().returncode, 0)
        self.assertEqual(self.commands(), [])
        self.assertFalse(self.tools.exists())

    def test_install_isolated_environments_and_matching_remotion_versions(self):
        self.assertEqual(self.run_setup().returncode, 0)
        commands = self.commands()
        self.assertIn(["python", "-m", "pip", "install", "moviepy>=2,<3"], commands)
        npm = next(c for c in commands if c[:2] == ["npm", "install"])
        self.assertIn("remotion@4.0.999", npm)
        self.assertIn("@remotion/cli@4.0.999", npm)
        torch = next(c for c in commands if "torch" in c)
        self.assertEqual(torch[-1], "https://download.pytorch.org/whl/cpu")
        self.assertTrue((self.tools / "moviepy/bin/python").exists())
        self.assertTrue((self.tools / "comfyui-venv/bin/python").exists())
        for name in ("moviepy-python", "remotion", "comfyui"):
            launcher = self.root / "shared bin" / name
            self.assertEqual(launcher.stat().st_mode & 0o777, 0o755)
            subprocess.run(["bash", "-n", str(launcher)], check=True)

    def test_rerun_preserves_checkout_and_accepts_gpu_index(self):
        self.assertEqual(self.run_setup().returncode, 0)
        marker = self.tools / "ComfyUI/local-model"
        marker.write_text("preserve")
        self.log.write_text("")
        self.env["COMFYUI_TORCH_INDEX_URL"] = "https://example.com/gpu"
        self.assertEqual(self.run_setup().returncode, 0)
        self.assertFalse(any(c[0] == "git" for c in self.commands()))
        self.assertEqual(marker.read_text(), "preserve")
        torch = next(c for c in self.commands() if "torch" in c)
        self.assertEqual(torch[-1], "https://example.com/gpu")

    def test_invalid_existing_checkout_fails_without_overwriting(self):
        (self.tools / "ComfyUI").mkdir(parents=True)
        result = self.run_setup()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Missing ComfyUI requirements", result.stderr)
        self.assertFalse(any(c[0] == "git" for c in self.commands()))

    def test_shared_launchers_forward_args_and_keep_user_data_separate(self):
        self.assertEqual(self.run_setup().returncode, 0)
        launchers = self.root / "shared bin"
        subprocess.run([str(launchers / "moviepy-python"), "scene.py"],
                       env=self.env, check=True)
        subprocess.run([str(launchers / "remotion"), "--help"],
                       env=self.env, check=True)
        for user in ("alice", "bob"):
            data = self.root / user
            subprocess.run([str(launchers / "comfyui"), "--cpu"],
                           env=dict(self.env, XDG_DATA_HOME=str(data)), check=True)
            command = self.commands()[-1]
            self.assertIn(str(data / "ComfyUI/output"), command)
            self.assertIn(str(data / "ComfyUI/user"), command)
            self.assertEqual(command[-1], "--cpu")
            self.assertTrue((data / "ComfyUI/input").is_dir())
        self.assertIn(["python", "scene.py"], self.commands())
        self.assertTrue(any(c[1:] == ["--help"] for c in self.commands()))


if __name__ == "__main__":
    unittest.main()
