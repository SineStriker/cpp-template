project(BinopConsole)

file(GLOB_RECURSE _src "*.cpp")
binop_add_executable(${PROJECT_NAME} CONSOLE
    SOURCES ${_src}
    LINKS BinopCore
)