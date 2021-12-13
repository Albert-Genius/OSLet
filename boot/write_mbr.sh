#!/bin/sh
dd if=mbr.bin of=../config/30M.img bs=512 count=1 conv=notrunc
