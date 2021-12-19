#!/bin/sh
nasm -i inc -o mbr.bin mbr.S
nasm -i inc -o loader.bin loader.S