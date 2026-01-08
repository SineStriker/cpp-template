# ----------------------------------
# Project Constants
# ----------------------------------
set(BINOP_MACOSX_BUNDLE_NAME "Binop")
set(BINOP_WINDOWS_APPLICATION on)
set(BINOP_INCLUDE_DIR "include")
set(BINOP_CONFIG_HEADER_PATH "binop/Core/Config.h")
set(BINOP_BUILD_INFO_HEADER_PATH "binop/Core/BuildInfo.h")

set(BINOP_RC_NAME "Binop")
set(BINOP_RC_VERSION "${PROJECT_VERSION}")
set(BINOP_RC_DESCRIPTION "${PROJECT_DESCRIPTION}")
set(BINOP_RC_COPYRIGHT "Copyright (c) 2025-present YouKnowWho")

function(_binop_common_configure_target _target)
    qm_configure_target(${_target}
        FEATURES cxx_std_17
    )

    if(WIN32)
        get_target_property(_type ${_target} BINOP_TARGET_TYPE)

        if(_type MATCHES "Library|Plugin|Executable")
            set(_metadata_args
                NAME ${BINOP_RC_NAME}
                VERSION ${BINOP_RC_VERSION}
                DESCRIPTION ${BINOP_RC_DESCRIPTION}
                COPYRIGHT ${BINOP_RC_COPYRIGHT}
            )
            qm_add_win_rc(${_target} ${_metadata_args})

            # Disable Administrator privileges
            if(_type STREQUAL "Executable")
                qm_add_win_manifest(${_target} ${_metadata_args})
            endif()
        endif()

        # The resource and manifest of Application target is set in its individual directory.
    endif()
endfunction()

set(BINOP_POST_CONFIGURE_COMMANDS _binop_common_configure_target)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(BINOP_INSTALL_DIR_USE_DEBUG_PREFIX on)
endif()

# ----------------------------------
# Include Build Helpers
# ----------------------------------
include(${BINOP_SOURCE_DIR}/cmake/QMBuildRepoHelpers.cmake)