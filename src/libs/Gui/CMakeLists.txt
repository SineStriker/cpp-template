project(BinopGui)

file(GLOB_RECURSE _src "*.cpp")

binop_add_library(${PROJECT_NAME}
    SOURCES ${_src}
    MACRO_PREFIX "BINOP_GUI"
)
qm_include_recursive(${PROJECT_NAME} PRIVATE . ${BINOP_INCLUDE_DIR}/binop/Gui)