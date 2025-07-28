"""
Local Video Transcriber

A production-ready, containerized Python application for local video transcription using AI.
"""

__version__ = "1.0.0"
__author__ = "Local Video Transcriber Team"
__email__ = "support@local-transcriber.com"

from .transcriber import VideoTranscriber
from .config import *

__all__ = [
    "VideoTranscriber",
    "SUPPORTED_FORMATS",
    "LANGUAGE_CODES",
    "WHISPER_MODELS",
] 