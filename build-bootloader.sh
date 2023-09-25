#!/bin/bash

set -e

VERSION=6

rm -rf ../uf2-samdx1/build/ ../uf2-samdx1/build.tmp/

(cd ../uf2-samdx1 && for i in boards/com.versioduo.*; do
  board=$(basename $i)
  make NAME=$board.bootloader-$VERSION UF2_VERSION_BASE=$VERSION-$(git describe --always --tags) BOARD=$board
done)

rm -f ../uf2-samdx1/build/*/update-*.bin
mv -f ../uf2-samdx1/build/*/update-*.uf2 .
mv -f ../uf2-samdx1/build/*/*.bin .
rm -rf ../uf2-samdx1/build/

rename update- '' *.uf2
chmod 0444 *.bin *.uf2
