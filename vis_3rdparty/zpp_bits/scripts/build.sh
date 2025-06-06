#!/bin/bash
# ./scripts/build.sh -d -c> build.log 2>&1

echo "========================================================================="
echo "At line: $LINENO"
script_full_path=$(readlink -f "$0")
echo "-- script full path --"
echo $script_full_path

echo "-- current working dir --"
cwd="$(pwd)"
echo $cwd

echo "-- script path --"
script_path="$(cd $(dirname $0);pwd)"
echo $script_path

script_display_path="./${script_full_path#$cwd/}"
echo $script_display_path

# project root path containing:
# 1. root CMakeLists.txt
# 2. scripts/build.sh
echo "-- project path --"
project_path="$(dirname $script_path)"
echo $project_path

# root CMakeLists.txt must contain formatted _PROJECT_NAME_ & _PROJECT_VERSION_
# set(_PROJECT_NAME_ project_name)
# set(_PROJECT_VERSION_ project_version)
project_line=$(grep -E 'set\(_PROJECT_NAME_.*' "$project_path/CMakeLists.txt")
version_line=$(grep -E 'set\(_PROJECT_VERSION_.*' "$project_path/CMakeLists.txt")

project_name=$(echo $project_line | cut -d' ' -f2 | cut -d')' -f1)
project_version=$(echo $version_line | cut -d' ' -f2 | cut -d')' -f1)

echo "========================================================================="
echo "At line: $LINENO"
echo "-- project name --"
echo $project_name
echo "-- project version --"
echo $project_version


echo "========================================================================="
echo "At line: $LINENO"
echo "-- Description: --"

echo "========================================================================="
echo "At line: $LINENO"
echo "$# Input args: $@"

is_debug=""
is_test=OFF
is_verbose=""
is_cmake_build=false
is_package=false

while getopts "dtvcp" arg
do
    case $arg in
        d)
        is_debug="-d"
        ;;
        t)
        is_test=ON
        ;;
        v)
        is_verbose="-v"
        ;;
        c)
        is_cmake_build=true
        ;;
        p)
        is_package=true
        ;;
        ?)
        echo "unknown args $OPTARG"
        # exit 1
        ;;
    esac
done

if [ "$is_debug" == "-d" ]; then
    build_type="Debug"
else
    build_type="RelWithDebInfo"
fi

build_path_suffix=""

echo "========================================================================="
echo "At line: $LINENO"
echo "-- Desired path --"

echo "-- 3rd path --"
third_path="$(dirname $project_path)"
echo $third_path

echo "-- root new vis path --"
vis_path="$(dirname $third_path)"
echo $vis_path

# root cmake path
echo "-- src path --"
src_path=$project_path
echo $src_path

out_dir=$vis_path/.out
path_dir=x64-$build_type/$project_name$build_path_suffix/$project_version

echo "-- build path --"
build_path=$out_dir/build/$path_dir
echo $build_path
mkdir -p $build_path

echo "-- install path --"
install_path=$out_dir/install/$path_dir
echo $install_path
mkdir -p $install_path

echo "========================================================================="
echo "At line: $LINENO"
echo "-- Builder & Compiler --"

if [ "$OS" = "Windows_NT" ]; then
    echo "Windows system"
    MAKE_PROGRAM="ninja.exe"
else
    echo "Non-Windows system"
fi

# exit 0

if [ $is_cmake_build == "true" ]; then
    echo "========================================================================="
    echo "At line: $LINENO"
    echo "-- Build --"

    if [ "$OS" = "Windows_NT" ]; then
        cmake -S $src_path -B $build_path -G "Ninja" \
            -DCMAKE_BUILD_TYPE:STRING=$build_type \
            -DCMAKE_INSTALL_PREFIX:PATH=$install_path \
            -DCMAKE_MAKE_PROGRAM=$MAKE_PROGRAM \
            -DVIS_ENABLE_TEST=$is_test \
            2>&1
    else
        cmake -S $src_path -B $build_path \
            -DCMAKE_BUILD_TYPE:STRING=$build_type \
            -DCMAKE_INSTALL_PREFIX:PATH=$install_path \
            -DVIS_ENABLE_TEST=$is_test \
            2>&1
    fi

    if [ $? -ne 0 ]; then
        echo -e "\033[31mError at $script_display_path:$LINENO\033[0m"
        exit 1
    fi
fi

# exit 0

# cmake  --graphviz=foo.dot  -S $src_path -B $build_path -G "Ninja" \
#         -DCMAKE_BUILD_TYPE:STRING=$build_type \
#         -DCMAKE_INSTALL_PREFIX:PATH=$install_path \
#         -DCMAKE_C_COMPILER:FILEPATH=$C_COMPILER_PATH \
#         -DCMAKE_CXX_COMPILER:FILEPATH=$CXX_COMPILER_PATH \
#         -DCMAKE_MAKE_PROGRAM=$MAKE_PROGRAM \
#         2>&1

echo "========================================================================="
echo "At line: $LINENO"
echo "-- Make --"
cmake --build   $build_path

if [ $? -ne 0 ]; then
    echo -e "\033[31mError at $script_display_path:$LINENO\033[0m"
    exit 1
fi

echo "========================================================================="
echo "At line: $LINENO"
echo "-- Install --"
cmake --install $build_path

if [ $? -ne 0 ]; then
    echo -e "\033[31mError at $script_display_path:$LINENO\033[0m"
    exit 1
fi

# cd test_dir
# make test
