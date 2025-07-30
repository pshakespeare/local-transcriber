#!/bin/bash

# Get the input video filename
VIDEO_FILE="$1"

# Extract the base name without extension
BASE_NAME=$(basename "$VIDEO_FILE" | sed 's/\.[^.]*$//')

# Create the output filename
echo "${BASE_NAME}.txt" 