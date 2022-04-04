#!/bin/bash

cp -R sound build/linux_amd64/
cp -R sound build/windows_amd64/
cp -R sound build/macos/

cd build/linux_amd64/
ln -f -s libfmod.so libfmod.so.13
ln -f -s libfmodstudio.so libfmodstudio.so.13
