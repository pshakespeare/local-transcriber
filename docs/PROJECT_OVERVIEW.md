# Project Overview - Local Video Transcriber

## 🎯 Project Vision

The Local Video Transcriber is a containerized Python application designed to provide a robust, scalable, and privacy-focused solution for video transcription. It leverages Whisper.cpp for local AI-powered transcription and FFmpeg for audio processing, all packaged in Docker for consistent deployment across environments.

## 🏗️ Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Host System                              │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐  │
│  │   Input Videos  │    │   Docker        │    │   Output    │  │
│  │   (MP4 files)   │───▶│   Container     │───▶│   Files     │  │
│  └─────────────────┘    └─────────────────┘    └─────────────┘  │
│           │                       │                      │      │
│           ▼                       ▼                      ▼      │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐  │
│  │   Whisper.cpp   │    │   Python App    │    │   Results   │  │
│  │   (Local)       │    │   (Container)   │    │   (TXT/SRT) │  │
│  └─────────────────┘    └─────────────────┘    └─────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Component Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Docker Container                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐  │
│  │   FFmpeg        │    │   Whisper.cpp   │    │   Python    │  │
│  │   (Audio        │───▶│   (Transcription)│───▶│   App       │  │
│  │   Extraction)   │    │                 │    │   (CLI)     │  │
│  └─────────────────┘    └─────────────────┘    └─────────────┘  │
│           │                       │                      │      │
│           ▼                       ▼                      ▼      │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐  │
│  │   WAV Audio     │    │   AI Models     │    │   Output    │  │
│  │   (16kHz, Mono) │    │   (GGML)        │    │   Formats   │  │
│  └─────────────────┘    └─────────────────┘    └─────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 Technical Stack

### Core Technologies

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Container Runtime** | Docker | 20.10+ | Application isolation and deployment |
| **Orchestration** | Docker Compose | 2.0+ | Multi-container management |
| **Programming Language** | Python | 3.8+ | Application logic and CLI |
| **Audio Processing** | FFmpeg | Latest | Video to audio conversion |
| **AI Transcription** | Whisper.cpp | Latest | Local speech recognition |
| **CLI Framework** | Click | 8.1+ | Command-line interface |
| **UI Framework** | Rich | 13.7+ | Terminal output formatting |

### Dependencies

#### System Dependencies
- **Ubuntu 22.04**: Base container OS
- **Build Tools**: gcc, make, cmake for Whisper.cpp compilation
- **Python 3.8+**: Runtime environment
- **FFmpeg**: Audio/video processing

#### Python Dependencies
```python
click==8.1.7          # CLI framework
rich==13.7.0          # Terminal formatting
pathlib2==2.3.7       # Path utilities
tqdm==4.66.1          # Progress bars
```

## 📁 Project Structure

```
local-transcriber/
├── 📄 Documentation
│   ├── README.md              # Comprehensive guide
│   ├── QUICK_REFERENCE.md     # Quick commands
│   ├── TROUBLESHOOTING.md     # Issue resolution
│   └── PROJECT_OVERVIEW.md    # This file
│
├── 🐳 Docker Configuration
│   ├── Dockerfile             # Container definition
│   ├── docker-compose.yml     # Orchestration
│   ├── .dockerignore          # Build exclusions
│   └── docker-setup.sh        # Setup automation
│
├── 🐍 Python Application
│   ├── transcriber.py         # Main application
│   ├── config.py              # Configuration
│   ├── setup_whisper.py       # Whisper.cpp setup
│   ├── example.py             # Usage examples
│   ├── quick_start.py         # Interactive setup
│   └── requirements.txt       # Dependencies
│
├── 📁 Data Directories
│   ├── input/                 # Video input files
│   ├── output/                # Transcription results
│   └── temp/                  # Temporary files
│
└── 🔧 Utility Scripts
    ├── setup-guide.sh         # Interactive setup
    └── docker-batch.sh        # Batch processing
```

## 🔄 Data Flow

### 1. Input Processing
```
Video File (MP4) → FFmpeg → WAV Audio (16kHz, Mono, 16-bit PCM)
```

### 2. Transcription Pipeline
```
WAV Audio → Whisper.cpp → Raw Transcription → Format Conversion → Output File
```

### 3. Output Generation
```
Raw Text → Format Processing → TXT/SRT/VTT/JSON → File Output
```

## 🎛️ Configuration Management

### Environment Variables

| Variable | Default | Description | Usage |
|----------|---------|-------------|-------|
| `WHISPER_CPP_PATH` | None | Host path to Whisper.cpp | Volume mounting |
| `WHISPER_CPP_DIR` | `/opt/whisper.cpp` | Container path | Application config |
| `CONTAINER_TEMP_DIR` | `/app/temp` | Temp directory | File processing |

### Volume Mounts

| Host Path | Container Path | Access | Purpose |
|-----------|----------------|--------|---------|
| `./input` | `/app/input` | Read-only | Video files |
| `./output` | `/app/output` | Read/Write | Results |
| `./temp` | `/app/temp` | Read/Write | Temporary files |
| `$WHISPER_CPP_PATH` | `/opt/whisper.cpp` | Read-only | Whisper.cpp installation |

## 🔐 Security Considerations

### Container Security
- **Non-root User**: Application runs as `transcriber` user (UID 1000)
- **Read-only Mounts**: Input directory mounted read-only
- **Minimal Base Image**: Ubuntu 22.04 with minimal packages
- **No Network Access**: Container operates offline for transcription

### Data Privacy
- **Local Processing**: All transcription happens locally
- **No API Calls**: No external services required
- **Temporary Files**: Audio files cleaned up automatically
- **Volume Isolation**: Data isolated in mounted volumes

## 📊 Performance Characteristics

### Resource Requirements

| Component | Minimum | Recommended | Notes |
|-----------|---------|-------------|-------|
| **RAM** | 4GB | 8GB+ | Model loading and processing |
| **CPU** | 2 cores | 4+ cores | Parallel processing |
| **Storage** | 5GB | 10GB+ | Models + temporary files |
| **Network** | None | None | Offline operation |

### Performance Metrics

| Model | Size | Speed | Memory | Accuracy |
|-------|------|-------|--------|----------|
| `tiny` | ~75MB | ~2x real-time | ~1GB | Basic |
| `base` | ~1GB | ~1x real-time | ~2GB | Good |
| `small` | ~500MB | ~0.8x real-time | ~1.5GB | Better |
| `medium` | ~1.5GB | ~0.5x real-time | ~3GB | High |
| `large` | ~3GB | ~0.3x real-time | ~4GB | Best |

## 🔄 CI/CD Integration

### Build Pipeline
```yaml
# GitHub Actions Example
name: Build and Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker-compose build
      - name: Run tests
        run: docker-compose run --rm transcriber python3 -m pytest
```

### Deployment Options

#### Local Development
```bash
# Development setup
docker-compose build
docker-compose run --rm transcriber python3 transcriber.py --help
```

#### Production Deployment
```bash
# Production build
docker build -t myregistry/local-transcriber:latest .
docker push myregistry/local-transcriber:latest

# Production run
docker-compose -f docker-compose.prod.yml up -d
```

#### Kubernetes Deployment
```yaml
# Kubernetes manifest example
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

### Unit Testing
- **Python Modules**: pytest for application logic
- **CLI Commands**: Click testing utilities
- **Configuration**: Environment variable validation

### Integration Testing
- **Docker Build**: Container creation and startup
- **Volume Mounts**: File system access verification
- **End-to-End**: Complete transcription pipeline

### Performance Testing
- **Memory Usage**: Resource consumption monitoring
- **Processing Speed**: Transcription time measurement
- **Scalability**: Batch processing validation

## 🔍 Monitoring and Logging

### Logging Levels
```python
# Application logging
import logging
logging.basicConfig(level=logging.INFO)

# Rich console output
from rich.console import Console
console = Console()
```

### Health Checks
```yaml
# Docker health check
healthcheck:
  test: ["CMD", "python3", "-c", "import transcriber; print('OK')"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### Metrics Collection
- **Processing Time**: Transcription duration tracking
- **Success Rate**: Error vs. success ratio
- **Resource Usage**: CPU, memory, disk utilization

## 🔄 Version Management

### Semantic Versioning
```
MAJOR.MINOR.PATCH
├── MAJOR: Breaking changes
├── MINOR: New features, backward compatible
└── PATCH: Bug fixes, backward compatible
```

### Dependency Management
- **Python**: requirements.txt with pinned versions
- **Docker**: Base image version pinning
- **Whisper.cpp**: Git commit hash tracking

## 🚀 Future Enhancements

### Planned Features
- **GPU Acceleration**: CUDA support for faster processing
- **Batch Processing**: Queue-based job management
- **Web Interface**: REST API and web UI
- **Cloud Integration**: S3, GCS storage support
- **Multi-language**: Parallel language processing

### Technical Improvements
- **Microservices**: Service decomposition
- **Caching**: Model and result caching
- **Streaming**: Real-time transcription
- **Optimization**: Memory and performance tuning

## 📚 Development Guidelines

### Code Standards
- **Python**: PEP 8 compliance
- **Documentation**: Docstring and inline comments
- **Testing**: Minimum 80% code coverage
- **Type Hints**: Full type annotation

### Git Workflow
```bash
# Feature development
git checkout -b feature/new-feature
# Development work
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
# Create pull request
```

### Code Review Process
1. **Automated Checks**: Linting, testing, security scanning
2. **Manual Review**: Code quality and architecture review
3. **Integration Testing**: End-to-end validation
4. **Documentation**: README and API documentation updates

---

This project overview provides a comprehensive understanding of the Local Video Transcriber architecture, design decisions, and technical implementation details for developers and DevOps engineers. 