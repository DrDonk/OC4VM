#!/usr/bin/env python3
# coding=utf-8

# SPDX-FileCopyrightText: © 2022-23 David Parsons
# SPDX-License-Identifier: MIT

import macrecovery
import os
import subprocess
import sys

def main():

    print('\nOC4VM macOS Recovery VMDK Maker')
    print('=================================')
    print('(c) David Parsons 2022-23\n')

    # Create full path to dmg2img utility for platform
    cwd = os.path.dirname(os.path.realpath(__file__))
    platform = sys.platform

    if platform == 'linux':
        dmg2img = 'dmg2img'
        qemu_img = 'qemu-img'
    elif platform == 'darwin':
        dmg2img = 'dmg2img'
        qemu_img = 'qemu-img'
    elif platform == 'win32':
        dmg2img = os.path.join(cwd, 'windows/dmg2img.exe')
        qemu_img = os.path.join(cwd, 'windows/qemu-img')
    else:
        print(f'Unknown platform {platform}')
        exit(1)

    # Print the menu
    print('Create a VMware VMDK Recovery Image')
    print('1. Catalina')
    print('2. Big Sur')
    print('3. Monterey')
    print('4. Ventura')

    # And get the input
    while True:
        selection = input('Input menu number: ')

        if selection == '1':
            basename = 'catalina'
            boardid = 'Mac-6F01561E16C75D06'
            break
        if selection == '2':
            basename = 'bigsur'
            boardid = 'Mac-2BD1B31983FE1663'
            break

        if selection == '3':
            basename = 'monterey'
            boardid = 'Mac-A5C67F76ED83108C'
            break
        if selection == '4':
            basename = 'ventura'
            boardid = 'Mac-B4831CEBD52A0C4C'
            break

    print('Downloading DMG... \n')

    # Setup args for macrecovery and get the download
    sys.argv = ['macrecovery.py',
                'download',
                '-b', boardid,
                '-m', '00000000000000000',
                '--basename', basename,
                '-os', 'latest']

    macrecovery.main()

    # Convert DMG to IMG using dmg2img
    dmg = f'{basename}.dmg'
    img = f'{basename}.img'
    vmdk = f'{basename}.vmdk'
    convert = f'{dmg2img} -i {dmg} -o {img}'
    subprocess.call(convert.split())

    print('Convertng to VMDK: ')
    qemu_img = f'{qemu_img} convert -O vmdk {img} {vmdk} -p'
    subprocess.call(qemu_img.split())

    # Cleanup raw file
    if os.path.exists(f'{img}'):
        os.remove(f'{img}')

    print(f'Created VMDK disk: {vmdk}')
    return


if __name__ == '__main__':
    main()
