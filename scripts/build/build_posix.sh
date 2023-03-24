#!/bin/bash

set -e

G_BASE_PATH="$(cd -- "$(dirname "$0")/../.."; pwd)"
G_SCRIPT_NAME="$(basename $0)"

function buildPosix() {
    output="$G_BASE_PATH/build/$1/$2"
    rm -rf "$output" && mkdir -p "$output"
    GOOS="$1" GOARCH="$2" go build -o "$output/netcat-go" .
}

os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=amd64

if [[ $# -gt 0 ]]; then
    os="$1"
    shift
fi

if [[ $# -gt 0 ]]; then
    arch="$1"
    shift
fi

if [[ $# -gt 0 ]]; then
    echo "unsupported arguments: $*"
    echo "usage: $G_SCRIPT_NAME [os [arch]]" >&2
    exit 1
fi

buildPosix "$os" "$arch"