#!/bin/bash

set -e

if [[ "$1" == "--clean" ]]; then
  rm -f *.firmware-*
fi

project=~/Documents/Arduino/versioduo

devices="\
 axis\
 connect\
 cv\
 dmx\
 express\
 express-drum\
 express-mini\
 ../euro/fader \
 ../euro/fader-keys \
 glockenspiel-37\
 ../euro/key-8 \
 ../euro/key-9 \
 kontra-2\
 kontra-2-string\
 pad\
 pedal\
 pulse\
 range\
 schlag-7\
 schlag-7-stepper\
 serial\
 step\
 ../voltek-labs/attune\
 ../studiovogelkuerstner/pi-14537\
"

output=index.json

rm -rf build/
mkdir build/

comma=''
echo '{' > $output

for i in $devices; do
  name=$(basename $i)
  meta=$(grep V2DEVICE_METADATA $project/$i/$(basename $name).ino)
  # V2DEVICE_METADATA("com.versioduo.pad", 4, "versioduo:samd:pad")
  match='.*V2DEVICE_METADATA\("(.*)",[[:space:]]([0-9]*),[[:space:]]"(.*)"\).*'
  id=$(echo $meta | sed -E "s/$match/\1/")
  version=$(echo $meta | sed -E "s/$match/\2/")
  board=$(echo $meta | sed -E "s/$match/\3/")
  firmware=$id.firmware-$version.bin

  arduino-cli compile --fqbn $board --output-dir build $project/$i
  mv build/$name.ino.bin build/$firmware

  hash=$(shasum -a 1 build/$firmware | sed -E 's/ .*//')

  echo -ne $comma >> $output
  comma=",\n"

  echo '  "'$id'": {' >> $output
  echo '    "file": "'$firmware'",' >> $output
  echo '    "version": '$version',' >> $output
  echo '    "board": "'$board'",' >> $output
  echo '    "hash": "'$hash'"' >> $output
  echo -n '  }' >> $output

  rm -f $id.firmware-$version.uf2
  python ../uf2-samdx1/lib/uf2/utils/uf2conv.py -b 16384 -c -o build/$id.firmware-$version.uf2 build/$firmware
done

echo -e "\n}" >> $output

chmod 0444 build/*.bin
mv -f build/*.bin .
mv -f build/*.uf2 .
rm -rf build/
git add index.json *.bin *.uf2
