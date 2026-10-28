#!/usr/bin/env python3
"""Run outside the Nix build sandbox: nix shell nixpkgs#{python3,openssh}.

Uses ephemeral keys and a loopback-only sshd running as the current user. Never
changes the user's SSH configuration or accesses an existing Org directory.
"""
import getpass
import os
from pathlib import Path
import shutil
import socket
import subprocess
import tempfile
import time


def run(*args, **kwargs):
    return subprocess.run(args, check=True, text=True, **kwargs)


def main():
    repo = Path(__file__).resolve().parent.parent
    package = run("nix", "build", str(repo) + "#default", "--no-link", "--print-out-paths",
                  capture_output=True).stdout.strip()
    init = run("nix", "build", str(repo) + "#test-init", "--no-link", "--print-out-paths",
               capture_output=True).stdout.strip()
    with tempfile.TemporaryDirectory(prefix="emacs-ssh-test-") as directory:
        root = Path(directory)
        for key in ("host", "client"):
            run("ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", str(root / key))
        with socket.socket() as sock:
            sock.bind(("127.0.0.1", 0))
            port = sock.getsockname()[1]
        (root / "sshd_config").write_text(f"""
ListenAddress 127.0.0.1
Port {port}
HostKey {root}/host
PidFile {root}/pid
AuthorizedKeysFile {root}/client.pub
StrictModes no
PasswordAuthentication no
KbdInteractiveAuthentication no
UsePAM no
AllowUsers {getpass.getuser()}
SetEnv EMACS_BASE_FIXTURE=remote
LogLevel ERROR
""")
        (root / "ssh_config").write_text(f"""
Host fixture
  HostName 127.0.0.1
  Port {port}
  User {getpass.getuser()}
  IdentityFile {root}/client
  IdentitiesOnly yes
  StrictHostKeyChecking no
  UserKnownHostsFile {root}/known_hosts
  BatchMode yes
  LogLevel ERROR
""")
        sshd = subprocess.Popen([shutil.which("sshd"), "-D", "-e", "-f", str(root / "sshd_config")],
                                stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        try:
            for _ in range(50):
                if sshd.poll() is not None:
                    raise RuntimeError(sshd.stderr.read().decode())
                try:
                    with socket.create_connection(("127.0.0.1", port), timeout=0.2):
                        break
                except OSError:
                    time.sleep(0.1)
            home = root / "home"
            home.mkdir()
            env = dict(os.environ, HOME=str(home), FIXTURE_ROOT=str(root), FIXTURE_INIT=init)
            run(package + "/bin/emacs", "--batch", "-l", str(repo / "tests/tramp-tests.el"),
                "-f", "ert-run-tests-batch-and-exit", env=env, timeout=120)
        finally:
            sshd.terminate()
            try:
                sshd.communicate(timeout=5)
            except subprocess.TimeoutExpired:
                sshd.kill()
                sshd.communicate()


if __name__ == "__main__":
    main()
