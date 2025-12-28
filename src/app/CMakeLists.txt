project(Binop)

file(GLOB_RECURSE _src "*.cpp")
binop_add_application(${PROJECT_NAME}
    SOURCES ${_src}
    LINKS BinopCore
)

if(WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE BinopWinMain)
endif()