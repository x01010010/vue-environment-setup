#!/bin/bash

# Functions for finalizing the project setup (package.json scripts, git hooks)

# Update package.json scripts
update_package_scripts() {
    print_step "Updating package.json scripts..."
    
    # Use node to update package.json scripts
    node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    
    pkg.scripts = {
      ...pkg.scripts,
      'dev': 'vite',
      'build': 'run-p type-check \"build-only {@}\" --',
      'preview': 'vite preview',
      'test:unit': 'vitest',
      'test:unit:ui': 'vitest --ui',
      'test:unit:watch': 'vitest --watch',
      'test:e2e': 'start-server-and-test preview http://localhost:4173 \"cypress run --e2e\"',
      'test:e2e:dev': 'start-server-and-test \"vite dev --port 4173\" http://localhost:4173 \"cypress open --e2e\"',
      'test:coverage': 'vitest run --coverage',
      'build-only': 'vite build',
      'type-check': 'vue-tsc --build --force',
      'lint': 'eslint . --fix',
      'format': 'prettier --write src/'
    };
    
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    "
    
    print_status "Package.json scripts updated ✓"
}

# Setup Git hooks with Husky and lint-staged
setup_git_hooks() {
    print_step "Setting up Git hooks..."
    
    # Initialize git if not already initialized
    if [ ! -d .git ]; then
        git init
    fi
    
    # Setup Husky with modern v9+ syntax
    npx husky init
    
    # Create pre-commit hook
    cat > .husky/pre-commit << 'EOF'
npx lint-staged
EOF
    chmod +x .husky/pre-commit
    
    # Create commit-msg hook
    cat > .husky/commit-msg << 'EOF'
npx --no -- commitlint --edit $1
EOF
    chmod +x .husky/commit-msg
    
    # Setup lint-staged
    cat > .lintstagedrc.json << 'EOF'
{
  "*.{js,jsx,ts,tsx,vue}": [
    "eslint --fix",
    "prettier --write"
  ],
  "*.{css,scss,html,md,json}": [
    "prettier --write"
  ]
}
EOF
    
    cat > .commitlintrc.json << 'EOF'
{
  "extends": ["@commitlint/config-conventional"]
}
EOF

    print_status "Git hooks configured with modern Husky ✓"
} 