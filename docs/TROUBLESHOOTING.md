# Troubleshooting Guide - Local Video Transcriber

This guide covers common issues and their solutions for the Docker-first approach.

## 🔍 Quick Diagnostic

Run this command to check your setup:

```bash
# System check
echo "=== System Information ==="
uname -a
docker --version
docker-compose --version

echo "=== Project Status ==="
ls -la
ls -la input/ output/ temp/ 2>/dev/null || echo "Directories not found"

echo "=== Docker Status ==="
docker-compose ps
docker images | grep local-transcriber
```

## 🚀 First-Time Setup Issues

### Setup Fails with "Permission denied"

**Error:** `chmod: cannot access 'scripts/setup-guide.sh': No such file or directory`

**Solution:**
```bash
# Ensure you're in the project root
pwd
ls -la

# Run setup again
make setup
```

### Docker Build Takes Too Long

**Issue:** First build takes 10+ minutes

**Solution:**
```bash
# This is normal for first build - Whisper.cpp compilation takes time
# Subsequent builds will be faster due to Docker layer caching

# To speed up future builds:
docker system prune -f  # Clean unused images
```

### "Docker not found" Error

**Error:** `docker: command not found`

**Solution:**
```bash
# Install Docker Desktop for your OS:
# macOS: https://docs.docker.com/desktop/install/mac-install/
# Windows: https://docs.docker.com/desktop/install/windows-install/
# Linux: https://docs.docker.com/engine/install/

# Verify installation
docker --version
docker-compose --version
```

## 🐳 Docker Issues

### Docker Build Failures

**Error: `failed to build: error building at step X`**

**Solution:**
```bash
# Clean build
make build-no-cache

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
make logs

# Run with verbose output
make transcribe-verbose VIDEO=video.mp4 MODEL=base

# Interactive debugging
make shell
```

**Error: `cannot connect to the Docker daemon`**

**Solution:**
```bash
# Start Docker service
# macOS/Windows: Start Docker Desktop
# Linux: sudo systemctl start docker

# Verify Docker is running
docker ps
```

## 🎤 Transcription Issues

### "Model not found" Error

**Error:** `Model 'base' not found`

**Solution:**
```bash
# The base model should be pre-downloaded in the Docker image
# If this error occurs, rebuild the image:

make build-no-cache
make setup

# Or download the model manually inside the container:
docker-compose run --rm transcriber bash -c \
    "cd /opt/whisper.cpp && bash ./models/download-ggml-model.sh base"
```

### "Whisper.cpp executable not found" Error

**Error:** `Whisper.cpp main executable not found`

**Solution:**
```bash
# This should not happen with the Docker-first approach
# If it does, rebuild the image:

make build-no-cache
make setup

# Verify the executable exists:
docker-compose run --rm transcriber ls -la /opt/whisper.cpp/build/bin/
```

### "Exec format error" Error

**Error:** `Exec format error: '/opt/whisper.cpp/main'`

**Solution:**
```bash
# This indicates an architecture mismatch
# The Docker image should handle this automatically
# If it persists, rebuild:

make build-no-cache
make setup
```

### Poor Transcription Quality

**Issue:** Transcription is inaccurate or has errors

**Solutions:**
```bash
# Try a larger model
make transcribe VIDEO=video.mp4 MODEL=small
make transcribe VIDEO=video.mp4 MODEL=medium

# Specify language if known
make transcribe VIDEO=video.mp4 MODEL=base LANGUAGE=en

# Check audio quality
docker-compose run --rm transcriber ffmpeg -i /app/input/video.mp4 -af "volumedetect" -f null /dev/null
```

### Slow Transcription

**Issue:** Transcription takes too long

**Solutions:**
```bash
# Use a smaller model
make transcribe VIDEO=video.mp4 MODEL=tiny

# Check system resources
docker stats

# Increase Docker resources
# Docker Desktop: Settings > Resources > Memory > 8GB, CPUs > 4
```

## 🔧 Command Line Issues

### "No such option: -i" Error

**Error:** `Error: No such option: -i`

**Solution:**
```bash
# Use the correct CLI structure with 'transcribe' subcommand
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
    -i /app/input/video.mp4 \
    -m base \
    -o /app/output/transcript.txt

# Or use the Makefile (recommended)
make transcribe VIDEO=video.mp4 MODEL=base
```

### "Module not found" Error

**Error:** `ModuleNotFoundError: No module named 'src'`

**Solution:**
```bash
# Ensure you're running from the project root
pwd
ls -la src/

# Rebuild the Docker image
make build-no-cache
```

## 📁 File System Issues

### "Input file not found" Error

**Error:** `Input file not found: /app/input/video.mp4`

**Solution:**
```bash
# Check if file exists in input directory
ls -la input/

# Ensure file is in the correct location
cp /path/to/your/video.mp4 input/

# Check file permissions
chmod 644 input/video.mp4
```

### "Permission denied" for Output

**Error:** `Permission denied: /app/output/transcript.txt`

**Solution:**
```bash
# Fix output directory permissions
chmod 755 output
chown -R $USER:$USER output

# Or run with proper permissions
sudo chown -R $USER:$USER .
```

### "No space left on device" Error

**Error:** `No space left on device`

**Solution:**
```bash
# Check disk space
df -h

# Clean up temporary files
make clean

# Clean Docker
docker system prune -a
```

## 🔄 Performance Issues

### High Memory Usage

**Issue:** Container uses too much memory

**Solutions:**
```bash
# Use a smaller model
make transcribe VIDEO=video.mp4 MODEL=tiny

# Limit Docker memory
# Docker Desktop: Settings > Resources > Memory > 4GB

# Monitor memory usage
docker stats
```

### Slow Processing

**Issue:** Transcription is very slow

**Solutions:**
```bash
# Use smaller model for speed
make transcribe VIDEO=video.mp4 MODEL=tiny

# Check CPU usage
docker stats

# Increase Docker CPU allocation
# Docker Desktop: Settings > Resources > CPUs > 4
```

## 🆘 Getting Help

### Debug Information

```bash
# Collect debug information
echo "=== System Info ==="
uname -a
docker --version
docker-compose --version

echo "=== Project Info ==="
pwd
ls -la
docker-compose ps

echo "=== Docker Images ==="
docker images | grep local-transcriber

echo "=== Container Logs ==="
docker-compose logs transcriber
```

### Common Commands

```bash
# Show help
make help

# Check prerequisites
make check-prerequisites

# View logs
make logs

# Interactive shell
make shell

# Clean everything
make clean
docker-compose down
docker system prune -f
```

### Reset Everything

```bash
# Complete reset
make clean
docker-compose down
docker system prune -a -f
make setup
```

## 📞 Support

If you're still having issues:

1. **Check the logs:** `make logs`
2. **Run diagnostics:** `make check-prerequisites`
3. **Try a clean setup:** `make clean && make setup`
4. **Check this guide** for your specific error
5. **Open an issue** with debug information

---

**Remember:** The Docker-first approach should handle most setup issues automatically. If you encounter problems, try rebuilding the Docker image with `make build-no-cache`. 