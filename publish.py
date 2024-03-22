#!/usr/bin/env python3

import os
import sys


support_pkg_name = [
    "image_editor",
    "image_editor_common",
    "image_editor_ohos",
    "image_editor_platform_interface",
]


if len(sys.argv) < 2:
    print("Usage: python3 publish.py <tag_name>")
    print('  The tag name is <package_name>-v{version}, e.g. image_editor-v0.0.1')
    print("  The available package names are: ", ", ".join(support_pkg_name))
    sys.exit(1)

# refs/tags/image_editor-v1.4.0
target_tag = sys.argv[1]

print('Current github.ref is: ', target_tag)

target_pkg_name = target_tag.split("/")[-1].split("-v")[0]

print("Publishing package: ", target_pkg_name)
current_dir = os.path.abspath(os.path.dirname(__file__))

if target_pkg_name not in support_pkg_name:
    print("The package is not supported.")
    print("The available package names are: ", ", ".join(support_pkg_name))
    sys.exit(1)

os.chdir(os.path.join(current_dir, target_pkg_name))

os.system("flutter pub get")
os.system("flutter pub publish -f")
