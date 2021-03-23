[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=NF3FBD3KHMXDN)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/horsicq/XELFViewer.svg)](https://github.com/horsicq/XELFViewer/releases)
[![GitHub All Releases](https://img.shields.io/github/downloads/horsicq/XELFViewer/total.svg)](https://github.com/horsicq/XELFViewer/releases)
[![gitlocalized ](https://gitlocalize.com/repo/4736/whole_project/badge.svg)](https://gitlocalize.com/repo/4736/whole_project?utm_source=badge)

ELF file viewer/editor for Windows, Linux and MacOS.

![alt text](https://github.com/horsicq/XELFViewer/blob/master/mascots/xelfviewer.png "Mascot")

![alt text](https://github.com/horsicq/XELFViewer/blob/master/docs/1.png "1")
![alt text](https://github.com/horsicq/XELFViewer/blob/master/docs/2.png "2")
![alt text](https://github.com/horsicq/XELFViewer/blob/master/docs/3.png "3")
![alt text](https://github.com/horsicq/XELFViewer/blob/master/docs/4.png "4")
![alt text](https://github.com/horsicq/XELFViewer/blob/master/docs/5.png "5")

How to build on Linux
=======

Install Qt 5.15.2: https://github.com/horsicq/build_tools

Clone project: git clone --recursive https://github.com/horsicq/XELFViewer.git

Edit build_lin64.bat ( check QT_PATH variable)

Run build_lin64.bat

How to build on OSX
=======

Install Qt 5.15.2: https://github.com/horsicq/build_tools

Clone project: git clone --recursive https://github.com/horsicq/XELFViewer.git

Edit build_mac.bat ( check QT_PATH variable)

Run build_mac.bat

How to build on Windows(XP)
=======

Install Visual Studio 2013: https://github.com/horsicq/build_tools

Install Qt 5.6.3 for VS2013: https://github.com/horsicq/build_tools

Install 7-Zip: https://github.com/horsicq/build_tools

Clone project: git clone --recursive https://github.com/horsicq/XELFViewer.git

Edit build_winxp.bat ( check VS_PATH,  SEVENZIP_PATH, QT_PATH variables)

Run build_winxp.bat

How to build on Windows(7-10)
=======

Install Visual Studio 2019: https://github.com/horsicq/build_tools

Install Qt 5.15.2 for VS2017: https://github.com/horsicq/build_tools

Install 7-Zip: https://github.com/horsicq/build_tools

Clone project: git clone --recursive https://github.com/horsicq/XELFViewer.git

Edit build_win32.bat ( check VS_PATH,  SEVENZIP_PATH, QT_PATH variables)

Edit build_win64.bat ( check VS_PATH,  SEVENZIP_PATH, QT_PATH variables)

Run build_win32.bat

Run build_win64.bat