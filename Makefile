# Local Video Transcriber - Makefile
# Provides easy commands for managing the project

# Configuration
PROJECT_NAME := local-transcriber
DOCKER_IMAGE := $(PROJECT_NAME)-transcriber
DOCKER_COMPOSE_FILE := docker-compose.yml
PYTHON := python3
PIP := pip3

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
NC := \033[0m # No Color

# Help target
.PHONY: help
help: ## Show this help message
	@echo -e "$(CYAN)╔══════════════════════════════════════════════════════════════╗$(NC)"
	@echo -e "$(CYAN)║                    Local Video Transcriber                   ║$(NC)"
	@echo -e "$(CYAN)║                        Makefile Help                         ║$(NC)"
	@echo -e "$(CYAN)╚══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo -e "$(BLUE)Available commands:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo -e "$(YELLOW)Examples:$(NC)"
	@echo "  make setup          # Complete project setup"
	@echo "  make build          # Build Docker image"
	@echo "  make test           # Run tests"
	@echo "  make transcribe     # Transcribe a video file"
	@echo "  make clean          # Clean up project"

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

.PHONY: setup-quick
setup-quick: ## Quick setup (non-interactive)
	@echo -e "$(BLUE)[INFO]$(NC) Quick setup..."
	@mkdir -p input output temp
	@chmod 755 input output temp
	@echo -e "$(GREEN)[SUCCESS]$(NC) Directories created"
	@echo -e "$(BLUE)[INFO]$(NC) Building Docker image..."
	@docker-compose build
	@echo -e "$(GREEN)[SUCCESS]$(NC) Setup complete! Ready to transcribe."

.PHONY: check-prerequisites
check-prerequisites: ## Check system prerequisites
	@echo -e "$(BLUE)[INFO]$(NC) Checking prerequisites..."
	@echo "=== System Information ==="
	@uname -a
	@echo ""
	@echo "=== Docker ==="
	@docker --version || echo -e "$(RED)[ERROR]$(NC) Docker not found"
	@docker-compose --version || echo -e "$(RED)[ERROR]$(NC) Docker Compose not found"
	@echo ""
	@echo "=== Git ==="
	@git --version || echo -e "$(RED)[ERROR]$(NC) Git not found"
	@echo ""
	@echo "=== Make ==="
	@make --version | head -n1 || echo -e "$(RED)[ERROR]$(NC) Make not found"
	@echo ""
	@echo "=== Docker Image ==="
	@if docker images | grep -q "$(DOCKER_IMAGE)"; then \
		echo -e "$(GREEN)[SUCCESS]$(NC) Docker image found"; \
	else \
		echo -e "$(YELLOW)[WARNING]$(NC) Docker image not found. Run 'make build' to create it."; \
	fi

# Docker targets
.PHONY: build
build: ## Build Docker image
	@echo -e "$(BLUE)[INFO]$(NC) Building Docker image..."
	@docker-compose build
	@echo -e "$(GREEN)[SUCCESS]$(NC) Docker image built"

.PHONY: build-no-cache
build-no-cache: ## Build Docker image (no cache)
	@echo -e "$(BLUE)[INFO]$(NC) Building Docker image (no cache)..."
	@docker-compose build --no-cache
	@echo -e "$(GREEN)[SUCCESS]$(NC) Docker image built"

.PHONY: up
up: ## Start containers
	@echo -e "$(BLUE)[INFO]$(NC) Starting containers..."
	@docker-compose up -d
	@echo -e "$(GREEN)[SUCCESS]$(NC) Containers started"

.PHONY: down
down: ## Stop containers
	@echo -e "$(BLUE)[INFO]$(NC) Stopping containers..."
	@docker-compose down
	@echo -e "$(GREEN)[SUCCESS]$(NC) Containers stopped"

.PHONY: logs
logs: ## Show container logs
	@docker-compose logs transcriber

.PHONY: shell
shell: ## Open shell in container
	@docker-compose run --rm transcriber bash

# Testing targets
.PHONY: test
test: ## Run all tests
	@echo -e "$(BLUE)[INFO]$(NC) Running tests..."
	@docker-compose run --rm transcriber python3 -m pytest || echo -e "$(YELLOW)[WARNING]$(NC) No pytest tests found"
	@echo -e "$(GREEN)[SUCCESS]$(NC) Tests completed"

.PHONY: test-help
test-help: ## Test help command
	@echo -e "$(BLUE)[INFO]$(NC) Testing help command..."
	@docker-compose run --rm transcriber python3 -m src.transcriber --help
	@echo -e "$(GREEN)[SUCCESS]$(NC) Help command works"

.PHONY: test-ffmpeg
test-ffmpeg: ## Test FFmpeg installation
	@echo -e "$(BLUE)[INFO]$(NC) Testing FFmpeg..."
	@docker-compose run --rm transcriber ffmpeg -version
	@echo -e "$(GREEN)[SUCCESS]$(NC) FFmpeg works"

.PHONY: test-whisper
test-whisper: ## Test Whisper.cpp installation
	@echo -e "$(BLUE)[INFO]$(NC) Testing Whisper.cpp..."
	@docker-compose run --rm transcriber /opt/whisper.cpp/main --help
	@echo -e "$(GREEN)[SUCCESS]$(NC) Whisper.cpp works"

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
	@docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
		-i "/app/input/$(VIDEO)" \
		-m "$(MODEL)" \
		-o "/app/output/$(basename $(VIDEO) .$(suffix $(VIDEO))).txt"

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
	@docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
		-i "/app/input/$(VIDEO)" \
		-m "$(MODEL)" \
		-f srt \
		-o "/app/output/$(basename $(VIDEO) .$(suffix $(VIDEO))).srt"

.PHONY: transcribe-batch
transcribe-batch: ## Batch transcribe all videos in input directory
	@echo -e "$(BLUE)[INFO]$(NC) Batch transcribing videos..."
	@chmod +x docker-batch.sh
	@./docker-batch.sh

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
	@docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
		-i "/app/input/$(VIDEO)" \
		-m "$(MODEL)" \
		-o "/app/output/$(basename $(VIDEO) .$(suffix $(VIDEO))).txt" \
		-v

# Model management targets
.PHONY: download-model
download-model: ## Download Whisper model (usage: make download-model MODEL=base)
	@if [ -z "$(MODEL)" ]; then \
		echo -e "$(RED)[ERROR]$(NC) Please specify MODEL: make download-model MODEL=base"; \
		exit 1; \
	fi
	@if [ -z "$(WHISPER_CPP_PATH)" ]; then \
		echo -e "$(RED)[ERROR]$(NC) WHISPER_CPP_PATH not set"; \
		exit 1; \
	fi
	@echo -e "$(BLUE)[INFO]$(NC) Downloading $(MODEL) model..."
	@cd $(WHISPER_CPP_PATH) && bash ./models/download-ggml-model.sh $(MODEL)
	@echo -e "$(GREEN)[SUCCESS]$(NC) Model downloaded"

.PHONY: list-models
list-models: ## List available models
	@if [ -z "$(WHISPER_CPP_PATH)" ]; then \
		echo -e "$(RED)[ERROR]$(NC) WHISPER_CPP_PATH not set"; \
		exit 1; \
	fi
	@echo -e "$(BLUE)[INFO]$(NC) Available models:"
	@ls -la $(WHISPER_CPP_PATH)/models/ || echo -e "$(YELLOW)[WARNING]$(NC) No models found"

.PHONY: show-models
show-models: ## Show available Whisper models with details
	@echo -e "$(BLUE)[INFO]$(NC) Available Whisper models:"
	@docker-compose run --rm transcriber python3 -m src.transcriber models

# Development targets
.PHONY: format
format: ## Format Python code
	@echo -e "$(BLUE)[INFO]$(NC) Formatting code..."
	@docker-compose run --rm transcriber python3 -m black . || echo -e "$(YELLOW)[WARNING]$(NC) Black not available"
	@echo -e "$(GREEN)[SUCCESS]$(NC) Code formatted"

.PHONY: lint
lint: ## Lint Python code
	@echo -e "$(BLUE)[INFO]$(NC) Linting code..."
	@docker-compose run --rm transcriber python3 -m flake8 . || echo -e "$(YELLOW)[WARNING]$(NC) Flake8 not available"
	@echo -e "$(GREEN)[SUCCESS]$(NC) Code linted"

.PHONY: type-check
type-check: ## Type check Python code
	@echo -e "$(BLUE)[INFO]$(NC) Type checking code..."
	@docker-compose run --rm transcriber python3 -m mypy . || echo -e "$(YELLOW)[WARNING]$(NC) MyPy not available"
	@echo -e "$(GREEN)[SUCCESS]$(NC) Type checking completed"

# Performance targets
.PHONY: benchmark
benchmark: ## Benchmark transcription (usage: make benchmark VIDEO=input.mp4 MODEL=base)
	@if [ -z "$(VIDEO)" ]; then \
		echo -e "$(RED)[ERROR]$(NC) Please specify VIDEO file: make benchmark VIDEO=input.mp4 MODEL=base"; \
		exit 1; \
	fi
	@if [ -z "$(MODEL)" ]; then \
		echo -e "$(YELLOW)[WARNING]$(NC) No MODEL specified, using 'base'"; \
		MODEL=base; \
	fi
	@echo -e "$(BLUE)[INFO]$(NC) Benchmarking transcription of $(VIDEO) with $(MODEL) model..."
	@time docker-compose run --rm transcriber python3 -m src.transcriber transcribe \
		-i "/app/input/$(VIDEO)" \
		-m "$(MODEL)" \
		-o "/app/output/$(VIDEO:.mp4=.txt)"

.PHONY: memory-check
memory-check: ## Check memory usage during transcription
	@echo -e "$(BLUE)[INFO]$(NC) Monitoring memory usage..."
	@docker stats --no-stream local-transcriber-transcriber || echo -e "$(YELLOW)[WARNING]$(NC) Container not running"

# Cleanup targets
.PHONY: clean
clean: ## Clean up temporary files
	@echo -e "$(BLUE)[INFO]$(NC) Cleaning up..."
	@rm -rf temp/*
	@rm -rf output/*.tmp
	@echo -e "$(GREEN)[SUCCESS]$(NC) Cleanup completed"

.PHONY: clean-docker
clean-docker: ## Clean up Docker resources
	@echo -e "$(BLUE)[INFO]$(NC) Cleaning Docker resources..."
	@docker-compose down
	@docker system prune -f
	@echo -e "$(GREEN)[SUCCESS]$(NC) Docker cleanup completed"

.PHONY: clean-all
clean-all: ## Clean everything (Docker, temp files, output)
	@echo -e "$(BLUE)[INFO]$(NC) Cleaning everything..."
	@make clean
	@make clean-docker
	@rm -rf output/*
	@echo -e "$(GREEN)[SUCCESS]$(NC) Complete cleanup finished"

# Deployment targets
.PHONY: deploy-build
deploy-build: ## Build production image
	@echo -e "$(BLUE)[INFO]$(NC) Building production image..."
	@docker build -t $(PROJECT_NAME):latest .
	@echo -e "$(GREEN)[SUCCESS]$(NC) Production image built"

.PHONY: deploy-push
deploy-push: ## Push to registry (usage: make deploy-push REGISTRY=myregistry)
	@if [ -z "$(REGISTRY)" ]; then \
		echo -e "$(RED)[ERROR]$(NC) Please specify REGISTRY: make deploy-push REGISTRY=myregistry"; \
		exit 1; \
	fi
	@echo -e "$(BLUE)[INFO]$(NC) Pushing to registry..."
	@docker tag $(PROJECT_NAME):latest $(REGISTRY)/$(PROJECT_NAME):latest
	@docker push $(REGISTRY)/$(PROJECT_NAME):latest
	@echo -e "$(GREEN)[SUCCESS]$(NC) Image pushed to registry"

.PHONY: deploy
deploy: ## Deploy to production
	@echo -e "$(BLUE)[INFO]$(NC) Deploying to production..."
	@docker-compose -f docker-compose.prod.yml up -d
	@echo -e "$(GREEN)[SUCCESS]$(NC) Deployed to production"

# Utility targets
.PHONY: status
status: ## Show project status
	@echo -e "$(BLUE)[INFO]$(NC) Project status:"
	@echo "=== Docker ==="
	@docker-compose ps
	@echo ""
	@echo "=== Directories ==="
	@ls -la input/ output/ temp/ 2>/dev/null || echo "Directories not found"
	@echo ""
	@echo "=== Environment ==="
	@echo "WHISPER_CPP_PATH: $(WHISPER_CPP_PATH)"
	@echo ""
	@echo "=== Disk Usage ==="
	@du -sh input/ output/ temp/ 2>/dev/null || echo "Cannot check disk usage"

.PHONY: info
info: ## Show detailed project information
	@echo -e "$(BLUE)[INFO]$(NC) Project information:"
	@echo "=== System ==="
	@uname -a
	@echo ""
	@echo "=== Docker ==="
	@docker --version
	@docker-compose --version
	@echo ""
	@echo "=== Project ==="
	@echo "Project name: $(PROJECT_NAME)"
	@echo "Docker image: $(DOCKER_IMAGE)"
	@echo "Compose file: $(DOCKER_COMPOSE_FILE)"
	@echo ""
	@echo "=== Whisper.cpp ==="
	@if [ -n "$(WHISPER_CPP_PATH)" ]; then \
		echo "Path: $(WHISPER_CPP_PATH)"; \
		if [ -f "$(WHISPER_CPP_PATH)/main" ]; then \
			echo "Status: Installed"; \
		else \
			echo "Status: Not found"; \
		fi; \
	else \
		echo "Status: WHISPER_CPP_PATH not set"; \
	fi

.PHONY: validate
validate: ## Validate project setup
	@echo -e "$(BLUE)[INFO]$(NC) Validating project setup..."
	@echo "=== Prerequisites ==="
	@make check-prerequisites
	@echo ""
	@echo "=== Docker ==="
	@docker-compose config > /dev/null && echo -e "$(GREEN)[SUCCESS]$(NC) Docker Compose config valid" || echo -e "$(RED)[ERROR]$(NC) Docker Compose config invalid"
	@echo ""
	@echo "=== Application ==="
	@make test-help > /dev/null && echo -e "$(GREEN)[SUCCESS]$(NC) Application works" || echo -e "$(RED)[ERROR]$(NC) Application not working"

# Documentation targets
.PHONY: docs
docs: ## Generate documentation
	@echo -e "$(BLUE)[INFO]$(NC) Documentation is already comprehensive"
	@echo "Available documentation:"
	@echo "  README.md              - Complete project guide"
	@echo "  DEVELOPER_GUIDE.md     - Developer entry point"
	@echo "  QUICK_REFERENCE.md     - Command cheat sheet"
	@echo "  TROUBLESHOOTING.md     - Issue resolution"
	@echo "  PROJECT_OVERVIEW.md    - Technical architecture"

.PHONY: readme
readme: ## Show README
	@cat README.md

# CI/CD targets
.PHONY: ci-build
ci-build: ## CI build target
	@echo -e "$(BLUE)[INFO]$(NC) CI build..."
	@make check-prerequisites
	@make build
	@make test-help
	@echo -e "$(GREEN)[SUCCESS]$(NC) CI build completed"

.PHONY: ci-test
ci-test: ## CI test target
	@echo -e "$(BLUE)[INFO]$(NC) CI testing..."
	@make test
	@make format
	@make lint
	@echo -e "$(GREEN)[SUCCESS]$(NC) CI testing completed"

# Convenience targets
.PHONY: all
all: ## Run complete setup and build
	@make setup-quick
	@make build
	@make test-help

.PHONY: quick
quick: ## Quick transcription (usage: make quick VIDEO=input.mp4)
	@if [ -z "$(VIDEO)" ]; then \
		echo -e "$(RED)[ERROR]$(NC) Please specify VIDEO file: make quick VIDEO=input.mp4"; \
		exit 1; \
	fi
	@make transcribe VIDEO=$(VIDEO)

.PHONY: dev
dev: ## Development mode
	@echo -e "$(BLUE)[INFO]$(NC) Starting development mode..."
	@docker-compose run --rm -v $(PWD):/app transcriber bash

# Special targets
.PHONY: .PHONY
.PHONY: ## Phony target for dependency management

# Include additional makefiles if they exist
-include Makefile.local
-include Makefile.prod

# Print variables for debugging
.PHONY: debug
debug: ## Print make variables
	@echo "PROJECT_NAME: $(PROJECT_NAME)"
	@echo "DOCKER_IMAGE: $(DOCKER_IMAGE)"
	@echo "DOCKER_COMPOSE_FILE: $(DOCKER_COMPOSE_FILE)"
	@echo "PYTHON: $(PYTHON)"
	@echo "PIP: $(PIP)"
	@echo "WHISPER_CPP_PATH: $(WHISPER_CPP_PATH)" 