#!/bin/bash

use_conan=false

# Loop through all arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    "--conan")
      use_conan=true
      ;;
    # Add more cases for other options if needed
  esac
  shift # Move to the next argument
done

script_dir=$(dirname $0)

if [[ -n $1 ]]; then
  cmake_build_folder=$1
else
  cmake_build_folder=build
fi

if [ "$use_conan" = true ]; then
  conan install . -of="$script_dir/$cmake_build_folder/conan" --profile:host=default --profile:build=default --build=missing -g CMakeDeps
  cmake -S . -B "$script_dir/$cmake_build_folder" -DUSE_CONAN=$use_conan -DCMAKE_TOOLCHAIN_FILE="$script_dir/$cmake_build_folder/conan/conan_toolchain.cmake" -DCMAKE_POLICY_DEFAULT_CMP0091=NEW -DCMAKE_BUILD_TYPE=Release "${@:2}"
else
  cmake -S . -B "$script_dir/$cmake_build_folder" -DUSE_CONAN=$use_conan
fi