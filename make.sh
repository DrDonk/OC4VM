#!/usr/bin/env zsh
#set -x
source ./venv/bin/activate
echo Creating OC4VM

./build-config.sh
./build-vmdk.sh
./build-templates.sh
./build-release.sh

deactivate
exit
