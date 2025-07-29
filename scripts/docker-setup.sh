#!/bin/bash

# Docker Setup Script for Local Video Transcriber
# This script helps set up the containerized environment

set -e

echo "🐳 Setting up Local Video Transcriber with Docker..."

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p input output temp

# Set permissions
echo "🔐 Setting permissions..."
chmod 755 input output temp

# Build the Docker image
echo "🔨 Building Docker image..."
docker-compose build

# Check for Whisper.cpp installation
echo "🔍 Checking for Whisper.cpp installation..."
if [[ -z "$WHISPER_CPP_PATH" ]]; then
    echo "⚠️  WHISPER_CPP_PATH not set. Please set it to your Whisper.cpp installation:"
    echo "   export WHISPER_CPP_PATH=/path/to/your/whisper.cpp"
    echo ""
    echo "📥 To install Whisper.cpp:"
    echo "   git clone https://github.com/ggerganov/whisper.cpp.git"
    echo "   cd whisper.cpp"
    echo "   make"
    echo "   bash ./models/download-ggml-model.sh base"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Usage:"
echo "1. Place your video files in the 'input' directory"
echo "2. Run the transcriber:"
echo "   docker-compose run --rm transcriber python3 -m src.transcriber transcribe -i /app/input/your_video.mp4 -m /opt/whisper.cpp/models/ggml-base.bin -o /app/output/transcript.txt"
echo ""
echo "3. Or use the interactive mode:"
echo "   docker-compose run --rm transcriber"
echo ""
echo "4. Find your transcriptions in the 'output' directory"
echo ""
echo "📚 For more help:"
echo "   docker-compose run --rm transcriber python3 -m src.transcriber --help" 