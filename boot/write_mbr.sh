#!/bin/sh
dir=`dirname $0`
cd $dir
dd if=mbr.bin of=../config/30M.img bs=512 count=1 conv=notrunc
dd if=loader.bin of=../config/30M.img seek=1 bs=512 count=2 conv=notrunc
