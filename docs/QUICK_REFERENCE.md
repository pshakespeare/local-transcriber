# Quick Reference - Local Video Transcriber

## 🚀 One-Minute Setup

```bash
# 1. Clone and setup (everything included)
git clone <repository-url>
cd local-transcriber
make setup

# 2. Transcribe your first video
cp /path/to/your/video.mp4 input/
make transcribe VIDEO=video.mp4 MODEL=base
```

## 📋 Essential Commands

### Basic Usage
```bash
# Transcribe video (recommended)
make transcribe VIDEO=video.mp4 MODEL=base

# Transcribe audio file (M4A, MP3, etc.)
make transcribe VIDEO=audio.m4a MODEL=base

# Generate subtitles
make transcribe-srt VIDEO=video.mp4 MODEL=small

# Batch process all videos
make transcribe-batch

# Or direct Docker commands
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
    -i /app/input/video.mp4 \
    -m base \
    -o /app/output/transcript.txt
```

### Model Management
```bash
# List available models
make show-models

# Download additional models (optional)
make download-model MODEL=small
make download-model MODEL=medium
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
# No environment variables needed for basic usage
# Whisper.cpp is built inside the container
# Models are pre-downloaded during Docker build
```

### Volume Mounts
```yaml
# docker-compose.yml (automatically configured)
volumes:
  - ./input:/app/input:ro          # Video files
  - ./output:/app/output           # Results
  - ./temp:/app/temp               # Temporary files
  - ./src:/app/src                 # Source code (development)
```

## 📊 Model Comparison

| Model | Size | Speed | Accuracy | Use Case |
|-------|------|-------|----------|----------|
| `tiny` | 39 MB | ⚡⚡⚡ | Basic | Testing |
| `base` | 142 MB | ⚡⚡ | Good | **General** ✅ |
| `small` | 466 MB | ⚡ | Better | Balanced |
| `medium` | 1.5 GB | 🐌 | High | Professional |
| `large` | 2.9 GB | 🐌🐌 | Best | High accuracy |

## 🌍 Language Support

```bash
# Auto-detect language (default)
make transcribe VIDEO=video.mp4 MODEL=base

# Specify language
make transcribe VIDEO=video.mp4 MODEL=base LANGUAGE=en
make transcribe VIDEO=video.mp4 MODEL=base LANGUAGE=es
make transcribe VIDEO=video.mp4 MODEL=base LANGUAGE=fr
```

## 📝 Output Formats

```bash
# Plain text (default)
make transcribe VIDEO=video.mp4 MODEL=base
```

## 📁 Output File Naming

```bash
# Input files and their output
video.mp4    → video.txt
audio.m4a    → audio.txt
presentation.mov → presentation.txt
meeting.avi  → meeting.txt

# All output files use .txt extension regardless of input format
# SRT files use .srt extension: video.mp4 → video.srt
```

# Subtitles for video editing
make transcribe-srt VIDEO=video.mp4 MODEL=base

# Web video subtitles
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
    -i /app/input/video.mp4 \
    -m base \
    -f vtt \
    -o /app/output/video.vtt

# Detailed JSON with timestamps
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
    -i /app/input/video.mp4 \
    -m base \
    -f json \
    -o /app/output/video.json
```

## 🚀 Advanced Usage

### Verbose Output
```bash
make transcribe-verbose VIDEO=video.mp4 MODEL=base
```

### Keep Audio Files
```bash
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
    -i /app/input/video.mp4 \
    -m base \
    -k \
    -o /app/output/transcript.txt
```

### Custom Temp Directory
```bash
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
            -i /app/input/video.mp4 \
    -m base \
    -t /app/temp/custom \
    -o /app/output/transcript.txt
```

### Performance Testing
```bash
make benchmark VIDEO=video.mp4 MODEL=base
```

## 🔍 Troubleshooting

### Common Issues
```bash
# Check prerequisites
make check-prerequisites

# View logs
make logs

# Interactive debugging
make shell

# Clean and rebuild
make clean
make build-no-cache
```

### Reset Everything
```bash
make clean
docker-compose down
docker system prune -f
make setup
```

## 📁 File Structure

```
local-transcriber/
├── input/                    # 📁 Add videos here
├── output/                   # 📄 Results here
├── temp/                     # 🔧 Auto-cleaned
├── src/                      # 🐍 Source code
├── scripts/                  # 🔧 Automation
├── docs/                     # 📚 Documentation
├── Makefile                  # ⚡ 40+ commands
└── docker-compose.yml        # 🐳 Container config
```

## 🎯 Quick Examples

```bash
# Test with tiny model (fastest)
make transcribe VIDEO=test.mp4 MODEL=tiny

# General purpose (recommended)
make transcribe VIDEO=meeting.mp4 MODEL=base

# High quality for important content
make transcribe VIDEO=presentation.mp4 MODEL=small

# Professional quality
make transcribe VIDEO=interview.mp4 MODEL=medium

# Batch process everything
make transcribe-batch
```

---

**Need help?** Check `docs/TROUBLESHOOTING.md` or run `make help` 