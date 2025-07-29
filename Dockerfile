# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV WHISPER_CPP_DIR=/opt/whisper.cpp
ENV PATH="${WHISPER_CPP_DIR}:${PATH}"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    make \
    cmake \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    ffmpeg \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Clone and build Whisper.cpp
RUN git clone https://github.com/ggerganov/whisper.cpp.git ${WHISPER_CPP_DIR} \
    && cd ${WHISPER_CPP_DIR} \
    && cmake -B build \
    && cmake --build build --parallel \
    && ln -sf ${WHISPER_CPP_DIR}/build/bin/main ${WHISPER_CPP_DIR}/main \
    && ln -sf ${WHISPER_CPP_DIR}/build/bin/whisper-cli ${WHISPER_CPP_DIR}/whisper-cli

# Create models directory and download base model
RUN mkdir -p ${WHISPER_CPP_DIR}/models \
    && cd ${WHISPER_CPP_DIR} \
    && bash ./models/download-ggml-model.sh base

# Copy application files
COPY src/ ./src/
COPY scripts/ ./scripts/
COPY docs/ ./docs/
COPY .github/ ./.github/
COPY *.md ./
COPY *.yml ./
COPY *.yaml ./
COPY *.toml ./
COPY *.txt ./
COPY *.sh ./

# Create directories for input/output
RUN mkdir -p /app/input /app/output /app/temp

# Set permissions
RUN chmod +x scripts/*.sh

# Create a non-root user
RUN useradd -m -u 1000 transcriber \
    && chown -R transcriber:transcriber /app \
    && chown -R transcriber:transcriber ${WHISPER_CPP_DIR}

# Switch to non-root user
USER transcriber

# Set working directory
WORKDIR /app

# Expose volumes for input/output
VOLUME ["/app/input", "/app/output", "/app/temp"]

# Default command
CMD ["python3", "-m", "src.transcriber", "--help"] 