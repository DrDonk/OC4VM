#!/usr/bin/env zsh
#set -x
echo Creating OpenCore config.plist Files

# Read current version
VERSION=$(<VERSION)
echo "$VERSION"

# Clear previous build
rm -rfv ./Config/*

# Create new output folders
mkdir -p ./Config/release_intel
mkdir -p ./Config/release_amd
mkdir -p ./Config/debug_intel
mkdir -p ./Config/debug_amd

# Build config.plist files
jinja2 --format=toml --section=release_intel -D VERSION=$VERSION --outfile=./Config/release_intel/config.plist config.j2 config.toml
jinja2 --format=toml --section=release_amd -D VERSION=$VERSION --outfile=./Config/release_amd/config.plist config.j2 config.toml
jinja2 --format=toml --section=debug_intel -D VERSION=$VERSION --outfile=./Config/debug_intel/config.plist config.j2 config.toml
jinja2 --format=toml --section=debug_amd -D VERSION=$VERSION --outfile=./Config/debug_amd/config.plist config.j2 config.toml

exit