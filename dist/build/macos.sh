#!/bin/sh

make_pkg() {
    ARCH=$1
    VERSION=$2
    TARGET_DIR="$3"
    if [ -z "$TARGET_DIR" ]; then
        TARGET_DIR=target/release/
    fi
    ROOT_DIR=$(pwd)
    cd $TARGET_DIR
    PKG="tuifeed-v${VERSION}-${ARCH}-apple-darwin.tar.gz"
    tar czf $PKG tuifeed
    HASH=$(sha256sum $PKG)
    mkdir -p ${ROOT_DIR}/dist/pkgs/macos/
    mv $PKG ${ROOT_DIR}/dist/pkgs/macos/$PKG
    cd -
    echo "$HASH"
}

if [ -z "$1" ]; then
    echo "Usage: macos.sh <version>"
    exit 1
fi

VERSION=$1
export BUILD_ROOT=$(pwd)/../../

set -e # Don't fail

# Go to root dir
cd ../../
# Check if in correct directory
if [ ! -f Cargo.toml ]; then
    echo "Please start macos.sh from dist/build/ directory"
    exit 1
fi

# Build release (x86_64)
cargo build --release
# Make pkg
X86_64_HASH=$(make_pkg "x86_64" $VERSION)

cd $BUILD_ROOT
# Build ARM64 pkg
cargo build --release --target aarch64-apple-darwin
# Make pkg
ARM64_HASH=$(make_pkg "arm64" $VERSION "target/aarch64-apple-darwin/release/")

echo "x86_64 hash: $X86_64_HASH"
echo "arm64  hash: $ARM64_HASH"

exit $?
