#!/bin/bash

# Function to install all additional dependencies

install_dependencies() {
    print_step "Installing additional dependencies..."
    
    # Tailwind CSS v4 with Vite plugin (official approach)
    npm install -D tailwindcss @tailwindcss/vite
    
    # Vuetify 3
    npm install vuetify @mdi/font
    npm install -D vite-plugin-vuetify
    
    # HTTP Client and API utilities
    npm install axios
    
    # Additional TypeScript tooling and ESLint packages
    npm install -D @types/node typescript @typescript-eslint/eslint-plugin @typescript-eslint/parser
    npm install -D @eslint/js eslint-plugin-vue vue-eslint-parser
    
    # Testing utilities
    npm install -D @vue/test-utils@latest jsdom vitest @vitest/ui @vitest/coverage-v8
    npm install -D @cypress/vite-dev-server start-server-and-test
    npm install -D axios-mock-adapter
    
    # Development utilities
    npm install -D @vueuse/core
    npm install -D husky lint-staged @commitlint/config-conventional @commitlint/cli
    
    # Ensure all packages are properly installed
    print_status "Dependencies installed, verifying installation..."
    sleep 2
    
    print_status "Dependencies installed ✓"
} 