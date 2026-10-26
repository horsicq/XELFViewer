if(NOT DEFINED CPACK_TEMPORARY_DIRECTORY
   OR "${CPACK_TEMPORARY_DIRECTORY}" STREQUAL "")
    message(FATAL_ERROR "CPACK_TEMPORARY_DIRECTORY is unavailable in the CPack pre-build hook")
endif()

file(GLOB_RECURSE _xelfviewer_app_candidates
    LIST_DIRECTORIES true
    "${CPACK_TEMPORARY_DIRECTORY}/*.app"
)

set(_xelfviewer_app "")
foreach(_xelfviewer_candidate ${_xelfviewer_app_candidates})
    if(IS_DIRECTORY "${_xelfviewer_candidate}"
       AND "${_xelfviewer_candidate}" MATCHES "\\.app$")
        if(NOT "${_xelfviewer_app}" STREQUAL "")
            message(FATAL_ERROR
                "Multiple app bundles found in CPack staging: "
                "${_xelfviewer_app};${_xelfviewer_candidate}")
        endif()
        set(_xelfviewer_app "${_xelfviewer_candidate}")
    endif()
endforeach()

if("${_xelfviewer_app}" STREQUAL "")
    message(FATAL_ERROR
        "XELFViewer app bundle not found under ${CPACK_TEMPORARY_DIRECTORY}")
endif()

set(_xelfviewer_macdeployqt "$ENV{XELFVIEWER_CPACK_MACDEPLOYQT}")
if("${_xelfviewer_macdeployqt}" STREQUAL ""
   OR NOT EXISTS "${_xelfviewer_macdeployqt}")
    message(FATAL_ERROR "XELFVIEWER_CPACK_MACDEPLOYQT does not name macdeployqt")
endif()

message(STATUS "Finalizing staged app bundle: ${_xelfviewer_app}")
execute_process(
    COMMAND "${_xelfviewer_macdeployqt}"
        "${_xelfviewer_app}"
        -always-overwrite
    RESULT_VARIABLE _xelfviewer_macdeployqt_result
)
if(NOT _xelfviewer_macdeployqt_result EQUAL 0)
    message(FATAL_ERROR
        "macdeployqt failed for staged bundle: ${_xelfviewer_app}")
endif()

set(_xelfviewer_app_cert "$ENV{XELFVIEWER_CPACK_APP_CERT}")
if(NOT "${_xelfviewer_app_cert}" STREQUAL "")
    find_program(_xelfviewer_codesign codesign REQUIRED)

    set(_xelfviewer_sign_args
        --force
        --deep
        --verbose
        --timestamp
        --options runtime
        --sign "${_xelfviewer_app_cert}"
    )

    set(_xelfviewer_entitlements
        "$ENV{XELFVIEWER_CPACK_APP_ENTITLEMENTS}")
    if(NOT "${_xelfviewer_entitlements}" STREQUAL "")
        if(NOT EXISTS "${_xelfviewer_entitlements}")
            message(FATAL_ERROR
                "Entitlements file not found: ${_xelfviewer_entitlements}")
        endif()
        list(APPEND _xelfviewer_sign_args
            --entitlements "${_xelfviewer_entitlements}")
    endif()

    execute_process(
        COMMAND "${_xelfviewer_codesign}"
            ${_xelfviewer_sign_args}
            "${_xelfviewer_app}"
        RESULT_VARIABLE _xelfviewer_codesign_result
    )
    if(NOT _xelfviewer_codesign_result EQUAL 0)
        message(FATAL_ERROR
            "codesign failed for staged bundle: ${_xelfviewer_app}")
    endif()

    execute_process(
        COMMAND "${_xelfviewer_codesign}"
            --verify
            --deep
            --strict
            --verbose=2
            "${_xelfviewer_app}"
        RESULT_VARIABLE _xelfviewer_verify_result
    )
    if(NOT _xelfviewer_verify_result EQUAL 0)
        message(FATAL_ERROR
            "codesign verification failed for staged bundle: ${_xelfviewer_app}")
    endif()
endif()
