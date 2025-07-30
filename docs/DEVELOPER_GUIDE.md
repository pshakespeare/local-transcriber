# Developer Guide - Local Video Transcriber

## 🎯 Welcome Developers & DevOps Engineers!

This guide is your comprehensive entry point to the Local Video Transcriber project. Whether you're setting up the project for the first time, troubleshooting issues, or contributing to the codebase, this guide has everything you need.

## 📚 Documentation Structure

### Essential Reading (Start Here)
1. **[README.md](README.md)** - Complete project documentation
2. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Command cheat sheet
3. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions
4. **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)** - Architecture and technical details

### Setup & Getting Started
- **[Makefile](Makefile)** - 40+ commands for project management
- **[docker-compose.yml](docker-compose.yml)** - Container orchestration
- **[Dockerfile](Dockerfile)** - Container definition

## 🚀 Quick Start for Developers

### 1. Automated Setup (Recommended)
```bash
# Complete setup in one command
make setup
```

### 2. Manual Setup (Alternative)
```bash
# Clone and setup
git clone <repository-url>
cd local-transcriber

# Build Docker image (includes Whisper.cpp)
docker-compose build

# Test installation
docker-compose run --rm transcriber python3 -m src.transcriber --help
```

### 3. Verify Installation
```bash
# Check everything works
make test-help
make show-models
```

## 🔧 Development Workflow

### Local Development
```bash
# Build development image
make build

# Run with volume mount for code changes
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
    -i /app/input/video.mp4 \
    -m base \
    -o /app/output/transcript.txt

# Interactive development
make shell
```

### Testing
```bash
# Run unit tests
make test

# Run integration tests
docker-compose run --rm transcriber python3 -m pytest tests/integration/

# Test specific functionality
docker-compose run --rm transcriber python3 -c "
from src.transcriber import VideoTranscriber
t = VideoTranscriber()
print('Transcriber initialized successfully')
"
```

### Code Quality
```bash
# Format code
docker-compose run --rm transcriber python3 -m black .

# Lint code
docker-compose run --rm transcriber python3 -m flake8 .

# Type checking
docker-compose run --rm transcriber python3 -m mypy .
```

## 🐳 Docker Operations

### Build & Deploy
```bash
# Development build
make build

# Production build (no cache)
make build-no-cache

# Push to registry
docker tag local-transcriber-transcriber:latest myregistry/local-transcriber:latest
docker push myregistry/local-transcriber:latest
```

### Container Management
```bash
# Start services
docker-compose up -d

# View logs
make logs

# Stop services
docker-compose down

# Clean up
make clean
```

## 🧪 Testing & Quality Assurance

### Unit Tests
```bash
# Run all tests
make test

# Run specific test file
docker-compose run --rm transcriber python3 -m pytest tests/test_transcriber.py

# Run with coverage
docker-compose run --rm transcriber python3 -m pytest --cov=src
```

### Integration Tests
```bash
# Test transcription pipeline
make transcribe VIDEO=test.mp4 MODEL=tiny

# Test batch processing
make transcribe-batch

# Test different output formats
make transcribe-srt VIDEO=test.mp4 MODEL=base
```

### Performance Testing
```bash
# Benchmark different models
make benchmark VIDEO=test.mp4 MODEL=base
make benchmark VIDEO=test.mp4 MODEL=small
make benchmark VIDEO=test.mp4 MODEL=medium
```

## 🔍 Debugging & Troubleshooting

### Debug Mode
```bash
# Verbose transcription
make transcribe-verbose VIDEO=video.mp4 MODEL=base

# Interactive debugging
make shell

# Check logs
make logs
```

### Common Issues
```bash
# Rebuild everything
make clean
make build-no-cache
make setup

# Check system status
make check-prerequisites

# Reset Docker
docker-compose down
docker system prune -a -f
```

## 📦 Code Structure

### Project Layout
```
local-transcriber/
├── src/                      # Python source code
│   ├── __init__.py          # Package initialization
│   ├── transcriber.py       # Main application
│   └── config.py            # Configuration settings
├── tests/                    # Test suite
│   ├── __init__.py
│   └── test_transcriber.py  # Unit tests
├── scripts/                  # Automation scripts
├── docs/                     # Documentation
├── input/                    # Video input directory
├── output/                   # Transcription output
├── temp/                     # Temporary files
├── Dockerfile               # Container definition
├── docker-compose.yml       # Orchestration
├── Makefile                 # Project management
└── requirements.txt         # Python dependencies
```

### Key Components

#### `src/transcriber.py`
- **VideoTranscriber class**: Core transcription logic
- **CLI interface**: Command-line interface using Click
- **Audio extraction**: FFmpeg integration
- **Model resolution**: Automatic model path resolution

#### `src/config.py`
- **WHISPER_MODELS**: Model specifications and metadata
- **Supported formats**: Input/output format definitions
- **Language codes**: Supported language mappings

#### `Makefile`
- **40+ commands**: Complete project management
- **Docker integration**: Build, run, and manage containers
- **Testing**: Unit and integration test automation
- **Documentation**: Help and reference commands

## 🔧 Configuration & Customization

### Environment Variables
```bash
# Development overrides
export DOCKER_COMPOSE_FILE=docker-compose.dev.yml
export PYTHONPATH=/app/src
```

### Docker Configuration
```yaml
# docker-compose.yml
services:
  transcriber:
    build: .
    volumes:
      - ./input:/app/input:ro
      - ./output:/app/output
      - ./temp:/app/temp
      - ./src:/app/src  # Development mount
    environment:
      - PYTHONPATH=/app/src
```

### Model Management
```bash
# List available models
make show-models

# Download additional models
make download-model MODEL=small
make download-model MODEL=medium

# Use custom model path
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
    -i /app/input/video.mp4 \
    -m /app/input/custom-model.bin \
    -o /app/output/transcript.txt
```

## 🚀 Performance Optimization

### Model Selection
```bash
# Fastest (lowest accuracy)
make transcribe VIDEO=video.mp4 MODEL=tiny

# Balanced (recommended)
make transcribe VIDEO=video.mp4 MODEL=base

# High accuracy (slower)
make transcribe VIDEO=video.mp4 MODEL=small
make transcribe VIDEO=video.mp4 MODEL=medium
```

### Docker Resource Allocation
```yaml
# docker-compose.yml
services:
  transcriber:
    deploy:
      resources:
        limits:
          memory: 8G
          cpus: '4.0'
        reservations:
          memory: 4G
          cpus: '2.0'
```

### Batch Processing
```bash
# Process multiple files
make transcribe-batch

# Parallel processing
parallel -j 2 make transcribe VIDEO={} MODEL=base ::: input/*.mp4
```

## 🔒 Security Considerations

### Container Security
```dockerfile
# Dockerfile
USER transcriber  # Non-root user
WORKDIR /app
```

### File Permissions
```bash
# Secure file handling
chmod 755 input output temp
chown -R $USER:$USER .
```

### Network Security
```yaml
# docker-compose.yml
services:
  transcriber:
    network_mode: "host"  # Optional: direct network access
    # OR
    networks:
      - internal  # Isolated network
```

## 📊 Monitoring & Logging

### Application Logs
```bash
# View logs
make logs

# Follow logs
docker-compose logs -f transcriber

# Log levels
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
    -i /app/input/video.mp4 \
    -m base \
    -v  # Verbose output
```

### Performance Monitoring
```bash
# Container stats
docker stats

# Resource usage
docker-compose run --rm transcriber python3 -c "
import psutil
print(f'Memory: {psutil.virtual_memory().percent}%')
print(f'CPU: {psutil.cpu_percent()}%')
"
```

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and test
        run: |
          make build
          make test
          make transcribe VIDEO=test.mp4 MODEL=tiny
```

### Docker Registry
```bash
# Build and push
docker build -t myregistry/local-transcriber:latest .
docker push myregistry/local-transcriber:latest

# Deploy
docker-compose -f docker-compose.prod.yml up -d
```

## 📚 Additional Resources

### Documentation
- **[MAKEFILE_GUIDE.md](MAKEFILE_GUIDE.md)** - Complete Makefile reference
- **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)** - Technical architecture
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines

### External Resources
- **[Whisper.cpp Documentation](https://github.com/ggerganov/whisper.cpp)**
- **[FFmpeg Documentation](https://ffmpeg.org/documentation.html)**
- **[Docker Documentation](https://docs.docker.com/)**

### Community
- **Issues**: Report bugs and request features
- **Discussions**: Ask questions and share ideas
- **Pull Requests**: Contribute code improvements

---

**Ready to contribute?** Check out [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines! 