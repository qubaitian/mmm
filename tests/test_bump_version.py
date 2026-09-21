import unittest
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from bump_version import bump_project_text


class BumpVersionTests(unittest.TestCase):
    def test_three_part_version_bumps_the_last_number(self):
        text, version, code = bump_project_text("[project]\nversion = 1.0.0\n\n[android]\npackage = com.mmm.app\n")
        self.assertEqual(version, "1.0.1")
        self.assertEqual(code, 10001)
        self.assertIn("version = 1.0.1", text)
        self.assertIn("version_code = 10001", text)

    def test_two_part_version_becomes_three_parts(self):
        text, version, code = bump_project_text("[project]\nversion = 1.0\n\n[android]\n")
        self.assertEqual(version, "1.0.1")
        self.assertEqual(code, 10001)
        self.assertIn("version = 1.0.1", text)

    def test_patch_roll_increases_minor(self):
        _, version, code = bump_project_text("[project]\nversion = 1.0.99\n\n[android]\n")
        self.assertEqual(version, "1.1.0")
        self.assertEqual(code, 10100)

    def test_existing_version_code_is_replaced(self):
        text, _, code = bump_project_text("[project]\nversion = 1.2.3\n\n[android]\nversion_code = 9\n")
        self.assertEqual(code, 10204)
        self.assertEqual(text.count("version_code ="), 1)
        self.assertIn("version_code = 10204", text)
        self.assertIn("version = 1.2.4", text)


if __name__ == "__main__":
    unittest.main()
