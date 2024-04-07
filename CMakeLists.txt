cmake_minimum_required(VERSION 3.15)
project(effortless-hsdis)

# Here is the catch: if the cmake is installed via Intel version of Homebrew, then CMake will consider itself running on x86
# I want users to avoid going through the painstaking process of figuring that out and workaround it here
# See also: https://stackoverflow.com/questions/76057246/why-does-cmake-insist-that-the-processor-used-is-x86-64-when-it-is-actually-arm6
EXECUTE_PROCESS(COMMAND uname -a OUTPUT_VARIABLE TMP_UNAME)
if ("${TMP_UNAME}" MATCHES "Darwin" AND "${TMP_UNAME}" MATCHES "ARM64")
    set(HSDIS_ARCH ARM64)
    # If there will be any issues, replace it with arm64;x86_64 and call it a day
    set(CMAKE_OSX_ARCHITECTURES arm64)
else()
    set(HSDIS_ARCH ${CMAKE_SYSTEM_PROCESSOR})
endif()

# See capstone CMake in order to figure out the configuration flags
if(${HSDIS_ARCH} MATCHES ARM64 OR ${HSDIS_ARCH} MATCHES aarch64)
    set(CAPSTONE_ARM64_SUPPORT ON)
    set(HSDIS_CAPSTONE_ARCH CS_ARCH_ARM64)
    set(HSDIS_CAPSTONE_MODE CS_MODE_ARM)
    set(HSDIS_LIB_SUFFIX aarch64)
elseif(${HSDIS_ARCH} STREQUAL X64)
    set(CAPSTONE_X86_SUPPORT ON)
    set(HSDIS_CAPSTONE_ARCH CS_ARCH_X86)
    set(HSDIS_CAPSTONE_MODE CS_MODE_64)
    set(HSDIS_LIB_SUFFIX amd64)
else()
    message(FATAL_ERROR "Unsupported architecture: ${HSDIS_ARCH}")
endif()

# https://github.com/libcapstone/libcapstone/blob/main/CMakeLists.txt#L30C8-L30C37 maybe reconsider
set(CAPSTONE_ARCHITECTURE_DEFAULT OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

### Configure revisions
set(HSDIS_JDK_REF 890adb6410dab4606a4f26a942aed02fb2f55387
        CACHE STRING "hsdis git ref. Current: openjdk/jdk21, LTS, 2023-09-19")
set(HSDIS_CAPSTONE_REF 097c04d9413c59a58b00d4d1c8d5dc0ac158ffaa
        CACHE STRING "Capstone git ref. Current: version 5.0.1, capstone-engine/capstone")

# Capstone build
include(FetchContent)
FetchContent_Declare(
        capstone
        GIT_REPOSITORY https://github.com/capstone-engine/capstone    GIT_TAG ${HSDIS_CAPSTONE_REF})
FetchContent_MakeAvailable(capstone)

# Kudos to https://jornvernee.github.io/hsdis/2022/04/30/hsdis.html for this patch

# Download OpenJDK hsdis
set(HSDIS_SOURCE_ROOT_URL
        https://raw.githubusercontent.com/openjdk/jdk/${HSDIS_JDK_REF}/src/utils/hsdis)
file(DOWNLOAD
        ${HSDIS_SOURCE_ROOT_URL}/capstone/hsdis-capstone.c
        ${CMAKE_SOURCE_DIR}/src/hsdis-capstone.c)
file(DOWNLOAD
        ${HSDIS_SOURCE_ROOT_URL}/hsdis.h
        ${CMAKE_SOURCE_DIR}/src/hsdis.h)

# Patch captstone include to point to local copy
file(READ src/hsdis-capstone.c FILE_CONTENTS)
string(REPLACE "#include <capstone.h>" "#include <capstone/capstone.h>"
        FILE_CONTENTS "${FILE_CONTENTS}")
file(WRITE src/hsdis-capstone.c "${FILE_CONTENTS}")

# Add hsdis shared library target
add_library(hsdis SHARED src/hsdis-capstone.c)

# Configure target
target_link_libraries(hsdis PRIVATE capstone::capstone)
target_include_directories(hsdis PUBLIC src)
target_compile_definitions(hsdis
        PRIVATE
        CAPSTONE_ARCH=${HSDIS_CAPSTONE_ARCH}
        CAPSTONE_MODE=${HSDIS_CAPSTONE_MODE})
set_target_properties(hsdis
        PROPERTIES
        OUTPUT_NAME hsdis-${HSDIS_LIB_SUFFIX}
        PREFIX "")

install(TARGETS hsdis)

add_custom_command(TARGET hsdis POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --green --bold "Path to hsdis: $<TARGET_FILE:hsdis>")

# The grand comedy begins: cmake **differently** expands generator-expressions, meaining that
# COMMENT properly works on OS X, but not on Linux, rendering the hint useless.
# 'echo' either expands too much or escapes every freaking whitespace, not making this easier.
# So the only reasonable option left is to use CMake script and color the hint manually.
add_custom_command(TARGET hsdis POST_BUILD
        COMMAND ${CMAKE_COMMAND} -D DIR=$<TARGET_FILE_DIR:hsdis> -D FILE=$<TARGET_FILE:hsdis> -P ${CMAKE_CURRENT_SOURCE_DIR}/Hint.cmake)
