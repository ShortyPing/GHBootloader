#!/bin/bash

# Create the build direcotry, if it doesn't exist already OR remove the existing dir
# and create a new one, to avoid accidentaly working with old build files.

if [ ! -d build ]
then
	mkdir build
else
	rm -rf build
	mkdir build
fi

# Compile and/or assemble all sources

nasm -f bin asm/boot.asm -o build/boot.bin

# Run the emulator, if boot.bin exists

if [ -f build/boot.bin ]
then
	qemu-system-i386 -fda build/boot.bin
fi
