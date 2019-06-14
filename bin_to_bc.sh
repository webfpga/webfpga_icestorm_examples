#!/bin/bash

binfile="$1"
header2="E+Fri_14_Jun_2019_09:00:38_PM_UTC+shastaplus"

gcc -Wall -o compdecomp compdecomp.c

compdecomp "$binfile" "$binfile".h h  "$header2"
compdecomp "$binfile".h "$binfile".c  c
compdecomp "$binfile".c "$binfile".cbin  b
compdecomp "$binfile".cbin "$binfile".db db
