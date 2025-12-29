#!/bin/bash

set -e

project=~/github

rm -rf build/
mkdir build/

function build {
  local device=$1

  name=$(basename $device)
  meta=$(grep V2DEVICE_METADATA $project/$device/$name.ino)
  # V2DEVICE_METADATA("com.versioduo.pad", 4, "versioduo:samd:pad")
  match='.*V2DEVICE_METADATA\("(.*)",[[:space:]]([0-9]*),[[:space:]]"(.*)"\).*'
  id=$(echo $meta | sed -E "s/$match/\1/")
  version=$(echo $meta | sed -E "s/$match/\2/")
  board=$(echo $meta | sed -E "s/$match/\3/")
  firmware=$id.firmware-$version.bin

  echo -e "\033[1;36mBuilding ${device} v${version}\033[0m"

  arduino-cli compile --fqbn $board --output-dir build $project/$device
  mv build/$name.ino.bin build/$firmware

  rm -f $id.firmware-$version.uf2
  python3 ../uf2-samdx1/lib/uf2/utils/uf2conv.py -b 16384 -c -o build/$id.firmware-$version.uf2 build/$firmware >/dev/null

  echo
}

if [[ -n "$1" && -d "$project/$1" ]]; then
  build $1

else
  while read device; do
    [[ "$device" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$device" ]] && continue

    build $device
  done < devices.txt
fi

if [[ "$1" == "--clean" ]]; then
  rm -f *.firmware-*
fi

chmod 0444 build/*.bin
mv -f build/*.bin .
mv -f build/*.uf2 .
rm -rf build/
git add *.firmware-*

./build-index.sh
