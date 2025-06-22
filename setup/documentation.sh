#!/bin/bash

# Functions for creating documentation

create_documentation() {
    print_step "Creating development documentation..."
    
    cat > README.md << 'EOF'
# Vue.js + TypeScript Development Environment

This project was created with a comprehensive Vue.js development setup script that provides a complete, production-ready development environment.

## 📋 Prerequisites

- **Node.js 18+** - [Download here](https://nodejs.org/)
- **npm** - Comes with Node.js
- **Git** - For version control hooks

## 🛠️ Setup Script Features

The `vue_setup.sh` script orchestrates a modular setup process to create a complete Vue.js development environment. Key features include:

- **Modular Architecture**: The setup logic is split into maintainable scripts located in the `setup/` directory.
- **Interactive Setup**: Prompts for project name and directory.
- **Comprehensive Tooling**: Includes TypeScript, Vuetify, Tailwind CSS, Pinia, Vitest, Cypress, and more.
- **Production-Ready**: Generates a project with best practices for building, testing, and linting.

## 🚀 Technology Stack

- **Vue 3** - Progressive JavaScript framework with Composition API
- **TypeScript** - Static type checking with strict configuration
- **Vite** - Fast build tool and dev server
- **Tailwind CSS v4** - Utility-first CSS framework with Vite plugin
- **Vuetify 3** - Material Design component library
- **Pinia** - State management
- **Vue Router** - Client-side routing
- **Axios v1.x** - HTTP client with modern TypeScript support
- **Vitest** - Unit testing framework
- **Cypress** - E2E testing framework

## 🏗️ Script Architecture

The main `vue_setup.sh` script acts as an orchestrator. It sources and executes a series of modular scripts from the `setup/` directory in a specific order. This design makes the setup process easier to understand, maintain, and customize.

- `setup/helpers.sh`: Contains utility functions for colored output.
- `setup/project.sh`: Handles prerequisite checks and initial project scaffolding.
- `setup/dependencies.sh`: Installs all required npm packages.
- `setup/configuration.sh`: Creates all the configuration files (Vite, ESLint, TypeScript, etc.).
- `setup/testing.sh`: Configures Vitest, Cypress, and the test environment.
- `setup/source_files.sh`: Updates the core application files (`App.vue`, `main.ts`, etc.).
- `setup/finalization.sh`: Updates `package.json` scripts and sets up Git hooks.
- `setup/components.sh`: Creates the example Vue components and stores.
- `setup/tests.sh`: Generates all unit and integration tests.
- `setup/documentation.sh`: Creates this README file.

## 📋 Features

- ✅ Strict TypeScript configuration (no `any` types allowed)
- ✅ Modern ESLint flat config with Vue and TypeScript rules
- ✅ Prettier code formatting
- ✅ Git hooks with Husky v9+ and lint-staged
- ✅ Conventional commits with commitlint
- ✅ 100% test coverage goal with Vitest
- ✅ Component and E2E testing setup
- ✅ Axios v1.x configuration with interceptors and composables
- ✅ API service layer with proper TypeScript interfaces
- ✅ Hot module replacement
- ✅ Production build optimization with code splitting
- ✅ Tailwind CSS v4 with Vite plugin integration
- ✅ Custom App.vue with Vuetify layout and theme switching
- ✅ Responsive router views with modern styling

## 🛠️ Development Scripts

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Run unit tests
npm run test:unit

# Run unit tests with UI
npm run test:unit:ui

# Run E2E tests
npm run test:e2e

# Run E2E tests in development mode
npm run test:e2e:dev

# Generate test coverage report
npm run test:coverage

# Lint and fix files
npm run lint

# Format code
npm run format

# Type check
npm run type-check
```

## 🧪 Testing

### Unit Tests
- Framework: Vitest
- Utils: @vue/test-utils
- Location: `src/**/__tests__/*.spec.ts`

### E2E Tests
- Framework: Cypress
- Location: `cypress/e2e/**/*.cy.ts`

## 📝 Code Standards

- **TypeScript**: Strict mode enabled with exactOptionalPropertyTypes and noUncheckedIndexedAccess
- **ESLint**: Modern flat config with Vue 3, TypeScript, and composition API rules
- **Prettier**: Automatic code formatting with lint-staged integration
- **Conventional Commits**: Enforced via commitlint with Husky v9+ hooks

## 🎨 Styling

- **Tailwind CSS v4**: Latest version with Vite plugin integration, no PostCSS config needed
- **Vuetify 3**: Material Design components with theme switching capability
- **Custom CSS**: Located in `src/assets/css/main.css` with proper layer organization
- **Component Styling**: Responsive design with utility-first approach
- **Theme Support**: Built-in light/dark mode switching

## 🌐 API Integration

- **Axios v1.x Configuration**: Modern TypeScript-compatible setup with built-in definitions
- **Request/Response Interceptors**: Authentication, logging, and comprehensive error handling
- **API Services**: Structured service layer with proper TypeScript interfaces and generics
- **Vue Composables**: `useApi` and `useApiImmediate` for reactive API calls with loading states
- **Environment Variables**: `.env.example` with API configuration templates
- **Error Handling**: Centralized error management with user-friendly messages

## 📁 Project Structure

```
.
├── setup/          # Modular setup scripts
├── src/
│   ├── api/        # Axios configuration and API services
│   ├── assets/     # Static assets
│   ├── components/ # Vue components
│   ├── composables/# Vue composables (including useApi)
│   ├── plugins/    # Vue plugins configuration
│   ├── router/     # Vue Router configuration
│   ├── stores/     # Pinia stores
│   ├── test/       # Test utilities
│   └── views/      # Route components
└── vue_setup.sh    # Master setup script
```

## 🔧 Configuration Files

- `vite.config.ts` - Vite configuration with Tailwind CSS v4 and Vuetify plugins
- `tsconfig.json` - TypeScript configuration with strict mode and project references
- `eslint.config.js` - Modern ESLint flat configuration (no legacy .eslintrc files)
- `vitest.config.ts` - Vitest configuration with Vue and Vuetify support
- `cypress.config.ts` - Cypress configuration for E2E and component testing
- **No PostCSS config needed** - Tailwind CSS v4 works directly with Vite plugin

## 🚀 Getting Started

### Installation Options

**Interactive Mode (Recommended):**
```bash
./vue_setup.sh
```
The script will prompt you for:
- Project name
- Target directory (with current directory as default)

**Command Line Mode:**
```bash
./vue_setup.sh [project_name] [target_directory]
```

**Examples:**
```bash
# Create in current directory
./vue_setup.sh MyProject

# Create in specific directory
./vue_setup.sh MyProject /Users/username/Projects

# Create in home directory
./vue_setup.sh MyProject ~/Development

# Full path example
./vue_setup.sh MyProject /opt/projects/web-apps
```

### Directory Selection Features

- **Flexible Paths**: Supports absolute paths, relative paths, and tilde expansion (`~/`)
- **Auto-Creation**: Creates target directories if they don't exist
- **Validation**: Checks for existing projects to prevent overwriting
- **User-Friendly**: Clear prompts and helpful examples during interactive mode

### After Project Creation

1. The script automatically navigates to your new project
2. Start development server: `npm run dev`
3. Open your browser to `http://localhost:3000`

## 🎯 What You'll See

The generated project includes:
- **Custom App.vue**: Clean Vuetify layout with app bar and theme toggle
- **HelloWorld Component**: Demonstrates Vue 3, TypeScript, Tailwind, Vuetify, and Axios integration
- **Responsive Views**: Modern HomeView and AboutView with comprehensive Tailwind styling
- **Working Examples**: Counter with Pinia, API calls with Axios composables, theme switching

## 🚨 Troubleshooting

### Common Issues

**Permission Issues (macOS/Linux):**
```bash
chmod +x vue_setup.sh && chmod +x setup/*.sh
./vue_setup.sh
```

**Node.js Version Issues:**
```bash
node --version  # Should be 18+
npm --version   # Should be 8+
```

**Directory Already Exists:**
- The script will check if the target directory already contains a project with the same name
- Choose a different name or different target directory

**Package Installation Issues:**
- The script includes 2-second delays and fallback mechanisms
- If issues persist, try running `npm install` manually in the created project

### Script Behavior

- **Automatic Navigation**: Script navigates to the created project directory
- **Error Handling**: Comprehensive error checking and user-friendly messages
- **Cleanup**: No temporary files are left behind
- **Safety**: Won't overwrite existing projects

## 📚 Additional Resources

- [Vue 3 Documentation](https://vuejs.org/)
- [TypeScript Documentation](https://www.typescriptlang.org/)
- [Tailwind CSS Documentation](https://tailwindcss.com/)
- [Vuetify Documentation](https://vuetifyjs.com/)
- [Pinia Documentation](https://pinia.vuejs.org/)
- [Vitest Documentation](https://vitest.dev/)
- [Cypress Documentation](https://docs.cypress.io/)
EOF

    print_status "Documentation created ✓"
}
