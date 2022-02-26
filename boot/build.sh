#!/bin/sh
dir=`dirname $0`
#echo $dir
nasm -i $dir/inc -o $dir/mbr.bin $dir/mbr.S
nasm -i $dir/inc -o $dir/loader.bin $dir/loader.S
