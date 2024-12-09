#!/bin/bash

set -e

arduino-cli core --additional-urls=https://versioduo.com/download/package_versioduo_index.json update-index
arduino-cli core --additional-urls=https://versioduo.com/download/package_versioduo_index.json install versioduo:samd
arduino-cli core --additional-urls=https://versioduo.com/download/package_versioduo_index.json upgrade
