#!/bin/bash

######################## START CONFIGURATION ########################
# Only choose one of these
NDK=$NDK_R21
#NDK=$NDK_R17

# Only choose one of these, depending on your device...
#TARGET=aarch64-linux-android
TARGET=armv7a-linux-androideabi
#TARGET=i686-linux-android
#TARGET=x86_64-linux-android

# Set this to your minSdkVersion.
API=21

######################### END CONFIGURATION #########################

if test -z "$NDK"; then
    echo "environment variable \$NDK is not set"
    exit 1
fi

TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)
mkdir -p build
# Build
CGO_ENABLED=1 \
  GOOS=android \
  GOARCH=arm \
  CC=$TOOLCHAIN/bin/$TARGET$API-clang \
  go build -o build/netcat-go .