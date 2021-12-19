#!/bin/sh
dd if=mbr.bin of=../config/30M.img bs=512 count=1 conv=notrunc
dd if=loader.bin of=../config/30M.img seek=1 bs=512 count=1 conv=notrunc
