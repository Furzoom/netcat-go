#!/bin/bash

G_BUILD_TYPE=release
G_OS=linux
G_ARCH=amd64

function usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -b <release|debug>"
    echo "          build type, 'release' or 'debug', the default is 'debug'"
    echo "  -h      show this help"
    echo "  --arch <arch>"
    echo "          architecture, one of 'amd64'(default), 'arm64', 'arm'"
    echo "  --os <OS>"
    echo "          OS type, one of 'linux'(default), 'android'"
    echo ""
    echo "Examples:"
    echo "  $0 -b release"
    echo "  $0 -b release"
    echo "  $0 -b --os android --arch arm64"
    echo ""
}

function parseOption() {
    echo "$@"
    ARGS=$(getopt -o ":hb:" --long "os:,arch:" -n "$0" -- "$@")
    if test $? != 0; then
        echo "unexpected error..."
        exit 1
    fi

    eval set -- "${ARGS}"

    while true
    do
        case "$1" in
            -b)
                build_type="$(echo "$2" | tr '[:upper:]' '[:lower:]')"
                if test "$build_type" == "release" -o "$build_type" == "debug"; then
                    G_BUILD_TYPE="$build_type"
                else
                    echo "Invalid build type '$2'"
                    exit 1
                fi
                shift 2
                ;;
            -h)
              usage
              shift
              ;;
            --os)
                G_OS=$2;
                shift 2
                ;;
            --arch)
                G_ARCH=$2;
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Error: invalid option '$1'"
                exit 1
                ;;
        esac
    done

    if test $# -ne 0; then
        echo "Error: unrecognized parameter(s) '$*'"
        exit 1
    fi
}

function buildAndroid() {
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
    output="build/android/$G_ARCH"
    mkdir -p "$output"
    # Build
    CGO_ENABLED=1 \
      GOOS="$G_OS" \
      GOARCH="$G_ARCH" \
      CC=$TOOLCHAIN/bin/$TARGET$API-clang \
      go build -o "$output/netcat-go" .
}

function buildPosix() {
    output="build/$G_OS/$G_ARCH"
    rm -rf "$output" && mkdir -p "$output"
    GOOS="$G_OS" GOARCH="$G_ARCH" go build -o "$output/netcat-go ."
}

function build() {
    if [[ "$G_OS" = "android" ]]; then
        buildAndroid
    elif [[ "$G_OS" = "linux" || "$G_OS" = "darwin" ]]; then
        buildPosix
    else
        usage
        exit 1
    fi
}

function main() {
    parseOption "$@"
    build
}

main "$@"