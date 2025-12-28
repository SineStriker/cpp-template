#[[
    BuildAPI.cmake

    Include this file to generate build APIs for your current project.

    ----------------------------------------------------------------------------------------------------
    
    Macros/Functions:
         <proj>_init_buildsystem
         <proj>_finish_buildsystem
         <proj>_add_application
         <proj>_add_plugin
         <proj>_add_library
         <proj>_add_executable
         <proj>_add_attached_files
         <proj>_sync_include
         <proj>_install
]] #

include_guard(DIRECTORY)

if(NOT DEFINED BUILD_API_FUNCTION_PREFIX)
    set(BUILD_API_FUNCTION_PREFIX ${PROJECT_NAME})
endif()

if(NOT DEFINED BUILD_API_VARIABLE_PREFIX)
    string(TOUPPER ${BUILD_API_VARIABLE_PREFIX} BUILD_API_VARIABLE_PREFIX)
endif()

# Internal variables
set(_F ${BUILD_API_FUNCTION_PREFIX})
set(_V ${BUILD_API_VARIABLE_PREFIX})

qm_import(Filesystem Preprocess)

#[[
    Initialize BuildAPI global configuration.

    <proj>_init_buildsystem(
        [MACOSX_BUNDLE_NAME <name>]
        [CONSOLE_APPLICATION]
        [WINDOWS_APPLICATION]
        [BUILD_SHARED]
        [BUILD_STATIC]
        [DEVEL]
        [NO_INSTALL]
        [SYNC_INCLUDE_FORCE]
        [EXPORT <name>]
        [INCLUDE_DIR <dir>]
        [INSTALL_NAME <name>]
        [INSTALL_VERSION <version>]
        [INSTALL_NAMESPACE <namespace>]
        [INSTALL_CONFIG_TEMPLATE <path>]
        [CONFIG_HEADER_PATH <path>]
        [BUILD_INFO_HEADER_PATH <path>]
        [BUILD_INFO_HEADER_PREFIX <prefix>]

        [CONFIGURE_TARGET_COMMANDS <commands>...]
    )

    Inherit variables:
        <proj>_BUILD_SHARED: boolean
        <proj>_BUILD_STATIC: boolean
        <proj>_DEVEL: boolean
        <proj>_INSTALL: boolean

    Defined variables:
        <proj>_MACOSX_BUNDLE_NAME: string (nullable)

        <proj>_SOURCE_DIR: string
        <proj>_PLATFORM_NAME: string
        <proj>_PLATFORM_LOWER: string

        <proj>_WINDOWS_APPLICATION: boolean
        <proj>_CONSOLE_APPLICATION: boolean
        <proj>_DEVEL: boolean
        <proj>_INSTALL: boolean
        <proj>_EXPORT: string
        <proj>_INCLUDE_DIR: string (nullable)
        <proj>_INSTALL_NAME: string
        <proj>_INSTALL_VERSION: string
        <proj>_INSTALL_NAMESPACE: string
        <proj>_INSTALL_CONFIG_TEMPLATE: string
        <proj>_CONFIG_HEADER_PATH: string (nullable)
        <proj>_BUILD_INFO_HEADER_PATH: string (nullable)
        <proj>_BUILD_INFO_HEADER_PREFIX: string (nullable)

        <proj>_BUILD_MAIN_DIR: string
        <proj>_BUILD_TEST_RUNTIME_DIR: string
        <proj>_BUILD_TEST_LIBRARY_DIR: string
        <proj>_BUILD_RUNTIME_DIR: string
        <proj>_BUILD_LIBRARY_DIR: string
        <proj>_BUILD_PLUGINS_DIR: string
        <proj>_BUILD_DATA_DIR: string
        <proj>_BUILD_SHARE_DIR: string
        <proj>_BUILD_DOC_DIR: string
        <proj>_BUILD_QML_DIR: string
        <proj>_BUILD_INCLUDE_DIR: string

        <proj>_INSTALL_RUNTIME_DIR: string
        <proj>_INSTALL_LIBRARY_DIR: string
        <proj>_INSTALL_PLUGINS_DIR: string
        <proj>_INSTALL_SHARE_DIR: string
        <proj>_INSTALL_DATA_DIR: string
        <proj>_INSTALL_DOC_DIR: string
        <proj>_INSTALL_QML_DIR: string
        <proj>_INSTALL_INCLUDE_DIR: string
        <proj>_INSTALL_CMAKE_DIR: string

        <proj>_CONFIGURE_TARGET_COMMANDS: list (nullable)

]] #
macro(${_F}_init_buildsystem)
    set(options CONSOLE_APPLICATION WINDOWS_APPLICATION DEVEL NO_INSTALL SYNC_INCLUDE_FORCE)
    set(oneValueArgs MACOSX_BUNDLE_NAME EXPORT INCLUDE_DIR
        INSTALL_NAME INSTALL_VERSION INSTALL_NAMESPACE INSTALL_CONFIG_TEMPLATE
        CONFIG_HEADER_PATH BUILD_INFO_HEADER_PATH BUILD_INFO_HEADER_PREFIX
    )
    set(multiValueArgs CONFIGURE_TARGET_COMMANDS)
    cmake_parse_arguments(FUNC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Set source directory
    set(${_V}_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

    # Check platform, only Windows/Macintosh/Linux is supported
    if(APPLE)
        set(${_V}_PLATFORM_NAME Macintosh)
        set(${_V}_PLATFORM_LOWER mac)
    elseif(WIN32)
        set(${_V}_PLATFORM_NAME Windows)
        set(${_V}_PLATFORM_LOWER win)
    elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
        set(LINUX true CACHE BOOL "Linux System" FORCE)
        set(${_V}_PLATFORM_NAME Linux)
        set(${_V}_PLATFORM_LOWER linux)
    else()
        message(FATAL_ERROR "Unsupported System ${CMAKE_HOST_SYSTEM_NAME}!!!")
    endif()

    # Whether to build Windows/Console application
    if(FUNC_WINDOWS_APPLICATION AND NOT FUNC_CONSOLE_APPLICATION)
        set(${_V}_WINDOWS_APPLICATION on)
        set(${_V}_CONSOLE_APPLICATION off)
    else()
        set(${_V}_WINDOWS_APPLICATION off)
        set(${_V}_CONSOLE_APPLICATION on)
    endif()

    # Whether to build shared libraries
    if(FUNC_BUILD_SHARED OR DEFINED ${_V}_BUILD_SHARED)
        set(${_V}_BUILD_SHARED on)
        set(${_V}_BUILD_STATIC off)
    elseif(FUNC_STATIC OR DEFINED ${_V}_BUILD_STATIC)
        set(${_V}_BUILD_SHARED off)
        set(${_V}_BUILD_STATIC on)
    else()
        # Fallback to default behavior
        if(BUILD_SHARED_LIBS)
            set(${_V}_BUILD_SHARED on)
            set(${_V}_BUILD_STATIC off)
        else()
            set(${_V}_BUILD_SHARED off)
            set(${_V}_BUILD_STATIC on)
        endif()
    endif()

    # Whether to install developer files
    if(FUNC_DEVEL)
        set(${_V}_DEVEL on)
    elseif(NOT DEFINED ${_V}_DEVEL)
        set(${_V}_DEVEL off)
    endif()

    # Whether to install
    if(FUNC_NO_INSTALL)
        set(${_V}_INSTALL off)
    elseif(NOT DEFINED ${_V}_INSTALL)
        set(${_V}_INSTALL on)
    endif()

    if(${_V}_INSTALL)
        include(GNUInstallDirs)
        include(CMakePackageConfigHelpers)
    endif()

    # Whether to force sync include files
    if(FUNC_SYNC_INCLUDE_FORCE)
        set(${_V}_SYNC_INCLUDE_FORCE on)
    else()
        set(${_V}_SYNC_INCLUDE_FORCE off)
    endif()

    # Export targets
    if(FUNC_EXPORT)
        set(${_V}_EXPORT ${FUNC_EXPORT})
    else()
        set(${_V}_EXPORT ${_F}Targets)
    endif()

    # Set include directory
    if(FUNC_INCLUDE_DIR)
        get_filename_component(${_V}_INCLUDE_DIR ${FUNC_INCLUDE_DIR} ABSOLUTE)
    else()
        set(${_V}_INCLUDE_DIR)
    endif()

    # Set install name, version and namespace
    if(FUNC_INSTALL_NAME)
        set(${_V}_INSTALL_NAME ${FUNC_INSTALL_NAME})
    else()
        set(${_V}_INSTALL_NAME ${PROJECT_NAME})
    endif()

    if(FUNC_INSTALL_VERSION)
        set(${_V}_INSTALL_VERSION ${FUNC_INSTALL_VERSION})
    else()
        set(${_V}_INSTALL_VERSION ${PROJECT_VERSION})
    endif()

    if(FUNC_INSTALL_NAMESPACE)
        set(${_V}_INSTALL_NAMESPACE ${FUNC_INSTALL_NAMESPACE})
    else()
        set(${_V}_INSTALL_NAMESPACE ${_V}_INSTALL_NAME)
    endif()

    # Set install config template
    if(FUNC_INSTALL_CONFIG_TEMPLATE)
        set(${_V}_INSTALL_CONFIG_TEMPLATE ${FUNC_INSTALL_CONFIG_TEMPLATE})
    else()
        set(${_V}_INSTALL_CONFIG_TEMPLATE ${CMAKE_CURRENT_LIST_DIR}/${${_V}_INSTALL_NAME}Config.cmake.in)
    endif()

    # Set output directories
    set(${_V}_BUILD_MAIN_DIR ${QMSETUP_BUILD_DIR})

    if(APPLE AND FUNC_MACOSX_BUNDLE_NAME)
        set(${_V}_MACOSX_BUNDLE_NAME ${FUNC_MACOSX_BUNDLE_NAME})
        set(_BUILD_BASE_DIR ${${_V}_BUILD_MAIN_DIR}/${FUNC_MACOSX_BUNDLE_NAME}.app/Contents)

        set(${_V}_BUILD_TEST_RUNTIME_DIR ${${_V}_BUILD_MAIN_DIR}/bin)
        set(${_V}_BUILD_TEST_LIBRARY_DIR ${${_V}_BUILD_MAIN_DIR}/lib)

        set(${_V}_BUILD_RUNTIME_DIR ${_BUILD_BASE_DIR}/MacOS)
        set(${_V}_BUILD_LIBRARY_DIR ${_BUILD_BASE_DIR}/Frameworks)
        set(${_V}_BUILD_PLUGINS_DIR ${_BUILD_BASE_DIR}/Plugins)
        set(${_V}_BUILD_SHARE_DIR ${_BUILD_BASE_DIR}/Resources)
        set(${_V}_BUILD_DATA_DIR ${_BUILD_BASE_DIR}/Resources)
        set(${_V}_BUILD_DOC_DIR ${_BUILD_BASE_DIR}/Resources/doc)
        set(${_V}_BUILD_QML_DIR ${_BUILD_BASE_DIR}/Resources/qml)
        set(${_V}_BUILD_INCLUDE_DIR ${_INSTALL_BASE_DIR}/Resources/include)

        set(_INSTALL_BASE_DIR ${FUNC_MACOSX_BUNDLE_NAME}.app/Contents)
        set(${_V}_INSTALL_RUNTIME_DIR ${_INSTALL_BASE_DIR}/MacOS)
        set(${_V}_INSTALL_LIBRARY_DIR ${_INSTALL_BASE_DIR}/Frameworks)
        set(${_V}_INSTALL_PLUGINS_DIR ${_INSTALL_BASE_DIR}/Plugins)
        set(${_V}_INSTALL_SHARE_DIR ${_INSTALL_BASE_DIR}/Resources)
        set(${_V}_INSTALL_DATA_DIR ${_INSTALL_BASE_DIR}/Resources)
        set(${_V}_INSTALL_DOC_DIR ${_INSTALL_BASE_DIR}/Resources/doc)
        set(${_V}_INSTALL_QML_DIR ${_INSTALL_BASE_DIR}/Resources/qml)
        set(${_V}_INSTALL_INCLUDE_DIR ${_INSTALL_BASE_DIR}/Resources/include)
        set(${_V}_INSTALL_CMAKE_DIR ${_INSTALL_BASE_DIR}/Resources/lib/cmake/${${_V}_INSTALL_NAME})
    else()
        set(${_V}_MACOSX_BUNDLE_NAME)
        set(_BUILD_BASE_DIR ${${_V}_BUILD_MAIN_DIR})

        set(${_V}_BUILD_TEST_RUNTIME_DIR ${_BUILD_BASE_DIR}/bin)
        set(${_V}_BUILD_TEST_LIBRARY_DIR ${_BUILD_BASE_DIR}/lib)

        set(${_V}_BUILD_RUNTIME_DIR ${_BUILD_BASE_DIR}/bin)
        set(${_V}_BUILD_LIBRARY_DIR ${_BUILD_BASE_DIR}/lib)
        set(${_V}_BUILD_PLUGINS_DIR ${_BUILD_BASE_DIR}/lib/${${_V}_INSTALL_NAME}/plugins)
        set(${_V}_BUILD_SHARE_DIR ${_BUILD_BASE_DIR}/share)
        set(${_V}_BUILD_DATA_DIR ${_BUILD_BASE_DIR}/share/${${_V}_INSTALL_NAME})
        set(${_V}_BUILD_DOC_DIR ${_BUILD_BASE_DIR}/share/doc/${${_V}_INSTALL_NAME})
        set(${_V}_BUILD_QML_DIR ${_BUILD_BASE_DIR}/qml)
        set(${_V}_BUILD_INCLUDE_DIR ${_BUILD_BASE_DIR}/include)

        set(${_V}_INSTALL_RUNTIME_DIR bin)
        set(${_V}_INSTALL_LIBRARY_DIR lib)
        set(${_V}_INSTALL_PLUGINS_DIR lib/${${_V}_INSTALL_NAME}/plugins)
        set(${_V}_INSTALL_SHARE_DIR share)
        set(${_V}_INSTALL_DATA_DIR share/${${_V}_INSTALL_NAME})
        set(${_V}_INSTALL_DOC_DIR share/doc/${${_V}_INSTALL_NAME})
        set(${_V}_INSTALL_QML_DIR qml)
        set(${_V}_INSTALL_INCLUDE_DIR include)
        set(${_V}_INSTALL_CMAKE_DIR lib/cmake/${${_V}_INSTALL_NAME})
    endif()

    if(FUNC_CONFIG_HEADER_PATH)
        # Set definition configuration
        set(QMSETUP_DEFINITION_SCOPE DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

        set(${_V}_CONFIG_HEADER_PATH ${FUNC_CONFIG_HEADER_PATH})
    endif()

    if(FUNC_BUILD_INFO_HEADER_PATH)
        set(${_V}_BUILD_INFO_HEADER_PATH ${FUNC_BUILD_INFO_HEADER_PATH})

        if(FUNC_BUILD_INFO_HEADER_PREFIX)
            set(${_V}_BUILD_INFO_HEADER_PREFIX ${FUNC_BUILD_INFO_HEADER_PREFIX})
        else()
            set(${_V}_BUILD_INFO_HEADER_PREFIX ${_V})
        endif()
    endif()

    # Set configure target commands
    if(FUNC_CONFIGURE_TARGET_COMMANDS)
        set(${_V}_CONFIGURE_TARGET_COMMANDS ${FUNC_CONFIGURE_TARGET_COMMANDS})
    else()
        set(${_V}_CONFIGURE_TARGET_COMMANDS)
    endif()
endmacro()

#[[
    Finish BuildAPI global configuration.

    <proj>_finish_buildsystem()
#]]
macro(${_F}_finish_buildsystem)
    if(${_V}_CONFIG_HEADER_PATH)
        set(_priv_config_file ${${_V}_BUILD_INCLUDE_DIR}/${${_V}_CONFIG_HEADER_PATH})
        qm_generate_config(${_priv_config_file})

        if(${_V}_INSTALL AND ${_V}_DEVEL)
            if(EXISTS ${_priv_config_file})
                get_filename_component(_dest ${${_V}_INSTALL_INCLUDE_DIR}/${${_V}_CONFIG_HEADER_PATH} DIRECTORY)
                install(FILES ${_priv_config_file} DESTINATION ${_dest})
            endif()
        endif()
    endif()

    if(${_V}_BUILD_INFO_HEADER_PATH)
        set(_priv_build_info_file ${${_V}_BUILD_INCLUDE_DIR}/${${_V}_BUILD_INFO_HEADER_PATH})
        qm_generate_build_info(${_priv_build_info_file} YEAR TIME PREFIX ${${_V}_BUILD_INFO_HEADER_PREFIX})

        if(${_V}_INSTALL AND ${_V}_DEVEL)
            if(EXISTS ${_priv_build_info_file})
                get_filename_component(_dest ${${_V}_INSTALL_INCLUDE_DIR}/${${_V}_BUILD_INFO_HEADER_PATH} DIRECTORY)
                install(FILES ${_priv_build_info_file} DESTINATION ${_dest})
            endif()
        endif()
    endif()
endmacro()

#[[
    Add application target.

    <proj>_add_application(<target>
        [QT_AUTOGEN]
        [NO_EXPORT]
        [NO_INSTALL]
    )
]] #
function(${_F}_add_application _target)
    set(options NO_EXPORT NO_INSTALL)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(FUNC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _priv_add_executable_internal(${_target} ${FUNC_UNPARSED_ARGUMENTS})

    # Set target properties and build output directories
    if(${_V}_MACOSX_BUNDLE_NAME)
        set_target_properties(${_target} PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${${_V}_BUILD_MAIN_DIR}
        )
    else()
        if(WIN32)
            if(NOT ${_V}_CONSOLE_APPLICATION)
                set_target_properties(${_target} PROPERTIES
                    WIN32_EXECUTABLE TRUE
                )
            endif()
        endif()

        set_target_properties(${_target} PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${${_V}_BUILD_RUNTIME_DIR}
        )
    endif()

    # Install target
    if(NOT FUNC_NO_INSTALL AND ${_V}_INSTALL)
        if(FUNC_NO_EXPORT OR NOT ${_V}_DEVEL)
            set(_export)
        else()
            set(_export EXPORT ${${_V}_EXPORT})
        endif()

        if(${_V}_MACOSX_BUNDLE_NAME)
            install(TARGETS ${_target}
                ${_export}
                DESTINATION . OPTIONAL
                PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ
            )
        else()
            install(TARGETS ${_target}
                ${_export}
                DESTINATION ${${_V}_INSTALL_RUNTIME_DIR} OPTIONAL
                PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ
            )
        endif()
    endif()
endfunction()

#[[
    Add an application plugin.

    <proj>_add_plugin(<target>
        [CATEGORY category]
        [QT_AUTOGEN]
        [NO_EXPORT]
        [NO_INSTALL_ARCHIVE]
        [NO_INSTALL]
    )
]] #
function(${_F}_add_plugin _target)
    set(options NO_EXPORT NO_INSTALL_ARCHIVE NO_INSTALL)
    set(oneValueArgs CATEGORY)
    set(multiValueArgs)
    cmake_parse_arguments(FUNC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _priv_add_library_internal(${_target} SHARED ${FUNC_UNPARSED_ARGUMENTS})

    if(NOT FUNC_CATEGORY)
        set(_category ${_target})
    else()
        set(_category ${FUNC_CATEGORY})
    endif()

    set(_build_output_dir ${${_V}_BUILD_PLUGINS_DIR}/${_category})
    set(_install_output_dir ${${_V}_INSTALL_PLUGINS_DIR}/${_category})

    # Set output directories
    set_target_properties(${_target} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${_build_output_dir}
        LIBRARY_OUTPUT_DIRECTORY ${_build_output_dir}
        ARCHIVE_OUTPUT_DIRECTORY ${_build_output_dir}
    )

    # Install target
    if(NOT FUNC_NO_INSTALL AND ${_V}_INSTALL)
        if(FUNC_NO_EXPORT OR NOT ${_V}_DEVEL)
            set(_export)
        else()
            set(_export EXPORT ${${_V}_EXPORT})
        endif()

        if(${_V}_DEVEL AND NOT FUNC_NO_INSTALL_ARCHIVE)
            install(TARGETS ${_target}
                ${_export}
                RUNTIME DESTINATION ${_install_output_dir}
                PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ
                LIBRARY DESTINATION ${_install_output_dir}
                PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ
                ARCHIVE DESTINATION ${_install_output_dir}
            )
        else()
            install(TARGETS ${_target}
                ${_export}
                RUNTIME DESTINATION ${_install_output_dir}
                PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ
                LIBRARY DESTINATION ${_install_output_dir}
                PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ
            )
        endif()
    endif()
endfunction()

#[[
    Add a library, default to static library.

    <proj>_add_library(<target>
        [STATIC | SHARED | INTERFACE]
        [MACRO_PREFIX <prefix>] [LIBRARY_MACRO <macro>] [STATIC_MACRO <macro>]
        [TEST]
        [QT_AUTOGEN]
        [NO_EXPORT]
        [NO_INSTALL]
    )
]] #
function(${_F}_add_library _target)
    set(options TEST NO_EXPORT NO_INSTALL)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(FUNC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Add library target and attach definitions
    _priv_add_library_internal(${_target} ${FUNC_UNPARSED_ARGUMENTS})

    # Set output directories
    if(FUNC_TEST)
        set_target_properties(${_target} PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${${_V}_BUILD_TEST_RUNTIME_DIR}
            LIBRARY_OUTPUT_DIRECTORY ${${_V}_BUILD_TEST_LIBRARY_DIR}
            ARCHIVE_OUTPUT_DIRECTORY ${${_V}_BUILD_TEST_LIBRARY_DIR}
        )
    else()
        set_target_properties(${_target} PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${${_V}_BUILD_RUNTIME_DIR}
            LIBRARY_OUTPUT_DIRECTORY ${${_V}_BUILD_LIBRARY_DIR}
            ARCHIVE_OUTPUT_DIRECTORY ${${_V}_BUILD_LIBRARY_DIR}
        )
    endif()

    # Install target
    if(NOT FUNC_TEST AND NOT FUNC_NO_INSTALL AND ${_V}_INSTALL)
        if(FUNC_NO_EXPORT OR NOT ${_V}_DEVEL)
            set(_export)
        else()
            set(_export EXPORT ${${_V}_EXPORT})
        endif()

        if(${_V}_DEVEL)
            install(TARGETS ${_target}
                ${_export}
                RUNTIME DESTINATION ${${_V}_INSTALL_RUNTIME_DIR}
                PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ
                LIBRARY DESTINATION ${${_V}_INSTALL_LIBRARY_DIR}
                PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ
                ARCHIVE DESTINATION ${${_V}_INSTALL_LIBRARY_DIR}
            )
        else()
            install(TARGETS ${_target}
                ${_export}
                RUNTIME DESTINATION ${${_V}_INSTALL_RUNTIME_DIR}
                PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ
                LIBRARY DESTINATION ${${_V}_INSTALL_LIBRARY_DIR}
                PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ
            )
        endif()
    endif()
endfunction()

#[[
    Add executable target.

    <proj>_add_executable(<target>
        [TEST]
        [QT_AUTOGEN]
        [CONSOLE] [WINDOWS]
        [NO_EXPORT]
        [NO_INSTALL]
    )
]] #
function(${_F}_add_executable _target)
    set(options TEST QT_AUTOGEN NO_EXPORT NO_INSTALL CONSOLE WINDOWS)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(FUNC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _priv_add_executable_internal(${_target} ${FUNC_UNPARSED_ARGUMENTS})

    if(WIN32 AND NOT FUNC_CONSOLE)
        if(FUNC_WINDOWS OR ${_V}_WINDOWS_APPLICATION)
            set_target_properties(${_target} PROPERTIES WIN32_EXECUTABLE TRUE)
        endif()
    endif()

    if(FUNC_TEST)
        set_target_properties(${_target} PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${${_V}_BUILD_TEST_RUNTIME_DIR}
        )
    else()
        set_target_properties(${_target} PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${${_V}_BUILD_RUNTIME_DIR}
        )
    endif()

    # Install target
    if(NOT FUNC_TEST AND NOT FUNC_NO_INSTALL AND ${_V}_INSTALL)
        if(FUNC_NO_EXPORT OR NOT ${_V}_DEVEL)
            set(_export)
        else()
            set(_export EXPORT ${${_V}_EXPORT})
        endif()

        install(TARGETS ${_target}
            ${_export}
            DESTINATION ${${_V}_INSTALL_RUNTIME_DIR} OPTIONAL
        )
    endif()
endfunction()

#[[
    Add a resources copying command after building a given target.

    <proj>_add_attached_files(<target>
        [NO_BUILD] [NO_INSTALL] [VERBOSE]

        SRC <files1...> DEST <dir1>
        SRC <files2...> DEST <dir2> ...
    )
    
    SRC: source files or directories, use "*" to collect all items in directory
    DEST: destination directory, can be a generator expression
]] #
function(${_F}_add_attached_files _target)
    set(options NO_BUILD NO_INSTALL VERBOSE)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(FUNC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(_error)
    set(_result)
    _priv_parse_copy_args("${FUNC_UNPARSED_ARGUMENTS}" _result _error)

    if(_error)
        message(FATAL_ERROR "${_F}_add_attached_files: ${_error}")
    endif()

    set(_options)

    if(FUNC_NO_BUILD)
        list(APPEND _options SKIP_BUILD)
    endif()

    if(FUNC_NO_INSTALL OR NOT ${_V}_INSTALL)
        list(APPEND _options SKIP_INSTALL)
    else()
        list(APPEND _options INSTALL_DIR .)
    endif()

    if(FUNC_VERBOSE)
        list(APPEND _options VERBOSE)
    endif()

    foreach(_src IN LISTS _result)
        list(POP_BACK _src _dest)

        qm_add_copy_command(${_target}
            SOURCES ${_src}
            DESTINATION ${_dest}
            ${_options}
        )
    endforeach()
endfunction()

#[[
    Sync include files for library or plugin target.

    <proj>_sync_include(<target>
        [DIRECTORY <dir>]
        [PREFIX <prefix>]
        [OPTIONS <options...>]
        [NO_INSTALL]
    )
]] #
function(${_F}_sync_include _target)
    set(options NO_INSTALL)
    set(oneValueArgs DIRECTORY PREFIX)
    set(multiValueArgs OPTIONS)
    cmake_parse_arguments(FUNC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(_inc_name)
    qm_set_value(_inc_name FUNC_PREFIX ${_target})

    set(_dir)
    qm_set_value(_dir FUNC_DIRECTORY .)

    set(_sync_options)

    if(${_V}_INSTALL AND ${_V}_DEVEL AND NOT FUNC_NO_INSTALL)
        set(_sync_options
            INSTALL_DIR "${${_V}_INSTALL_INCLUDE_DIR}/${_inc_name}"
        )
    endif()

    if(${_V}_SYNC_INCLUDE_FORCE)
        list(APPEND _sync_options FORCE)
    endif()

    # Generate a standard include directory in build directory
    qm_sync_include(${_dir} "${${_V}_BUILD_INCLUDE_DIR}/${_inc_name}" ${_sync_options}
        ${FUNC_OPTIONS}
    )
endfunction()

#[[
    Install targets, CMake configuration files and include files.

    <proj>_install(
        [NO_EXPORT]
        [NO_INCLUDE]
    )
]] #
function(${_F}_install)
    set(options NO_EXPORT NO_INCLUDE)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(FUNC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(${_V}_INSTALL AND ${_V}_DEVEL)
        if(NOT FUNC_NO_EXPORT)
            qm_basic_install(
                NAME ${${_V}_INSTALL_NAME}
                VERSION ${${_V}_INSTALL_VERSION}
                INSTALL_DIR ${${_V}_INSTALL_CMAKE_DIR}
                CONFIG_TEMPLATE ${${_V}_INSTALL_CONFIG_TEMPLATE}
                NAMESPACE ${${_V}_INSTALL_NAMESPACE}::
                EXPORT ${${_V}_EXPORT}
                WRITE_CONFIG_OPTIONS NO_CHECK_REQUIRED_COMPONENTS_MACRO
            )
        endif()

        if(NOT FUNC_NO_INCLUDE AND ${_V}_INCLUDE_DIR)
            install(DIRECTORY ${${_V}_INCLUDE_DIR}/
                DESTINATION ${${_V}_INSTALL_INCLUDE_DIR}
                FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.hxx"
            )
        endif()
    endif()
endfunction()

# ----------------------------------
# BuildAPI Internal Functions
# ----------------------------------
macro(_priv_set_cmake_qt_autogen _val)
    set(CMAKE_AUTOMOC ${_val})
    set(CMAKE_AUTOUIC ${_val})
    set(CMAKE_AUTORCC ${_val})
endmacro()

#[[
    Configure a target with include directories.

    _priv_configure_target_internal(<target>)

    Required variables:
        FUNC_NO_INSTALL (nullable)
]] #
macro(_priv_configure_target_internal _target)
    if(${_V}_INCLUDE_DIR)
        target_include_directories(${_target} PUBLIC
            $<BUILD_INTERFACE:${${_V}_INCLUDE_DIR}>
        )
    endif()

    target_include_directories(${_target} PUBLIC
        $<BUILD_INTERFACE:${${_V}_BUILD_INCLUDE_DIR}>
    )

    if(${_V}_CONFIGURE_TARGET_COMMANDS)
        foreach(_cmd IN LISTS ${_V}_CONFIGURE_TARGET_COMMANDS)
            cmake_language(CALL ${_cmd} ${_target})
        endforeach()
    endif()

    if(${_V}_INSTALL AND ${_V}_DEVEL AND NOT FUNC_NO_INSTALL)
        target_include_directories(${_target} PUBLIC
            $<INSTALL_INTERFACE:${${_V}_INSTALL_INCLUDE_DIR}>
        )
    endif()
endmacro()

#[[
    Add an executable target.

    _priv_add_executable_internal(<target>
        [QT_AUTOGEN]
    )
]] #
macro(_priv_add_executable_internal _target)
    set(options QT_AUTOGEN)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(FUNC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(FUNC_QT_AUTOGEN)
        _priv_set_cmake_qt_autogen()
    endif()

    add_executable(${_target})
    _priv_configure_target_internal(${_target})
    qm_configure_target(${_target} ${FUNC_UNPARSED_ARGUMENTS})
endmacro()

#[[
    Add a library target.

    _priv_add_library_internal(<target>
        [STATIC] [SHARED] [INTERFACE]
        [QT_AUTOGEN]
        [MACRO_PREFIX <prefix>]
        [LIBRARY_MACRO <name>]
        [STATIC_MACRO <name>]
    )
]] #
function(_priv_add_library_internal _target)
    set(options STATIC SHARED INTERFACE QT_AUTOGEN)
    set(oneValueArgs MACRO_PREFIX LIBRARY_MACRO STATIC_MACRO)
    set(multiValueArgs)
    cmake_parse_arguments(FUNC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(FUNC_QT_AUTOGEN)
        _priv_set_cmake_qt_autogen()
    endif()

    set(_options)

    if(FUNC_MACRO_PREFIX)
        set(_prefix ${FUNC_MACRO_PREFIX})
    else()
        string(TOUPPER ${_target} _prefix)
    endif()

    list(APPEND _options PREFIX ${_prefix})

    if(FUNC_LIBRARY_MACRO)
        list(APPEND _options LIBRARY ${FUNC_LIBRARY_MACRO})
    endif()

    if(FUNC_STATIC_MACRO)
        list(APPEND _options STATIC ${FUNC_STATIC_MACRO})
    endif()

    set(_scope PUBLIC)
    set(_interface off)

    if(FUNC_SHARED)
        add_library(${_target} SHARED)
    elseif(FUNC_INTERFACE)
        set(_scope INTERFACE)
        set(_interface on)
        add_library(${_target} INTERFACE)
    elseif(FUNC_STATIC)
        add_library(${_target} STATIC)
    else()
        # Fallback to default behavior
        if(${_V}_BUILD_SHARED)
            add_library(${_target} SHARED)
        else()
            add_library(${_target} STATIC)
        endif()
    endif()

    if(NOT _interface)
        qm_export_defines(${_target} ${_options})
    endif()

    _priv_configure_target_internal(${_target})
    qm_configure_target(${_target} ${FUNC_UNPARSED_ARGUMENTS})
endfunction()

#[[
    _priv_parse_copy_args(<args> <RESULT> <ERROR>)

    args:   SRC <files...> DEST <dir1>
            SRC <files...> DEST <dir2> ...
]] #
function(_priv_parse_copy_args _args _result _error)
    # State Machine
    set(_src)
    set(_dest)
    set(_status NONE) # NONE, SRC, DEST
    set(_count 0)

    set(_list)

    foreach(_item IN LISTS _args)
        if(${_item} STREQUAL SRC)
            if(${_status} STREQUAL NONE)
                set(_src)
                set(_status SRC)
            elseif(${_status} STREQUAL DEST)
                set(${_error} "missing directory name after DEST!" PARENT_SCOPE)
                return()
            else()
                set(${_error} "missing source files after SRC!" PARENT_SCOPE)
                return()
            endif()
        elseif(${_item} STREQUAL DEST)
            if(${_status} STREQUAL SRC)
                set(_status DEST)
            elseif(${_status} STREQUAL DEST)
                set(${_error} "missing directory name after DEST!" PARENT_SCOPE)
                return()
            else()
                set(${_error} "no source files specified for DEST!" PARENT_SCOPE)
                return()
            endif()
        else()
            if(${_status} STREQUAL NONE)
                set(${_error} "missing SRC or DEST token!" PARENT_SCOPE)
                return()
            elseif(${_status} STREQUAL DEST)
                if(NOT _src)
                    set(${_error} "no source files specified for DEST!" PARENT_SCOPE)
                    return()
                endif()

                set(_status NONE)
                math(EXPR _count "${_count} + 1")

                string(JOIN "\\;" _src_str ${_src})
                list(APPEND _list "${_src_str}\\;${_item}")
            else()
                set(_slash off)

                if(${_item} MATCHES "(.+)/\\**$")
                    set(_slash on)
                    set(_item ${CMAKE_MATCH_1})
                endif()

                get_filename_component(_path ${_item} ABSOLUTE)

                if(_slash)
                    set(_path "${_path}/")
                endif()

                list(APPEND _src ${_path})
            endif()
        endif()
    endforeach()

    if(${_status} STREQUAL SRC)
        set(${_error} "missing DEST after source files!" PARENT_SCOPE)
        return()
    elseif(${_status} STREQUAL DEST)
        set(${_error} "missing directory name after DEST!" PARENT_SCOPE)
        return()
    elseif(${_count} STREQUAL 0)
        set(${_error} "no files specified!" PARENT_SCOPE)
        return()
    endif()

    set(${_result} "${_list}" PARENT_SCOPE)
endfunction()