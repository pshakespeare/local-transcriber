# Local Video Transcriber

A containerized Python application for transcribing local video files using Whisper.cpp and FFmpeg. Get up and running in minutes with Docker - no complex setup required!

## 🚀 Quick Start (3 minutes)

### 1. Prerequisites
```bash
# Verify you have Docker and Make installed
docker --version && docker-compose --version && make --version
```

### 2. Setup Project
```bash
# Clone this repository
git clone <repository-url>
cd local-transcriber

# Run the complete setup (builds Docker image with Whisper.cpp included)
make setup
```

### 3. Transcribe Your First Video
```bash
# Add your video to the input directory
cp /path/to/your/video.mp4 input/

# Transcribe using Make (easiest way)
make transcribe VIDEO=video.mp4 MODEL=base

# Check your results
ls -la output/
```

**That's it!** Your transcription will be saved in the `output/` directory.

## 🎯 What It Does

- **🎬 Extracts audio** from video files (MP4, M4A, AVI, MOV, MKV, WebM) using FFmpeg
- **🎤 Transcribes audio** using Whisper.cpp (local, no API calls, no internet required)
- **📝 Supports multiple formats**: TXT, SRT, VTT, JSON
- **🐳 Runs in Docker** for consistent, portable deployment
- **🌍 Supports 99+ languages** with automatic detection
- **⚡ Fast and efficient** - processes files locally

## 🔧 Essential Commands

### Quick Transcription
```bash
# Basic transcription (recommended for most users)
make transcribe VIDEO=my_video.mp4 MODEL=base

# Generate subtitles for video editing
make transcribe-srt VIDEO=my_video.mp4 MODEL=small

# High-quality transcription
make transcribe VIDEO=my_video.mp4 MODEL=medium

# Batch process all videos in input folder
make transcribe-batch
```

### Setup & Management
```bash
make help                    # Show all available commands
make setup                   # Complete project setup (builds everything)
make build                   # Rebuild Docker image
make clean                   # Clean temporary files
make show-models             # List available models
```

## 🎯 Model Selection

Choose the right model for your needs:

| Model | Size | Speed | Accuracy | Best For |
|-------|------|-------|----------|----------|
| `tiny` | 39 MB | ⚡⚡⚡ | Basic | Quick drafts, testing |
| `base` | 142 MB | ⚡⚡ | Good | **General purpose** ✅ |
| `small` | 466 MB | ⚡ | Better | Balanced performance |
| `medium` | 1.5 GB | 🐌 | High | Professional use |
| `large` | 2.9 GB | 🐌🐌 | Best | High accuracy required |

### Quick Examples
```bash
# Quick test transcription
make transcribe VIDEO=video.mp4 MODEL=tiny

# General purpose (recommended)
make transcribe VIDEO=video.mp4 MODEL=base

# Better quality for important content
make transcribe VIDEO=video.mp4 MODEL=small

# Professional quality
make transcribe VIDEO=video.mp4 MODEL=medium
```

## 📁 Project Structure

```
local-transcriber/
├── input/                    # 📁 Add your videos here
├── output/                   # 📄 Transcriptions appear here
├── temp/                     # 🔧 Temporary files (auto-cleaned)
├── src/                      # 🐍 Python source code
├── scripts/                  # 🔧 Automation scripts
├── docs/                     # 📚 Documentation
├── Makefile                  # ⚡ 40+ automation commands
├── docker-compose.yml        # 🐳 Docker orchestration
└── README.md                 # 📖 This file
```

## 🐳 Docker Commands (Advanced)

### Basic Docker Usage
```bash
# Build the image (included in make setup)
docker-compose build

# Run transcription directly
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
    -i /app/input/video.mp4 -m base -o /app/output/transcript.txt

# Interactive shell for debugging
docker-compose run --rm transcriber bash
```

### Advanced Options
```bash
# Transcribe with specific language and format
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
    -i /app/input/video.mp4 \
    -m small \
    -l en \
    -f srt \
    -o /app/output/video.srt \
    -v

# Keep extracted audio file for reuse
docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
    -i /app/input/video.mp4 \
    -m medium \
    -k \
    -o /app/output/transcript.txt
```

## ✅ Real-World Example

**Successfully transcribed a 37-minute technical meeting:**

```bash
# Input: M4A audio file (37:13 duration)
# Model: Whisper Base (142MB)
# Processing time: ~75 seconds
# Language: English (auto-detected)

# Output files created:
# - transcript.txt (32.8 KB) - Plain text
# - transcript.srt (39.6 KB) - Subtitles for video editing
# - transcript.vtt (38.9 KB) - Web video subtitles
# - transcript.json (64.8 KB) - Detailed metadata with timestamps
```

## 🔧 Development & Testing

### Code Quality
```bash
make format                   # Format Python code
make lint                     # Lint code
make type-check               # Type checking
make test                     # Run tests
```

### Performance Testing
```bash
make benchmark VIDEO=video.mp4 MODEL=base
make memory-check
```

### Troubleshooting
```bash
make check-prerequisites      # Verify system requirements
make logs                     # View container logs
make shell                    # Interactive container shell
```

## 🆘 Common Issues & Solutions

### "Docker not found"
```bash
# Install Docker Desktop for your OS
# macOS: https://docs.docker.com/desktop/install/mac-install/
# Windows: https://docs.docker.com/desktop/install/windows-install/
# Linux: https://docs.docker.com/engine/install/
```

### "Make not found"
```bash
# macOS: Install Xcode Command Line Tools
xcode-select --install

# Ubuntu/Debian:
sudo apt-get install make

# Windows: Use WSL or install Make for Windows
```

### "Permission denied"
```bash
# Make sure Docker has permission to access your directories
chmod 755 input output temp
```

### "Model not found"
```bash
# The base model is included by default
# For other models, use:
make download-model MODEL=small
```

## 📚 Additional Resources

- **Quick Reference**: `docs/QUICK_REFERENCE.md` - Command cheat sheet
- **Troubleshooting**: `docs/TROUBLESHOOTING.md` - Detailed issue resolution
- **Developer Guide**: `docs/DEVELOPER_GUIDE.md` - For contributors
- **Makefile Guide**: `docs/MAKEFILE_GUIDE.md` - All available commands

## 🎯 Project Status

**✅ Fully Functional and Production Ready!**

- ✅ Whisper.cpp built and included in Docker image
- ✅ Base model pre-downloaded and ready to use
- ✅ Transcription tested with real-world audio (37+ minutes)
- ✅ Multiple output formats working (TXT, SRT, VTT, JSON)
- ✅ Comprehensive documentation and examples
- ✅ 40+ Makefile commands for easy automation
- ✅ Ready for production use

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for contribution guidelines.

---

**Happy transcribing! 🎬📝**

*Need help? Check the troubleshooting guide or open an issue!* 