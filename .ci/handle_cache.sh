#!/bin/bash

set -e

if [ ! -d "${CACHE_DIR}/src" ]; then
	echo "first time run"
	mkdir -p "${CACHE_DIR}"
	cd "${CACHE_DIR}"
	echo "clone https://github.com/mxe/mxe ."
	git clone https://github.com/mxe/mxe .
fi

if [ ! -f "${CACHE_DIR}/shout" ]; then
	echo "first time run"
	cd "${CACHE_DIR}"
	echo "clone https://github.com/7890/shout shout_src"
	git clone https://github.com/7890/shout shout_src
	cd shout_src && make && sudo make install
	cd ..
	cp build/c/cshout shout
	rm -rf shout_src
	shout "test big"
fi

sudo cp shout /usr/local/bin

#========================================================================
initial_mxe_build()
{
	TARGET="$1"
	cd "${CACHE_DIR}"
	#starting dummy output: some targets take a long time, travis would stop after 10min without output
	 "${TRAVIS_BUILD_DIR}/.ci/dummy_output.sh" &

	INITIAL_PACKAGES="cc cmake waf libsndfile db libsamplerate portaudio libgnurx readline liblo"

	shout "===="
	echo "mxe HEAD is `git rev-parse HEAD`"
	echo "building target $TARGET"
	echo "building packages $INITIAL_PACKAGES"

	git checkout src/portaudio.mk

	#build a common set of packages for given target
	make MXE_TARGETS=$TARGET $INITIAL_PACKAGES

	killall -9 dummy_output.sh
}

#after targets are available
#========================================================================
portaudio_asio()
{
	TARGET="$1"

	ls -l "${CACHE_DIR}/usr/bin/$TARGET-gcc"

	if [ ! -f "${CACHE_DIR}/asio/asiosdk2.3.zip" ]; then
		echo "first time run"
		mkdir -p "${CACHE_DIR}/asio"
		cd "${CACHE_DIR}/asio"
		wget -q http://www.steinberg.net/sdk_downloads/asiosdk2.3.zip
	fi

	cd "${CACHE_DIR}"

	git checkout src/portaudio.mk
	cp "${TRAVIS_BUILD_DIR}/jack2/portaudio.mk.diff" .
	patch -p 1 < portaudio.mk.diff

	unzip -q "${CACHE_DIR}/asio/asiosdk2.3.zip"
	sudo mv ASIOSDK2.3 /usr/local/asiosdk2

	#https://github.com/spatialaudio/portaudio-binaries
#	for TARGET in i686-w64-mingw32.static x86_64-w64-mingw32.static
	cp "${CACHE_DIR}/asio/asiosdk2.3.zip" .
	make MXE_TARGETS=$TARGET portaudio
	./usr/bin/$TARGET-gcc -O2 -shared -o libportaudio-$TARGET.dll -Wl,--whole-archive -lportaudio -Wl,--no-whole-archive -lstdc++ -lwinmm -lole32 -lsetupapi
	./usr/bin/$TARGET-strip libportaudio-$TARGET.dll
#	chmod -x libportaudio-$TARGET.dll

	ls -l libportaudio*

	exit 0
}

#for linux
#========================================================================
download_and_build_nsis()
{
	cd "${CACHE_DIR}"
	rm -rf nsis
	mkdir nsis
	cd nsis
	INST_PREFIX="`pwd`"
	#sources
	wget -q "https://sourceforge.net/projects/nsis/files/NSIS 3/3.04/nsis-3.04-src.tar.bz2"
	#stubs
	wget -q "https://sourceforge.net/projects/nsis/files/NSIS 3/3.04/nsis-3.04.zip"
	#extract
	bunzip2 nsis-3.04-src.tar.bz2
	tar xf nsis-3.04-src.tar
	unzip -q nsis-3.04.zip
	cd nsis-3.04-src
	#build
	scons SKIPSTUBS=all SKIPPLUGINS=all SKIPUTILS=all SKIPMISC=all NSIS_CONFIG_CONST_DATA=no PREFIX="$INST_PREFIX" install-compiler -j10
	#post tasks
	cd "${INST_PREFIX}"
	mkdir -p "share/nsis"
	cp -r nsis-3.04/Stubs/ share/nsis/
	mv bin/makensis .
	#clean up
	rm -rf bin
	rm -rf nsis-3.04
	rm -rf nsis-3.04-src
	mkdir archive
	mv nsis-3.04-src.tar archive
	mv nsis-3.04.zip archive
	touch "archive/`date`"

	#binary to use
	echo "`pwd`/bin/makensis"

	cd "${CACHE_DIR}"
}

#force rebuild
#rm -rf "${CACHE_DIR}/nsis"

if [ ! -f "${CACHE_DIR}/nsis_ok" ]; then
	cd "${CACHE_DIR}"
	echo "first time run"
	rm -rf nsis
	download_and_build_nsis
	echo "nsis minimal test"
cat - > hello.nsi << _EOF_
Name "Hello World"
OutFile "helloworld.exe"
Section "Hello World"
MessageBox MB_OK "Hello World!"
SectionEnd
_EOF_
	nsis/makensis hello.nsi
	echo "ok" > nsis_ok
	ls -l helloworld.exe
	rm -f hello.nsi helloworld.exe
fi

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
#initial_mxe_build i686-w64-mingw32.shared
#initial_mxe_build i686-w64-mingw32.static
#initial_mxe_build x86_64-w64-mingw32.shared
#initial_mxe_build x86_64-w64-mingw32.static
#=============

#build portaudio with asio headers (one by one)
#portaudio_asio i686-w64-mingw32.static
#portaudio_asio x86_64-w64-mingw32.static

#EOF
