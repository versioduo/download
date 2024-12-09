# download

[github.com/versioduo/download/](https://github.com/versioduo/download/)

## Firmware
Binary firmware images: `com.versioduo.$DEVICE.firmware-$VERSION.bin`, automatically picked up by the 
web [configure](https://github.com/versioduo/configure) interface; or can be uploaded to the device
with [BOSSA](https://github.com/shumatech/BOSSA).

Firmware updates, installed using the [Mass Storage Interface](https://github.com/microsoft/uf2): 
`com.versioduo.$DEVICE.firmware-$VERSION.uf2`; a recovery option in case the
bootloader is updated and there is no running firmware, or in case the web [configure](https://github.com/versioduo/configure)
interface is unable to update the device.

## Bootloader
Binary bootloader images, installed using a chip programming interface/device: `com.versioduo.$DEVICE.bootloader-$VERSION.bin`.

Boot loader updates installed using the [Mass Storage Interface](https://github.com/microsoft/uf2): `com.versioduo.$DEVICE.bootloader-$VERSION.uf2`.

## Web Interface
Index of firmware updates, picked up by the web [configure](https://github.com/versioduo/configure) interface: 
[`index.json`](https://versioduo.com/download/index.json).

## Arduino Board Manager
Core, tools, boards [configuration](https://arduino.github.io/arduino-cli/latest/package_index_json-specification/)
for the Arduino CLI and IDE: [`package_versioduo_index.json`](https://versioduo.com/download/package_versioduo_index.json).

## Build System
Builds all bootloders: `build-bootloader.sh`.

Builds the core package: `build-core.sh`.

Builds all firmware images: `build-firmware.sh`.

# Copying
Anyone can use this public domain work without having to seek authorisation, no one can ever own it.
