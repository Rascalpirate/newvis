message(STATUS "==============================================================")
message(STATUS "At file: ${CMAKE_CURRENT_LIST_FILE}")
message(STATUS "==============================================================")

message(STATUS "==============================================================")
message(STATUS "1. Settings of cmake & platform")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")
message(STATUS "==============================================================")

cmake_minimum_required(VERSION 3.26.0 FATAL_ERROR)

include(CMakePrintHelpers)

# Compile time
# what about time zone? like "2023-06-14 17:41:12 CST"
string(TIMESTAMP COMPILE_TIME %Y%m%d.%H%M%S) # 20230913_101810
cmake_print_variables(COMPILE_TIME)

cmake_print_variables(WIN32)

if(WIN32)
    # Win10
    add_definitions(-D_WIN32_WINNT=0x0A00)
    add_compile_definitions(WIN32_LEAN_AND_MEAN)
    add_compile_definitions(-DVIS_OS_WINDOWS=WIN32)
endif()

message(STATUS "==============================================================")
message(STATUS "2. Settings of project")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")
message(STATUS "==============================================================")

set(_PROJECT_NAME_ zpp_bits)
set(_PROJECT_VERSION_ 4.5.0)

# git commit hash 528514489a4405b453c479cb6b8b9738388b6596
project(
    ${_PROJECT_NAME_}
    VERSION ${_PROJECT_VERSION_}
    DESCRIPTION "zpp_bits project for serialization"
    LANGUAGES CXX
)

message(STATUS "==============================================================")
message(STATUS "2.1. Settings of version")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")
message(STATUS "==============================================================")

message(STATUS "==============================================================")
message(STATUS "2.2. Settings of PDB")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")
message(STATUS "==============================================================")

set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "ProgramDatabase")
set(PDB_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/pdbs)
file(MAKE_DIRECTORY ${PDB_INSTALL_DIR})

message(STATUS "==============================================================")
message(STATUS "3. Settings of building")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")
message(STATUS "==============================================================")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Set language property
if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
    set(CMAKE_DEBUG_POSTFIX ".dbg")
else()
    unset(CMAKE_DEBUG_POSTFIX)
endif()

cmake_print_variables(CMAKE_DEBUG_POSTFIX)

message(STATUS "==============================================================")
message(STATUS "3.1. Settings of compiler")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")
message(STATUS "==============================================================")

add_library(_compiler_flags INTERFACE)
target_compile_features(_compiler_flags INTERFACE cxx_std_20)

set(gcc_like_cxx "$<COMPILE_LANG_AND_ID:CXX,ARMClang,AppleClang,Clang,GNU,LCC>")
set(msvc_cxx "$<COMPILE_LANG_AND_ID:CXX,MSVC>")
target_compile_options(_compiler_flags INTERFACE
    "$<${gcc_like_cxx}:$<BUILD_INTERFACE:-Wall;-Wextra;-Wshadow;-Wformat=2;
                                       -Wunused;-fPIC;-Werror=uninitialized;
                                       -Werror=return-type>>"
    "$<${msvc_cxx}:$<BUILD_INTERFACE:-W3>>")

message(STATUS "==============================================================")
message(STATUS "3.2. Settings of modules/thirdparty libs")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")
message(STATUS "==============================================================")

message(STATUS "==============================================================")
message(STATUS "4. Build Tree...")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")
message(STATUS "==============================================================")

set(CMAKE_INSTALL_LIBDIR "lib")
set(CMAKE_INSTALL_INCLUDEDIR "include")

add_subdirectory(src)

message(STATUS "==============================================================")
message(STATUS "5. Subdirs")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")
message(STATUS "==============================================================")

message(STATUS "==============================================================")
message(STATUS "6. Install Tree...")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")

# Targets, files, directory, export, cmake, etc.
message(STATUS "==============================================================")

install(TARGETS _compiler_flags
    EXPORT ${PROJECT_NAME}Targets
)

set(PACKAGE__CMAKE_DIR ${CMAKE_INSTALL_LIBDIR}/cmake)

# Install Targets.cmake, including-dir and lib-dir are referencing this file
install(EXPORT ${PROJECT_NAME}Targets
    FILE ${PROJECT_NAME}Targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION ${PACKAGE__CMAKE_DIR}
)

message(STATUS "==============================================================")
message(STATUS "7. Relocatable lib Package")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")
message(STATUS "==============================================================")

# set(PHOENIX_CMAKE_DIR share/cmake)

# Generate library version info which will generate xxxConfigVersion.cmake,
# the ${PACKAGE_VERSION} is the version defined in project()
include(CMakePackageConfigHelpers)

set(PACKAGE_NAME ${PROJECT_NAME})
set(PACKAGE_VERSION ${PROJECT_VERSION}.${COMPILE_TIME})
cmake_print_variables(PACKAGE_VERSION)

# Should dependencies of phoenix be added to Config.cmake
# so that apps that depend on phoenix don't need to explicitly specify them.

# Generate the config file to include the exports
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/${PACKAGE_NAME}Config.cmake.in
    ${PACKAGE_NAME}Config.cmake
    INSTALL_DESTINATION ${PACKAGE__CMAKE_DIR})

# Generate package config version file for the config file
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}ConfigVersion.cmake
    VERSION ${PACKAGE_VERSION}
    COMPATIBILITY SameMajorVersion)

# Install package config version files
install(
    FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}Config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}ConfigVersion.cmake
    DESTINATION ${PACKAGE__CMAKE_DIR})

# # install(RUNTIME_DEPENDENCIES)
message(STATUS "==============================================================")
message(STATUS "8. Testing")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")
message(STATUS "==============================================================")

message(STATUS "==============================================================")
message(STATUS "9. Executable Package")
message(STATUS "At line: ${CMAKE_CURRENT_LIST_LINE}")
message(STATUS "==============================================================")
