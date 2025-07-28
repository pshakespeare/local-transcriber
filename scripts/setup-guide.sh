#!/bin/bash

# Local Video Transcriber - Comprehensive Setup Guide
# This script guides you through the complete setup process

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check system requirements
check_system_requirements() {
    print_header "System Requirements Check"
    
    # Check OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        print_success "OS: Linux detected"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        print_success "OS: macOS detected"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        print_warning "OS: Windows detected - Consider using WSL2"
    else
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
    
    # Check RAM
    if command_exists "free"; then
        RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
        if [ "$RAM_GB" -ge 4 ]; then
            print_success "RAM: ${RAM_GB}GB (Minimum 4GB required)"
        else
            print_error "RAM: ${RAM_GB}GB (Minimum 4GB required)"
            exit 1
        fi
    elif command_exists "vm_stat"; then
        # macOS
        RAM_GB=$(sysctl hw.memsize | awk '{print $2}')
        RAM_GB=$((RAM_GB / 1024 / 1024 / 1024))
        if [ "$RAM_GB" -ge 4 ]; then
            print_success "RAM: ${RAM_GB}GB (Minimum 4GB required)"
        else
            print_error "RAM: ${RAM_GB}GB (Minimum 4GB required)"
            exit 1
        fi
    else
        print_warning "Could not check RAM - please ensure you have at least 4GB"
    fi
    
    # Check disk space
    DISK_GB=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$DISK_GB" -ge 5 ]; then
        print_success "Disk space: ${DISK_GB}GB available (Minimum 5GB required)"
    else
        print_error "Disk space: ${DISK_GB}GB available (Minimum 5GB required)"
        exit 1
    fi
}

# Function to check and install prerequisites
check_prerequisites() {
    print_header "Prerequisites Check"
    
    local missing_deps=()
    
    # Check Docker
    if command_exists "docker"; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_success "Docker: $DOCKER_VERSION"
    else
        print_error "Docker not found"
        missing_deps+=("docker")
    fi
    
    # Check Docker Compose
    if command_exists "docker-compose"; then
        COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
        print_success "Docker Compose: $COMPOSE_VERSION"
    else
        print_error "Docker Compose not found"
        missing_deps+=("docker-compose")
    fi
    
    # Check Git
    if command_exists "git"; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        print_success "Git: $GIT_VERSION"
    else
        print_error "Git not found"
        missing_deps+=("git")
    fi
    
    # Check Make (Linux/macOS)
    if [[ "$OSTYPE" != "msys" ]] && [[ "$OSTYPE" != "cygwin" ]]; then
        if command_exists "make"; then
            MAKE_VERSION=$(make --version | head -n1 | cut -d' ' -f3)
            print_success "Make: $MAKE_VERSION"
        else
            print_error "Make not found"
            missing_deps+=("make")
        fi
    fi
    
    # If missing dependencies, provide installation instructions
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        print_header "Installation Instructions"
        
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "Ubuntu/Debian:"
            echo "  sudo apt-get update"
            echo "  sudo apt-get install -y docker.io docker-compose git make"
            echo ""
            echo "CentOS/RHEL:"
            echo "  sudo yum install -y docker docker-compose git make"
            echo ""
            echo "After installation, start Docker:"
            echo "  sudo systemctl start docker"
            echo "  sudo usermod -aG docker \$USER"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            echo "macOS:"
            echo "  # Install Docker Desktop from https://www.docker.com/products/docker-desktop"
            echo "  brew install git make"
        else
            echo "Windows:"
            echo "  # Install Docker Desktop from https://www.docker.com/products/docker-desktop"
            echo "  # Install Git from https://git-scm.com/download/win"
            echo "  # Consider using WSL2 for better compatibility"
        fi
        
        echo ""
        echo "After installing dependencies, run this script again."
        exit 1
    fi
    
    print_success "All prerequisites are installed!"
}

# Function to install Whisper.cpp
install_whisper_cpp() {
    print_header "Whisper.cpp Installation"
    
    # Check if Whisper.cpp is already installed
    if [ -n "$WHISPER_CPP_PATH" ] && [ -f "$WHISPER_CPP_PATH/main" ]; then
        print_success "Whisper.cpp already installed at: $WHISPER_CPP_PATH"
        return 0
    fi
    
    # Ask user for installation directory
    echo ""
    echo "Where would you like to install Whisper.cpp?"
    echo "1. Current directory (./whisper.cpp)"
    echo "2. Home directory (~/whisper.cpp)"
    echo "3. Custom path"
    echo "4. Skip (if already installed)"
    
    read -p "Choose option (1-4): " choice
    
    case $choice in
        1)
            WHISPER_CPP_PATH="./whisper.cpp"
            ;;
        2)
            WHISPER_CPP_PATH="$HOME/whisper.cpp"
            ;;
        3)
            read -p "Enter custom path: " WHISPER_CPP_PATH
            ;;
        4)
            read -p "Enter path to existing Whisper.cpp installation: " WHISPER_CPP_PATH
            if [ ! -f "$WHISPER_CPP_PATH/main" ]; then
                print_error "Whisper.cpp not found at: $WHISPER_CPP_PATH"
                exit 1
            fi
            print_success "Using existing Whisper.cpp at: $WHISPER_CPP_PATH"
            return 0
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$WHISPER_CPP_PATH")"
    
    # Clone Whisper.cpp
    print_status "Cloning Whisper.cpp repository..."
    if [ -d "$WHISPER_CPP_PATH" ]; then
        print_warning "Directory already exists, updating..."
        cd "$WHISPER_CPP_PATH"
        git pull origin master
    else
        git clone https://github.com/ggerganov/whisper.cpp.git "$WHISPER_CPP_PATH"
    fi
    
    # Navigate to Whisper.cpp directory
    cd "$WHISPER_CPP_PATH"
    
    # Install system dependencies
    print_status "Installing system dependencies..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists "apt-get"; then
            sudo apt-get update
            sudo apt-get install -y build-essential cmake
        elif command_exists "yum"; then
            sudo yum groupinstall -y "Development Tools"
            sudo yum install -y cmake
        else
            print_warning "Could not install dependencies automatically. Please install build-essential and cmake manually."
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command_exists "brew"; then
            brew install cmake
        else
            print_warning "Homebrew not found. Please install cmake manually."
        fi
    fi
    
    # Build Whisper.cpp
    print_status "Building Whisper.cpp..."
    make
    
    if [ -f "main" ]; then
        print_success "Whisper.cpp built successfully!"
    else
        print_error "Whisper.cpp build failed!"
        exit 1
    fi
    
    # Download a model
    print_status "Downloading base model..."
    if [ -f "models/download-ggml-model.sh" ]; then
        bash ./models/download-ggml-model.sh base
        if [ -f "models/ggml-base.bin" ]; then
            print_success "Base model downloaded successfully!"
        else
            print_error "Model download failed!"
            exit 1
        fi
    else
        print_warning "Model download script not found. Please download models manually."
    fi
    
    # Set environment variable
    export WHISPER_CPP_PATH="$WHISPER_CPP_PATH"
    echo "export WHISPER_CPP_PATH=\"$WHISPER_CPP_PATH\"" >> ~/.bashrc
    echo "export WHISPER_CPP_PATH=\"$WHISPER_CPP_PATH\"" >> ~/.zshrc
    
    print_success "Whisper.cpp installation completed!"
}

# Function to setup project
setup_project() {
    print_header "Project Setup"
    
    # Check if we're in the project directory
    if [ ! -f "docker-compose.yml" ]; then
        print_error "Please run this script from the project root directory"
        exit 1
    fi
    
    # Create necessary directories
    print_status "Creating directories..."
    mkdir -p input output temp
    chmod 755 input output temp
    
    # Build Docker image
    print_status "Building Docker image..."
    docker-compose build
    
    if [ $? -eq 0 ]; then
        print_success "Docker image built successfully!"
    else
        print_error "Docker build failed!"
        exit 1
    fi
    
    # Test installation
    print_status "Testing installation..."
    docker-compose run --rm transcriber python3 transcriber.py --help > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "Installation test passed!"
    else
        print_error "Installation test failed!"
        exit 1
    fi
}

# Function to provide usage examples
show_usage_examples() {
    print_header "Usage Examples"
    
    echo ""
    echo "Basic transcription:"
    echo "  docker-compose run --rm transcriber python3 transcriber.py \\"
    echo "    -i /app/input/my_video.mp4 \\"
    echo "    -m /opt/whisper.cpp/models/ggml-base.bin \\"
    echo "    -o /app/output/transcript.txt"
    echo ""
    
    echo "Generate subtitles:"
    echo "  docker-compose run --rm transcriber python3 transcriber.py \\"
    echo "    -i /app/input/my_video.mp4 \\"
    echo "    -m /opt/whisper.cpp/models/ggml-base.bin \\"
    echo "    -f srt \\"
    echo "    -o /app/output/my_video.srt"
    echo ""
    
    echo "Batch processing:"
    echo "  ./docker-batch.sh"
    echo ""
    
    echo "Interactive mode:"
    echo "  docker-compose run --rm transcriber"
    echo ""
}

# Function to show next steps
show_next_steps() {
    print_header "Next Steps"
    
    echo ""
    echo "1. Add your video files to the 'input' directory"
    echo "2. Run transcription commands (see examples above)"
    echo "3. Check the 'output' directory for results"
    echo ""
    echo "For more information, see the README.md file"
    echo ""
    echo "Happy transcribing! 🎬📝"
}

# Main execution
main() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Local Video Transcriber                   ║"
    echo "║                        Setup Guide                           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Check system requirements
    check_system_requirements
    
    # Check prerequisites
    check_prerequisites
    
    # Install Whisper.cpp
    install_whisper_cpp
    
    # Setup project
    setup_project
    
    # Show usage examples
    show_usage_examples
    
    # Show next steps
    show_next_steps
}

# Run main function
main "$@" 