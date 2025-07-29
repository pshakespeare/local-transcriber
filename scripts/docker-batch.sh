#!/bin/bash

# Docker Batch Processing Script for Local Video Transcriber
# This script processes all video files in the input directory

set -e

# Configuration
INPUT_DIR="./input"
OUTPUT_DIR="./output"
MODEL_PATH="/opt/whisper.cpp/models/ggml-base.bin"
FORMAT="txt"
LANGUAGE=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -m, --model MODEL     Whisper model to use (default: base)"
    echo "  -f, --format FORMAT   Output format: txt, srt, vtt, json (default: txt)"
    echo "  -l, --language LANG   Language code (e.g., en, es, fr)"
    echo "  -i, --input DIR       Input directory (default: ./input)"
    echo "  -o, --output DIR      Output directory (default: ./output)"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Process all videos with default settings"
    echo "  $0 -m small -f srt                   # Use small model, output SRT subtitles"
    echo "  $0 -l es -f vtt                      # Spanish language, VTT format"
    echo "  $0 -i /path/to/videos -o /path/to/output"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--model)
            MODEL_NAME="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -l|--language)
            LANGUAGE="$2"
            shift 2
            ;;
        -i|--input)
            INPUT_DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Set model path based on model name
if [[ -n "$MODEL_NAME" ]]; then
    MODEL_PATH="/opt/whisper.cpp/models/ggml-${MODEL_NAME}.bin"
fi

# Check if input directory exists
if [[ ! -d "$INPUT_DIR" ]]; then
    print_error "Input directory does not exist: $INPUT_DIR"
    exit 1
fi

# Check if output directory exists, create if not
if [[ ! -d "$OUTPUT_DIR" ]]; then
    print_status "Creating output directory: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi

# Find video files
VIDEO_FILES=()
while IFS= read -r -d '' file; do
    VIDEO_FILES+=("$file")
done < <(find "$INPUT_DIR" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.mkv" -o -iname "*.wmv" -o -iname "*.flv" -o -iname "*.webm" -o -iname "*.m4v" \) -print0)

# Check if any video files found
if [[ ${#VIDEO_FILES[@]} -eq 0 ]]; then
    print_warning "No video files found in $INPUT_DIR"
    print_status "Supported formats: MP4, AVI, MOV, MKV, WMV, FLV, WebM, M4V"
    exit 0
fi

print_status "Found ${#VIDEO_FILES[@]} video file(s) to process"
print_status "Model: $MODEL_PATH"
print_status "Format: $FORMAT"
if [[ -n "$LANGUAGE" ]]; then
    print_status "Language: $LANGUAGE"
fi
echo ""

# Process each video file
SUCCESS_COUNT=0
FAILED_COUNT=0

for video_file in "${VIDEO_FILES[@]}"; do
    filename=$(basename "$video_file")
    name_without_ext="${filename%.*}"
    
    print_status "Processing: $filename"
    
    # Build command
    cmd="docker-compose run --rm transcriber python3 -m src.transcriber transcribe"
    cmd="$cmd -i /app/input/$filename"
    cmd="$cmd -m $MODEL_PATH"
    cmd="$cmd -f $FORMAT"
    cmd="$cmd -o /app/output/${name_without_ext}_transcript.$FORMAT"
    
    if [[ -n "$LANGUAGE" ]]; then
        cmd="$cmd -l $LANGUAGE"
    fi
    
    # Execute command
    if eval "$cmd"; then
        print_success "Completed: $filename"
        ((SUCCESS_COUNT++))
    else
        print_error "Failed: $filename"
        ((FAILED_COUNT++))
    fi
    
    echo ""
done

# Summary
echo "=========================================="
print_status "Batch processing completed!"
print_success "Successful: $SUCCESS_COUNT"
if [[ $FAILED_COUNT -gt 0 ]]; then
    print_error "Failed: $FAILED_COUNT"
fi
print_status "Output files are in: $OUTPUT_DIR"
echo "==========================================" 