#!/bin/zsh

set -e

# Get the list of devices.
typeset -A devices
for i in *.firmware-*.bin; do
  local meta=$(strings $i | grep '"com.versioduo.firmware"')
  local id=$(echo $meta | sed -E 's/.*"id":"([^"]+).*/\1/')
  devices[$id]=""
done

echo '{' > index.json

# Write the device array.
local comma=''
for device in "${(@k)devices}"; do
  echo -ne $comma >> index.json
  comma=",\n"
  echo '  "'$device'": [' >> index.json

  # Write the firmware versions for this device.
  local comma2=''
  for i in $device.firmware-*.bin; do
    echo -ne $comma2 >> index.json
    comma2=",\n"
    meta=$(strings "$i" | grep '"com.versioduo.firmware"')
    id=$(echo $meta | sed -E 's/.*"id":"([^"]+).*/\1/')
    version=$(echo $meta | sed -E 's/.*"version":([^,]+).*/\1/')
    release=$(grep -s "$id" releases.txt | sed -E 's/.* //')
    board=$(echo $meta | sed -E 's/.*"board":"([^"]+).*/\1/')
    hash=$(shasum -a 1 $i | sed -E 's/ .*//')
    echo '    {' >> index.json
    echo '      "file": "'$i'",' >> index.json
    echo '      "version": '$version',' >> index.json
    [[ "$version" == "$release" ]] && echo '      "release": true,' >> index.json
    echo '      "board": "'$board'",' >> index.json
    echo '      "hash": "'$hash'"' >> index.json
    echo -n '    }' >> index.json
  done

  echo -ne '\n  ]' >> index.json
done

echo -e "\n}" >> index.json
