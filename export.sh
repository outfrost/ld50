#!/bin/bash

echo "Cleaning build outputs" >&2
rm -rf build/RePlacement-Linux/
rm -rf build/RePlacement-Windows/

echo "Creating build directories" >&2
mkdir -p build/RePlacement-Linux/
mkdir -p build/RePlacement-Windows/

echo >&2
echo "Starting Linux export" >&2
godot -v --no-window --export RePlacement-Linux-X11-amd64 build/RePlacement-Linux/replacement
echo >&2
echo "Starting Windowsexport" >&2
godot -v --no-window --export RePlacement-Windows-amd64 build/RePlacement-Windows/replacement.exe

echo >&2
echo "Copying sound files" >&2
cp -R sound build/RePlacement-Linux/
rm build/RePlacement-Linux/sound/*.import
cp -R sound build/RePlacement-Windows/
rm build/RePlacement-Windows/sound/*.import

echo >&2
echo "Creating library symlinks" >&2
pushd build/RePlacement-Linux/ >/dev/null
ln -f -s libfmod.so libfmod.so.13
ln -f -s libfmodstudio.so libfmodstudio.so.13
popd >/dev/null

echo >&2
echo "Archiving exports" >&2
pushd build/ >/dev/null
echo "RePlacement-Linux.zip" >&2
zip -r RePlacement-Linux.zip RePlacement-Linux
echo "RePlacement-Windows.zip" >&2
zip -r RePlacement-Windows.zip RePlacement-Windows
popd >/dev/null
