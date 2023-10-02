#!/usr/bin/env zsh
#set -x
echo Creating OC4VM

./build-configs.sh
./build-disks.sh
./build-templates.sh
./build-release.sh
./build-zip.sh

exit
