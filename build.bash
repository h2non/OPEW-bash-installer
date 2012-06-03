#/bin/bash
#
# OPEW Bash Installer - Bash-based installer builder utility for the OPEW project
# This was developed for the OPEW project <http://opew.sf.net>
#
# @license	GNU GPL 3.0
# @author	Tomas Aparicio <tomas@rijndael-project.com>
# @version	2.3 beta - revision 03/06/2012
# 
# Copyright (C) 2012 - Tomas Aparicio
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#

#
# base functions
#

# 
# Check if exists a binary/file looking on the $PATH folders 
# @param {String} Binary/file to check 
#
function _check 
{
    type "$1" &> /dev/null ;
}

#
# get the file via cat 
# @param {String} File path 
#
function getfile
{
    cat $1
}

# check PATH environment variable
if [ -z $PATH ]; then
	echo "The PATH environment variable is empty."
	echo "Must be defined in order to run this script properly. "
	echo "Please, copy and ejecute this (or your customized PATH environment): " 
	echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
	exit 1
fi

ERROR=0
# check OS binary tools required by the installer builder
for i in $(echo "source;dirname;declare;type;read;awk;head;tail;wc;tar;df;cat" | tr ";" "\n")
do
	if ! _check $i ; then
		echo " "
		echo "Error:"
		echo "The binary tool '$i' not found in the system (looking using PATH env variable)"
		echo "Check it or install '$i' via your package manager and try again with the installation"
		echo " "
		ERROR=1
	fi
done
if [ $ERROR -eq 1 ]; then
	echo "Cannot continue. Exiting."
	exit 1
fi

# config variables
LOCATION=$(dirname $0)
TMPDIR="$LOCATION/tmp" # temporal output directory
PKGDIR="$LOCATION/pkg" # packages output directory
INCDIR="$LOCATION/inc" # includes source directory
LOGDIR="$LOCATION/log" # log output dir
VERSION="1.0 Beta"
OUTPUT=installer.bash

# check bash install folders
if [ ! -d  $TMPDIR ]; then
    echo "Error: $TMPDIR folder don't exists. Cannot continue."
fi
if [ ! -d  $LOGDIR ]; then
    echo "Error: $LOGDIR folder don't exists. Cannot continue."
fi
if [ ! -d  $PKGDIR ]; then
    echo "Error: $PKGDIR folder don't exists. Cannot continue."
fi
if [ ! -d  $INCDIR ]; then
    echo "Error: $INCDIR folder don't exists. Cannot continue."
fi

# change dir
cd $LOCATION > /dev/null

# output header info
cat <<- _EOF_
--------------------------------------------------------
 OPEW Bash-based installer builder utility ($VERSION)
 A simple UNIX bash-based installer builder utility

 Version: $VERSION
 Author: Tomas Aparicio <tomas@rijndael-project.com>
 License: GNU GPL 3.0
 Code: <http://github.com/h2non/OPEW-bash-installer>
 Note: this utility was developed for the OPEW project.
 More info: <http://opew.sf.net> 
--------------------------------------------------------

Please, follow the wizard in order to build a new installer

_EOF_


# define the software name package (default opew)
read -p "Release package name (e.g. opew): " res
if [ -z $res ]; then
    _NAME=opew
    echo "Default to 'opew'"
    echo " "
else 
    _NAME=$res
fi

# define the OPEW release version
read -p "Enter the release version (e.g. 1.1.0): " res
if [ -z $res ]; then
    echo "You must enter a version. Cannot continue. "
    exit 1
else 
    # define the version
    _VERSION=$res
fi

# define the software processor architecture (default to amd64)
read -p "Enter the processor architecture (amd64|x86): " res
if [ -z $res ]; then
    _ARCH="amd64"
    echo "Default to 'amd64'"
    echo " "
else 
    _ARCH=$res
fi

# output file
_OUTPUT="$_NAME-$_VERSION-$_ARCH"

cat <<- _EOF_

Now you must enter the header file and bash base installer script.
The builder provides five variables that you must use in your custom bash installer.
See inc/installer.inc for a real example of a complete installer. 
_EOF_

echo " "
echo "Header file with custom copyright and licensing info (see $LOCATION/inc/header.inc) "
while : ; do
    read -p "Enter the path of the file: " res
    if [ $res == "exit" ]; then 
        exit 0
    fi
    if [ -z $res ] || [ ! -f "$res" ]; then
        echo "Invalid path. Enter a new file path... (enter CTRL+C or 'exit' for exit)"
        echo " "
    else 
        _FILE_HEADER=$res
        break
    fi 
done 

echo " "
echo "Installer main script (see $LOCATION/inc/installer.inc) "
while : ; do
    read -p "Enter the path of the file: " res
    if [ $res == "exit" ]; then 
        exit 0
    fi
    if [ -z $res ] || [ ! -f "$res" ]; then
        echo "Invalid path. Enter a new file path... (enter CTRL+C or 'exit' for exit)"
        echo " "
    else 
        _FILE_INSTALLER=$res
        break
    fi 
done 

echo " "
echo "Software folder (e.g. /opt/opew) "
while : ; do
    read -p "Enter the software folder: " res
    if [ $res == "exit" ]; then 
        exit 0
    fi
    if [ -z $res ] || [ ! -d "$res" ]; then
        echo "Invalid folder. Enter a valid folder path... (enter CTRL+C or 'exit' for exit)"
        echo " "
    else 
        _FILE_FOLDER=$res
        break
    fi 
done 

echo " "
read -p "Do you want to generate the installer? (y|n): " res
case $res in
y|Y|yes|YES|Yes) 
    # continue
;;
*)
    echo "You enter '$res'. Exiting."
    exit 0
;;
esac

sleep 1

echo " "
echo "Generating the file package. This may take some minutes..."
tar czvf "$TMPDIR/$_OUTPUT.tar.gz" $_FILE_FOLDER > "$LOGDIR/compress-files.log"

# takes the lines
_LINES=`wc -l "$LOGDIR/compress-files.log" | awk '{ print $1; }'`
echo "Done! Added $_LINES files."

sleep 1

echo "Generating the installer..."

# generating the installer
echo '#!/bin/bash' > "$TMPDIR/$OUTPUT"
getfile $_FILE_HEADER >> "$TMPDIR/$OUTPUT"

# set config variables
echo '# config variables' >> "$TMPDIR/$OUTPUT"
echo "VERSION=$_VERSION # current OPEW version" >> "$TMPDIR/$OUTPUT"
echo "LOG='$_NAME-install.log' # output log of the installer script" >> "$TMPDIR/$OUTPUT"
echo "FILES='$_NAME-files.log' # output log of files" >> "$TMPDIR/$OUTPUT"
echo "OUTPUT=/opt/ # default installation path" >> "$TMPDIR/$OUTPUT"
echo "LINES=$_LINES # number of files" >> "$TMPDIR/$OUTPUT"
echo "ERROR=0 # default with no errors" >> "$TMPDIR/$OUTPUT"
# replace the config
#getfile "$TMPDIR/$OUTPUT" | sed -e "s/{LINES}/$_LINES/g" >> "$TMPDIR/$OUTPUT"
#getfile "$TMPDIR/$OUTPUT" | sed -e "s/{VERSION}/$_VERSION/g" >> "$TMPDIR/$OUTPUT"
#getfile "$TMPDIR/$OUTPUT" | sed -e "s/{NAME}/$_NAME/g" >> "$TMPDIR/$OUTPUT"
#getfile "$TMPDIR/$OUTPUT" | sed -e "s/{NAME}/$_NAME/g" >> "$TMPDIR/$OUTPUT"

# get the installer
getfile $_FILE_INSTALLER >> "$TMPDIR/$OUTPUT"

echo "Packing the installer ($_OUTPUT.bin)"
# merge to .bin
cat "$TMPDIR/$OUTPUT" "$TMPDIR/$_OUTPUT.tar.gz" > "$PKGDIR/$_OUTPUT.bin"

echo "Cleaning temporal file..."
rm -f "$TMPDIR/$_OUTPUT.tar.gz"

echo "Finished. New release generated: "
echo "$PKGDIR/$_OUTPUT.bin"
