# Makefile Guide - Local Video Transcriber

## 🎯 Overview

The Makefile provides a comprehensive set of commands to manage the Local Video Transcriber project. It simplifies common tasks like building, testing, transcribing, and deploying the application.

## 🚀 Quick Start

### Basic Commands
```bash
# Show all available commands
make help

# Complete project setup
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
| `setup` | Complete interactive setup | `make setup` |
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
| `transcribe` | Transcribe video to TXT | `make transcribe VIDEO=input.mp4` |
| `transcribe-srt` | Transcribe to SRT format | `make transcribe-srt VIDEO=input.mp4` |
| `transcribe-verbose` | Transcribe with verbose output | `make transcribe-verbose VIDEO=input.mp4` |
| `transcribe-batch` | Batch transcribe all videos | `make transcribe-batch` |
| `quick` | Quick transcription alias | `make quick VIDEO=input.mp4` |

### 🤖 Model Management

| Command | Description | Usage |
|---------|-------------|-------|
| `download-model` | Download Whisper model | `make download-model MODEL=base` |
| `list-models` | List available models | `make list-models` |

### 🧹 Cleanup

| Command | Description | Usage |
|---------|-------------|-------|
| `clean` | Clean temporary files | `make clean` |
| `clean-docker` | Clean Docker resources | `make clean-docker` |
| `clean-all` | Clean everything | `make clean-all` |

### 📊 Performance & Monitoring

| Command | Description | Usage |
|---------|-------------|-------|
| `benchmark` | Benchmark transcription | `make benchmark VIDEO=input.mp4` |
| `memory-check` | Check memory usage | `make memory-check` |
| `status` | Show project status | `make status` |
| `info` | Show detailed information | `make info` |

### 🚀 Deployment

| Command | Description | Usage |
|---------|-------------|-------|
| `deploy-build` | Build production image | `make deploy-build` |
| `deploy-push` | Push to registry | `make deploy-push REGISTRY=myregistry` |
| `deploy` | Deploy to production | `make deploy` |

### 🔧 Development

| Command | Description | Usage |
|---------|-------------|-------|
| `format` | Format Python code | `make format` |
| `lint` | Lint Python code | `make lint` |
| `type-check` | Type check Python code | `make type-check` |
| `dev` | Development mode | `make dev` |

### 🔄 CI/CD

| Command | Description | Usage |
|---------|-------------|-------|
| `ci-build` | CI build target | `make ci-build` |
| `ci-test` | CI test target | `make ci-test` |

### 📚 Documentation

| Command | Description | Usage |
|---------|-------------|-------|
| `docs` | Show documentation info | `make docs` |
| `readme` | Show README | `make readme` |

### 🛠️ Utilities

| Command | Description | Usage |
|---------|-------------|-------|
| `all` | Complete setup and build | `make all` |
| `debug` | Print make variables | `make debug` |

## 💡 Usage Examples

### Complete Workflow
```bash
# 1. Setup project
make setup

# 2. Build Docker image
make build

# 3. Test installation
make test-help

# 4. Transcribe a video
make transcribe VIDEO=my_video.mp4

# 5. Check status
make status
```

### Development Workflow
```bash
# 1. Quick setup
make setup-quick

# 2. Build and test
make build
make test-help

# 3. Development mode
make dev

# 4. Format and lint code
make format
make lint
```

### Production Deployment
```bash
# 1. Build production image
make deploy-build

# 2. Push to registry
make deploy-push REGISTRY=myregistry

# 3. Deploy
make deploy
```

### Troubleshooting
```bash
# 1. Check prerequisites
make check-prerequisites

# 2. Validate setup
make validate

# 3. Check status
make status

# 4. View logs
make logs
```

## 🔧 Configuration

### Environment Variables

The Makefile uses these environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `WHISPER_CPP_PATH` | Path to Whisper.cpp installation | None (required) |
| `VIDEO` | Video file for transcription | None (required for transcribe commands) |
| `MODEL` | Whisper model name | None (required for download-model) |
| `REGISTRY` | Docker registry | None (required for deploy-push) |

### Setting Environment Variables

```bash
# Set Whisper.cpp path
export WHISPER_CPP_PATH=/path/to/whisper.cpp

# Add to shell profile
echo 'export WHISPER_CPP_PATH="/path/to/whisper.cpp"' >> ~/.bashrc
echo 'export WHISPER_CPP_PATH="/path/to/whisper.cpp"' >> ~/.zshrc
```

## 🎯 Common Use Cases

### First-Time Setup
```bash
# Interactive setup (recommended)
make setup

# Or quick setup
make setup-quick
export WHISPER_CPP_PATH=/path/to/whisper.cpp
make build
make test-help
```

### Daily Usage
```bash
# Transcribe a video
make transcribe VIDEO=presentation.mp4

# Generate subtitles
make transcribe-srt VIDEO=presentation.mp4

# Batch process
make transcribe-batch
```

### Development
```bash
# Start development mode
make dev

# Format code
make format

# Run tests
make test
```

### Production
```bash
# Build and deploy
make deploy-build
make deploy-push REGISTRY=myregistry
make deploy
```

## 🔍 Troubleshooting

### Common Issues

**"WHISPER_CPP_PATH not set"**
```bash
# Set the environment variable
export WHISPER_CPP_PATH=/path/to/whisper.cpp

# Verify it's set
echo $WHISPER_CPP_PATH
```

**"Please specify VIDEO file"**
```bash
# Use the VIDEO parameter
make transcribe VIDEO=my_video.mp4
```

**Docker build fails**
```bash
# Clean build
make build-no-cache

# Check prerequisites
make check-prerequisites
```

**Permission issues**
```bash
# Fix permissions
chmod 755 input output temp
sudo chown -R $USER:$USER .
```

### Debugging Commands

```bash
# Check system status
make status

# Validate setup
make validate

# Show detailed info
make info

# Debug make variables
make debug
```

## 📊 Performance Tips

### Optimizing Transcription
```bash
# Use smaller model for speed
make download-model MODEL=tiny
make transcribe VIDEO=input.mp4

# Use larger model for accuracy
make download-model MODEL=large
make transcribe VIDEO=input.mp4

# Benchmark performance
make benchmark VIDEO=input.mp4
```

### Resource Management
```bash
# Check memory usage
make memory-check

# Clean up resources
make clean
make clean-docker
```

## 🔄 Integration with CI/CD

### GitHub Actions Example
```yaml
name: Build and Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup
        run: make setup-quick
      - name: Build
        run: make build
      - name: Test
        run: make ci-test
```

### Local CI Testing
```bash
# Run CI build locally
make ci-build

# Run CI tests locally
make ci-test
```

## 📚 Related Documentation

- **[README.md](README.md)** - Complete project documentation
- **[DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)** - Developer guide
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Command reference
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Issue resolution

---

**Happy Transcribing! 🎬📝**

This Makefile guide provides everything you need to effectively manage the Local Video Transcriber project using simple, consistent commands. 