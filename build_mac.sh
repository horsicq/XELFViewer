#!/bin/sh -x
QT_PATH=$HOME/Qt/5.15.2/clang_64
RELEASE_VERSION=$(cat "release_version.txt")
echo $RELEASE_VERSION
SOURCE_PATH=$PWD

BUILD_NAME=xelfviewer_mac_portable
GUIEXE=xelfviewer

cd $SOURCE_PATH

rm -rf build

function makeproject
{
    cd $SOURCE_PATH/$1
    
    $QT_PATH/bin/qmake $1.pro -spec macx-clang CONFIG+=x86_64
    make -f Makefile clean
    make -f Makefile

    rm -rf Makefile
    rm -rf Makefile.Release
    rm -rf Makefile.Debug
    rm -rf object_script.*     

    cd $SOURCE_PATH
}

makeproject gui_source

mkdir -p release
rm -rf release/$BUILD_NAME
mkdir -p release/$BUILD_NAME

cp -R $SOURCE_PATH/build/release/$GUIEXE.app               $SOURCE_PATH/release/$BUILD_NAME
mkdir $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/PlugIns

function fixlibrary
{
    install_name_tool -change @rpath/$1.framework/Versions/5/$1 @executable_path/../Frameworks/$1.framework/Versions/5/$1  $2    
}

function fiximport
{
    fixlibrary QtWidgets $1
    fixlibrary QtGui $1
    fixlibrary QtCore $1  
	fixlibrary QtDBus $1
	fixlibrary QtPrintSupport $1
	fixlibrary QtSvg $1
    fixlibrary QtOpenGL $1
    fixlibrary QtConcurrent $1
}

function copylibrary
{
    mkdir $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/Frameworks
    mkdir $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/Frameworks/$1.framework
    mkdir $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/Frameworks/$1.framework/Versions
    mkdir $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/Frameworks/$1.framework/Versions/5
    
    cp -R $QT_PATH/lib/$1.framework/Versions/5/$1 $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/Frameworks/$1.framework/Versions/5
    
    install_name_tool -id @executable_path/../Frameworks/$1.framework/Versions/5/$1 $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/Frameworks/$1.framework/Versions/5/$1
    fiximport $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/Frameworks/$1.framework/Versions/5/$1
}

function copyplugin
{
    mkdir $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/PlugIns/$1/
    cp -R $QT_PATH/plugins/$1/$2.dylib $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/PlugIns/$1/
    
    install_name_tool -id @executable_path/../PlugIns/$1/$2.dylib $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/PlugIns/$1/$2.dylib
    fiximport $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/PlugIns/$1/$2.dylib
}

fiximport $SOURCE_PATH/release/$BUILD_NAME/$GUIEXE.app/Contents/MacOS/$GUIEXE

copylibrary QtWidgets
copylibrary QtGui
copylibrary QtCore
copylibrary QtDBus
copylibrary QtPrintSupport
copylibrary QtSvg
copylibrary QtOpenGL
copylibrary QtConcurrent

copyplugin platforms libqcocoa
copyplugin platforms libqminimal
copyplugin platforms libqoffscreen

rm -rf $SOURCE_PATH/release/${BUILD_NAME}_${RELEASE_VERSION}.dmg
hdiutil create -format UDBZ -quiet -srcfolder $SOURCE_PATH/release/$BUILD_NAME $SOURCE_PATH/release/${BUILD_NAME}_${RELEASE_VERSION}.dmg
cd $SOURCE_PATH/release/
zip -r $SOURCE_PATH/release/${BUILD_NAME}_${RELEASE_VERSION}.zip ${BUILD_NAME}

rm -rf $SOURCE_PATH/release/$BUILD_NAME


