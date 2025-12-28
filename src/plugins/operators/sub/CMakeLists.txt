project(sub)

file(GLOB_RECURSE _src "*.cpp")
binop_add_plugin(${PROJECT_NAME} NO_INSTALL_ARCHIVE
    SOURCES ${_src}
    LINKS BinopCore
)