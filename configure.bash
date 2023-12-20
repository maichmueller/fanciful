#!/bin/bash

if [[ -n $1 ]]; then
  cmake_build_folder=$1
else
  cmake_build_folder=build
fi
conan install . -of="$cmake_build_folder/conan" --profile:host=default --profile:build=default --build=missing -g CMakeDeps
cmake -S . -B "$cmake_build_folder" -DCMAKE_TOOLCHAIN_FILE="$(pwd)/$cmake_build_folder/conan/build/Release/generators/conan_toolchain.cmake" -DCMAKE_POLICY_DEFAULT_CMP0091=NEW -DCMAKE_BUILD_TYPE=Release