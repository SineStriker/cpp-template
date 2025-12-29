cmake_minimum_required(VERSION 3.19)

project(binop
    VERSION 0.0.1.0
    LANGUAGES CXX
    DESCRIPTION "This is a C++ project"
    HOMEPAGE_URL "https://foo.bar"
)

# ----------------------------------
# Project Options
# ----------------------------------
option(BINOP_BUILD_SHARED "Build shared libraries" ON)
option(BINOP_BUILD_TESTS "Build test cases" OFF)
option(BINOP_DEVEL "Install developer files" ON)
option(BINOP_INSTALL "Install library" ON)

# ----------------------------------
# Global CMake Settings
# ----------------------------------
if(MSVC)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /manifest:no")
    set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /manifest:no")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /manifest:no")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /utf-8")
elseif(MINGW)
    set(CMAKE_STATIC_LIBRARY_PREFIX "")
    set(CMAKE_SHARED_LIBRARY_PREFIX "")
endif()

# ----------------------------------
# Project Variables
# ----------------------------------
set(BINOP_VERSION ${PROJECT_VERSION})
set(BINOP_DESCRIPTION ${PROJECT_DESCRIPTION})
set(BINOP_HOMEPAGE_URL ${PROJECT_HOMEPAGE_URL})
set(BINOP_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# ----------------------------------
# Add external modules
# ----------------------------------
add_subdirectory(external)

# ----------------------------------
# Initialize QMSetup (Required)
# ----------------------------------
find_package(qmsetup REQUIRED)

qm_import(Filesystem)

if(NOT DEFINED QMSETUP_BUILD_DIR)
    set(QMSETUP_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/out")
endif()

qm_init_directories()

# ----------------------------------
# Add source modules
# ----------------------------------
add_subdirectory(src)

add_subdirectory(dist)