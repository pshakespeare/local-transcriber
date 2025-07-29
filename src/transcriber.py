#!/usr/bin/env python3
"""
Local Video Transcriber

A Python application that transcribes local video files using Whisper.cpp and FFmpeg.
"""

import os
import sys
import json
import subprocess
import tempfile
import shutil
from pathlib import Path
from typing import Optional, Dict, Any, List
import click
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn
from rich.panel import Panel
from rich.text import Text
from rich.table import Table
import tqdm
from . import config

console = Console()

class VideoTranscriber:
    """Main class for video transcription using Whisper.cpp and FFmpeg."""
    
    def __init__(self, whisper_path: str = None, temp_dir: str = None):
        """
        Initialize the transcriber.
        
        Args:
            whisper_path: Path to Whisper.cpp main executable
            temp_dir: Directory for temporary files
        """
        self.whisper_path = whisper_path or self._find_whisper_executable()
        
        # Use container temp directory if available
        if temp_dir is None:
            container_temp = os.environ.get('CONTAINER_TEMP_DIR', '/app/temp')
            if os.path.exists(container_temp):
                self.temp_dir = container_temp
            else:
                self.temp_dir = tempfile.gettempdir()
        else:
            self.temp_dir = temp_dir
            
        self.console = Console()
        
    def _find_whisper_executable(self) -> str:
        """Find the Whisper.cpp main executable."""
        # Check environment variable first (for containerized environments)
        whisper_dir = os.environ.get('WHISPER_CPP_DIR')
        if whisper_dir:
            container_path = os.path.join(whisper_dir, "main")
            if os.path.isfile(container_path) and os.access(container_path, os.X_OK):
                return container_path
        
        possible_paths = [
            # Container paths (preferred) - whisper-cli first
            "/opt/whisper.cpp/whisper-cli",  # Container path (preferred)
            "/opt/whisper.cpp/build/bin/whisper-cli",  # Alternative container path
            # Local development paths
            "./whisper.cpp/whisper-cli",
            "./whisper.cpp/build/bin/whisper-cli",
            "../whisper.cpp/whisper-cli",
            "../whisper.cpp/build/bin/whisper-cli",
            "~/whisper.cpp/whisper-cli",
            "~/whisper.cpp/build/bin/whisper-cli",
            # Fallback to main executable (deprecated but still works)
            "/opt/whisper.cpp/main",  # Container fallback
            "/opt/whisper.cpp/build/bin/main",  # Container fallback
            "./whisper.cpp/main",
            "./whisper.cpp/build/bin/main",
            "../whisper.cpp/main",
            "../whisper.cpp/build/bin/main",
            "~/whisper.cpp/main",
            "~/whisper.cpp/build/bin/main",
            "/usr/local/bin/whisper-main",
            "/opt/whisper.cpp/whisper-main"
        ]
        
        for path in possible_paths:
            expanded_path = os.path.expanduser(path)
            if os.path.isfile(expanded_path) and os.access(expanded_path, os.X_OK):
                return expanded_path
                
        # Try to find in PATH
        try:
            result = subprocess.run(["which", "whisper-main"], 
                                  capture_output=True, text=True, check=True)
            return result.stdout.strip()
        except subprocess.CalledProcessError:
            pass
            
        raise FileNotFoundError(
            "Whisper.cpp main executable not found. Please specify --whisper-path or "
            "ensure it's in your PATH as 'whisper-main'"
        )
    
    def _resolve_model_path(self, model_name_or_path: str) -> str:
        """Resolve model name to file path or validate custom path."""
        # If it's already a file path, validate it
        if os.path.isfile(model_name_or_path):
            return model_name_or_path
            
        # Check if it's a model name from config
        if model_name_or_path in config.WHISPER_MODELS:
            # Try to find the model file in common locations
            model_filename = f"ggml-{model_name_or_path}.bin"
            possible_paths = [
                f"./whisper.cpp/models/{model_filename}",
                f"~/whisper.cpp/models/{model_filename}",
                f"/opt/whisper.cpp/models/{model_filename}",
                f"/usr/local/whisper.cpp/models/{model_filename}",
                f"/app/input/{model_filename}"  # Allow models in input directory
            ]
            
            for path in possible_paths:
                expanded_path = os.path.expanduser(path)
                if os.path.isfile(expanded_path):
                    return expanded_path
                    
            # If not found, provide helpful error message
            raise FileNotFoundError(
                f"Model '{model_name_or_path}' not found. Please download it using:\n"
                f"cd whisper.cpp && ./models/download-ggml-model.sh {model_name_or_path}"
            )
        
        # If it's not a recognized model name, treat as file path
        if os.path.isfile(model_name_or_path):
            return model_name_or_path
        else:
            raise FileNotFoundError(
                f"Model file not found: {model_name_or_path}\n"
                f"Available models: {', '.join(config.WHISPER_MODELS.keys())}"
            )

    def _check_dependencies(self) -> None:
        """Check if required dependencies are available."""
        # Check FFmpeg
        try:
            subprocess.run(["ffmpeg", "-version"], 
                         capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            raise RuntimeError(
                "FFmpeg not found. Please install FFmpeg and ensure it's in your PATH."
            )
        
        # Check Whisper.cpp
        if not os.path.isfile(self.whisper_path):
            raise FileNotFoundError(f"Whisper.cpp executable not found at: {self.whisper_path}")
        
        if not os.access(self.whisper_path, os.X_OK):
            raise PermissionError(f"Whisper.cpp executable not executable: {self.whisper_path}")
    
    def extract_audio(self, video_path: str, output_path: str = None) -> str:
        """
        Extract audio from video file using FFmpeg.
        
        Args:
            video_path: Path to input video file
            output_path: Path for output audio file (optional)
            
        Returns:
            Path to extracted audio file
        """
        if output_path is None:
            video_name = Path(video_path).stem
            output_path = os.path.join(self.temp_dir, f"{video_name}_audio.wav")
        
        self.console.print(f"[blue]Extracting audio from video...[/blue]")
        
        # FFmpeg command to extract audio in Whisper-compatible format
        cmd = [
            "ffmpeg",
            "-i", video_path,
            "-ar", "16000",  # 16kHz sample rate
            "-ac", "1",      # Mono audio
            "-c:a", "pcm_s16le",  # 16-bit PCM
            "-y",  # Overwrite output file
            output_path
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            self.console.print(f"[green]✓ Audio extracted successfully: {output_path}[/green]")
            return output_path
        except subprocess.CalledProcessError as e:
            self.console.print(f"[red]✗ Audio extraction failed:[/red]")
            self.console.print(f"[red]Error: {e.stderr}[/red]")
            raise
    
    def transcribe_audio(self, audio_path: str, model_path: str, 
                        language: str = None, output_format: str = "txt") -> Dict[str, Any]:
        """
        Transcribe audio using Whisper.cpp.
        
        Args:
            audio_path: Path to audio file
            model_path: Path to Whisper model
            language: Language code (optional)
            output_format: Output format (txt, srt, vtt, json)
            
        Returns:
            Dictionary containing transcription results
        """
        self.console.print(f"[blue]Transcribing audio with Whisper.cpp...[/blue]")
        
        # Build Whisper.cpp command
        cmd = [self.whisper_path, "-m", model_path, "-f", audio_path]
        
        if language:
            cmd.extend(["-l", language])
        
        # Add output format
        if output_format == "json":
            cmd.append("-oj")
        elif output_format == "srt":
            cmd.append("-osrt")
        elif output_format == "vtt":
            cmd.append("-ovtt")
        else:  # txt format
            cmd.append("-otxt")
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            
            # Parse output based on format
            if output_format == "json":
                # Find the JSON output file
                json_path = audio_path.replace(".wav", ".json")
                if os.path.exists(json_path):
                    with open(json_path, 'r') as f:
                        return json.load(f)
                else:
                    # Parse stdout if JSON file not found
                    return json.loads(result.stdout)
            else:
                # For text-based formats, return the content
                output_file = audio_path.replace(".wav", f".{output_format}")
                if os.path.exists(output_file):
                    with open(output_file, 'r') as f:
                        return {"transcription": f.read()}
                else:
                    return {"transcription": result.stdout}
                    
        except subprocess.CalledProcessError as e:
            self.console.print(f"[red]✗ Transcription failed:[/red]")
            self.console.print(f"[red]Error: {e.stderr}[/red]")
            raise
        except json.JSONDecodeError as e:
            self.console.print(f"[red]✗ Failed to parse JSON output: {e}[/red]")
            raise
    
    def transcribe_video(self, video_path: str, model_name_or_path: str, 
                        output_path: str = None, language: str = None,
                        output_format: str = "txt", keep_audio: bool = False,
                        verbose: bool = False) -> str:
        """
        Complete video transcription pipeline.
        
        Args:
            video_path: Path to input video file
            model_path: Path to Whisper model
            output_path: Path for output file
            language: Language code
            output_format: Output format
            keep_audio: Whether to keep extracted audio file
            verbose: Enable verbose output
            
        Returns:
            Path to output file
        """
        try:
            # Check dependencies
            self._check_dependencies()
            
            # Validate inputs
            if not os.path.exists(video_path):
                raise FileNotFoundError(f"Video file not found: {video_path}")
            
            # Resolve model path
            model_path = self._resolve_model_path(model_name_or_path)
            
            # Generate output path if not provided
            if output_path is None:
                video_name = Path(video_path).stem
                output_path = f"{video_name}_transcript.{output_format}"
            
            # Create output directory if it doesn't exist
            output_dir = os.path.dirname(output_path)
            if output_dir and not os.path.exists(output_dir):
                os.makedirs(output_dir)
            
            with Progress(
                SpinnerColumn(),
                TextColumn("[progress.description]{task.description}"),
                BarColumn(),
                TaskProgressColumn(),
                console=self.console
            ) as progress:
                
                # Step 1: Extract audio
                task1 = progress.add_task("Extracting audio...", total=None)
                audio_path = self.extract_audio(video_path)
                progress.update(task1, completed=True)
                
                # Step 2: Transcribe audio
                task2 = progress.add_task("Transcribing audio...", total=None)
                result = self.transcribe_audio(audio_path, model_path, language, output_format)
                progress.update(task2, completed=True)
                
                # Step 3: Save output
                task3 = progress.add_task("Saving transcription...", total=None)
                
                if output_format == "json":
                    with open(output_path, 'w') as f:
                        json.dump(result, f, indent=2)
                else:
                    with open(output_path, 'w', encoding='utf-8') as f:
                        f.write(result.get("transcription", str(result)))
                
                progress.update(task3, completed=True)
                
                # Clean up audio file unless requested to keep it
                if not keep_audio and os.path.exists(audio_path):
                    os.remove(audio_path)
                    if verbose:
                        self.console.print(f"[dim]Removed temporary audio file: {audio_path}[/dim]")
                
                # Clean up intermediate files
                for ext in [".json", ".srt", ".vtt", ".txt"]:
                    temp_file = audio_path.replace(".wav", ext)
                    if os.path.exists(temp_file) and temp_file != output_path:
                        os.remove(temp_file)
                        if verbose:
                            self.console.print(f"[dim]Removed temporary file: {temp_file}[/dim]")
            
            self.console.print(f"[green]✓ Transcription completed successfully![/green]")
            self.console.print(f"[green]Output saved to: {output_path}[/green]")
            
            return output_path
            
        except Exception as e:
            self.console.print(f"[red]✗ Transcription failed: {str(e)}[/red]")
            raise

def display_info():
    """Display application information."""
    console.print(Panel.fit(
        "[bold blue]Local Video Transcriber[/bold blue]\n"
        "Transcribe local video files using Whisper.cpp and FFmpeg",
        title="Welcome"
    ))

def list_models():
    """Display available Whisper models."""
    table = Table(title="Available Whisper Models")
    table.add_column("Model", style="cyan", no_wrap=True)
    table.add_column("Size", style="magenta")
    table.add_column("Speed", style="yellow")
    table.add_column("Accuracy", style="green")
    table.add_column("Description", style="white")
    
    for model_name, model_info in config.WHISPER_MODELS.items():
        table.add_row(
            model_name,
            model_info['size'],
            model_info['speed'],
            model_info['accuracy'],
            model_info['description']
        )
    
    console.print(table)
    console.print("\n[bold]Usage:[/bold]")
    console.print("• Use model name: python3 -m src.transcriber transcribe -i video.mp4 -m base")
    console.print("• Use custom path: python3 -m src.transcriber transcribe -i video.mp4 -m /path/to/model.bin")

@click.group()
def cli():
    """Local Video Transcriber - Transcribe video files using Whisper.cpp and FFmpeg."""
    pass

@cli.command()
@click.option('--input', '-i', 'input_file', required=True,
              help='Input video file (MP4 format)')
@click.option('--model', '-m', 'model_path', required=True,
              help='Whisper model name (tiny, base, small, medium, large) or path to model file (.bin)')
@click.option('--output', '-o', 'output_file',
              help='Output file for transcription (default: auto-generated)')
@click.option('--whisper-path', '-w', 'whisper_path',
              help='Path to Whisper.cpp main executable')
@click.option('--language', '-l', 'language',
              help='Language code (e.g., "en", "es", "fr")')
@click.option('--format', '-f', 'output_format', default='txt',
              type=click.Choice(['txt', 'srt', 'vtt', 'json']),
              help='Output format')
@click.option('--temp-dir', '-t', 'temp_dir',
              help='Directory for temporary files')
@click.option('--keep-audio', '-k', is_flag=True,
              help='Keep extracted audio file after transcription')
@click.option('--verbose', '-v', is_flag=True,
              help='Enable verbose output')
def transcribe(input_file, model_path, output_file, whisper_path, language, 
         output_format, temp_dir, keep_audio, verbose):
    """Local Video Transcriber - Transcribe video files using Whisper.cpp and FFmpeg."""
    
    try:
        display_info()
        
        # Create transcriber instance
        transcriber = VideoTranscriber(whisper_path=whisper_path, temp_dir=temp_dir)
        
        # Display configuration
        if verbose:
            config_table = Table(title="Configuration")
            config_table.add_column("Setting", style="cyan")
            config_table.add_column("Value", style="green")
            
            config_table.add_row("Input File", input_file)
            config_table.add_row("Model Path", model_path)
            config_table.add_row("Output File", output_file or "auto-generated")
            config_table.add_row("Whisper Path", transcriber.whisper_path)
            config_table.add_row("Language", language or "auto-detect")
            config_table.add_row("Output Format", output_format)
            config_table.add_row("Temp Directory", transcriber.temp_dir)
            config_table.add_row("Keep Audio", str(keep_audio))
            
            console.print(config_table)
            console.print()
        
        # Perform transcription
        output_path = transcriber.transcribe_video(
            video_path=input_file,
            model_name_or_path=model_path,
            output_path=output_file,
            language=language,
            output_format=output_format,
            keep_audio=keep_audio,
            verbose=verbose
        )
        
        # Display success message
        console.print(Panel.fit(
            f"[bold green]Transcription completed successfully![/bold green]\n"
            f"Output saved to: [blue]{output_path}[/blue]",
            title="Success"
        ))
        
    except KeyboardInterrupt:
        console.print("\n[yellow]Transcription cancelled by user[/yellow]")
        sys.exit(1)
    except Exception as e:
        console.print(f"\n[red]Error: {str(e)}[/red]")
        if verbose:
            import traceback
            console.print(f"[red]{traceback.format_exc()}[/red]")
        sys.exit(1)

@cli.command()
def models():
    """List available Whisper models."""
    list_models()

if __name__ == "__main__":
    cli() 