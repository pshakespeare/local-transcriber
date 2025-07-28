# Troubleshooting Guide - Local Video Transcriber

This guide covers common issues and their solutions for developers and DevOps engineers.

## 🔍 Quick Diagnostic

Run this command to check your setup:

```bash
# System check
echo "=== System Information ==="
uname -a
docker --version
docker-compose --version
echo "WHISPER_CPP_PATH: $WHISPER_CPP_PATH"

echo "=== Project Status ==="
ls -la
ls -la input/ output/ temp/ 2>/dev/null || echo "Directories not found"

echo "=== Whisper.cpp Check ==="
if [ -n "$WHISPER_CPP_PATH" ]; then
    ls -la "$WHISPER_CPP_PATH/main" 2>/dev/null || echo "Whisper.cpp main not found"
    ls -la "$WHISPER_CPP_PATH/models/" 2>/dev/null || echo "Models directory not found"
else
    echo "WHISPER_CPP_PATH not set"
fi

echo "=== Docker Status ==="
docker-compose ps
```

## 🐳 Docker Issues

### Docker Build Failures

**Error: `failed to build: error building at step X`**

**Solution:**
```bash
# Clean build
docker-compose build --no-cache

# Check Docker daemon
docker info

# Increase Docker resources (Docker Desktop)
# Settings > Resources > Memory > 8GB, CPUs > 4
```

**Error: `permission denied` during build**

**Solution:**
```bash
# Fix permissions
sudo chown -R $USER:$USER .
chmod 755 input output temp

# Check Docker group membership
groups $USER
sudo usermod -aG docker $USER
# Log out and back in
```

**Error: `no space left on device`**

**Solution:**
```bash
# Clean Docker
docker system prune -a
docker volume prune

# Check disk space
df -h
```

### Container Runtime Issues

**Error: `container exited with code 1`**

**Solution:**
```bash
# Check logs
docker-compose logs transcriber

# Run with verbose output
docker-compose run --rm transcriber python3 transcriber.py \
    -i /app/input/video.mp4 \
    -m /opt/whisper.cpp/models/ggml-base.bin \
    -v

# Interactive debugging
docker-compose run --rm transcriber bash
```

**Error: `cannot connect to the Docker daemon`**

**Solution:**
```bash
# Start Docker service
sudo systemctl start docker

# Check Docker status
sudo systemctl status docker

# Restart Docker Desktop (macOS/Windows)
```

## 🔧 Whisper.cpp Issues

### Installation Problems

**Error: `make: command not found`**

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y build-essential cmake

# CentOS/RHEL
sudo yum groupinstall -y "Development Tools"
sudo yum install -y cmake

# macOS
brew install cmake

# Windows
# Use WSL2 or install Visual Studio Build Tools
```

**Error: `cmake: command not found`**

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install -y cmake

# CentOS/RHEL
sudo yum install -y cmake

# macOS
brew install cmake
```

**Error: `git: command not found`**

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install -y git

# CentOS/RHEL
sudo yum install -y git

# macOS
brew install git

# Windows
# Download from https://git-scm.com/download/win
```

### Build Failures

**Error: `make: *** [main] Error 1`**

**Solution:**
```bash
# Check system requirements
free -h  # At least 4GB RAM
df -h    # At least 5GB disk space

# Clean and rebuild
cd whisper.cpp
make clean
make

# Check for specific errors
make VERBOSE=1
```

**Error: `fatal error: 'stdio.h' file not found`**

**Solution:**
```bash
# Install development headers
sudo apt-get install -y build-essential
# OR
sudo yum groupinstall -y "Development Tools"
```

### Model Issues

**Error: `model file not found`**

**Solution:**
```bash
# Check model path
ls -la $WHISPER_CPP_PATH/models/

# Download model
cd $WHISPER_CPP_PATH
bash ./models/download-ggml-model.sh base

# Verify download
ls -la models/ggml-base.bin
```

**Error: `failed to load model`**

**Solution:**
```bash
# Check model integrity
cd $WHISPER_CPP_PATH
ls -la models/ggml-base.bin

# Re-download model
rm models/ggml-base.bin
bash ./models/download-ggml-model.sh base

# Test model directly
./main -m models/ggml-base.bin -f test.wav
```

## 🎬 Video/Audio Issues

### FFmpeg Problems

**Error: `ffmpeg: command not found`**

**Solution:**
```bash
# Check if FFmpeg is in container
docker-compose run --rm transcriber ffmpeg -version

# If not found, rebuild container
docker-compose build --no-cache
```

**Error: `Invalid data found when processing input`**

**Solution:**
```bash
# Check video file
file input/video.mp4

# Try different audio codec
docker-compose run --rm transcriber python3 transcriber.py \
    -i /app/input/video.mp4 \
    -m /opt/whisper.cpp/models/ggml-base.bin \
    -v

# Convert video first
docker-compose run --rm transcriber ffmpeg \
    -i /app/input/video.mp4 \
    -c:v copy -c:a aac /app/input/converted.mp4
```

**Error: `No such file or directory`**

**Solution:**
```bash
# Check file exists
ls -la input/

# Check file permissions
chmod 644 input/*.mp4

# Check volume mounts
docker-compose run --rm transcriber ls -la /app/input/
```

### Audio Extraction Issues

**Error: `audio extraction failed`**

**Solution:**
```bash
# Check video has audio
docker-compose run --rm transcriber ffprobe \
    -v quiet -show_streams -select_streams a \
    /app/input/video.mp4

# Extract audio manually
docker-compose run --rm transcriber ffmpeg \
    -i /app/input/video.mp4 \
    -ar 16000 -ac 1 -c:a pcm_s16le \
    /app/temp/extracted.wav
```

## 💾 Memory and Performance Issues

### Out of Memory

**Error: `Killed` or `Out of memory`**

**Solution:**
```bash
# Use smaller model
docker-compose run --rm transcriber python3 transcriber.py \
    -i /app/input/video.mp4 \
    -m /opt/whisper.cpp/models/ggml-tiny.bin

# Increase Docker memory
# Docker Desktop: Settings > Resources > Memory > 8GB

# Set memory limits
docker-compose run --rm --memory=4g transcriber python3 transcriber.py \
    -i /app/input/video.mp4 \
    -m /opt/whisper.cpp/models/ggml-base.bin
```

### Slow Performance

**Solution:**
```bash
# Use faster model
-m /opt/whisper.cpp/models/ggml-tiny.bin

# Increase CPU allocation
docker-compose run --rm --cpus=4 transcriber python3 transcriber.py \
    -i /app/input/video.mp4 \
    -m /opt/whisper.cpp/models/ggml-base.bin

# Use SSD storage
# Mount volumes on SSD for better I/O
```

## 🔐 Permission Issues

### File Permissions

**Error: `Permission denied`**

**Solution:**
```bash
# Fix directory permissions
chmod 755 input output temp

# Fix file permissions
chmod 644 input/*.mp4

# Check ownership
ls -la input/ output/ temp/

# Fix ownership
sudo chown -R $USER:$USER .
```

### Docker Permissions

**Error: `Got permission denied while trying to connect to the Docker daemon`**

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker

# Check group membership
groups $USER
```

## 🌐 Network Issues

### Model Download Failures

**Error: `Failed to download model`**

**Solution:**
```bash
# Check internet connection
ping -c 3 google.com

# Use different download method
cd $WHISPER_CPP_PATH
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin \
    -O models/ggml-base.bin

# Check proxy settings
echo $http_proxy $https_proxy
```

### Docker Network Issues

**Error: `network unreachable`**

**Solution:**
```bash
# Check Docker network
docker network ls

# Restart Docker
sudo systemctl restart docker

# Check DNS
docker run --rm alpine nslookup google.com
```

## 🔧 Configuration Issues

### Environment Variables

**Error: `WHISPER_CPP_PATH not set`**

**Solution:**
```bash
# Set environment variable
export WHISPER_CPP_PATH=/path/to/whisper.cpp

# Add to shell profile
echo 'export WHISPER_CPP_PATH="/path/to/whisper.cpp"' >> ~/.bashrc
echo 'export WHISPER_CPP_PATH="/path/to/whisper.cpp"' >> ~/.zshrc

# Reload shell
source ~/.bashrc  # or source ~/.zshrc
```

### Volume Mount Issues

**Error: `bind mount failed`**

**Solution:**
```bash
# Check volume syntax
docker-compose config

# Fix volume paths
# Use absolute paths or relative paths from project root

# Check file system
df -T .
```

## 🐛 Debugging Techniques

### Verbose Logging

```bash
# Enable verbose output
docker-compose run --rm transcriber python3 transcriber.py \
    -i /app/input/video.mp4 \
    -m /opt/whisper.cpp/models/ggml-base.bin \
    -v

# Check Docker logs
docker-compose logs transcriber

# Interactive debugging
docker-compose run --rm transcriber bash
```

### Step-by-Step Testing

```bash
# 1. Test Docker
docker run --rm hello-world

# 2. Test FFmpeg
docker-compose run --rm transcriber ffmpeg -version

# 3. Test Whisper.cpp
docker-compose run --rm transcriber /opt/whisper.cpp/main --help

# 4. Test audio extraction
docker-compose run --rm transcriber ffmpeg \
    -i /app/input/video.mp4 \
    -ar 16000 -ac 1 -c:a pcm_s16le \
    /app/temp/test.wav

# 5. Test transcription
docker-compose run --rm transcriber /opt/whisper.cpp/main \
    -m /opt/whisper.cpp/models/ggml-base.bin \
    -f /app/temp/test.wav
```

### System Diagnostics

```bash
# Check system resources
htop
df -h
free -h

# Check Docker resources
docker system df
docker stats

# Check network
netstat -tuln
ping -c 3 google.com
```

## 📞 Getting Help

### Information to Include

When reporting issues, include:

```bash
# System information
uname -a
docker --version
docker-compose --version
echo $WHISPER_CPP_PATH

# Project status
ls -la
docker-compose ps

# Error logs
docker-compose logs transcriber

# Full error message
# Copy the complete error output
```

### Common Debugging Commands

```bash
# Check everything
./setup-guide.sh

# Quick test
docker-compose run --rm transcriber python3 transcriber.py --help

# Interactive shell
docker-compose run --rm transcriber bash

# Check file structure
tree -L 2
find . -name "*.py" -o -name "*.sh" -o -name "*.yml"
```

---

**Still having issues?** Check the [README.md](README.md) for comprehensive documentation or create an issue with detailed error information. 