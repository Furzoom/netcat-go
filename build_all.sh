#!/bin/bash

set -e
base_path="$(cd -- "$(dirname "$0")"; pwd)"

echo "building linux/amd64..."
"$base_path/scripts/build/build_posix.sh" linux amd64
echo "built linux/amd64"

echo "building darwin/amd64..."
"$base_path/scripts/build/build_posix.sh" darwin amd64
echo "built darwin/amd64"

echo "building android/arm..."
"$base_path/scripts/build/build_android.sh" arm
echo "built android/arm"

echo "building android/arm64..."
"$base_path/scripts/build/build_android.sh" arm64
echo "built android/arm64"
