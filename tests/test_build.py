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
        self.assertIn("web|desktop", result.stderr)
        self.assertFalse(self.log.exists())


if __name__ == "__main__":
    unittest.main()
