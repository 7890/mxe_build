#!/bin/bash

set -e

JACK_REPO_CLONE_LINE="git clone https://github.com/7890/jack2 jack2"

#for variables and use_archive()
. "${TRAVIS_BUILD_DIR}/.ci/handle_cache.sh"

cd "${TRAVIS_BUILD_DIR}"
cd ..
rm -rf jack2
$JACK_REPO_CLONE_LINE
#cp "${TRAVIS_BUILD_DIR}/jack2/Makefile.mingw" jack2
cp "${TRAVIS_BUILD_DIR}/jack2/waf_build.sh" jack2
cd jack2
JACK_REPO_HEAD=`git rev-parse HEAD`
JACK_VERSION=`cat wscript|grep "^VERSION='"|cut -d"'" -f2`

echo "JACK_REPO_HEAD: $JACK_REPO_HEAD"
echo "JACK_VERSION: $JACK_VERSION"

CMD_PREFIX="${CACHE_DIR}/usr/bin/x86_64-w64-mingw32.shared"

PKGCONFIG=${CMD_PREFIX}-pkg-config CC=${CMD_PREFIX}-gcc CXX=${CMD_PREFIX}-g++ ./waf configure \
        --platform=win32 --prefix=install
PKGCONFIG=${CMD_PREFIX}-pkg-config CC=${CMD_PREFIX}-gcc CXX=${CMD_PREFIX}-g++ ./waf build -v -j10 $(DEBUG)
PKGCONFIG=${CMD_PREFIX}-pkg-config CC=${CMD_PREFIX}-gcc CXX=${CMD_PREFIX}-g++ ./waf install

cd man
mkdir pdf
#to resolve links like jack_disconnect.1:.so man1/jack_connect.1
ln -s . man1
sh fill_template $JACK_VERSION
#ls -l
ls -1 *.1|while read line; do fn=${line%.*}; groff -t -e -mandoc -t ./"$line"|ps2pdf - pdf/"$fn".pdf; done
cd ..

TARGET="x86_64-w64-mingw32.shared"
cp ${CACHE_DIR}/usr/${TARGET}/bin/libgcc_s_seh-1.dll install/
cp ${CACHE_DIR}/usr/${TARGET}/bin/libstdc++-6.dll install/
cp ${CACHE_DIR}/usr/${TARGET}/bin/libgnurx-0.dll install/
cp ${CACHE_DIR}/usr/${TARGET}/bin/libsamplerate-0.dll install/
cp ${CACHE_DIR}/usr/${TARGET}/bin/libwinpthread-1.dll install/
#cp ${CACHE_DIR}/usr/${TARGET}/bin/libportaudio-2.dll install/
cp ${CACHE_DIR}/libportaudio-x86_64-w64-mingw32.static.dll install/libportaudio-2.dll

mv man/pdf install
ls -l install
cd install
(
date
echo "TRAVIS JOB: ${TRAVIS_JOB_NUMBER}"
echo "TRAVIS_JOB_WEB_URL: ${TRAVIS_JOB_WEB_URL}"
echo "JACK_REPO_CLONE_LINE: ${JACK_REPO_CLONE_LINE}"
echo "JACK_REPO_HEAD: ${JACK_REPO_HEAD}"
echo ""
find . | grep -e "\.exe$" -e "\.dll$" | while read line; do md5sum "$line"; sha256sum "$line"; exiftool "$line"; echo ""; done
) | unix2dos > files.txt
cat files.txt
cd ..

OUTNAME="jack2_win64_TEST_`date +%s`"
mv install "$OUTNAME"
#tar cfvz "${OUTNAME}.tgz" "$OUTNAME"

rm -rf  "${TRAVIS_BUILD_DIR}/../pages_out"
mkdir   "${TRAVIS_BUILD_DIR}/../pages_out"
tar cfz "${TRAVIS_BUILD_DIR}/../pages_out/${OUTNAME}.tgz" "${OUTNAME}"
ls -l   "${TRAVIS_BUILD_DIR}/../pages_out"

#EOF
