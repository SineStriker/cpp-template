project(Binop)

file(GLOB_RECURSE _src "*.cpp")
binop_add_application(${PROJECT_NAME}
    SOURCES ${_src}
    LINKS BinopCore
)

set(_metadata_args
    NAME ${BINOP_RC_NAME}
    VERSION ${BINOP_RC_VERSION}
    DESCRIPTION ${BINOP_RC_DESCRIPTION}
    COPYRIGHT ${BINOP_RC_COPYRIGHT}
)

if(WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE BinopWinMain)

    set(_icon_args ICON ${CMAKE_CURRENT_SOURCE_DIR}/app.ico)

    # Add resource file
    qm_add_win_rc(${PROJECT_NAME}
        ${_metadata_args}
        ${_icon_args}
    )

    # Disable Administrator privileges
    qm_add_win_manifest(${PROJECT_NAME} ${_metadata_args})
elseif(APPLE)
    set(_icon_args ICON ${CMAKE_CURRENT_SOURCE_DIR}/app.icns)

    # Add bundle
    qm_add_mac_bundle(${PROJECT_NAME}
        ${_metadata_args}
        ${_icon_args}
    )
endif()