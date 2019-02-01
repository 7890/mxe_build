#!/bin/bash

set -e

CMD_PREFIX="${CACHE_DIR}/usr/bin/x86_64-w64-mingw32.shared"

ls -1 $CMD_PREFIX

rm -rf build
rm -rf install

PKGCONFIG=${CMD_PREFIX}-pkg-config CC=${CMD_PREFIX}-gcc CXX=${CMD_PREFIX}-g++ ./waf configure \
        --platform=win32 --prefix=install

PKGCONFIG=${CMD_PREFIX}-pkg-config CC=${CMD_PREFIX}-gcc CXX=${CMD_PREFIX}-g++ ./waf build -v -j10 $(DEBUG)

PKGCONFIG=${CMD_PREFIX}-pkg-config CC=${CMD_PREFIX}-gcc CXX=${CMD_PREFIX}-g++ ./waf install

#EOF
