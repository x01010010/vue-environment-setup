#!/bin/bash

# Vue.js + TypeScript + Tailwind + Vuetify Setup Script (Master)
# This script orchestrates the setup by running modular scripts.

set -e # Exit on any error

# Find the script's own directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
SETUP_DIR="$SCRIPT_DIR/setup"

# Source all modular scripts
source "$SETUP_DIR/helpers.sh"
source "$SETUP_DIR/project.sh"
source "$SETUP_DIR/dependencies.sh"
source "$SETUP_DIR/configuration.sh"
source "$SETUP_DIR/testing.sh"
source "$SETUP_DIR/source_files.sh"
source "$SETUP_DIR/finalization.sh"
source "$SETUP_DIR/components.sh"
source "$SETUP_DIR/tests.sh"
source "$SETUP_DIR/documentation.sh"

# --- Main execution function ---
main() {
    print_status "Starting Vue.js + TypeScript development environment setup..."
    
    # --- Project Initialization ---
    check_prerequisites
    get_project_info "$1" "$2"
    
    # --- Scaffolding and Dependencies ---
    create_vue_project
    install_dependencies
    
    # --- Configuration ---
    setup_axios
    setup_tailwind
    setup_vuetify
    update_vite_config
    setup_typescript
    setup_eslint
    setup_testing
    
    # --- Source Code and Examples ---
    update_main_ts
    update_app_vue
    update_router_views
    create_example_components
    create_tests

    # --- Finalization ---
    update_package_scripts
    setup_git_hooks
    create_documentation
    
    # --- Completion Message ---
    print_status "🎉 Setup completed successfully!"
    echo ""
    print_status "Project created at: $PROJECT_PATH"
    echo ""
    print_status "Next steps:"
    echo "  npm run dev    # (you're already in the project directory)"
    echo ""
    print_status "Or if you need to navigate to the project later:"
    echo "  cd $PROJECT_PATH"
    echo "  npm run dev"
    echo ""
    print_status "Happy coding! 🚀"
}

# --- Script Entry Point ---
# Usage: ./vue_setup.sh [project_name] [target_directory]
# Example: ./vue_setup.sh MyApp /Users/username/Projects

# Run main function with all script arguments
main "$@"
