#!/usr/bin/env bash

set -euo pipefail

##try minimal if buildchain available
if [ "$TRAVIS_OS_NAME" == "linux" ]; then
  sudo apt-get install -y \
  dos2unix \
  libimage-exiftool-perl \
  ghostscript \
  imagemagick \
  bc
fi
exit #

#according to mxe.cc these packages need to be installed
#the travis build image already has some of them installed
if [ "$TRAVIS_OS_NAME" == "linux" ]; then
  sudo apt-get install -y \
  autoconf \
  automake \
  autopoint \
  bash \
  bison \
  bzip2 \
  flex \
  g++ \
  g++-multilib \
  gettext \
  git \
  gperf \
  intltool \
  libc6-dev-i386 \
  libgdk-pixbuf2.0-dev \
  libltdl-dev \
  libssl-dev \
  libtool \
  libxml-parser-perl \
  lzip \
  make \
  openssl \
  p7zip-full \
  patch \
  perl \
  pkg-config \
  python \
  ruby \
  sed \
  unzip \
  wget \
  xz-utils \
  scons
fi

exit 0
