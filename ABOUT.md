# 🎬 Local Video Transcriber

**Privacy-first, containerized video transcription using AI - no internet required!**

A production-ready Python application that transcribes MP4 videos to text using Whisper.cpp and FFmpeg, all running locally on your computer. Perfect for content creators, researchers, and anyone who needs fast, private video transcription.

## ✨ Key Features

- 🔒 **100% Private** - All processing happens locally, no data sent to external servers
- 🐳 **Docker Ready** - One-command setup and deployment
- ⚡ **Fast Processing** - Real-time to 2x real-time depending on model size
- 🌍 **99+ Languages** - Automatic language detection and support
- 📄 **Multiple Formats** - TXT, SRT, VTT, JSON output
- 🎛️ **Flexible Models** - Tiny to Large Whisper models for speed vs accuracy
- 🔄 **Batch Processing** - Process multiple videos efficiently
- 🛠️ **Production Ready** - Comprehensive testing, CI/CD, and documentation

## 🚀 Quick Start

```bash
# Setup (one-time)
make setup

# Transcribe a video
make transcribe VIDEO=my_video.mp4

# Generate subtitles
make transcribe-srt VIDEO=my_video.mp4
```

## ✅ Proven Results

**Successfully transcribed a 37-minute technical meeting:**
- **Input**: M4A audio file (37:13 duration)
- **Processing**: ~75 seconds with Whisper Base model
- **Output**: TXT, SRT, VTT, and JSON formats
- **Content**: Technical discussion about AWS infrastructure optimization
- **Quality**: High accuracy with automatic language detection

**Perfect for:** Content creators, researchers, accessibility, data analysis, and anyone who values privacy in AI transcription.

---

*Built with Python, Docker, Whisper.cpp, and FFmpeg. MIT Licensed.* 