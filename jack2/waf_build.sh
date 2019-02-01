#!/bin/bash

MXEPATH="/home/travis/build/7890/mxe"

BC_ARCH="x86_64-w64-mingw32.shared"

CMD_PREFIX="${MXEPATH}/usr/bin/${BC_ARCH}"

rm -rf build
rm -rf install

PKGCONFIG=${CMD_PREFIX}-pkg-config CC=${CMD_PREFIX}-gcc CXX=${CMD_PREFIX}-g++ ./waf configure \
        --platform=win32 --prefix=install ${DEBUG}

PKGCONFIG=${CMD_PREFIX}-pkg-config CC=${CMD_PREFIX}-gcc CXX=${CMD_PREFIX}-g++ ./waf build -v -j10 $(DEBUG)

PKGCONFIG=${CMD_PREFIX}-pkg-config CC=${CMD_PREFIX}-gcc CXX=${CMD_PREFIX}-g++ ./waf install
