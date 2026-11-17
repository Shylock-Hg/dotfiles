"""Exercise installer failure paths without Android or network access."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
STUB = '''#!/usr/bin/python3
import json, os, pathlib, sys, zipfile
args = sys.argv[1:]
state = pathlib.Path(os.environ['APP_STATE'])
packages = json.loads(state.read_text())
with open(os.environ['APP_LOG'], 'a') as log:
    log.write(json.dumps([pathlib.Path(sys.argv[0]).name, *args]) + '\\n')
if pathlib.Path(sys.argv[0]).name == 'curl':
    with zipfile.ZipFile(args[args.index('--output') + 1], 'w') as apk:
        apk.writestr('AndroidManifest.xml', 'com.xingin.xhs' if 'xhscdn.com' in args[-1] else 'cn.soulapp.android')
        apk.writestr('classes.dex', b'dex')
elif args == ['status']:
    print('Session: ' + os.environ.get('APP_SESSION', 'RUNNING'))
elif args == ['app', 'list']:
    for package in packages: print('packageName: ' + package)
elif args[:2] == ['app', 'install']:
    with zipfile.ZipFile(args[2]) as apk:
        packages.append(apk.read('AndroidManifest.xml').decode())
    state.write_text(json.dumps(packages))
'''


class WaydroidSetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='waydroid setup ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.state = self.root / 'apps.json'
        self.state.write_text('[]')
        self.log = self.root / 'commands.jsonl'
        self.log.touch()
        for name in ('waydroid', 'curl', 'kbuildsycoca6'):
            path = self.bin / name
            path.write_text(STUB)
            path.chmod(0o755)
        self.env = dict(os.environ, PATH=f'{self.bin}:/usr/bin:/bin',
                        WAYDROID_BIN=str(self.bin / 'waydroid'),
                        APP_STATE=str(self.state), APP_LOG=str(self.log),
                        TMPDIR=str(self.root))

    def run_setup(self, *args):
        return subprocess.run(['bash', str(ROOT / 'waydroid/setup.sh'), *args],
                              env=self.env, capture_output=True, text=True)

    def apk(self, name, package):
        path = self.root / name
        with zipfile.ZipFile(path, 'w') as apk:
            apk.writestr('AndroidManifest.xml', package)
            apk.writestr('classes.dex', b'dex')
        return str(path)

    def commands(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()]

    def test_installs_both_local_apks_with_spaces_and_refreshes_kde(self):
        result = self.run_setup('--xiaohongshu-apk', self.apk('red note.apk', 'com.xingin.xhs'),
                                '--soul-apk', self.apk('soul app.apk', 'cn.soulapp.android'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(self.state.read_text()), ['com.xingin.xhs', 'cn.soulapp.android'])
        self.assertTrue(any(c[0] == 'kbuildsycoca6' for c in self.commands()))
        self.assertFalse(list(self.root.glob('waydroid-apps.*')))

    def test_existing_packages_skip_download_and_install(self):
        self.state.write_text(json.dumps(['com.xingin.xhs', 'cn.soulapp.android']))
        result = self.run_setup()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(any(c[0] == 'curl' or c[1:3] == ['app', 'install'] for c in self.commands()))

    def test_invalid_second_apk_prevents_any_install(self):
        invalid = self.root / 'soul.apk'
        invalid.write_text('<html>download failed</html>')
        result = self.run_setup('--xiaohongshu-apk', self.apk('rednote.apk', 'com.xingin.xhs'),
                                '--soul-apk', str(invalid))
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(json.loads(self.state.read_text()), [])
        self.assertFalse(list(self.root.glob('waydroid-apps.*')))

    def test_soul_download_uses_https_and_publisher_referrer(self):
        result = self.run_setup('--app', 'soul')
        self.assertEqual(result.returncode, 0, result.stderr)
        curl = next(c for c in self.commands() if c[0] == 'curl')
        self.assertEqual(curl[-1], 'https://china-img.soulapp.cn/apk/channel/soul_channel_soul64.apk')
        self.assertEqual(curl[curl.index('--referer') + 1], 'https://www.soulapp.cn/')
        self.assertEqual(curl[curl.index('--proto-redir') + 1], '=https')

    def test_defaults_download_and_install_both_apps(self):
        result = self.run_setup()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(self.state.read_text()), ['com.xingin.xhs', 'cn.soulapp.android'])
        downloads = [c for c in self.commands() if c[0] == 'curl']
        self.assertEqual(len(downloads), 2)
        self.assertEqual(downloads[0][-1], 'https://redgray.xhscdn.com/ui/androidPublish/prod/xhs/channel/apk/9.54.1/9541801/v9541801-xhs-share_package_common_X64.apk')
        self.assertEqual(downloads[0][downloads[0].index('--referer') + 1], 'https://www.xiaohongshu.com/')

    def test_xiaohongshu_url_override(self):
        url = 'https://redgray.xhscdn.com/custom.apk'
        result = self.run_setup('--app', 'xiaohongshu', '--xiaohongshu-url', url)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(next(c for c in self.commands() if c[0] == 'curl')[-1], url)

    def test_rejects_two_explicit_xiaohongshu_sources(self):
        result = self.run_setup('--xiaohongshu-apk', self.apk('rednote.apk', 'com.xingin.xhs'),
                                '--xiaohongshu-url', 'https://redgray.xhscdn.com/custom.apk')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Choose one Xiaohongshu APK source', result.stderr)
        self.assertFalse(self.commands())

    def test_stopped_session_does_not_install(self):
        self.env['APP_SESSION'] = 'STOPPED'
        self.assertNotEqual(self.run_setup('--app', 'soul').returncode, 0)
        self.assertEqual(json.loads(self.state.read_text()), [])

    def test_rejects_http_download_and_invalid_arguments(self):
        for args in [('--xiaohongshu-url', 'http://example.test/app.apk'),
                     ('--app', 'unknown'), ('--soul-apk',), ('--unknown',)]:
            with self.subTest(args=args):
                self.assertNotEqual(self.run_setup(*args).returncode, 0)
        self.assertEqual(json.loads(self.state.read_text()), [])


if __name__ == '__main__':
    unittest.main()
