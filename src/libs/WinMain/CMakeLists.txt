project(BinopWinMain)

file(GLOB_RECURSE _src "*.cpp")

binop_add_library(${PROJECT_NAME} STATIC
    SOURCES ${_src}
    MACRO_PREFIX "BINOP_WINMAIN"
)