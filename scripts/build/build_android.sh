#!/bin/bash

set -e

G_BASE_PATH="$(cd -- "$(dirname "$0")/../.."; pwd)"
G_SCRIPT_NAME="$(basename "$0")"

function buildAndroid() {
    ######################## START CONFIGURATION ########################
    # Only choose one of these
    NDK=$NDK_R21
    #NDK=$NDK_R17

    # Only choose one of these, depending on your device...
    if [[ "$1" == "arm" ]]; then
        TARGET=armv7a-linux-androideabi
    elif [[ "$1" == "arm64" ]]; then
        TARGET=aarch64-linux-android
    elif [[ "$1" == "x86_64" ]]; then
        TARGET=x86_64-linux-android
    else
        echo "unsupported architecture $1" >&2
        exit 1
    fi
    #TARGET=i686-linux-android

    # Set this to your minSdkVersion.
    API=21

    ######################### END CONFIGURATION #########################

    if test -z "$NDK"; then
        echo "environment variable \$NDK is not set"
        exit 1
    fi

    TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)
    output="$G_BASE_PATH/build/android/$1"
    rm -rf "$output" && mkdir -p "$output"
    # Build
    CGO_ENABLED=1 \
      GOOS="android" \
      GOARCH="$1" \
      CC=$TOOLCHAIN/bin/$TARGET$API-clang \
      go build -o "$output/netcat-go" .
}

if [[ $# != 1 ]]; then
    echo "usage: $G_SCRIPT_NAME <arm|arm64>"
    exit 1
fi
buildAndroid "$@"