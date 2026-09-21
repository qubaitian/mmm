import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class BuildTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.app = self.directory / "Defold Test.app"
        packages = self.app / "Contents/Resources/packages"
        java = packages / "jdk-test/bin/java"
        java.parent.mkdir(parents=True)
        java.write_text('''#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
Path(os.environ["BUILD_TEST_LOG"]).write_text(json.dumps(sys.argv[1:]))
sys.exit(int(os.environ.get("BUILD_TEST_EXIT", "0")))
''')
        java.chmod(0o755)
        (packages / "defold-test.jar").touch()
        self.log = self.directory / "args.json"
        self.env = {**os.environ, "DEFOLD_APP": str(self.app), "BUILD_TEST_LOG": str(self.log)}

    def run_build(self, *args):
        return subprocess.run(["bash", str(ROOT / "build.sh"), *args], cwd=self.directory,
                              env=self.env, capture_output=True, text=True)

    def test_build_finds_tools_and_dependencies_from_another_directory(self):
        result = self.run_build("web")
        self.assertEqual(result.returncode, 0, result.stderr)
        args = json.loads(self.log.read_text())
        self.assertEqual(args[-3:], ["resolve", "build", "bundle"])
        self.assertEqual(args[args.index("--root") + 1], str(ROOT / "defold"))
        self.assertEqual(args[args.index("--platform") + 1], "wasm-web")
        self.assertEqual(args[args.index("-cp") + 1], str(self.app / "Contents/Resources/packages/defold-test.jar"))

    def test_build_failure_reaches_the_caller(self):
        self.env["BUILD_TEST_EXIT"] = "9"
        result = self.run_build("web")
        self.assertEqual(result.returncode, 9, result.stderr)

    def test_desktop_build_uses_native_tools(self):
        result = self.run_build("desktop")
        self.assertEqual(result.returncode, 0, result.stderr)
        args = json.loads(self.log.read_text())
        self.assertIn(args[args.index("--platform") + 1], ["arm64-macos", "x86_64-macos"])
        self.assertEqual(args[-3:], ["resolve", "build", "bundle"])
        self.assertEqual(args[args.index("--bundle-output") + 1], str(ROOT / "dist/desktop"))

    def test_unknown_target_does_not_start_a_build(self):
        result = self.run_build("unknown")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("web|desktop|android", result.stderr)
        self.assertFalse(self.log.exists())

    def test_android_build_makes_an_apk(self):
        self.env["SKIP_VERSION_BUMP"] = "1"
        android_dir = ROOT / "dist/android"
        android_dir.mkdir(parents=True, exist_ok=True)
        dummy = android_dir / "mmm.apk"
        web_dir = ROOT / "dist/web/mmm"
        web_apk = web_dir / "mmm.apk"
        versioned = web_dir / "mmm-1.0.0.apk"
        previous = dummy.read_bytes() if dummy.exists() else None
        web_previous = web_apk.read_bytes() if web_apk.exists() else None
        versioned_previous = versioned.read_bytes() if versioned.exists() else None
        dummy.write_bytes(b"placeholder")
        def restore():
            if previous is None:
                dummy.unlink(missing_ok=True)
            else:
                dummy.write_bytes(previous)
            if web_previous is None:
                web_apk.unlink(missing_ok=True)
            else:
                web_apk.parent.mkdir(parents=True, exist_ok=True)
                web_apk.write_bytes(web_previous)
            if versioned_previous is None:
                versioned.unlink(missing_ok=True)
            else:
                versioned.write_bytes(versioned_previous)
        self.addCleanup(restore)
        result = self.run_build("android")
        self.assertEqual(result.returncode, 0, result.stderr)
        args = json.loads(self.log.read_text())
        self.assertEqual(args[args.index("--platform") + 1], "armv7-android")
        self.assertEqual(args[args.index("--architectures") + 1], "armv7-android,arm64-android")
        self.assertEqual(args[args.index("--bundle-format") + 1], "apk")
        self.assertEqual(args[args.index("--bundle-output") + 1], str(ROOT / "dist/android"))
        self.assertEqual(args[-3:], ["resolve", "build", "bundle"])
        self.assertEqual(web_apk.read_bytes(), b"placeholder")
        self.assertEqual(versioned.read_bytes(), b"placeholder")


if __name__ == "__main__":
    unittest.main()
