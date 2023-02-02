#!/usr/bin/env zsh
#set -x
echo Creating OC4VM

./build-config.sh
./build-vmdk.sh
./build-templates.sh

exit