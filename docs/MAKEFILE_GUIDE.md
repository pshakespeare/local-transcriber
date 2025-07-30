# Makefile Guide - Local Video Transcriber

## 🎯 Overview

The Makefile provides a comprehensive set of commands to manage the Local Video Transcriber project. It simplifies common tasks like building, testing, transcribing, and deploying the application with a Docker-first approach.

## 🚀 Quick Start

### Basic Commands
```bash
# Show all available commands
make help

# Complete project setup (Docker-first)
make setup

# Quick setup (non-interactive)
make setup-quick

# Build Docker image
make build

# Test the application
make test-help
```

## 📋 Command Categories

### 🔧 Setup & Configuration

| Command | Description | Usage |
|---------|-------------|-------|
| `setup` | Complete Docker-first setup | `make setup` |
| `setup-quick` | Quick non-interactive setup | `make setup-quick` |
| `check-prerequisites` | Check system requirements | `make check-prerequisites` |
| `validate` | Validate project setup | `make validate` |

### 🐳 Docker Management

| Command | Description | Usage |
|---------|-------------|-------|
| `build` | Build Docker image | `make build` |
| `build-no-cache` | Build without cache | `make build-no-cache` |
| `up` | Start containers | `make up` |
| `down` | Stop containers | `make down` |
| `logs` | Show container logs | `make logs` |
| `shell` | Open shell in container | `make shell` |

### 🧪 Testing & Validation

| Command | Description | Usage |
|---------|-------------|-------|
| `test` | Run all tests | `make test` |
| `test-help` | Test help command | `make test-help` |
| `test-ffmpeg` | Test FFmpeg installation | `make test-ffmpeg` |
| `test-whisper` | Test Whisper.cpp installation | `make test-whisper` |

### 🎬 Transcription

| Command | Description | Usage |
|---------|-------------|-------|
| `transcribe` | Transcribe video to TXT | `make transcribe VIDEO=input.mp4 MODEL=base` |
| `transcribe-srt` | Transcribe to SRT format | `make transcribe-srt VIDEO=input.mp4 MODEL=base` |
| `transcribe-verbose` | Transcribe with verbose output | `make transcribe-verbose VIDEO=input.mp4 MODEL=base` |
| `transcribe-batch` | Batch transcribe all videos | `make transcribe-batch` |
| `quick` | Quick transcription alias | `make quick VIDEO=input.mp4 MODEL=base` |

### 🤖 Model Management

| Command | Description | Usage |
|---------|-------------|-------|
| `show-models` | List available models | `make show-models` |
| `download-model` | Download Whisper model | `make download-model MODEL=small` |

### 🧹 Cleanup

| Command | Description | Usage |
|---------|-------------|-------|
| `clean` | Clean temporary files | `make clean` |
| `clean-docker` | Clean Docker resources | `make clean-docker` |
| `clean-all` | Clean everything | `make clean-all` |

### 📊 Performance & Monitoring

| Command | Description | Usage |
|---------|-------------|-------|
| `benchmark` | Benchmark transcription | `make benchmark VIDEO=input.mp4 MODEL=base` |
| `memory-check` | Check memory usage | `make memory-check` |
| `status` | Show project status | `make status` |
| `info` | Show detailed information | `make info` |

### 🚀 Deployment

| Command | Description | Usage |
|---------|-------------|-------|
| `deploy-build` | Build production image | `make deploy-build` |
| `deploy-push` | Push to registry | `make deploy-push REGISTRY=myregistry` |
| `deploy` | Deploy to production | `make deploy` |

## 🔧 Detailed Command Reference

### Setup Commands

#### `make setup`
Complete project setup with Docker-first approach.

**What it does:**
- Checks system requirements (OS, RAM, disk space)
- Verifies prerequisites (Docker, Docker Compose, Git, Make)
- Creates project directories (input, output, temp)
- Builds Docker image (includes Whisper.cpp and base model)
- Tests installation

**Example:**
```bash
make setup
```

**Output:**
```
[INFO] Starting complete project setup...
[SUCCESS] OS: Darwin detected
[SUCCESS] RAM: 64GB (Minimum 4GB required)
[SUCCESS] Docker: 28.0.4
[SUCCESS] Docker image built successfully!
[SUCCESS] Installation test passed!
```

#### `make setup-quick`
Quick non-interactive setup for experienced users.

**What it does:**
- Creates project directories
- Builds Docker image
- Skips verbose output

**Example:**
```bash
make setup-quick
```

#### `make check-prerequisites`
Check if all system requirements are met.

**What it checks:**
- Docker and Docker Compose versions
- Git and Make availability
- Docker image status

**Example:**
```bash
make check-prerequisites
```

### Docker Commands

#### `make build`
Build the Docker image with all dependencies.

**What it builds:**
- Ubuntu 22.04 base image
- Python dependencies
- Whisper.cpp (cloned and compiled)
- Base Whisper model (pre-downloaded)
- Application code

**Example:**
```bash
make build
```

#### `make build-no-cache`
Build Docker image without using cache.

**Use when:**
- Dependencies have changed
- Troubleshooting build issues
- Ensuring fresh build

**Example:**
```bash
make build-no-cache
```

#### `make shell`
Open an interactive shell in the container.

**Useful for:**
- Debugging
- Manual testing
- Exploring the container environment

**Example:**
```bash
make shell
```

### Transcription Commands

#### `make transcribe`
Transcribe a video file to plain text.

**Parameters:**
- `VIDEO`: Input video filename (required)
- `MODEL`: Whisper model to use (optional, defaults to 'base')

**Example:**
```bash
make transcribe VIDEO=meeting.mp4 MODEL=base
```

**What it does:**
- Extracts audio from video using FFmpeg
- Transcribes audio using Whisper.cpp
- Saves result to output directory

#### `make transcribe-srt`
Generate subtitles in SRT format.

**Parameters:**
- `VIDEO`: Input video filename (required)
- `MODEL`: Whisper model to use (optional, defaults to 'base')

**Example:**
```bash
make transcribe-srt VIDEO=presentation.mp4 MODEL=small
```

#### `make transcribe-verbose`
Transcribe with detailed output for debugging.

**Example:**
```bash
make transcribe-verbose VIDEO=video.mp4 MODEL=base
```

#### `make transcribe-batch`
Process all video files in the input directory.

**Example:**
```bash
make transcribe-batch
```

### Model Management Commands

#### `make show-models`
Display available Whisper models and their characteristics.

**Example:**
```bash
make show-models
```

**Output:**
```
Available Whisper Models:
┌─────────┬──────────┬─────────┬──────────┬─────────────────────────────┐
│ Model   │ Size     │ Speed   │ Accuracy │ Description                 │
├─────────┼──────────┼─────────┼──────────┼─────────────────────────────┤
│ tiny    │ 39 MB    │ ⚡⚡⚡   │ Low      │ Fastest model, suitable for │
│         │          │         │          │ real-time transcription     │
│ base    │ 142 MB   │ ⚡⚡     │ Medium   │ Good balance of speed and   │
│         │          │         │          │ accuracy                    │
│ small   │ 466 MB   │ ⚡       │ Better   │ Better accuracy for        │
│         │          │         │          │ important content           │
└─────────┴──────────┴─────────┴──────────┴─────────────────────────────┘
```

#### `make download-model`
Download additional Whisper models.

**Parameters:**
- `MODEL`: Model name to download (tiny, base, small, medium, large)

**Example:**
```bash
make download-model MODEL=small
```

### Testing Commands

#### `make test`
Run the complete test suite.

**What it tests:**
- Unit tests for VideoTranscriber class
- FFmpeg functionality
- Whisper.cpp integration
- CLI interface

**Example:**
```bash
make test
```

#### `make test-help`
Test the help command functionality.

**Example:**
```bash
make test-help
```

#### `make benchmark`
Benchmark transcription performance.

**Parameters:**
- `VIDEO`: Video file to benchmark
- `MODEL`: Model to test

**Example:**
```bash
make benchmark VIDEO=test.mp4 MODEL=base
```

### Cleanup Commands

#### `make clean`
Remove temporary files and directories.

**What it cleans:**
- temp/ directory contents
- Generated audio files
- Temporary transcription files

**Example:**
```bash
make clean
```

#### `make clean-docker`
Clean Docker resources.

**What it cleans:**
- Stopped containers
- Unused images
- Build cache

**Example:**
```bash
make clean-docker
```

#### `make clean-all`
Complete cleanup of all project resources.

**Example:**
```bash
make clean-all
```

## 🎯 Common Usage Patterns

### First-Time Setup
```bash
# Complete setup
make setup

# Verify installation
make test-help
make show-models
```

### Daily Usage
```bash
# Transcribe a video
make transcribe VIDEO=meeting.mp4 MODEL=base

# Generate subtitles
make transcribe-srt VIDEO=presentation.mp4 MODEL=small

# Batch process
make transcribe-batch
```

### Development Workflow
```bash
# Build for development
make build

# Run tests
make test

# Interactive debugging
make shell
```

### Troubleshooting
```bash
# Check system status
make check-prerequisites

# Rebuild everything
make clean
make build-no-cache
make setup

# View logs
make logs
```

## 🔧 Advanced Usage

### Custom Parameters
```bash
# Use specific model
make transcribe VIDEO=video.mp4 MODEL=medium

# Verbose output
make transcribe-verbose VIDEO=video.mp4 MODEL=base

# Custom output format (via Docker)
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
    -i /app/input/video.mp4 \
    -m base \
    -f json \
    -o /app/output/video.json
```

### Environment Variables
```bash
# Override Docker Compose file
export DOCKER_COMPOSE_FILE=docker-compose.dev.yml
make build

# Set custom model path
export WHISPER_MODEL_PATH=/custom/path
make transcribe VIDEO=video.mp4
```

### Parallel Processing
```bash
# Process multiple files in parallel
parallel -j 2 make transcribe VIDEO={} MODEL=base ::: input/*.mp4
```

## 🐛 Troubleshooting

### Common Issues

**"Permission denied" errors:**
```bash
# Fix permissions
chmod 755 input output temp
chown -R $USER:$USER .
```

**Docker build failures:**
```bash
# Clean rebuild
make clean
make build-no-cache
```

**"Model not found" errors:**
```bash
# Rebuild image (includes model download)
make build-no-cache
make setup
```

**"No such option: -i" errors:**
```bash
# Use correct CLI structure
make transcribe VIDEO=video.mp4 MODEL=base
# NOT: make transcribe -i video.mp4
```

### Debug Commands
```bash
# Check system status
make check-prerequisites

# View container logs
make logs

# Interactive debugging
make shell

# Test individual components
make test-ffmpeg
make test-whisper
```

## 📚 Additional Resources

- **[README.md](README.md)** - Complete project documentation
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Command cheat sheet
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions
- **[DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)** - Development workflow

---

**Need help?** Run `make help` to see all available commands! 