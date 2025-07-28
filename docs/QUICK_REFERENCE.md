# Quick Reference - Local Video Transcriber

## 🚀 One-Minute Setup

```bash
# 1. Install Whisper.cpp
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp && make
bash ./models/download-ggml-model.sh base

# 2. Setup project
export WHISPER_CPP_PATH=/path/to/whisper.cpp
make setup-quick
make build

# 3. Transcribe
make transcribe VIDEO=video.mp4
```

## 📋 Essential Commands

### Basic Usage
```bash
# Transcribe video
make transcribe VIDEO=video.mp4

# Generate subtitles
make transcribe-srt VIDEO=video.mp4

# Batch process
make transcribe-batch

# Or traditional Docker commands
docker-compose run --rm transcriber python3 transcriber.py \
    -i /app/input/video.mp4 \
    -m /opt/whisper.cpp/models/ggml-base.bin
```

### Model Management
```bash
# Download models
cd /path/to/whisper.cpp
bash ./models/download-ggml-model.sh base    # ~1GB
bash ./models/download-ggml-model.sh small   # ~500MB
bash ./models/download-ggml-model.sh large   # ~3GB
```

### Docker Operations
```bash
# Build image
make build

# Rebuild (no cache)
make build-no-cache

# Check logs
make logs

# Interactive shell
make shell

# Or traditional Docker commands
docker-compose build
docker-compose build --no-cache
docker-compose logs transcriber
docker-compose run --rm transcriber bash
```

## 🔧 Configuration

### Environment Variables
```bash
export WHISPER_CPP_PATH=/path/to/whisper.cpp
export WHISPER_CPP_DIR=/opt/whisper.cpp  # Container path
```

### Volume Mounts
```yaml
# docker-compose.yml
volumes:
  - ./input:/app/input:ro          # Video files
  - ./output:/app/output           # Results
  - ./temp:/app/temp               # Temporary files
  - ${WHISPER_CPP_PATH}:/opt/whisper.cpp  # Whisper.cpp
```

## 📊 Model Comparison

| Model | Size | Speed | Accuracy | Use Case |
|-------|------|-------|----------|----------|
| `tiny` | ~75MB | Fastest | Basic | Testing |
| `base` | ~1GB | Fast | Good | General |
| `small` | ~500MB | Medium | Better | Balanced |
| `medium` | ~1.5GB | Slower | High | Professional |
| `large` | ~3GB | Slowest | Best | High accuracy |

## 🌍 Language Support

```bash
# Auto-detect language
docker-compose run --rm transcriber python3 transcriber.py \
    -i /app/input/video.mp4 -m /opt/whisper.cpp/models/ggml-base.bin

# Specify language
docker-compose run --rm transcriber python3 transcriber.py \
    -i /app/input/video.mp4 -m /opt/whisper.cpp/models/ggml-base.bin \
    -l en  # en, es, fr, de, zh, ja, ko, etc.
```

## 📄 Output Formats

```bash
-f txt   # Plain text
-f srt   # SubRip subtitles
-f vtt   # WebVTT
-f json  # Structured data
```

## 🐛 Troubleshooting

### Common Issues

**Docker build fails:**
```bash
docker-compose build --no-cache
```

**Whisper.cpp not found:**
```bash
echo $WHISPER_CPP_PATH
ls -la $WHISPER_CPP_PATH/main
```

**Model not found:**
```bash
ls -la $WHISPER_CPP_PATH/models/ggml-base.bin
cd $WHISPER_CPP_PATH && bash ./models/download-ggml-model.sh base
```

**Permission issues:**
```bash
chmod 755 input output temp
```

**Memory issues:**
```bash
# Use smaller model
-m /opt/whisper.cpp/models/ggml-tiny.bin
```

### Performance Tuning

```bash
# Increase Docker memory
# Docker Desktop: Settings > Resources > Memory > 8GB

# Use parallel processing
parallel -j 2 docker-compose run --rm transcriber python3 transcriber.py \
    -i /app/input/{} -m /opt/whisper.cpp/models/ggml-base.bin \
    -o /app/output/{.}.txt ::: input/*.mp4
```

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
name: Transcribe
on: [push]
jobs:
  transcribe:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: docker-compose build
      - name: Transcribe
        run: |
          docker-compose run --rm transcriber python3 transcriber.py \
            -i /app/input/video.mp4 \
            -m /opt/whisper.cpp/models/ggml-base.bin
```

### Docker Registry
```bash
# Build and push
docker build -t myregistry/local-transcriber:latest .
docker push myregistry/local-transcriber:latest

# Deploy
docker-compose -f docker-compose.prod.yml up -d
```

## 📚 API Reference

### Command Line
```bash
python3 transcriber.py [OPTIONS]

Options:
  -i, --input TEXT                Input video file [required]
  -m, --model TEXT                Whisper model file [required]
  -o, --output TEXT               Output file (auto-generated)
  -l, --language TEXT             Language code (en, es, fr, etc.)
  -f, --format [txt|srt|vtt|json] Output format
  -k, --keep-audio                Keep extracted audio
  -v, --verbose                   Verbose output
```

### Python API
```python
from transcriber import VideoTranscriber

transcriber = VideoTranscriber()
result = transcriber.transcribe_video(
    "input/video.mp4",
    "/opt/whisper.cpp/models/ggml-base.bin",
    output_file="output/transcript.txt",
    language="en",
    format="txt"
)
```

## 🆘 Getting Help

```bash
# Show help
make help

# Test application
make test-help

# Check system info
make check-prerequisites

# View logs
make logs

# Interactive debugging
make shell

# Or traditional commands
docker-compose run --rm transcriber python3 transcriber.py --help
docker --version
docker-compose --version
echo $WHISPER_CPP_PATH
docker-compose logs transcriber
docker-compose run --rm transcriber bash
```

## 📁 Project Structure

```
local-transcriber/
├── Dockerfile                 # Container definition
├── docker-compose.yml         # Orchestration
├── Makefile                   # Project management
├── transcriber.py            # Main application
├── setup-guide.sh            # Interactive setup
├── input/                    # Video files
├── output/                   # Results
└── temp/                     # Temporary files
```

---

**Need more help?** See `README.md` for comprehensive documentation or `MAKEFILE_GUIDE.md` for Makefile details. 