#!/bin/sh -x
export QMAKE_PATH=$HOME/Qt/5.15.2/clang_64/bin/qmake

export X_SOURCE_PATH=$PWD
export X_BUILD_NAME=xapkdetector_mac
export X_RELEASE_VERSION=$(cat "release_version.txt")

source build_tools/mac.sh

check_file $QMAKE_PATH

if [ -z "$X_ERROR" ]; then
    make_init
    make_build "$X_SOURCE_PATH/xelfviewer_source.pro"
    cd "$X_SOURCE_PATH/gui_source"
    make_translate "gui_source_tr.pro" xelfviewer
    cd "$X_SOURCE_PATH"

    check_file "$X_SOURCE_PATH/build/release/XELFViewer.app/Contents/MacOS/XELFViewer"
    if [ -z "$X_ERROR" ]; then
        cp -R "$X_SOURCE_PATH/build/release/XELFViewer.app"    "$X_SOURCE_PATH/release/$X_BUILD_NAME"

        mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/XELFViewer.app/Contents/Resources/signatures
        cp -R $X_SOURCE_PATH/signatures/crypto.db       $X_SOURCE_PATH/release/$X_BUILD_NAME/XELFViewer.app/Contents/Resources/signatures
        cp -Rf $X_SOURCE_PATH/XStyles/qss               $X_SOURCE_PATH/release/$X_BUILD_NAME/XELFViewer.app/Contents/Resources/

        fiximport "$X_SOURCE_PATH/build/release/XELFViewer.app/Contents/MacOS/XELFViewer"

        deploy_qt XELFViewer

        make_release
        make_clear
    fi
fi
