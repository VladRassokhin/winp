cmake_minimum_required(VERSION 3.20 FATAL_ERROR)
project(winp)

if (NOT WIN32)
    message(FATAL_ERROR "Windows only.")
endif ()

include(CheckSymbolExists)
check_symbol_exists("_M_ARM64" "" TARGET_ARM64)
check_symbol_exists("_M_AMD64" "" TARGET_X64)
check_symbol_exists("_M_IX86" "" TARGET_X86)
if(TARGET_ARM64)
    set(JAVA_HOME $ENV{JDK_11_0_ARM64})
elseif(TARGET_X64)
    set(JAVA_HOME $ENV{JDK_11_0_x64})
elseif(TARGET_X86)
    set(JAVA_HOME $ENV{JDK_11_0})
else()
    message(FATAL_ERROR "Unsupported target (x86=${TARGET_X86}, x64=${TARGET_X64}, arm64=${TARGET_ARM64})")
endif()
if(NOT JAVA_HOME)
    message(FATAL_ERROR "JDK_11_0/JDK_11_0_x64/JDK_11_0_ARM64 variables not defined (x86=${TARGET_X86}, x64=${TARGET_X64}, arm64=${TARGET_ARM64}).")
endif()

include_directories(${JAVA_HOME}/include ${JAVA_HOME}/include/win32)

set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT")

add_library(winp SHARED
        auto_handle.h
        enableDebugPrivilege.cpp
        enumProcess.cpp
        envvar-cmdline.cpp
        java-interface.h
        java-interface.cpp
        runtime.cpp
        stdafx.h
        stdafx.cpp
        winp.h
        winp.cpp
)

target_compile_options(winp PRIVATE "/sdl" "/Oi" "/Ob2" "/FC" "/GL" "/Zi" "/EHsc" "/Gy")
target_link_options(winp PRIVATE "/DEBUG" "/OPT:REF" "/OPT:ICF" "/LTCG:incremental" "/pdbaltpath:%_PDB%")
set_target_properties(winp PROPERTIES
    MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>"
)

add_executable(sendctrlc "sendctrlc/main.cpp")
target_compile_options(sendctrlc PRIVATE "/sdl" "/Oi" "/Ob2" "/FC" "/GL" "/Zi" "/EHsc" "/Gy")
target_link_options(sendctrlc PRIVATE "/DEBUG" "/OPT:REF" "/OPT:ICF" "/LTCG:incremental" "/pdbaltpath:%_PDB%")
set_target_properties(sendctrlc PROPERTIES
    MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>"
)
