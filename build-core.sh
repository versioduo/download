#!/bin/bash

set -o errexit
set -o errtrace; trap 'echo "Error ${?} ${BASH_SOURCE[0]:-?}:${LINENO:-?}"' ERR
set -o nounset
set -o pipefail

set -e

vendor=versioduo
architecture=samd

if [[ ${1:-} == "--clean" ]]; then
  rm -f ${vendor}-${architecture}-*
fi

rm -rf arduino-board-package
git clone --depth=1 git@github.com:${vendor}/arduino-board-package
(cd arduino-board-package && git submodule update --init --recursive --filter=blob:none)

# Revert SERCOM
sed -i '' -E 's/sercom->I2CM.STATUS.bit.BUSERR/sercom->I2CM.INTFLAG.bit.ERROR/' arduino-board-package/ArduinoCore-samd/cores/arduino/SERCOM.cpp
grep -q 'sercom->I2CM.INTFLAG.bit.ERROR' arduino-board-package/ArduinoCore-samd/cores/arduino/SERCOM.cpp

# Increase the number of USB descriptor strings.
sed -i '' -E 's/STRING_DESCRIPTOR_MAX = 12/STRING_DESCRIPTOR_MAX = 24/' arduino-board-package/ArduinoCore-samd/libraries/Adafruit_TinyUSB_Arduino/src/arduino/Adafruit_USBD_Device.h
grep -q 'STRING_DESCRIPTOR_MAX = 24' arduino-board-package/ArduinoCore-samd/libraries/Adafruit_TinyUSB_Arduino/src/arduino/Adafruit_USBD_Device.h

# Suppress alignment warning.
sed -i '' -E 's/\(uint32_t \*\)serial_id;/\(uint32_t \*\)__builtin_assume_aligned\(serial_id, 4\);/' arduino-board-package/libraries/Adafruit_TinyUSB_Arduino/src/arduino/ports/samd/Adafruit_TinyUSB_samd.cpp
grep -qE '__builtin_assume_aligned\(serial_id, 4\);' arduino-board-package/libraries/Adafruit_TinyUSB_Arduino/src/arduino/ports/samd/Adafruit_TinyUSB_samd.cpp

# Disable host mode (requires SPI)
sed -i '' -E 's:#define CFG_TUH_ENABLED 1://#define CFG_TUH_ENABLED 1:' arduino-board-package/libraries/Adafruit_TinyUSB_Arduino/src/arduino/ports/samd/tusb_config_samd.h
grep -qE '//#define CFG_TUH_ENABLED 1' arduino-board-package/libraries/Adafruit_TinyUSB_Arduino/src/arduino/ports/samd/tusb_config_samd.h
sed -i '' -E 's:#define CFG_TUH_MAX3421 1://#define CFG_TUH_MAX3421 1:' arduino-board-package/libraries/Adafruit_TinyUSB_Arduino/src/arduino/ports/samd/tusb_config_samd.h
grep -qE '//#define CFG_TUH_MAX3421 1' arduino-board-package/libraries/Adafruit_TinyUSB_Arduino/src/arduino/ports/samd/tusb_config_samd.h

# Get rif of double promotion
sed -i '' -E 's/fraction \*= 0\.1;/fraction \*= 0\.1f;/' arduino-board-package/cores/arduino/Stream.cpp
grep -qE 'fraction \*= 0\.1f;' arduino-board-package/cores/arduino/Stream.cpp

rm -rf samd/
mkdir samd/

# Our board definitions
cp -a  arduino-board-package/{variants,boards.txt,platform.txt} samd/

# The SAMD core from Adafruit
cp -a  arduino-board-package/ArduinoCore-samd/cores samd/
rm -f  samd/cores/arduino/math_helper.*

# Copy only the needed libraries
cp -aL  arduino-board-package/libraries/ samd/libraries/

# Delete git metadata
rm -rf samd/libraries/*/.git*

version=$(grep 'version=' arduino-board-package/platform.txt | sed -E 's/.*version=([0-9]*).*/\1/')

# Create reproducible tar, use the timestamp of the last commit from the board package repository.
date=$(git log -1 --format=%cd arduino-board-package)
#tar --numeric-owner --owner=0 --group=0 --sort=name --clamp-mtime --mtime="$date" -cjf ${vendor}-${architecture}-${version}.tar.bz2 samd/
tar --numeric-owner -cjf ${vendor}-${architecture}-${version}.tar.bz2 samd/

hash=$(shasum -a 256 ${vendor}-${architecture}-${version}.tar.bz2 | sed -E 's/ .*//')
size=$(stat -f %z ${vendor}-${architecture}-${version}.tar.bz2)

cp package_${vendor}_index.json.in package_${vendor}_index.json
sed -i '' -E "s/@@VERSION@@/${version}/" package_${vendor}_index.json
sed -i '' -E "s/@@HASH@@/${hash}/" package_${vendor}_index.json
sed -i '' -E "s/@@SIZE@@/${size}/" package_${vendor}_index.json

rm -rf arduino-board-package
rm -rf samd/
git add ${vendor}-${architecture}-${version}.tar.bz2
