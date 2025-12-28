add_subdirectory(Core)

add_subdirectory(Gui)

if (WIN32)
    add_subdirectory(WinMain)
endif()