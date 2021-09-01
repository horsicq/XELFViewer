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

    check_file "$X_SOURCE_PATH/build/release/xelfviewer.app/Contents/MacOS/xelfviewer"
    if [ -z "$X_ERROR" ]; then
        cp -R "$X_SOURCE_PATH/build/release/xelfviewer.app"    "$X_SOURCE_PATH/release/$X_BUILD_NAME"

        mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/xelfviewer.app/Contents/Resources/signatures
        cp -R $X_SOURCE_PATH/signatures/crypto.db       $X_SOURCE_PATH/release/$X_BUILD_NAME/xelfviewer.app/Contents/Resources/signatures
        cp -Rf $X_SOURCE_PATH/XStyles/qss               $X_SOURCE_PATH/release/$X_BUILD_NAME/xelfviewer.app/Contents/Resources/

        fiximport "$X_SOURCE_PATH/build/release/xelfviewer.app/Contents/MacOS/xelfviewer"

        deploy_qt_library QtWidgets xelfviewer
        deploy_qt_library QtGui xelfviewer
        deploy_qt_library QtCore xelfviewer
        deploy_qt_library QtDBus xelfviewer
        deploy_qt_library QtPrintSupport xelfviewer
        deploy_qt_library QtSvg xelfviewer
        deploy_qt_library QtOpenGL xelfviewer
        deploy_qt_library QtConcurrent xelfviewer

        deploy_qt_plugin platforms libqcocoa xelfviewer
        deploy_qt_plugin platforms libqminimal xelfviewer
        deploy_qt_plugin platforms libqoffscreen xelfviewer
        
        deploy_qt_plugin imageformats libqjpeg xelfviewer
        deploy_qt_plugin imageformats libqtiff xelfviewer
        deploy_qt_plugin imageformats libqico xelfviewer
        deploy_qt_plugin imageformats libqgif xelfviewer

        make_release
        make_clear
    fi
fi