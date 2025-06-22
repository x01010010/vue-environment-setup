#!/bin/bash

# Functions for checking prerequisites and creating the project structure

# Check if required tools are installed
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js is required but not installed. Please install Node.js 18+ first."
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "npm is required but not installed."
        exit 1
    fi
    
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        print_error "Node.js 18+ is required. Current version: $(node --version)"
        exit 1
    fi
    
    print_status "Prerequisites check passed ✓"
}

# Get project name and target directory
get_project_info() {
    # Get project name
    if [ -z "$1" ]; then
        read -p "Enter project name: " PROJECT_NAME
    else
        PROJECT_NAME=$1
    fi
    
    if [ -z "$PROJECT_NAME" ]; then
        print_error "Project name is required"
        exit 1
    fi
    
    # Get target directory
    if [ -z "$2" ]; then
        echo ""
        print_status "Where would you like to create the project?"
        echo "  Enter full path (e.g., /Users/username/Projects)"
        echo "  Or press Enter for current directory: $(pwd)"
        read -p "Target directory: " TARGET_DIR
        
        if [ -z "$TARGET_DIR" ]; then
            TARGET_DIR=$(pwd)
        fi
    else
        TARGET_DIR=$2
    fi
    
    # Expand tilde to home directory if used
    TARGET_DIR="${TARGET_DIR/#\~/$HOME}"
    
    # Create target directory if it doesn't exist
    if [ ! -d "$TARGET_DIR" ]; then
        print_status "Creating target directory: $TARGET_DIR"
        mkdir -p "$TARGET_DIR" || {
            print_error "Failed to create directory: $TARGET_DIR"
            exit 1
        }
    fi
    
    # Check if project directory already exists in target
    PROJECT_PATH="$TARGET_DIR/$PROJECT_NAME"
    if [ -d "$PROJECT_PATH" ]; then
        print_error "Directory '$PROJECT_PATH' already exists"
        exit 1
    fi
    
    print_status "Project will be created at: $PROJECT_PATH"
}

# Create Vue project with Vite and TypeScript
create_vue_project() {
    print_step "Creating Vue project with Vite and TypeScript..."
    
    # Navigate to target directory
    cd "$TARGET_DIR"
    
    npm create vue@latest "$PROJECT_NAME" -- \
        --typescript \
        --jsx \
        --router \
        --pinia \
        --vitest \
        --cypress \
        --eslint \
        --prettier
    
    cd "$PROJECT_NAME"
    
    # Remove default boilerplate files that are not used
    print_status "Removing default boilerplate files..."
    rm -f src/components/TheWelcome.vue
    rm -f src/components/WelcomeItem.vue
    rm -rf src/components/icons
    
    print_status "Vue project created at: $PROJECT_PATH ✓"
} 