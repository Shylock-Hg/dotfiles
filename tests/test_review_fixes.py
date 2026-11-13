"""Regression tests using temporary files and stubbed external commands."""
import base64
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
STUB = r'''
import json, os, pathlib, sys
name = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
with open(os.environ['COMMAND_LOG'], 'a') as f:
    f.write(json.dumps([name, *args]) + '\n')
if name == 'tar':
    pathlib.Path(args[args.index('-cf') + 1]).write_text('new archive')
    sys.exit(int(os.environ.get('TAR_STATUS', '0')))
if name == 'gpg2':
    if '--output' in args:
        pathlib.Path(args[args.index('--output') + 1]).write_text('new encrypted')
    else:
        print('new plaintext', end='')
    sys.exit(int(os.environ.get('GPG_STATUS', '0')))
if name == 'tailscale':
    sys.exit(int(os.environ.get('TAILSCALE_STATUS', '0')))
if name == 'sudo':
    os.execvp(args[0], args)
if name == 'git':
    pathlib.Path(args[-1]).mkdir(parents=True)
'''


class RegressionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='review fixes ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.log = self.root / 'commands.jsonl'
        self.log.touch()
        for name in ('tar', 'gpg2', 'sudo', 'git', 'zypper', 'curl', 'stow', 'python3', 'tailscale'):
            p = self.bin / name
            p.write_text(f'#!{sys.executable}\n' + STUB)
            p.chmod(0o755)
        self.env = dict(os.environ, PATH=f'{self.bin}:{os.environ["PATH"]}',
                        COMMAND_LOG=str(self.log))

    def run_script(self, path, *args, cwd=None):
        return subprocess.run(['bash', str(path), *map(str, args)],
                              env=self.env, cwd=cwd, capture_output=True, text=True)

    def commands(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()]

    def test_home_backup_failure_preserves_both_previous_files(self):
        for variable in ('TAR_STATUS', 'GPG_STATUS'):
            with self.subTest(stage=variable):
                dest = self.root / variable
                dest.mkdir()
                for name in ('shylock.tar.zst', 'shylock.tar.zst.gpg'):
                    (dest / name).write_text('old backup')
                self.env[variable] = '2'
                result = self.run_script(ROOT / 'shylock/sh/backup-home.sh', self.root, dest)
                self.assertNotEqual(result.returncode, 0, result.stderr)
                self.assertEqual(sorted(p.name for p in dest.iterdir()),
                                 ['shylock.tar.zst', 'shylock.tar.zst.gpg'])
                for p in dest.iterdir():
                    self.assertEqual(p.read_text(), 'old backup')
                del self.env[variable]
        # Archiving failure must not reach encryption.
        self.assertEqual(sum(c[0] == 'gpg2' for c in self.commands()), 1)

    def test_home_backup_success_replaces_both_files(self):
        dest = self.root / 'backups'
        result = self.run_script(ROOT / 'shylock/sh/backup-home.sh', self.root, dest)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((dest / 'shylock.tar.zst').read_text(), 'new archive')
        self.assertEqual((dest / 'shylock.tar.zst.gpg').read_text(), 'new encrypted')
        self.assertEqual(len(list(dest.iterdir())), 2)

    def test_encrypt_failure_preserves_previous_backup_and_cleans_temporary_files(self):
        archive = self.root / 'archive'
        archive.write_text('source')
        output = self.root / 'archive.gpg'
        output.write_text('old encrypted')
        self.env['GPG_STATUS'] = '2'
        result = self.run_script(ROOT / 'shylock/sh/encrypt-backup.sh', archive, 'recipient')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(output.read_text(), 'old encrypted')
        self.assertFalse(list(self.root.glob('archive.encrypt.*')))
        self.env['GPG_STATUS'] = '0'
        result = self.run_script(ROOT / 'shylock/sh/encrypt-backup.sh', archive, 'recipient')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(output.read_text(), 'new encrypted')
        self.assertEqual(output.stat().st_mode & 0o777, 0o600)

    def test_encryption_wrappers_stop_on_failure_and_preserve_backups(self):
        data = self.root / 'Data'
        data.mkdir()
        self.env['TEST_HOME'] = str(self.root)
        self.env['GPG_STATUS'] = '2'
        (self.root / 'encrypt-backup.sh').symlink_to(ROOT / 'shylock/sh/encrypt-backup.sh')
        for wrapper, archives in (
            ('encrypt-forgejo-backup.sh', ['forgejo.tar.zst']),
            ('encrypt-gitlab-backup.sh', ['gitlab.tar.zst']),
            ('encrypt-public-server.sh', ['headscale.dump.tar.zst', 'openclash.dump.tar.zst']),
        ):
            with self.subTest(wrapper=wrapper):
                for archive in archives:
                    (data / archive).write_text('source')
                    (data / (archive + '.gpg')).write_text('old encrypted')
                script = self.root / wrapper
                script.write_text((ROOT / 'shylock/sh' / wrapper).read_text()
                                  .replace('$HOME', '$TEST_HOME'))
                self.log.write_text('')
                result = self.run_script(script)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(len(self.commands()), 1)
                for archive in archives:
                    self.assertEqual((data / (archive + '.gpg')).read_text(), 'old encrypted')
                self.assertFalse(list(data.glob('*.encrypt.*')))

    def test_decryption_failures_preserve_key(self):
        for invalid_base64 in (False, True):
            with self.subTest(invalid_base64=invalid_base64):
                key = self.root / 'private key'
                key.write_text('old key')
                source = self.root / 'private key.gpg.b64'
                source.write_bytes(b'!!!' if invalid_base64 else base64.b64encode(b'ciphertext'))
                self.env['GPG_STATUS'] = '2'
                result = self.run_script(ROOT / 'shylock/sh/de-gpg-b64.sh', source)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(key.read_text(), 'old key')
                self.assertFalse(list(self.root.glob('*.decrypt.*')))
                self.assertTrue(source.exists())

    def test_decryption_success_replaces_key_with_private_permissions(self):
        source = self.root / 'private key.gpg.b64'
        source.write_bytes(base64.b64encode(b'ciphertext'))
        result = self.run_script(ROOT / 'shylock/sh/de-gpg-b64.sh', source)
        self.assertEqual(result.returncode, 0, result.stderr)
        key = self.root / 'private key'
        self.assertEqual(key.read_text(), 'new plaintext')
        self.assertEqual(key.stat().st_mode & 0o777, 0o600)
        self.assertFalse(list(self.root.glob('*.decrypt.*')))

    def setup_fixture(self):
        checkout = self.root / 'checkout'
        checkout.mkdir()
        home = self.root / 'user'
        (home / '.cargo').mkdir(parents=True)
        (home / '.cargo/env').touch()
        (home / '.emacs').write_text('preserve legacy configuration')
        self.env['TEST_HOME'] = str(home)
        # Redirect home references in the fixture, without changing real HOME.
        script = (ROOT / 'setup.sh').read_text().replace('$HOME', '$TEST_HOME')
        script = script.replace('~/', '${TEST_HOME}/')
        (checkout / 'setup.sh').write_text(script)
        for name in ('zypper/setup.sh', 'flatpak/setup.sh', 'wine/setup.sh',
                     'vim/setup-vim.sh', 'rust/setup-rust.sh', 'ocaml/setup.sh',
                     'aaau/setup.sh', 'video/setup.sh', 'certs/setup.sh',
                     'nginx/setup.sh', 'dnsmasq/setup.sh', 'shylock/sh/de-b64.sh',
                     'shylock/sh/de-gpg-b64.sh'):
            p = checkout / name
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text('#!/bin/sh\nexit 0\n')
            p.chmod(0o755)
        return checkout, home

    def test_setup_rerun_preserves_emacs_and_elevates_system_stages(self):
        checkout, home = self.setup_fixture()
        for _ in range(2):
            result = self.run_script(checkout / 'setup.sh', cwd=checkout)
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(sum(c[0] == 'git' for c in self.commands()), 1)
        self.assertEqual((home / '.emacs').read_text(), 'preserve legacy configuration')
        for stage in ('certs', 'nginx'):
            self.assertIn(['sudo', 'env', 'IN_CI=false', f'./{stage}/setup.sh'], self.commands())

    def test_setup_stops_when_native_tailscale_installation_is_broken(self):
        checkout, _ = self.setup_fixture()
        self.env['TAILSCALE_STATUS'] = '1'
        result = self.run_script(checkout / 'setup.sh', 'IN_CI', cwd=checkout)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any('./nginx/setup.sh' in c for c in self.commands()))

    def test_ci_passes_flag_to_privileged_nginx_and_skips_certs(self):
        checkout, home = self.setup_fixture()
        (home / '.config').mkdir()
        (home / '.config/emacs').symlink_to(home / 'missing-target')
        result = self.run_script(checkout / 'setup.sh', 'IN_CI', cwd=checkout)
        self.assertEqual(result.returncode, 0, result.stderr)
        commands = self.commands()
        self.assertFalse(any(c[0] == 'git' for c in commands))
        self.assertIn(['sudo', 'env', 'IN_CI=true', './nginx/setup.sh'], commands)
        self.assertIn(['tailscale', '--version'], commands)
        self.assertFalse(any('https://tailscale.com/install.sh' in c for c in commands))
        self.assertFalse(any('./certs/setup.sh' in c for c in commands))
        self.assertTrue((home / '.config/emacs').is_symlink())


if __name__ == '__main__':
    unittest.main()
