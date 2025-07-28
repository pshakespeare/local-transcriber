"""
Configuration settings for Local Video Transcriber
"""

import os
from pathlib import Path
import tempfile

# Default paths
DEFAULT_WHISPER_PATHS = [
    "./whisper.cpp/main",
    "../whisper.cpp/main",
    "~/whisper.cpp/main",
    "/usr/local/bin/whisper-main",
    "/opt/whisper.cpp/main"
]

# Default model paths
DEFAULT_MODEL_PATHS = [
    "./whisper.cpp/models/ggml-base.bin",
    "./whisper.cpp/models/ggml-base.en.bin",
    "./whisper.cpp/models/ggml-small.bin",
    "./whisper.cpp/models/ggml-medium.bin",
    "./whisper.cpp/models/ggml-large.bin",
    "~/whisper.cpp/models/ggml-base.bin",
    "~/whisper.cpp/models/ggml-base.en.bin",
    "~/whisper.cpp/models/ggml-small.bin",
    "~/whisper.cpp/models/ggml-medium.bin",
    "~/whisper.cpp/models/ggml-large.bin",
]

# Supported video formats
SUPPORTED_VIDEO_FORMATS = [
    '.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm', '.m4v'
]

# Supported audio formats for output
SUPPORTED_AUDIO_FORMATS = [
    '.wav', '.mp3', '.aac', '.ogg', '.flac'
]

# Output formats
OUTPUT_FORMATS = ['txt', 'srt', 'vtt', 'json']

# Language codes (common ones)
LANGUAGE_CODES = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'ja': 'Japanese',
    'ko': 'Korean',
    'zh': 'Chinese',
    'ar': 'Arabic',
    'hi': 'Hindi',
    'nl': 'Dutch',
    'sv': 'Swedish',
    'no': 'Norwegian',
    'da': 'Danish',
    'fi': 'Finnish',
    'pl': 'Polish',
    'tr': 'Turkish',
    'he': 'Hebrew',
    'th': 'Thai',
    'vi': 'Vietnamese',
    'id': 'Indonesian',
    'ms': 'Malay',
    'fa': 'Persian',
    'ur': 'Urdu',
    'bn': 'Bengali',
    'ta': 'Tamil',
    'te': 'Telugu',
    'ml': 'Malayalam',
    'kn': 'Kannada',
    'gu': 'Gujarati',
    'pa': 'Punjabi',
    'mr': 'Marathi',
    'ne': 'Nepali',
    'si': 'Sinhala',
    'my': 'Burmese',
    'km': 'Khmer',
    'lo': 'Lao',
    'ka': 'Georgian',
    'am': 'Amharic',
    'sw': 'Swahili',
    'zu': 'Zulu',
    'af': 'Afrikaans',
    'hr': 'Croatian',
    'cs': 'Czech',
    'sk': 'Slovak',
    'hu': 'Hungarian',
    'ro': 'Romanian',
    'bg': 'Bulgarian',
    'uk': 'Ukrainian',
    'be': 'Belarusian',
    'sl': 'Slovenian',
    'et': 'Estonian',
    'lv': 'Latvian',
    'lt': 'Lithuanian',
    'mt': 'Maltese',
    'ga': 'Irish',
    'cy': 'Welsh',
    'is': 'Icelandic',
    'fo': 'Faroese',
    'sq': 'Albanian',
    'mk': 'Macedonian',
    'sr': 'Serbian',
    'bs': 'Bosnian',
    'me': 'Montenegrin',
    'el': 'Greek',
    'hy': 'Armenian',
    'az': 'Azerbaijani',
    'kk': 'Kazakh',
    'ky': 'Kyrgyz',
    'uz': 'Uzbek',
    'tk': 'Turkmen',
    'tg': 'Tajik',
    'mn': 'Mongolian',
    'bo': 'Tibetan',
    'dz': 'Dzongkha',
    'ne': 'Nepali',
    'si': 'Sinhala',
    'my': 'Burmese',
    'km': 'Khmer',
    'lo': 'Lao',
    'ka': 'Georgian',
    'am': 'Amharic',
    'sw': 'Swahili',
    'zu': 'Zulu',
    'af': 'Afrikaans',
    'hr': 'Croatian',
    'cs': 'Czech',
    'sk': 'Slovak',
    'hu': 'Hungarian',
    'ro': 'Romanian',
    'bg': 'Bulgarian',
    'uk': 'Ukrainian',
    'be': 'Belarusian',
    'sl': 'Slovenian',
    'et': 'Estonian',
    'lv': 'Latvian',
    'lt': 'Lithuanian',
    'mt': 'Maltese',
    'ga': 'Irish',
    'cy': 'Welsh',
    'is': 'Icelandic',
    'fo': 'Faroese',
    'sq': 'Albanian',
    'mk': 'Macedonian',
    'sr': 'Serbian',
    'bs': 'Bosnian',
    'me': 'Montenegrin',
    'el': 'Greek',
    'hy': 'Armenian',
    'az': 'Azerbaijani',
    'kk': 'Kazakh',
    'ky': 'Kyrgyz',
    'uz': 'Uzbek',
    'tk': 'Turkmen',
    'tg': 'Tajik',
    'mn': 'Mongolian',
    'bo': 'Tibetan',
    'dz': 'Dzongkha'
}

# FFmpeg audio extraction settings
FFMPEG_AUDIO_SETTINGS = {
    'sample_rate': '16000',  # 16kHz
    'channels': '1',         # Mono
    'codec': 'pcm_s16le',   # 16-bit PCM
    'format': 'wav'         # WAV format
}

# Whisper.cpp model sizes and their characteristics
WHISPER_MODELS = {
    'tiny': {
        'size': '39 MB',
        'speed': 'Fast',
        'accuracy': 'Low',
        'description': 'Fastest model, suitable for real-time transcription'
    },
    'base': {
        'size': '142 MB',
        'speed': 'Fast',
        'accuracy': 'Medium',
        'description': 'Good balance of speed and accuracy'
    },
    'base.en': {
        'size': '142 MB',
        'speed': 'Fast',
        'accuracy': 'Medium',
        'description': 'English-only model, faster than base'
    },
    'small': {
        'size': '466 MB',
        'speed': 'Medium',
        'accuracy': 'Good',
        'description': 'Better accuracy than base models'
    },
    'small.en': {
        'size': '466 MB',
        'speed': 'Medium',
        'accuracy': 'Good',
        'description': 'English-only small model'
    },
    'medium': {
        'size': '1.5 GB',
        'speed': 'Slow',
        'accuracy': 'Very Good',
        'description': 'High accuracy, slower processing'
    },
    'medium.en': {
        'size': '1.5 GB',
        'speed': 'Slow',
        'accuracy': 'Very Good',
        'description': 'English-only medium model'
    },
    'large': {
        'size': '2.9 GB',
        'speed': 'Very Slow',
        'accuracy': 'Best',
        'description': 'Highest accuracy, slowest processing'
    },
    'large-v2': {
        'size': '2.9 GB',
        'speed': 'Very Slow',
        'accuracy': 'Best',
        'description': 'Latest large model with improved accuracy'
    }
}

def get_default_temp_dir():
    """Get the default temporary directory."""
    return os.path.join(tempfile.gettempdir(), 'local-transcriber')

def get_default_output_dir():
    """Get the default output directory."""
    return os.path.join(os.getcwd(), 'transcriptions')

def validate_language_code(language_code):
    """Validate if a language code is supported."""
    return language_code in LANGUAGE_CODES

def get_language_name(language_code):
    """Get the full language name from a language code."""
    return LANGUAGE_CODES.get(language_code, 'Unknown')

def validate_output_format(format_name):
    """Validate if an output format is supported."""
    return format_name in OUTPUT_FORMATS

def validate_video_format(file_path):
    """Validate if a file has a supported video format."""
    return Path(file_path).suffix.lower() in SUPPORTED_VIDEO_FORMATS 