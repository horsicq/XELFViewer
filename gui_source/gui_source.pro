QT       += core gui widgets

TARGET = xelfviewer

macx {
    TARGET = XELFViewer
}

TEMPLATE = app

CONFIG += c++11

SOURCES += \
        guimainwindow.cpp \
        main_gui.cpp \
        dialogoptions.cpp \
        dialogabout.cpp

HEADERS += \
        dialogoptions.h \
        dialogabout.h \
        guimainwindow.h

FORMS += \
        dialogoptions.ui \
        dialogabout.ui \
        guimainwindow.ui

include(../build.pri)

XCONFIG += use_extrabuttons

!contains(XCONFIG, elfwidget) {
    XCONFIG += elfwidget
    include(../FormatWidgets/ELF/elfwidget.pri)
}

!contains(XCONFIG, xoptions) {
    XCONFIG += xoptions
    include(../XOptions/xoptions.pri)
}

win32 {
    RC_ICONS = ../icons/main.ico
    CONFIG -= embed_manifest_exe
    QMAKE_MANIFEST = windows.manifest.xml
}
macx {
    ICON = ../icons/main.icns
}

RESOURCES += \
    rsrc.qrc

DISTFILES += \
    ../CMakeLists.txt \
    ../LICENSE \
    ../README.md \
    ../changelog.txt \
    ../release_version.txt \
    CMakeLists.txt
