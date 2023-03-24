#!/bin/bash

set -e

G_BASE_PATH=
G_BUILD_TYPE=release
G_OS=linux
G_ARCH=amd64

function init() {
    G_BASE_PATH="$(cd -- "$(dirname "$0")"; pwd)"
    host_os=$(uname -s | tr '[:upper:]' '[:lower:]')
    if [[ $host_os = "darwin" ]]; then
        echo "usage: "
        echo "  $G_BASE_PATH/scripts/build/build_android.sh"
        echo "  $G_BASE_PATH/scripts/build/build_posix.sh"
        exit 1
    fi
}

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
    set +e
    ARGS=$(getopt -o ":hb:" --long "os:,arch:" -n "$0" -- "$@")
    set -e
    if [[ $? -ne 0 ]]; then
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
                exit 0
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

function build() {
    if [[ "$G_OS" = "android" ]]; then
        "$G_BASE_PATH/scripts/build/build_android.sh" "$G_ARCH"
    elif [[ "$G_OS" = "linux" || "$G_OS" = "darwin" ]]; then
        "$G_BASE_PATH/scripts/build/build_posix.sh" "$G_OS" "$G_ARCH"
    else
        usage
        exit 1
    fi
    echo "built $G_OS/$G_ARCH done"
}

function main() {
    init "$@"
    parseOption "$@"
    build
}

main "$@"