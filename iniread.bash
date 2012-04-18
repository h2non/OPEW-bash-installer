#!/bin/bash

source inc/inireader.bash

cfg.parser 'config.ini'
 
# enable section called 'sec2' (in the file [sec2]) for reading
cfg.set2
 
# read the content of the variable called 'var2' (in the file
# var2=XXX). If your var2 is an array, then you can use
# ${var[index]}
echo "$v1"

