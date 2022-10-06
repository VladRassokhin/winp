cmake_minimum_required(VERSION 3.20 FATAL_ERROR)
project(winp)

if (NOT WIN32)
    message(FATAL_ERROR "Windows only.")
endif ()

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
