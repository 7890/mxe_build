#!/bin/bash

set -e

JACK_REPO_CLONE_LINE="git clone https://github.com/7890/jack2 jack2"

#for variables and use_archive()
. "${TRAVIS_BUILD_DIR}/.ci/handle_cache.sh"

cd "${TRAVIS_BUILD_DIR}"
cd ..
rm -rf jack2
$JACK_REPO_CLONE_LINE
cp "${TRAVIS_BUILD_DIR}/jack2/Makefile.mingw" jack2
cd jack2
JACK_REPO_HEAD=`git rev-parse HEAD`
JACK_VERSION=`cat wscript|grep "^VERSION='"|cut -d"'" -f2`

echo "JACK_REPO_HEAD: $JACK_REPO_HEAD"
echo "JACK_VERSION: $JACK_VERSION"

cd man
mkdir pdf
#to resolve links like jack_disconnect.1:.so man1/jack_connect.1
ln -s . man1
sh fill_template $JACK_VERSION
#ls -l
ls -1 *.1|while read line; do fn=${line%.*}; groff -t -e -mandoc -t ./"$line"|ps2pdf - pdf/"$fn".pdf; done
cd ..

PATH_SAVE="$PATH"
export PATH="${TRAVIS_BUILD_DIR}/../mxe/usr/bin:$PATH"
make -f Makefile.mingw
export PATH="$PATH_SAVE"
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
md5sum jackd.exe
sha256sum jackd.exe
exiftool jackd.exe
ls -1 *.dll|while read line; do md5sum "$line"; sha256sum "$line"; exiftool "$line"; echo ""; done
ls -1 jack/*.dll|while read line; do md5sum "$line"; sha256sum "$line"; exiftool "$line"; echo ""; done
ls -1 win32libs/*.dll|while read line; do md5sum "$line"; sha256sum "$line"; exiftool "$line"; echo ""; done
) | unix2dos > files.txt
cat files.txt

cd "${TRAVIS_BUILD_DIR}"
cd ..
rm -rf pages_out
mkdir pages_out
tar cfz pages_out/jack2_build_`date +%s`.tgz jack2/install
ls -l pages_out

#EOF
