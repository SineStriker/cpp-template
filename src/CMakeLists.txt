include("conf.cmake")

function(_binop_common_configure_target _target)
    target_compile_features(${_target} PUBLIC cxx_std_17)
endfunction()


#[[
    Inherited variables:
        <PROJ>_BUILD_SHARED: boolean
        <PROJ>_DEVEL: boolean
        <PROJ>_INSTALL: boolean
]] #
binop_init_buildsystem(
    MACOSX_BUNDLE_NAME "Binop"
    WINDOWS_APPLICATION
    INCLUDE_DIR "include"
    CONFIG_HEADER_PATH "binop/Core/Config.h"
    BUILD_INFO_HEADER_PATH "binop/Core/BuildInfo.h"
    CONFIGURE_TARGET_COMMANDS _binop_common_configure_target
)

qm_add_definition(BINOP_VERSION "${PROJECT_VERSION}" STRING_LITERAL)
qm_add_definition(BINOP_DESCRIPTION "${PROJECT_DESCRIPTION}" STRING_LITERAL)
qm_add_definition(BINOP_HOMEPAGE_URL "${PROJECT_HOMEPAGE_URL}" STRING_LITERAL)

add_subdirectory(libs)
add_subdirectory(plugins)
add_subdirectory(app)
add_subdirectory(tools)

if(BINOP_BUILD_TESTS)
    add_subdirectory(tests)
endif()

binop_install()
binop_finish_buildsystem()