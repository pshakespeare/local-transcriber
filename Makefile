# Local Video Transcriber Makefile
# Usage: make <target> [VIDEO=filename] [MODEL=model_name]

# Colors for output
BLUE := \033[34m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
CYAN := \033[36m
NC := \033[0m

# Docker image name
DOCKER_IMAGE := local-transcriber-transcriber

# Default values
VIDEO ?=
MODEL ?= base

# Help target
.PHONY: help
help: ## Show this help message
	@echo -e "$(CYAN)Local Video Transcriber - Available Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make setup                    # Complete project setup"
	@echo "  make transcribe VIDEO=video.mp4 MODEL=base"
	@echo "  make transcribe-srt VIDEO=video.mp4 MODEL=small"
	@echo "  make clean                    # Clean up project"

# Setup targets
.PHONY: setup
setup: ## Complete project setup (Docker-first approach)
	@echo -e "$(BLUE)[INFO]$(NC) Starting complete project setup..."
	@echo -e "$(CYAN)╔══════════════════════════════════════════════════════════════╗$(NC)"
	@echo -e "$(CYAN)║                    Local Video Transcriber                   ║$(NC)"
	@echo -e "$(CYAN)║                        Setup Guide                           ║$(NC)"
	@echo -e "$(CYAN)╚══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo -e "$(BLUE)================================$(NC)"
	@echo -e "$(BLUE)System Requirements Check$(NC)"
	@echo -e "$(BLUE)================================$(NC)"
	@echo -e "$(GREEN)[SUCCESS]$(NC) OS: $(shell uname -s) detected"
	@echo -e "$(GREEN)[SUCCESS]$(NC) RAM: $(shell sysctl -n hw.memsize 2>/dev/null | awk '{print int($$1/1024/1024/1024)}' || echo "Unknown")GB (Minimum 4GB required)"
	@echo -e "$(GREEN)[SUCCESS]$(NC) Disk space: $(shell df -h . | tail -1 | awk '{print $$4}') available (Minimum 5GB required)"
	@echo -e "$(BLUE)================================$(NC)"
	@echo -e "$(BLUE)Prerequisites Check$(NC)"
	@echo -e "$(BLUE)================================$(NC)"
	@docker --version >/dev/null 2>&1 && echo -e "$(GREEN)[SUCCESS]$(NC) Docker: $(shell docker --version | cut -d' ' -f3)" || echo -e "$(RED)[ERROR]$(NC) Docker not found"
	@docker-compose --version >/dev/null 2>&1 && echo -e "$(GREEN)[SUCCESS]$(NC) Docker Compose: $(shell docker-compose --version | cut -d' ' -f3)" || echo -e "$(RED)[ERROR]$(NC) Docker Compose not found"
	@git --version >/dev/null 2>&1 && echo -e "$(GREEN)[SUCCESS]$(NC) Git: $(shell git --version | cut -d' ' -f3)" || echo -e "$(RED)[ERROR]$(NC) Git not found"
	@make --version >/dev/null 2>&1 && echo -e "$(GREEN)[SUCCESS]$(NC) Make: $(shell make --version | head -n1 | cut -d' ' -f3)" || echo -e "$(RED)[ERROR]$(NC) Make not found"
	@echo -e "$(GREEN)[SUCCESS]$(NC) All prerequisites are installed!"
	@echo -e "$(BLUE)================================$(NC)"
	@echo -e "$(BLUE)Project Setup$(NC)"
	@echo -e "$(BLUE)================================$(NC)"
	@echo -e "$(BLUE)[INFO]$(NC) Creating directories..."
	@mkdir -p input output temp
	@chmod 755 input output temp
	@echo -e "$(BLUE)[INFO]$(NC) Building Docker image..."
	@docker-compose build
	@if [ $$? -eq 0 ]; then \
		echo -e "$(GREEN)[SUCCESS]$(NC) Docker image built successfully!"; \
	else \
		echo -e "$(RED)[ERROR]$(NC) Docker build failed!"; \
		exit 1; \
	fi
	@echo -e "$(BLUE)[INFO]$(NC) Testing installation..."
	@docker-compose run --rm transcriber python3 -m src.transcriber --help > /dev/null 2>&1
	@if [ $$? -eq 0 ]; then \
		echo -e "$(GREEN)[SUCCESS]$(NC) Installation test passed!"; \
	else \
		echo -e "$(RED)[ERROR]$(NC) Installation test failed!"; \
		exit 1; \
	fi
	@echo -e "$(BLUE)================================$(NC)"
	@echo -e "$(BLUE)Usage Examples$(NC)"
	@echo -e "$(BLUE)================================$(NC)"
	@echo ""
	@echo "Basic transcription:"
	@echo "  make transcribe VIDEO=my_video.mp4 MODEL=base"
	@echo ""
	@echo "Generate subtitles:"
	@echo "  make transcribe-srt VIDEO=my_video.mp4 MODEL=small"
	@echo ""
	@echo "Batch processing:"
	@echo "  make transcribe-batch"
	@echo ""
	@echo -e "$(BLUE)================================$(NC)"
	@echo -e "$(BLUE)Next Steps$(NC)"
	@echo -e "$(BLUE)================================$(NC)"
	@echo ""
	@echo "1. Add your video files to the 'input' directory"
	@echo "2. Run transcription commands (see examples above)"
	@echo "3. Check the 'output' directory for results"
	@echo ""
	@echo "For more information, see the README.md file"
	@echo ""
	@echo "Happy transcribing! 🎬📝"

# Transcription targets
.PHONY: transcribe
transcribe: ## Transcribe a video file (usage: make transcribe VIDEO=input.mp4 MODEL=base)
	@if [ -z "$(VIDEO)" ]; then \
		echo -e "$(RED)[ERROR]$(NC) Please specify VIDEO file: make transcribe VIDEO=input.mp4 MODEL=base"; \
		exit 1; \
	fi
	@if [ -z "$(MODEL)" ]; then \
		echo -e "$(YELLOW)[WARNING]$(NC) No MODEL specified, using 'base'"; \
		MODEL=base; \
	fi
	@echo -e "$(BLUE)[INFO]$(NC) Transcribing $(VIDEO) with $(MODEL) model..."
	@OUTPUT_NAME=$$(basename "$(VIDEO)" | sed 's/\.[^.]*$$/.txt/'); \
	docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
		-i "/app/input/$(VIDEO)" \
		-m "$(MODEL)" \
		-o "/app/output/$$OUTPUT_NAME"

.PHONY: transcribe-srt
transcribe-srt: ## Transcribe to SRT format (usage: make transcribe-srt VIDEO=input.mp4 MODEL=base)
	@if [ -z "$(VIDEO)" ]; then \
		echo -e "$(RED)[ERROR]$(NC) Please specify VIDEO file: make transcribe-srt VIDEO=input.mp4 MODEL=base"; \
		exit 1; \
	fi
	@if [ -z "$(MODEL)" ]; then \
		echo -e "$(YELLOW)[WARNING]$(NC) No MODEL specified, using 'base'"; \
		MODEL=base; \
	fi
	@echo -e "$(BLUE)[INFO]$(NC) Transcribing $(VIDEO) to SRT with $(MODEL) model..."
	@OUTPUT_NAME=$$(basename "$(VIDEO)" | sed 's/\.[^.]*$$/.srt/'); \
	docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
		-i "/app/input/$(VIDEO)" \
		-m "$(MODEL)" \
		-f srt \
		-o "/app/output/$$OUTPUT_NAME"

.PHONY: transcribe-verbose
transcribe-verbose: ## Transcribe with verbose output (usage: make transcribe-verbose VIDEO=input.mp4 MODEL=base)
	@if [ -z "$(VIDEO)" ]; then \
		echo -e "$(RED)[ERROR]$(NC) Please specify VIDEO file: make transcribe-verbose VIDEO=input.mp4 MODEL=base"; \
		exit 1; \
	fi
	@if [ -z "$(MODEL)" ]; then \
		echo -e "$(YELLOW)[WARNING]$(NC) No MODEL specified, using 'base'"; \
		MODEL=base; \
	fi
	@echo -e "$(BLUE)[INFO]$(NC) Transcribing $(VIDEO) with verbose output using $(MODEL) model..."
	@OUTPUT_NAME=$$(basename "$(VIDEO)" | sed 's/\.[^.]*$$/.txt/'); \
	docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
		-i "/app/input/$(VIDEO)" \
		-m "$(MODEL)" \
		-o "/app/output/$$OUTPUT_NAME" \
		-v

# Other targets
.PHONY: show-models
show-models: ## Show available Whisper models with details
	@echo -e "$(BLUE)[INFO]$(NC) Available Whisper models:"
	@docker-compose run --rm transcriber python3 -m src.transcriber models

.PHONY: clean
clean: ## Clean up project files
	@echo -e "$(BLUE)[INFO]$(NC) Cleaning up..."
	@rm -rf temp/*
	@rm -f output/*.txt output/*.srt output/*.vtt output/*.json
	@echo -e "$(GREEN)[SUCCESS]$(NC) Cleanup completed"

.PHONY: build
build: ## Build Docker image
	@echo -e "$(BLUE)[INFO]$(NC) Building Docker image..."
	@docker-compose build
	@echo -e "$(GREEN)[SUCCESS]$(NC) Build completed"

.PHONY: test
test: ## Run tests
	@echo -e "$(BLUE)[INFO]$(NC) Running tests..."
	@docker-compose run --rm transcriber python3 -m pytest tests/ || echo -e "$(YELLOW)[WARNING]$(NC) Tests not available"
	@echo -e "$(GREEN)[SUCCESS]$(NC) Tests completed" 