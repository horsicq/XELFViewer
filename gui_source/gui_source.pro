QT       += core gui widgets

TARGET = xelfviewer
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

XCONFIG += use_disasm
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
}
macx {
    ICON = ../icons/main.icns
}

RESOURCES += \
    rsrc.qrc
