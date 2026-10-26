include("${XELFVIEWER_DEP_ROOT}/build_tools/cmake/cpp_standart_setup.cmake")

add_definitions(-DUSE_YARA)

include("${XELFVIEWER_DEP_ROOT}/archive_widget/archive_widget.cmake")
include("${XELFVIEWER_DEP_ROOT}/XAboutWidget/xaboutwidget.cmake")
include("${XELFVIEWER_DEP_ROOT}/XStyles/xstyles.cmake")

find_package(Threads REQUIRED)

set(XELFVIEWER_GUI_TARGET XELFViewer)
set(XELFVIEWER_GUI_SOURCES
    ${ARCHIVE_WIDGET_SOURCES}
    ${XABOUTWIDGET_SOURCES}
    ${XSTYLES_SOURCES}
    dialogabout.cpp
    dialogabout.h
    dialogabout.ui
    dialogoptions.cpp
    dialogoptions.h
    dialogoptions.ui
    guimainwindow.cpp
    guimainwindow.h
    guimainwindow.ui
    main_gui.cpp
    "${CMAKE_CURRENT_LIST_DIR}/../../res/resources_gui.qrc"
)

if(WIN32 AND EXISTS "${X_WINDOWS_RESOURCE_ICON_RC}")
    list(APPEND XELFVIEWER_GUI_SOURCES "${X_WINDOWS_RESOURCE_ICON_RC}")
endif()

if(APPLE AND EXISTS "${X_MACOS_ICON}")
    set_source_files_properties("${X_MACOS_ICON}" PROPERTIES
        MACOSX_PACKAGE_LOCATION "Resources"
    )
    list(APPEND XELFVIEWER_GUI_SOURCES "${X_MACOS_ICON}")
endif()

add_executable(${XELFVIEWER_GUI_TARGET} WIN32
    ${XELFVIEWER_GUI_SOURCES}
)

set_target_properties(${XELFVIEWER_GUI_TARGET} PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_GUI_IDENTIFIER "${MACOSX_BUNDLE_GUI_IDENTIFIER}"
    OUTPUT_NAME "${X_ORIGINAL_FILENAME}"
)

if(APPLE AND EXISTS "${X_MACOS_INFO_PLIST}")
    set_target_properties(${XELFVIEWER_GUI_TARGET} PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST "${X_MACOS_INFO_PLIST}"
    )
endif()

target_include_directories(${XELFVIEWER_GUI_TARGET} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(${XELFVIEWER_GUI_TARGET} PRIVATE
    capstone
    cppfilt
    yara
    Qt${XELFVIEWER_QT_MAJOR}::Widgets
    Qt${XELFVIEWER_QT_MAJOR}::Concurrent
    Qt${XELFVIEWER_QT_MAJOR}::Network
    Qt${XELFVIEWER_QT_MAJOR}::PrintSupport
    Qt${XELFVIEWER_QT_MAJOR}::OpenGL
    Qt${XELFVIEWER_QT_MAJOR}::Svg
    Qt${XELFVIEWER_QT_MAJOR}::Sql
    Threads::Threads
)

if(XELFVIEWER_QT_MAJOR EQUAL 5)
    target_link_libraries(${XELFVIEWER_GUI_TARGET} PRIVATE
        Qt5::Script
        Qt5::ScriptTools
    )
elseif(XELFVIEWER_QT_MAJOR GREATER_EQUAL 6)
    target_link_libraries(${XELFVIEWER_GUI_TARGET} PRIVATE
        Qt${XELFVIEWER_QT_MAJOR}::Qml
    )
endif()

if(WIN32)
    target_link_libraries(${XELFVIEWER_GUI_TARGET} PRIVATE Wintrust Crypt32)
endif()

if(TARGET xelfviewer_translations)
    add_dependencies(${XELFVIEWER_GUI_TARGET} xelfviewer_translations)
endif()

if(UNIX AND NOT APPLE AND NOT XELFVIEWER_PORTABLE_LAYOUT)
    set(XELFVIEWER_RUNTIME_DESTINATION "${CMAKE_INSTALL_BINDIR}")
    set(XELFVIEWER_DOC_DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/doc/xelfviewer")
    set(XELFVIEWER_DESKTOP_TEMPLATE "${CMAKE_CURRENT_SOURCE_DIR}/../../res/linux/xelfviewer.desktop.in")
    set(XELFVIEWER_DESKTOP_FILE "${CMAKE_CURRENT_BINARY_DIR}/xelfviewer.desktop")

    if(EXISTS "${XELFVIEWER_DESKTOP_TEMPLATE}")
        configure_file("${XELFVIEWER_DESKTOP_TEMPLATE}" "${XELFVIEWER_DESKTOP_FILE}" @ONLY)
    endif()
else()
    set(XELFVIEWER_RUNTIME_DESTINATION ".")
    set(XELFVIEWER_DOC_DESTINATION ".")
endif()

install(TARGETS ${XELFVIEWER_GUI_TARGET}
    RUNTIME DESTINATION ${XELFVIEWER_RUNTIME_DESTINATION}
    BUNDLE DESTINATION .
)

if(UNIX AND NOT APPLE AND NOT XELFVIEWER_PORTABLE_LAYOUT)
    install(FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/../../LICENSE"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../README.md"
        DESTINATION ${XELFVIEWER_DOC_DESTINATION}
        OPTIONAL
    )

    if(EXISTS "${XELFVIEWER_DESKTOP_FILE}")
        install(FILES "${XELFVIEWER_DESKTOP_FILE}"
            DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/applications")
    endif()

    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../../res/linux/hicolor")
        install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../../res/linux/hicolor/"
            DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor")
    endif()
elseif(APPLE)
    # productbuild installs the bundle at /Applications. Keep documentation
    # inside the bundle instead of dropping loose files into /Applications.
    install(FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/../../LICENSE"
        DESTINATION "${X_RESOURCES}"
        RENAME LICENSE.txt
        OPTIONAL
    )

    install(FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/../../README.md"
        DESTINATION "${X_RESOURCES}"
        OPTIONAL
    )
else()
    install(FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/../../LICENSE"
        DESTINATION .
        RENAME LICENSE.txt
        OPTIONAL
    )

    install(FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/../../README.md"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../res/license.txt"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../res/readme.txt"
        DESTINATION .
        OPTIONAL
    )

    if(WIN32)
        install(FILES "${X_WINDOWS_ICON}"
            DESTINATION .
            OPTIONAL
        )
    endif()

    install(CODE [[file(WRITE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/portable" "")]])
endif()

if(APPLE)
    include("${XELFVIEWER_DEP_ROOT}/build_tools/cmake/macdeployqt.cmake")
endif()

if(WIN32)
    include("${XELFVIEWER_DEP_ROOT}/build_tools/cmake/deploy_qt_windows.cmake")
    include("${XELFVIEWER_DEP_ROOT}/build_tools/cmake/deploy_msvc.cmake")

    # The shared deploy helper does not yet cover these two directly linked
    # modules. Without them, the portable archive builds but cannot start.
    set(_xelfviewer_extra_qt_dlls)
    foreach(_xelfviewer_qt_module Concurrent PrintSupport)
        set(_xelfviewer_qt_target
            "Qt${XELFVIEWER_QT_MAJOR}::${_xelfviewer_qt_module}")
        get_target_property(_xelfviewer_qt_dll
            "${_xelfviewer_qt_target}" IMPORTED_LOCATION_RELEASE)
        if(NOT _xelfviewer_qt_dll
           OR _xelfviewer_qt_dll MATCHES "-NOTFOUND$")
            get_target_property(_xelfviewer_qt_dll
                "${_xelfviewer_qt_target}" IMPORTED_LOCATION)
        endif()
        if(NOT _xelfviewer_qt_dll
           OR _xelfviewer_qt_dll MATCHES "-NOTFOUND$"
           OR NOT EXISTS "${_xelfviewer_qt_dll}")
            message(FATAL_ERROR
                "Release DLL not found for ${_xelfviewer_qt_target}")
        endif()
        list(APPEND _xelfviewer_extra_qt_dlls
            "${_xelfviewer_qt_dll}")
    endforeach()
    install(FILES ${_xelfviewer_extra_qt_dlls} DESTINATION .)

    # Select OpenSSL by the target architecture. CMAKE_SYSTEM_PROCESSOR can
    # describe the 64-bit host even for a Visual Studio Win32 target.
    if(MSVC AND XELFVIEWER_QT_MAJOR EQUAL 5)
        set(_xelfviewer_openssl_root
            "${XELFVIEWER_DEP_ROOT}/build_tools/openssl")

        if(MSVC_VERSION EQUAL 1800)
            install(FILES
                "${_xelfviewer_openssl_root}/winxp_x86/libeay32.dll"
                "${_xelfviewer_openssl_root}/winxp_x86/ssleay32.dll"
                DESTINATION .
                OPTIONAL
            )
        elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
            install(FILES
                "${_xelfviewer_openssl_root}/win_x64/libcrypto-1_1-x64.dll"
                "${_xelfviewer_openssl_root}/win_x64/libssl-1_1-x64.dll"
                DESTINATION .
                OPTIONAL
            )
        else()
            install(FILES
                "${_xelfviewer_openssl_root}/win_x86/libcrypto-1_1.dll"
                "${_xelfviewer_openssl_root}/win_x86/libssl-1_1.dll"
                DESTINATION .
                OPTIONAL
            )
        endif()
    endif()
endif()
