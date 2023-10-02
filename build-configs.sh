#!/usr/bin/env zsh
#set -x
echo Creating OpenCore config.plist Files

# Read current version
VERSION=$(<VERSION)
VERSION+=-$(git rev-parse --short HEAD)
echo "$VERSION"

# Clear previous build
rm -rfv ./build/config/* 2>/dev/null

# Create new output folders
mkdir -p ./build/config/intel-release
mkdir -p ./build/config/intel-verbose
mkdir -p ./build/config/intel-debug
mkdir -p ./build/config/intel-kdk

# Build config.plist files
jinja2 --format=toml --section=intel-release -D VERSION=$VERSION --outfile=./build/config/intel-release/config.plist config.j2 config.toml
jinja2 --format=toml --section=intel-verbose -D VERSION=$VERSION --outfile=./build/config/intel-verbose/config.plist config.j2 config.toml
jinja2 --format=toml --section=intel-debug -D VERSION=$VERSION --outfile=./build/config/intel-debug/config.plist config.j2 config.toml
jinja2 --format=toml --section=intel-kdk -D VERSION=$VERSION --outfile=./build/config/intel-kdk/config.plist config.j2 config.toml

exit