TEMPLATE      = subdirs

SUBDIRS        += build_libs
SUBDIRS        += gui_source

isEmpty(PREFIX) {
 PREFIX = /usr
}

target.path = $PWD
target.commands = bash -x "$$PWD/install.sh $$PREFIX"
INSTALLS += target
