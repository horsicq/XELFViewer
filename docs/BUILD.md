How to build on Docker
=======
git clone --recursive https://github.com/horsicq/XELFViewer.git

cd XELFViewer

docker build .

How to build on Linux(Debian package, tested on Ubuntu 14.04-20.04)
=======

Install packages:

- sudo apt-get install --quiet --assume-yes git
- sudo apt-get install --quiet --assume-yes build-essential
- sudo apt-get install --quiet --assume-yes qt5-default qtbase5-dev qttools5-dev-tools

git clone --recursive https://github.com/horsicq/XELFViewer.git

cd XELFViewer

Run build script: bash -x build_dpkg.sh

How to build on Linux(Automake)
=======

Qt framework has to be installed on the system.

- (Ubuntu) Install GIT: sudo apt-get install --quiet --assume-yes git
- (Ubuntu 20.04)Install Qt Framework: sudo apt-get install --quiet --assume-yes build-essential qt5-default qtbase5-dev qttools5-dev-tools

Clone project: git clone --recursive https://github.com/horsicq/XELFViewer.git

cd XELFViewer

- chmod a+x configure
- ./configure
- make
- sudo make install

How to build on OSX
=======

Install Qt 5.15.2: https://github.com/horsicq/build_tools

Clone project: git clone --recursive https://github.com/horsicq/XELFViewer.git

cd XELFViewer

Edit build_mac.bat ( check QT_PATH variable)

Run build_mac.bat

How to build on Windows(XP)
=======

Install Visual Studio 2013: https://github.com/horsicq/build_tools

Install Qt 5.6.3 for VS2013: https://github.com/horsicq/build_tools

Install 7-Zip: https://www.7-zip.org/

Clone project: git clone --recursive https://github.com/horsicq/XELFViewer.git

cd XELFViewer

Edit build_winxp.bat ( check VS_PATH,  SEVENZIP_PATH, QT_PATH variables)

Run build_winxp.bat

How to build on Windows(7-10)
=======

Install Visual Studio 2019: https://github.com/horsicq/build_tools

Install Qt 5.15.2 for VS2019: https://github.com/horsicq/build_tools

Install 7-Zip: https://www.7-zip.org/

Install Inno Setup: https://github.com/horsicq/build_tools

Clone project: git clone --recursive https://github.com/horsicq/XELFViewer.git

cd XELFViewer

Edit build_msvc_win32.bat ( check VSVARS_PATH, SEVENZIP_PATH, INNOSETUP_PATH, QMAKE_PATH variables)

Edit build_msvc_win64.bat ( check VSVARS_PATH, SEVENZIP_PATH, INNOSETUP_PATH, QMAKE_PATH variables)

Run build_win32.bat

Run build_win64.bat