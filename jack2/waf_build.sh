#!/bin/bash

set -e

#for variables and use_archive()
. "${TRAVIS_BUILD_DIR}/.ci/handle_cache.sh"

CMD_PREFIX="${CACHE_DIR}/usr/bin/x86_64-w64-mingw32.shared"

rm -rf build
rm -rf install

PKGCONFIG=${CMD_PREFIX}-pkg-config CC=${CMD_PREFIX}-gcc CXX=${CMD_PREFIX}-g++ ./waf configure \
        --platform=win32 --prefix=install

PKGCONFIG=${CMD_PREFIX}-pkg-config CC=${CMD_PREFIX}-gcc CXX=${CMD_PREFIX}-g++ ./waf build -v -j10 $(DEBUG)

PKGCONFIG=${CMD_PREFIX}-pkg-config CC=${CMD_PREFIX}-gcc CXX=${CMD_PREFIX}-g++ ./waf install

#EOF
