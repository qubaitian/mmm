import argparse
import re
from pathlib import Path


def parse_version(text):
    match = re.search(r"(?m)^version\s*=\s*(\d+)\.(\d+)\.(\d+)\s*$", text)
    if match:
        return int(match.group(1)), int(match.group(2)), int(match.group(3))
    match = re.search(r"(?m)^version\s*=\s*(\d+)\.(\d+)\s*$", text)
    if match:
        return int(match.group(1)), int(match.group(2)), 0
    raise ValueError("game.project needs a version like 1.0.0")


def next_version(major, minor, patch):
    patch += 1
    if patch >= 100:
        patch = 0
        minor += 1
    if minor >= 100:
        minor = 0
        major += 1
    return major, minor, patch


def version_code(major, minor, patch):
    return major * 10000 + minor * 100 + patch


def bump_project_text(text):
    major, minor, patch = next_version(*parse_version(text))
    version = f"{major}.{minor}.{patch}"
    code = version_code(major, minor, patch)
    text = re.sub(r"(?m)^version\s*=\s*.*$", f"version = {version}", text, count=1)
    if re.search(r"(?m)^version_code\s*=", text):
        text = re.sub(r"(?m)^version_code\s*=\s*.*$", f"version_code = {code}", text, count=1)
    else:
        text = re.sub(r"(\[android\]\n)", f"\\1version_code = {code}\n", text, count=1)
    return text, version, code


def bump_project_file(path):
    project = Path(path)
    text, version, code = bump_project_text(project.read_text())
    project.write_text(text)
    return version, code


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("project")
    args = parser.parse_args()
    version, _ = bump_project_file(args.project)
    print(version)


if __name__ == "__main__":
    main()
