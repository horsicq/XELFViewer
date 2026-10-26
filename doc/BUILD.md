# Building and packaging XELFViewer

Clone the repository with its submodules:

```sh
git clone --recursive https://github.com/horsicq/XELFViewer.git
cd XELFViewer
```

The recursive checkout populates the repository's `dep/` submodules, which are
used automatically. A combined development workspace may instead provide a
sibling `_mylibs/` tree:

```text
qt5/
  _mylibs/
  xelfviewer_source/
```

You can select another dependency tree explicitly with
`-DXELFVIEWER_DEP_ROOT=/path/to/dependencies`.

XELFViewer requires CMake 3.19 or newer, a C++ toolchain, and Qt 5 or Qt 6.
Qt 5 builds also require Script and ScriptTools; Qt 6 builds require Qml.

## Direct CMake build

```sh
cmake -S . -B tmp_build -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/path/to/Qt
cmake --build tmp_build --config Release --parallel
```

To install into a staging directory:

```sh
cmake --install tmp_build --config Release --prefix /path/to/staging
```

## Windows portable packages

The wrappers use the standard Qt 5.15.2 MSVC locations:

```bat
packaging\windows\build_portable_win32.bat
packaging\windows\build_portable_win64.bat
```

For a different Qt installation, invoke the common script directly:

```bat
packaging\windows\build_portable_windows.cmd C:\Qt\5.15.2\msvc2019_64 x64 win64
```

Set `CMAKE_GENERATOR_NAME` to override the default `Visual Studio 17 2022`
generator. The scripts create both an installed portable folder and a CPack ZIP
under `release\`.

## Linux packages

Install the Qt development packages supplied by your distribution, including
Qt Widgets, Concurrent, Network, PrintSupport, OpenGL, SVG, SQL, Script, and
Qt Tools. Then run either:

```sh
bash packaging/linux/build_linux.sh [/optional/qt/prefix]
bash packaging/debian/build_dpkg.sh [/optional/qt/prefix]
```

The first command creates a portable `.tar.gz`; the second creates a `.deb`.

## macOS packages

```sh
bash packaging/macos/build_mac.sh [/optional/qt/prefix]
```

The script creates a ZIP and a `productbuild` PKG. Architecture, deployment
target, signing, and notarization can be configured through the environment
variables printed by `packaging/macos/build_mac.sh --help`.

All working build trees and CPack staging directories are created under the
system temporary directory. Only finished artifacts are copied to `release/`.
