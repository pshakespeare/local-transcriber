"""
Tests for the VideoTranscriber class
"""

import pytest
import tempfile
import os
from unittest.mock import Mock, patch
from src.transcriber import VideoTranscriber
from src.config import SUPPORTED_FORMATS, LANGUAGE_CODES


class TestVideoTranscriber:
    """Test cases for VideoTranscriber class"""

    def setup_method(self):
        """Set up test fixtures"""
        self.temp_dir = tempfile.mkdtemp()
        self.transcriber = VideoTranscriber(temp_dir=self.temp_dir)

    def teardown_method(self):
        """Clean up test fixtures"""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_transcriber_initialization(self):
        """Test VideoTranscriber initialization"""
        assert self.transcriber is not None
        assert hasattr(self.transcriber, 'temp_dir')
        assert self.transcriber.temp_dir == self.temp_dir

    def test_supported_formats(self):
        """Test supported output formats"""
        assert 'txt' in SUPPORTED_FORMATS
        assert 'srt' in SUPPORTED_FORMATS
        assert 'vtt' in SUPPORTED_FORMATS
        assert 'json' in SUPPORTED_FORMATS

    def test_language_codes(self):
        """Test language codes configuration"""
        assert 'en' in LANGUAGE_CODES
        assert 'es' in LANGUAGE_CODES
        assert 'fr' in LANGUAGE_CODES
        assert len(LANGUAGE_CODES) > 50  # Should support many languages

    @patch('src.transcriber.subprocess.run')
    def test_ffmpeg_check(self, mock_run):
        """Test FFmpeg availability check"""
        mock_run.return_value.returncode = 0
        result = self.transcriber._check_ffmpeg()
        assert result is True

    @patch('src.transcriber.subprocess.run')
    def test_ffmpeg_check_failure(self, mock_run):
        """Test FFmpeg check when not available"""
        mock_run.return_value.returncode = 1
        result = self.transcriber._check_ffmpeg()
        assert result is False

    def test_validate_input_file_missing(self):
        """Test input file validation with missing file"""
        with pytest.raises(FileNotFoundError):
            self.transcriber._validate_input_file("nonexistent.mp4")

    def test_validate_output_format_valid(self):
        """Test output format validation with valid format"""
        result = self.transcriber._validate_output_format("txt")
        assert result is True

    def test_validate_output_format_invalid(self):
        """Test output format validation with invalid format"""
        with pytest.raises(ValueError):
            self.transcriber._validate_output_format("invalid")

    def test_validate_language_valid(self):
        """Test language validation with valid language"""
        result = self.transcriber._validate_language("en")
        assert result is True

    def test_validate_language_invalid(self):
        """Test language validation with invalid language"""
        with pytest.raises(ValueError):
            self.transcriber._validate_language("invalid")

    def test_create_temp_file(self):
        """Test temporary file creation"""
        temp_file = self.transcriber._create_temp_file("test", "wav")
        assert os.path.exists(temp_file)
        assert temp_file.endswith(".wav")
        os.remove(temp_file)

    def test_cleanup_temp_files(self):
        """Test temporary file cleanup"""
        # Create a temporary file
        temp_file = self.transcriber._create_temp_file("test", "wav")
        assert os.path.exists(temp_file)
        
        # Clean up
        self.transcriber._cleanup_temp_files([temp_file])
        assert not os.path.exists(temp_file)


class TestConfig:
    """Test cases for configuration"""

    def test_whisper_models(self):
        """Test Whisper model configuration"""
        from src.config import WHISPER_MODELS
        assert 'tiny' in WHISPER_MODELS
        assert 'base' in WHISPER_MODELS
        assert 'small' in WHISPER_MODELS
        assert 'medium' in WHISPER_MODELS
        assert 'large' in WHISPER_MODELS

    def test_model_characteristics(self):
        """Test model characteristics"""
        from src.config import WHISPER_MODELS
        for model_name, model_info in WHISPER_MODELS.items():
            assert 'size_mb' in model_info
            assert 'params' in model_info
            assert 'multilingual' in model_info
            assert 'english_only' in model_info
            assert 'speed' in model_info
            assert 'accuracy' in model_info


if __name__ == "__main__":
    pytest.main([__file__]) 