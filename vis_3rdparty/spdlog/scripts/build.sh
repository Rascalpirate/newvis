#!/bin/bash
# ./scripts/build.sh -d -c> build.log 2>&1

echo "========================================================================="
echo "At line: $LINENO"
script_full_path=$(readlink -f "$0")
echo $script_full_path

echo "-- Current working dir --"
cwd="$(pwd)"
echo $cwd

echo "At line: $LINENO"
echo "-- Script path --"
script_path="$(cd $(dirname $0);pwd)"
echo $script_path

echo "At line: $LINENO"
script_path_display_in_terminal="./${script_full_path#$cwd/}"
echo $script_path_display_in_terminal

echo "At line: $script_path_display_in_terminal:$LINENO"
echo "-- Project path --"
project_path="$(dirname $script_path)"
echo $project_path

project_name="spdlog"
project_version="1.15.1"

echo "========================================================================="
echo "At line: $script_path_display_in_terminal:$LINENO"
echo "-- Project name --"
echo $project_name
echo "-- Project version --"
echo $project_version

echo "========================================================================="
echo "At line: $script_path_display_in_terminal:$LINENO"
echo "-- Description: --"

echo "========================================================================="
echo "At line: $script_path_display_in_terminal:$LINENO"
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
        exit 1
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
echo "At line: $script_path_display_in_terminal:$LINENO"
echo "-- Desired path --"

new_vis_path="$(dirname $(dirname $project_path))"
src_path=$project_path/src

out_dir=$new_vis_path/.out
path_dir=x64-$build_type/$project_name$build_path_suffix/$project_version

build_path=$out_dir/build/$path_dir
mkdir -p $build_path
install_path=$out_dir/install/$path_dir
mkdir -p $install_path

echo "-- New vis path: $new_vis_path"
echo "-- Src path:     $src_path"
echo "-- Build path:   $build_path"
echo "-- Install path: $install_path"

echo "========================================================================="
echo "At line: $script_path_display_in_terminal:$LINENO"
echo "-- Builder & Compiler --"

if [ "$OS" = "Windows_NT" ]; then
    echo "Windows system"
    MAKE_PROGRAM="ninja.exe"
else
    echo "Non-Windows system"
fi

if [ $is_cmake_build == "true" ]; then
    echo "========================================================================="
    echo "At line: $script_path_display_in_terminal:$LINENO"
    echo "-- Build --"


    cmake -S $src_path -B $build_path \
        -DCMAKE_BUILD_TYPE:STRING=$build_type \
        -DCMAKE_INSTALL_PREFIX:PATH=$install_path \
        -DSPDLOG_USE_STD_FORMAT=ON \
        2>&1

    if [ $? -ne 0 ]; then
        echo -e "\033[31mError at $script_path_display_in_terminal:$LINENO\033[0m"
        exit 1
    fi
fi

echo "========================================================================="
echo "At line: $script_path_display_in_terminal:$LINENO"
echo "-- Make --"
cmake --build   $build_path
if [ $? -ne 0 ]; then
    echo -e "\033[31mError at $script_path_display_in_terminal:$LINENO\033[0m"
    exit 1
fi

echo "========================================================================="
echo "At line: $script_path_display_in_terminal:$LINENO"
echo "-- Install --"
cmake --install $build_path --config $build_type # why is config in need? why doesn't the specification CMAKE_BUILD_TYPE work?

# cmake --install . --config Debug # why is config in need? why doesn't the specification CMAKE_BUILD_TYPE work?
if [ $? -ne 0 ]; then
    echo -e "\033[31mError at $script_path_display_in_terminal:$LINENO\033[0m"
    exit 1
fi
