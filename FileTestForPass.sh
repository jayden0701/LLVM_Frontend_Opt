#!/bin/bash

# Input file
input_file=$1

# Front part of the filename
front_part=$2

source_dir=$3

# Set LLVM directory
LLVM_DIR=$4


# Run LLVM passes
$LLVM_DIR/bin/opt -load-pass-plugin ${source_dir}/build/src/lib/opt/lib${front_part}.so -passes="${front_part}" "${input_file}" -S -o ${front_part}.ll
$LLVM_DIR/bin/FileCheck "${input_file}" < ${front_part}.ll

# Check the exit code of FileCheck
if [ $? -eq 0 ]; then
    # FileCheck succeeded, return 0
    exit 0
else
    # FileCheck failed, return non-zero exit code
    exit 1
fi
