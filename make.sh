#!/bin/bash
rm -R build
mkdir build
nasm -f bin asm/boot.asm -o build/boot.bin
