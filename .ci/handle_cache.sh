#!/bin/bash

set -e

CACHE_DIR="${TRAVIS_BUILD_DIR}/../mxe"

if [ ! -d "${CACHE_DIR}/src" ]; then
	echo "first time run"
	mkdir -p "${CACHE_DIR}"
	cd "${CACHE_DIR}"
	echo "clone https://github.com/mxe/mxe ."
	git clone https://github.com/mxe/mxe .
fi

#========================================================================
initial_mxe_build()
{
	TARGET="$1"
	cd "${CACHE_DIR}"
	#starting dummy output: some targets take a long time, travis would stop after 10min without output
	 "${TRAVIS_BUILD_DIR}/.ci/dummy_output.sh" &

	INITIAL_PACKAGES="cc cmake waf libsndfile db libsamplerate portaudio libgnurx readline liblo"

	echo "mxe HEAD is `git rev-parse HEAD`"
	echo "building target $TARGET"
	echo "building packages $INITIAL_PACKAGES"

	#build a common set of packages for given target
	make MXE_TARGETS=$TARGET $INITIAL_PACKAGES

	killall -9 dummy_output.sh
}

#problem for large builds:
#after ~ 50 minutes, travis tells
#The job exceeded the maximum time limit for jobs, and has been terminated.
#solution: split up to single targets, build as single jobs.
#this is an incremental task. change initial_mxe_build target in this file for every initial build job until all targets are built.

#after ca. 25 minutes
#[done]        gcc                    i686-w64-mingw32.shared                                  2932204 KiB    18m12.496s
#after ca 30. minutes
#[done]        cmake                  x86_64-pc-linux-gnu                                      352176 KiB     7m0.679s
#all done after ca. 40 minutes

#===TARGETS=== (build one by one)
initial_mxe_build i686-w64-mingw32.shared
#initial_mxe_build i686-w64-mingw32.static
#initial_mxe_build x86_64-w64-mingw32.shared
#initial_mxe_build x86_64-w64-mingw32.static
#=============

#EOF
