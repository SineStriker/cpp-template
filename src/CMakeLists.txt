include("conf.cmake")

binop_init_buildsystem()

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

add_subdirectory(share)

binop_install()

binop_finish_buildsystem()