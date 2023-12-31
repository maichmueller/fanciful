cmake_minimum_required(VERSION 3.12)

project(fancy_cmake_build
        LANGUAGES CXX
        VERSION 0.1
        HOMEPAGE_URL "https://github.com/maichmueller/fanciful"
        DESCRIPTION "A simple CMake based example library with Conan usage.")

if (DEFINED ENV{CONDA_PREFIX})
    message(STATUS "Building in a conda environment.")
    set(CONDA_ACTIVE TRUE)
    execute_process(
            COMMAND bash -c "conda info | grep 'active env location' | cut -d':' -f 2 | xargs"
            OUTPUT_VARIABLE CONDA_ACTIVE_ENV_PREFIX
            OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    message(STATUS "Conda Active Environment: ${CONDA_ACTIVE_ENV_PREFIX}")
    set(CMAKE_INSTALL_PREFIX "${CONDA_ACTIVE_ENV}")
    list(INSERT CMAKE_PREFIX_PATH 0 "${CONDA_ACTIVE_ENV_PREFIX}")
    list(INSERT CMAKE_INCLUDE_PATH 0 "${CONDA_ACTIVE_ENV_PREFIX}/include")
    #include_directories($ENV{CONDA_PREFIX}/include)
    list(INSERT CMAKE_LIBRARY_PATH 0 "${CONDA_ACTIVE_ENV_PREFIX}/lib")
endif ()

set(PROJECT_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(PROJECT_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")

#
# Add our project's cmake dir the the module path. This gives us the
# Cppyy commands and targets.
#
message("EFFECTIVE CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")
message("EFFECTIVE CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}")
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_SOURCE_DIR}/cmake)
find_package(Cppyy)

#
# Make the default build us c++20 and "RELEASE" (-O3)
#
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif (NOT CMAKE_BUILD_TYPE)

include(GNUInstallDirs)

find_package(fmt REQUIRED)

add_library(
        fancy_shared
        SHARED
        ${PROJECT_SRC_DIR}/libfancy/impl/formatter.cpp
)
set_target_properties(
        fancy_shared
        PROPERTIES
        LINKER_LANGUAGE CXX
)
target_include_directories(
        fancy_shared
        PUBLIC
        ${PROJECT_SRC_DIR}/libfancy/include
)
target_link_libraries(
        fancy_shared
        PUBLIC
        fmt::fmt
)


include(cmake/utilities.cmake)

#
# Set up the Cppyy bindings generation. This is a customized version defined
# in boink's cmake/ dir; it uses genreflex rather than calling rootcling directly.
# I did this because I couldn't get rootcling to properly include/exclude classes
# via the LinkDef header, and I wanted to be able to use the better syntax in
# the genreflex selection XML anyhow. Also, I think this is now the recommended /
# more modern way anyhow? Code was modified from the versions cppyy distributes.
#
set(
        BINDING_HEADERS
        formatter.hpp
        fancy.hpp
)
list(TRANSFORM BINDING_HEADERS PREPEND "${PROJECT_SRC_DIR}/libfancy/include/fancy/")
message("Binding headers are: ${BINDING_HEADERS}")
cppyy_add_bindings(
        "fancy" "${PROJECT_VERSION}" "Michael Aichmueller" "m.aichmueller@gmail.com"
        LICENSE "MIT"
        LANGUAGE_STANDARD "20"
        SELECTION_XML ${CMAKE_SOURCE_DIR}/py/selection.xml
        INTERFACE_FILE ${CMAKE_SOURCE_DIR}/py/interface.hpp
        HEADERS ${BINDING_HEADERS}
        INCLUDE_DIRS $<TARGET_PROPERTY:fancy_shared,INTERFACE_INCLUDE_DIRECTORIES>
        LINK_LIBRARIES fancy_shared fmt::fmt
        NAMESPACES fancy
        README_FILE README.md
)

print_target_properties(fancy_shared)
print_target_properties(fmt::fmt)
print_target_properties(fancyCppyy)

install(TARGETS fancy_shared
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/fancy
)

install(CODE "execute_process(COMMAND pip install ${PY_WHEEL_FILE})")
