#!/bin/bash

set -e

FDB_REPO_NAME="fastdb"
FDB_REPO_CLONE_LINE="git clone https://github.com/7890/${FDB_REPO_NAME} ${FDB_REPO_NAME}"

cd "${TRAVIS_BUILD_DIR}"
cd ..
rm -rf ${FDB_REPO_NAME}
$FDB_REPO_CLONE_LINE
cp "${TRAVIS_BUILD_DIR}/${FDB_REPO_NAME}/Makefile.mingw" ${FDB_REPO_NAME}
cd ${FDB_REPO_NAME}
FDB_REPO_HEAD=`git rev-parse HEAD`
FDB_VERSION=3.76

echo "FDB_REPO_HEAD: $FDB_REPO_HEAD"
echo "FDB_VERSION: $FDB_VERSION"

PATH_SAVE="$PATH"
export PATH="${CACHE_DIR}/usr/bin:$PATH"
make -f Makefile.mingw
export PATH="$PATH_SAVE"

rm -rf install
mkdir install
cp *.exe install
ls -l install
cd install
(
date
echo "TRAVIS JOB: ${TRAVIS_JOB_NUMBER}"
echo "TRAVIS_JOB_WEB_URL: ${TRAVIS_JOB_WEB_URL}"
echo "FDB_REPO_CLONE_LINE: ${FDB_REPO_CLONE_LINE}"
echo "FDB_REPO_HEAD: ${FDB_REPO_HEAD}"
echo ""
ls -1 *.exe|while read line; do md5sum "$line"; sha256sum "$line"; exiftool "$line"; echo ""; done
) | unix2dos > files.txt
cat files.txt

mkdir -p "${PAGES_OUT}"
cd "${TRAVIS_BUILD_DIR}"
cd ..
tar cfz "${PAGES_OUT}/${FDB_REPO_NAME}_build_`date +%s`.tgz" "${FDB_REPO_NAME}/install"
ls -l "${PAGES_OUT}"

#EOF
