#!/bin/bash

# Define paths
UNISWAP_PERIPHERY='./node_modules/@uniswap/v3-periphery/artifacts/'
UNISWAP_CORE='./node_modules/@uniswap/v3-core/artifacts/'
ABI_ARTIFACTS='./abi-artifacts/'

# Check if abi-artifacts folder exists and remove it
if [ -d "$ABI_ARTIFACTS" ]; then
    echo "Removing existing abi-artifacts directory..."
    rm -rf "$ABI_ARTIFACTS"
fi

# Create a new abi-artifacts folder
mkdir -p "$ABI_ARTIFACTS"
echo "Created new abi-artifacts directory: $ABI_ARTIFACTS"

# Function to copy files from a directory
copy_files() {
    local source_dir=$1
    if [ -d "$source_dir" ]; then
        find "$source_dir" -type f -name '*.json' -exec cp {} "$ABI_ARTIFACTS" \;
        echo "Copied files from $source_dir"
    else
        echo "Warning: Directory not found - $source_dir"
    fi
}

# Copy files from both directories
copy_files "$UNISWAP_PERIPHERY"
copy_files "$UNISWAP_CORE"

# Count the number of files copied
FILE_COUNT=$(find "$ABI_ARTIFACTS" -type f -name '*.json' | wc -l)

echo "Total JSON files copied to $ABI_ARTIFACTS: $FILE_COUNT"