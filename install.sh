#!/bin/bash -x
export X_SOURCE_PATH=$PWD

cp -f $X_SOURCE_PATH/build/release/xelfviewer                       /usr/bin/
cp -f $X_SOURCE_PATH/DEBIAN/xelfviewer.desktop                      /usr/share/applications/
cp -Rf $X_SOURCE_PATH/DEBIAN/hicolor/                               /usr/share/icons/
cp -Rf $X_SOURCE_PATH/XStyles/qss/                                  /usr/lib/xelfviewer/
mkdir -p  /usr/lib/xelfviewer/signatures
cp -f $X_SOURCE_PATH/signatures/crypto.db                           /usr/lib/xelfviewer/signatures/
