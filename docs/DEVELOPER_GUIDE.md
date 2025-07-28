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
- **[setup-guide.sh](setup-guide.sh)** - Interactive setup script
- **[docker-setup.sh](docker-setup.sh)** - Automated Docker setup
- **[quick_start.py](quick_start.py)** - Interactive Python setup

## 🚀 Quick Start for Developers

### 1. Prerequisites Check
```bash
# Run the comprehensive setup guide
./setup-guide.sh
```

### 2. Manual Setup (Alternative)
```bash
# Install Whisper.cpp
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp && make
bash ./models/download-ggml-model.sh base

# Setup project
export WHISPER_CPP_PATH=/path/to/whisper.cpp
docker-compose build
```

### 3. Test Installation
```bash
# Verify everything works
docker-compose run --rm transcriber python3 transcriber.py --help
```

## 🔧 Development Workflow

### Local Development
```bash
# Build development image
docker-compose build

# Run with volume mount for code changes
docker-compose run --rm -v $(pwd):/app transcriber python3 transcriber.py \
    -i /app/input/video.mp4 \
    -m /opt/whisper.cpp/models/ggml-base.bin

# Interactive development
docker-compose run --rm transcriber bash
```

### Testing
```bash
# Run unit tests
docker-compose run --rm transcriber python3 -m pytest

# Run integration tests
docker-compose run --rm transcriber python3 -m pytest tests/integration/

# Test specific functionality
docker-compose run --rm transcriber python3 -c "
from transcriber import VideoTranscriber
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
docker-compose build

# Production build
docker build -t myregistry/local-transcriber:latest .

# Push to registry
docker push myregistry/local-transcriber:latest

# Deploy
docker-compose -f docker-compose.prod.yml up -d
```

### Container Management
```bash
# View logs
docker-compose logs transcriber

# Execute commands
docker-compose run --rm transcriber bash

# Check resource usage
docker stats local-transcriber-transcriber

# Clean up
docker-compose down
docker system prune -a
```

## 🔍 Debugging & Troubleshooting

### Quick Diagnostics
```bash
# System check
echo "=== System Information ==="
uname -a
docker --version
docker-compose --version
echo "WHISPER_CPP_PATH: $WHISPER_CPP_PATH"

# Project status
ls -la
docker-compose ps

# Whisper.cpp check
ls -la "$WHISPER_CPP_PATH/main" 2>/dev/null || echo "Whisper.cpp not found"
```

### Common Issues

**Docker Build Fails:**
```bash
docker-compose build --no-cache
```

**Permission Issues:**
```bash
chmod 755 input output temp
sudo chown -R $USER:$USER .
```

**Whisper.cpp Not Found:**
```bash
echo $WHISPER_CPP_PATH
ls -la $WHISPER_CPP_PATH/main
```

**Memory Issues:**
```bash
# Use smaller model
-m /opt/whisper.cpp/models/ggml-tiny.bin

# Increase Docker memory (Docker Desktop)
# Settings > Resources > Memory > 8GB
```

### Advanced Debugging
```bash
# Verbose output
docker-compose run --rm transcriber python3 transcriber.py \
    -i /app/input/video.mp4 \
    -m /opt/whisper.cpp/models/ggml-base.bin \
    -v

# Step-by-step testing
docker-compose run --rm transcriber ffmpeg -version
docker-compose run --rm transcriber /opt/whisper.cpp/main --help
```

## 📊 Performance Optimization

### Resource Tuning
```bash
# Memory limits
docker-compose run --rm --memory=4g transcriber python3 transcriber.py

# CPU allocation
docker-compose run --rm --cpus=4 transcriber python3 transcriber.py

# Parallel processing
parallel -j 2 docker-compose run --rm transcriber python3 transcriber.py \
    -i /app/input/{} -m /opt/whisper.cpp/models/ggml-base.bin \
    -o /app/output/{.}.txt ::: input/*.mp4
```

### Model Selection
| Model | Use Case | Memory | Speed |
|-------|----------|--------|-------|
| `tiny` | Testing, quick drafts | ~1GB | Fastest |
| `base` | General purpose | ~2GB | Fast |
| `small` | Balanced performance | ~1.5GB | Medium |
| `medium` | Professional use | ~3GB | Slower |
| `large` | High accuracy | ~4GB | Slowest |

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
name: Build and Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: docker-compose build
      - name: Test
        run: docker-compose run --rm transcriber python3 -m pytest
```

### Docker Registry
```bash
# Build and push
docker build -t myregistry/local-transcriber:latest .
docker push myregistry/local-transcriber:latest

# Deploy
docker-compose -f docker-compose.prod.yml up -d
```

### Kubernetes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: local-transcriber
spec:
  replicas: 1
  selector:
    matchLabels:
      app: local-transcriber
  template:
    metadata:
      labels:
        app: local-transcriber
    spec:
      containers:
      - name: transcriber
        image: myregistry/local-transcriber:latest
        volumeMounts:
        - name: input
          mountPath: /app/input
        - name: output
          mountPath: /app/output
        - name: whisper-cpp
          mountPath: /opt/whisper.cpp
```

## 🧪 Testing Strategy

### Unit Tests
```bash
# Run all tests
pytest

# Run specific test file
pytest tests/test_transcriber.py

# Run with coverage
pytest --cov=transcriber tests/
```

### Integration Tests
```bash
# Test Docker build
docker-compose build

# Test volume mounts
docker-compose run --rm transcriber ls -la /app/input/

# Test end-to-end
docker-compose run --rm transcriber python3 transcriber.py \
    -i /app/input/test.mp4 \
    -m /opt/whisper.cpp/models/ggml-base.bin \
    -o /app/output/test.txt
```

### Performance Tests
```bash
# Memory usage
docker stats local-transcriber-transcriber

# Processing time
time docker-compose run --rm transcriber python3 transcriber.py \
    -i /app/input/video.mp4 \
    -m /opt/whisper.cpp/models/ggml-base.bin
```

## 📝 Contributing

### Code Standards
- **Python**: PEP 8 compliance
- **Documentation**: Docstrings and inline comments
- **Testing**: Minimum 80% code coverage
- **Type Hints**: Full type annotation

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes
git add .
git commit -m "feat: add new feature"

# Push and create PR
git push origin feature/new-feature
```

### Code Review Checklist
- [ ] Code follows PEP 8
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No security issues
- [ ] Performance impact considered

## 🔐 Security Considerations

### Container Security
- Non-root user execution
- Read-only input mounts
- Minimal base image
- No network access for transcription

### Data Privacy
- Local processing only
- No external API calls
- Automatic cleanup of temporary files
- Volume isolation

## 📈 Monitoring & Logging

### Application Logging
```python
import logging
logging.basicConfig(level=logging.INFO)

from rich.console import Console
console = Console()
```

### Health Checks
```yaml
healthcheck:
  test: ["CMD", "python3", "-c", "import transcriber; print('OK')"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### Metrics Collection
- Processing time tracking
- Success/failure rates
- Resource utilization
- Error monitoring

## 🚀 Advanced Usage

### Programmatic Integration
```python
from transcriber import VideoTranscriber

# Initialize
transcriber = VideoTranscriber(
    whisper_path="/opt/whisper.cpp/main",
    temp_dir="/app/temp"
)

# Extract audio
audio_file = transcriber.extract_audio("input/video.mp4")

# Transcribe
result = transcriber.transcribe_audio(
    audio_file,
    model_path="/opt/whisper.cpp/models/ggml-base.bin",
    language="en"
)

# Full pipeline
transcriber.transcribe_video(
    "input/video.mp4",
    "/opt/whisper.cpp/models/ggml-base.bin",
    output_file="output/transcript.txt",
    language="en",
    format="txt"
)
```

### Custom Configuration
```python
# In config.py
SUPPORTED_VIDEO_FORMATS = ['.mp4', '.avi', '.mov', '.mkv']
SUPPORTED_AUDIO_FORMATS = ['.wav', '.mp3', '.m4a']
DEFAULT_LANGUAGE = 'en'
DEFAULT_MODEL = 'ggml-base.bin'
```

## 🆘 Getting Help

### Documentation
- **[README.md](README.md)** - Complete project guide
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Command reference

### Debugging Commands
```bash
# Quick system check
./setup-guide.sh

# Test application
docker-compose run --rm transcriber python3 transcriber.py --help

# Interactive debugging
docker-compose run --rm transcriber bash

# View logs
docker-compose logs transcriber
```

### Reporting Issues
When reporting issues, include:
- System information (`uname -a`, `docker --version`)
- Error logs (`docker-compose logs transcriber`)
- Complete error messages
- Steps to reproduce

---

**Happy Coding! 🎬📝**

This developer guide provides everything you need to work effectively with the Local Video Transcriber project. For additional help, refer to the specific documentation files or create an issue with detailed information. 