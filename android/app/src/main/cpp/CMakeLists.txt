cmake_minimum_required(VERSION 3.18)
project(noxira_audio LANGUAGES C CXX)

# Noxira audio analysis engine. Built for Android by Gradle
# (externalNativeBuild) and on a host for unit tests / Dart FFI tests:
#
#   cmake -S android/app/src/main/cpp -B build/noxira_host -DNOXIRA_BUILD_TESTS=ON
#   cmake --build build/noxira_host && ctest --test-dir build/noxira_host

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

option(NOXIRA_BUILD_TESTS "Build the host unit tests" OFF)

set(NOXIRA_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/noxira_audio)
set(KISS_DIR ${NOXIRA_ROOT}/third_party/kissfft)

# The DSP is the hot path: optimise it even in debug builds.
set(NOXIRA_OPT_FLAGS -O2)

# An object library: no archive step, so the build only needs the compiler.
add_library(noxira_dsp OBJECT
  ${NOXIRA_ROOT}/src/dsp/analysis_pipeline.cpp
  ${NOXIRA_ROOT}/src/dsp/band_mapper.cpp
  ${NOXIRA_ROOT}/src/dsp/pcm_convert.cpp
  ${NOXIRA_ROOT}/src/dsp/real_fft.cpp
  ${NOXIRA_ROOT}/src/dsp/visualizer_spectrum.cpp
  ${NOXIRA_ROOT}/src/engine/analysis_engine.cpp
  ${KISS_DIR}/kiss_fft.c
  ${KISS_DIR}/kiss_fftr.c)
target_include_directories(noxira_dsp PUBLIC
  ${NOXIRA_ROOT}/include
  ${NOXIRA_ROOT}/src
  ${KISS_DIR})
target_compile_options(noxira_dsp PRIVATE ${NOXIRA_OPT_FLAGS} -Wall -Wextra)
set_source_files_properties(${KISS_DIR}/kiss_fft.c ${KISS_DIR}/kiss_fftr.c
  PROPERTIES COMPILE_OPTIONS "-w")
find_package(Threads REQUIRED)
target_link_libraries(noxira_dsp PUBLIC Threads::Threads)

# The shared library: the C ABI (Dart FFI) plus, on Android, the JNI bridge.
set(NOXIRA_SHARED_SOURCES ${NOXIRA_ROOT}/src/ffi/ffi_api.cpp)
if(ANDROID)
  list(APPEND NOXIRA_SHARED_SOURCES ${NOXIRA_ROOT}/src/jni/jni_bridge.cpp)
endif()
add_library(noxira_audio SHARED ${NOXIRA_SHARED_SOURCES})
target_link_libraries(noxira_audio PRIVATE noxira_dsp)
if(ANDROID)
  target_link_libraries(noxira_audio PRIVATE log)
  # 16 KB page-size compatible (Android 15+ devices).
  target_link_options(noxira_audio PRIVATE -Wl,-z,max-page-size=16384)
endif()

if(NOXIRA_BUILD_TESTS)
  enable_testing()
  add_executable(noxira_tests ${NOXIRA_ROOT}/tests/noxira_tests.cpp
                            ${NOXIRA_ROOT}/src/ffi/ffi_api.cpp)
  target_link_libraries(noxira_tests PRIVATE noxira_dsp)
  target_compile_options(noxira_tests PRIVATE -O2 -Wall -Wextra)
  add_test(NAME noxira_tests COMMAND noxira_tests)
endif()
