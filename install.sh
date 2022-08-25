#!/bin/bash -x
export X_SOURCE_PATH=$PWD

if [ -z "$1" ]; then
    X_PREFIX="/usr"
else
    X_PREFIX="$1"
fi

mkdir -p  $X_PREFIX/lib/bin
mkdir -p  $X_PREFIX/lib/share/applications
mkdir -p  $X_PREFIX/lib/share/icons
mkdir -p  $X_PREFIX/lib/xelfviewer
mkdir -p  $X_PREFIX/lib/xelfviewer/signatures

cp -f $X_SOURCE_PATH/build/release/xelfviewer                       $X_PREFIX/bin/
cp -f $X_SOURCE_PATH/LINUX/xelfviewer.desktop                       $X_PREFIX/share/applications/
cp -Rf $X_SOURCE_PATH/LINUX/hicolor/                                $X_PREFIX/share/icons/
cp -Rf $X_SOURCE_PATH/XStyles/qss/                                  $X_PREFIX/lib/xelfviewer/
cp -f $X_SOURCE_PATH/signatures/crypto.db                           $X_PREFIX/lib/xelfviewer/signatures/
cp -Rf $X_SOURCE_PATH/images/                                       $X_PREFIX/lib/xelfviewer/
