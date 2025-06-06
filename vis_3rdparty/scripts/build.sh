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

$project_path/cctz/scripts/build.sh "$@"
$project_path/spdlog/scripts/build.sh "$@"
$project_path/zpp_bits/scripts/build.sh "$@"
