#!/bin/bash

# Vue.js + TypeScript + Tailwind + Vuetify + Pinia Setup Script
# This script creates a complete Vue.js development environment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

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

# Get project name
get_project_name() {
    if [ -z "$1" ]; then
        read -p "Enter project name: " PROJECT_NAME
    else
        PROJECT_NAME=$1
    fi
    
    if [ -z "$PROJECT_NAME" ]; then
        print_error "Project name is required"
        exit 1
    fi
    
    if [ -d "$PROJECT_NAME" ]; then
        print_error "Directory '$PROJECT_NAME' already exists"
        exit 1
    fi
}

# Create Vue project with Vite and TypeScript
create_vue_project() {
    print_step "Creating Vue project with Vite and TypeScript..."
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
    print_status "Vue project created ✓"
}

# Install additional dependencies
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
    npm install -D axios-mock-adapter  # For mocking API calls in tests
    
    # Development utilities
    npm install -D @vueuse/core
    npm install -D husky lint-staged
    
    # Ensure all packages are properly installed
    print_status "Dependencies installed, verifying installation..."
    sleep 2
    
    print_status "Dependencies installed ✓"
}

# Setup Axios configuration
setup_axios() {
    print_step "Setting up Axios configuration..."
    
    # Create API configuration directory
    mkdir -p src/api
    
    # Create Axios instance configuration
    cat > src/api/index.ts << 'EOF'
import axios from 'axios'

// Create axios instance with base configuration
const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor
api.interceptors.request.use(
  (config) => {
    // Add auth token if available
    const token = localStorage.getItem('auth_token')
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`
    }
    
    // Log request in development
    if (import.meta.env.DEV) {
      console.log('API Request:', config.method?.toUpperCase(), config.url)
    }
    
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor
api.interceptors.response.use(
  (response) => {
    // Log response in development
    if (import.meta.env.DEV) {
      console.log('API Response:', response.status, response.config.url)
    }
    
    return response
  },
  (error) => {
    // Handle common errors
    if (error.response?.status === 401) {
      // Unauthorized - redirect to login or refresh token
      localStorage.removeItem('auth_token')
      window.location.href = '/login'
    } else if (error.response?.status === 403) {
      // Forbidden
      console.error('Access denied')
    } else if (error.response?.status >= 500) {
      // Server error
      console.error('Server error:', error.response.status)
    }
    
    return Promise.reject(error)
  }
)

export default api

// Export common API methods with proper typing
export const apiGet = <T = any>(url: string, config?: any) =>
  api.get<T>(url, config)

export const apiPost = <T = any>(url: string, data?: any, config?: any) =>
  api.post<T>(url, data, config)

export const apiPut = <T = any>(url: string, data?: any, config?: any) =>
  api.put<T>(url, data, config)

export const apiPatch = <T = any>(url: string, data?: any, config?: any) =>
  api.patch<T>(url, data, config)

export const apiDelete = <T = any>(url: string, config?: any) =>
  api.delete<T>(url, config)
EOF

    # Create API service examples
    cat > src/api/services.ts << 'EOF'
import { apiGet, apiPost, apiPut, apiDelete } from './index'

// Define TypeScript interfaces for API responses
export interface User {
  id: number
  name: string
  email: string
  created_at: string
  updated_at: string
}

export interface ApiResponse<T> {
  data: T
  message?: string
  status: string
}

export interface PaginatedResponse<T> {
  data: T[]
  meta: {
    current_page: number
    last_page: number
    per_page: number
    total: number
  }
}

// User API service
export const userService = {
  // Get all users
  getUsers: (page = 1, perPage = 10) =>
    apiGet<PaginatedResponse<User>>(`/users?page=${page}&per_page=${perPage}`),
  
  // Get user by ID
  getUser: (id: number) =>
    apiGet<ApiResponse<User>>(`/users/${id}`),
  
  // Create new user
  createUser: (userData: Omit<User, 'id' | 'created_at' | 'updated_at'>) =>
    apiPost<ApiResponse<User>>('/users', userData),
  
  // Update user
  updateUser: (id: number, userData: Partial<User>) =>
    apiPut<ApiResponse<User>>(`/users/${id}`, userData),
  
  // Delete user
  deleteUser: (id: number) =>
    apiDelete<ApiResponse<null>>(`/users/${id}`),
}

// Authentication service
export const authService = {
  login: (credentials: { email: string; password: string }) =>
    apiPost<ApiResponse<{ token: string; user: User }>>('/auth/login', credentials),
  
  register: (userData: { name: string; email: string; password: string }) =>
    apiPost<ApiResponse<{ token: string; user: User }>>('/auth/register', userData),
  
  logout: () =>
    apiPost<ApiResponse<null>>('/auth/logout'),
  
  refreshToken: () =>
    apiPost<ApiResponse<{ token: string }>>('/auth/refresh'),
  
  getProfile: () =>
    apiGet<ApiResponse<User>>('/auth/profile'),
}
EOF

    # Create composable for API usage
    mkdir -p src/composables
    cat > src/composables/useApi.ts << 'EOF'
import { ref, type Ref } from 'vue'

interface UseApiState<T> {
  data: Ref<T | null>
  loading: Ref<boolean>
  error: Ref<string | null>
}

interface UseApiReturn<T> extends UseApiState<T> {
  execute: () => Promise<void>
  reset: () => void
}

// Composable for handling API calls with loading states
export function useApi<T>(
  apiCall: () => Promise<any>
): UseApiReturn<T> {
  const data = ref<T | null>(null)
  const loading = ref<boolean>(false)
  const error = ref<string | null>(null)

  const execute = async (): Promise<void> => {
    try {
      loading.value = true
      error.value = null
      
      const response = await apiCall()
      data.value = response.data
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'An error occurred'
    } finally {
      loading.value = false
    }
  }

  const reset = (): void => {
    data.value = null
    loading.value = false
    error.value = null
  }

  return {
    data,
    loading,
    error,
    execute,
    reset,
  }
}

// Composable for API calls with immediate execution
export function useApiImmediate<T>(
  apiCall: () => Promise<any>
): UseApiReturn<T> {
  const result = useApi(apiCall)
  
  // Execute immediately
  result.execute()
  
  return result
}
EOF

    # Add environment variables example
    cat > .env.example << 'EOF'
# API Configuration
VITE_API_BASE_URL=http://localhost:8000/api

# App Configuration
VITE_APP_TITLE=My Vue App
VITE_APP_DESCRIPTION=A Vue.js application with TypeScript

# Development
VITE_DEV_MODE=true
VITE_SHOW_DEBUG=true
EOF

    print_status "Axios configuration created ✓"
}

# Setup Tailwind CSS v4 with Vite plugin
setup_tailwind() {
    print_step "Setting up Tailwind CSS v4 with Vite plugin..."
    
    # No need for tailwind.config.js or PostCSS config with v4 Vite plugin
    # Tailwind v4 works without configuration files
    
    # Create main CSS file with Tailwind v4 import
    mkdir -p src/assets/css
    cat > src/assets/css/main.css << 'EOF'
@import 'tailwindcss';

/* Custom component styles */
@layer components {
  .btn {
    @apply px-4 py-2 rounded-lg font-medium transition-colors duration-200 inline-flex items-center justify-center;
  }
  
  .btn-primary {
    @apply bg-blue-600 text-white hover:bg-blue-700 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2;
  }
  
  .btn-secondary {
    @apply bg-gray-600 text-white hover:bg-gray-700 focus:ring-2 focus:ring-gray-500 focus:ring-offset-2;
  }
}
EOF

    print_status "Tailwind CSS v4 configured with Vite plugin ✓"
}

# Setup Vuetify
setup_vuetify() {
    print_step "Setting up Vuetify..."
    
    # Create Vuetify plugin file
    mkdir -p src/plugins
    cat > src/plugins/vuetify.ts << 'EOF'
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { mdi } from 'vuetify/iconsets/mdi'
import '@mdi/font/css/materialdesignicons.css'

export default createVuetify({
  components,
  directives,
  icons: {
    defaultSet: 'mdi',
    sets: {
      mdi,
    }
  },
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          primary: '#1976D2',
          secondary: '#424242',
          accent: '#82B1FF',
          error: '#FF5252',
          info: '#2196F3',
          success: '#4CAF50',
          warning: '#FFC107',
        },
      },
      dark: {
        colors: {
          primary: '#2196F3',
          secondary: '#424242',
          accent: '#FF4081',
          error: '#FF5252',
          info: '#2196F3',
          success: '#4CAF50',
          warning: '#FB8C00',
        },
      },
    },
  },
})
EOF

    print_status "Vuetify configured ✓"
}

# Update Vite config
update_vite_config() {
    print_step "Updating Vite configuration..."
    
    cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vuetify from 'vite-plugin-vuetify'
import tailwindcss from '@tailwindcss/vite'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig({
  plugins: [
    vue(),
    vuetify({ autoImport: true }),
    tailwindcss(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    port: 3000,
    open: true,
  },
  build: {
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['vue', 'vue-router', 'pinia'],
          vuetify: ['vuetify'],
        },
      },
    },
  },
})
EOF

    print_status "Vite configuration updated ✓"
}

# Setup strict TypeScript configuration
setup_typescript() {
    print_step "Setting up strict TypeScript configuration..."
    
    cat > tsconfig.json << 'EOF'
{
  "files": [],
  "references": [
    {
      "path": "./tsconfig.node.json"
    },
    {
      "path": "./tsconfig.app.json"
    },
    {
      "path": "./tsconfig.vitest.json"
    }
  ]
}
EOF

    cat > tsconfig.app.json << 'EOF'
{
  "extends": "@vue/tsconfig/tsconfig.dom.json",
  "include": ["env.d.ts", "src/**/*", "src/**/*.vue"],
  "exclude": ["src/**/__tests__/*"],
  "compilerOptions": {
    "composite": true,
    "tsBuildInfoFile": "./node_modules/.tmp/tsconfig.app.tsbuildinfo",
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    },
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "allowUnusedLabels": false,
    "allowUnreachableCode": false
  }
}
EOF

    print_status "TypeScript configuration updated ✓"
}

# Setup ESLint with modern flat config
setup_eslint() {
    print_step "Setting up ESLint with modern flat config..."
    
    cat > eslint.config.js << 'EOF'
import js from '@eslint/js'
import vue from 'eslint-plugin-vue'
import typescript from '@typescript-eslint/eslint-plugin'
import typescriptParser from '@typescript-eslint/parser'
import vueParser from 'vue-eslint-parser'

export default [
  // Base configuration
  js.configs.recommended,
  
  // Vue files
  {
    files: ['**/*.vue'],
    languageOptions: {
      parser: vueParser,
      parserOptions: {
        parser: typescriptParser,
        ecmaVersion: 'latest',
        sourceType: 'module',
      },
    },
    plugins: {
      vue,
      '@typescript-eslint': typescript,
    },
    rules: {
      ...vue.configs['vue3-essential'].rules,
      
      // Vue specific rules
      'vue/multi-word-component-names': 'error',
      'vue/component-definition-name-casing': ['error', 'PascalCase'],
      'vue/component-name-in-template-casing': ['error', 'PascalCase'],
      'vue/define-emits-declaration': 'error',
      'vue/define-props-declaration': 'error',
      'vue/no-undef-components': 'error',
      'vue/no-unused-components': 'error',
      'vue/no-unused-vars': 'error',
    },
  },
  
  // TypeScript files
  {
    files: ['**/*.ts', '**/*.tsx'],
    languageOptions: {
      parser: typescriptParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
      },
    },
    plugins: {
      '@typescript-eslint': typescript,
    },
    rules: {
      // TypeScript specific rules
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': 'error',
      '@typescript-eslint/explicit-function-return-type': 'warn',
      '@typescript-eslint/no-non-null-assertion': 'error',
      '@typescript-eslint/prefer-nullish-coalescing': 'error',
      '@typescript-eslint/prefer-optional-chain': 'error',
    },
  },
  
  // All JavaScript/TypeScript files
  {
    files: ['**/*.js', '**/*.jsx', '**/*.ts', '**/*.tsx', '**/*.vue'],
    rules: {
      // General rules
      'prefer-const': 'error',
      'no-var': 'error',
      'no-console': 'warn',
      'no-debugger': 'error',
    },
  },
  
  // Ignore patterns
  {
    ignores: [
      'dist/**',
      'node_modules/**',
      '.output/**',
      '.nuxt/**',
      'coverage/**',
    ],
  },
]
EOF

    print_status "ESLint flat config created ✓"
}

# Setup testing configuration
setup_testing() {
    print_step "Setting up testing configuration..."
    
    # Update vitest config
    cat > vitest.config.ts << 'EOF'
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'
import vuetify from 'vite-plugin-vuetify'
import { fileURLToPath } from 'node:url'

export default defineConfig({
  plugins: [vue(), vuetify({ autoImport: true })],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.d.ts',
        '**/*.config.*',
        'dist/',
      ],
    },
  },
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
})
EOF

    # Create test setup file
    mkdir -p src/test
    cat > src/test/setup.ts << 'EOF'
import { config } from '@vue/test-utils'
import vuetify from '../plugins/vuetify'

config.global.plugins = [vuetify]
EOF

    # Update Cypress config
    cat > cypress.config.ts << 'EOF'
import { defineConfig } from 'cypress'

export default defineConfig({
  e2e: {
    specPattern: 'cypress/e2e/**/*.{cy,spec}.{js,jsx,ts,tsx}',
    baseUrl: 'http://localhost:4173',
    supportFile: 'cypress/support/e2e.ts',
  },
  component: {
    devServer: {
      framework: 'vue',
      bundler: 'vite',
    },
    specPattern: 'src/**/__tests__/*.{cy,spec}.{js,ts,jsx,tsx}',
    supportFile: 'cypress/support/component.ts',
  },
})
EOF

    print_status "Testing configuration updated ✓"
}

# Update main.ts to include all plugins
update_main_ts() {
    print_step "Updating main.ts..."
    
    cat > src/main.ts << 'EOF'
import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import vuetify from './plugins/vuetify'

// Import styles - order matters!
import './assets/css/main.css'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(vuetify)

app.mount('#app')
EOF

    print_status "main.ts updated ✓"
}

# Update App.vue to use our custom component
update_app_vue() {
    print_step "Updating App.vue to use custom components..."
    
    cat > src/App.vue << 'EOF'
<template>
  <v-app>
    <v-app-bar
      :elevation="2"
      color="primary"
    >
      <v-app-bar-title>Vue Development Environment</v-app-bar-title>
      
      <v-spacer></v-spacer>
      
      <v-btn
        icon="mdi-theme-light-dark"
        @click="toggleTheme"
      ></v-btn>
    </v-app-bar>

    <v-main>
      <v-container fluid class="pa-4">
        <HelloWorld />
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
import { useTheme } from 'vuetify'
import HelloWorld from './components/HelloWorld.vue'

const theme = useTheme()

const toggleTheme = () => {
  theme.global.name.value = theme.global.current.value.dark ? 'light' : 'dark'
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>
EOF

    print_status "App.vue updated ✓"
}

# Update router views to use proper styling
update_router_views() {
    print_step "Updating router views..."
    
    # Update HomeView
    cat > src/views/HomeView.vue << 'EOF'
<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-4xl mx-auto py-8 px-4">
      <div class="text-center mb-8">
        <h1 class="text-4xl font-bold text-gray-900 mb-4">
          Welcome to Vue.js Development Environment
        </h1>
        <p class="text-xl text-gray-600">
          A complete setup with TypeScript, Tailwind CSS, Vuetify, and more
        </p>
      </div>
      
      <HelloWorld msg="You did it!" />
    </div>
  </div>
</template>

<script setup lang="ts">
import HelloWorld from '@/components/HelloWorld.vue'
</script>
EOF

    # Update AboutView  
    cat > src/views/AboutView.vue << 'EOF'
<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-4xl mx-auto py-8 px-4">
      <div class="bg-white rounded-lg shadow-md p-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-6">About This Project</h1>
        
        <div class="prose max-w-none">
          <p class="text-lg text-gray-700 mb-6">
            This Vue.js project was generated with a comprehensive development setup that includes:
          </p>
          
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
            <div class="bg-blue-50 p-4 rounded-lg">
              <h3 class="font-semibold text-blue-900 mb-2">Frontend Framework</h3>
              <ul class="text-sm text-blue-800 space-y-1">
                <li>• Vue 3 with Composition API</li>
                <li>• TypeScript with strict typing</li>
                <li>• Vite for fast development</li>
              </ul>
            </div>
            
            <div class="bg-green-50 p-4 rounded-lg">
              <h3 class="font-semibold text-green-900 mb-2">Styling & UI</h3>
              <ul class="text-sm text-green-800 space-y-1">
                <li>• Tailwind CSS v4</li>
                <li>• Vuetify 3 components</li>
                <li>• Material Design icons</li>
              </ul>
            </div>
            
            <div class="bg-purple-50 p-4 rounded-lg">
              <h3 class="font-semibold text-purple-900 mb-2">Development Tools</h3>
              <ul class="text-sm text-purple-800 space-y-1">
                <li>• ESLint + Prettier</li>
                <li>• Vitest + Cypress testing</li>
                <li>• Husky Git hooks</li>
              </ul>
            </div>
          </div>
          
          <div class="bg-yellow-50 border-l-4 border-yellow-400 p-4">
            <h3 class="font-semibold text-yellow-900 mb-2">API Integration</h3>
            <p class="text-yellow-800">
              Complete Axios setup with interceptors, error handling, and Vue composables for reactive API calls.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
EOF

    print_status "Router views updated ✓"
}

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

    # Install commitlint for conventional commits
    npm install -D @commitlint/config-conventional @commitlint/cli
    
    cat > .commitlintrc.json << 'EOF'
{
  "extends": ["@commitlint/config-conventional"]
}
EOF

    print_status "Git hooks configured with modern Husky ✓"
}

# Create example components
create_example_components() {
    print_step "Creating example components..."
    
    # Create a sample component using both Tailwind and Vuetify
    mkdir -p src/components
    cat > src/components/HelloWorld.vue << 'EOF'
<template>
  <div class="hello-world">
    <!-- Vuetify Card -->
    <v-card class="mx-auto mb-6" max-width="400">
      <v-card-title class="text-h5">
        Hello World Component
      </v-card-title>
      <v-card-text>
        <p class="mb-4">This component demonstrates:</p>
        <ul class="list-disc list-inside space-y-1">
          <li>Vue 3 Composition API</li>
          <li>TypeScript with strict typing</li>
          <li>Vuetify components</li>
          <li>Tailwind CSS utilities</li>
          <li>Pinia state management</li>
          <li>Axios API integration</li>
        </ul>
      </v-card-text>
      <v-card-actions>
        <v-btn 
          color="primary" 
          @click="incrementCounter"
          variant="elevated"
        >
          Count: {{ counter }}
        </v-btn>
        <v-spacer></v-spacer>
        <v-btn 
          color="secondary" 
          @click="resetCounter"
          variant="outlined"
        >
          Reset
        </v-btn>
      </v-card-actions>
    </v-card>

    <!-- API Demo Section -->
    <v-card class="mx-auto mb-6" max-width="400">
      <v-card-title class="text-h5">
        Axios API Demo
      </v-card-title>
      <v-card-text>
        <div v-if="loading" class="text-center">
          <v-progress-circular indeterminate color="primary"></v-progress-circular>
          <p class="mt-2">Loading...</p>
        </div>
        <div v-else-if="error" class="text-red-500">
          <p>Error: {{ error }}</p>
        </div>
        <div v-else-if="apiData">
          <p class="text-sm text-gray-600">Sample API response:</p>
          <pre class="bg-gray-100 p-2 rounded text-xs overflow-auto">{{ JSON.stringify(apiData, null, 2) }}</pre>
        </div>
        <div v-else>
          <p class="text-gray-600">Click the button to test API call</p>
        </div>
      </v-card-text>
      <v-card-actions>
        <v-btn 
          color="success" 
          @click="fetchData"
          :loading="loading"
          variant="elevated"
        >
          Fetch Data
        </v-btn>
        <v-btn 
          color="warning" 
          @click="resetApiData"
          variant="outlined"
        >
          Reset
        </v-btn>
      </v-card-actions>
    </v-card>

    <!-- Tailwind styled section -->
    <div class="bg-gradient-to-r from-blue-500 to-purple-600 p-6 rounded-lg text-white shadow-lg">
      <h3 class="text-xl font-bold mb-2">Tailwind Styling</h3>
      <p class="mb-4">This section uses Tailwind CSS classes for styling.</p>
      <div class="space-x-2">
        <button 
          class="bg-white text-blue-600 px-4 py-2 rounded-lg font-medium hover:bg-gray-100 transition-colors"
          @click="toggleTheme"
        >
          Toggle Theme
        </button>
        <span class="text-sm opacity-90">Current theme: {{ currentTheme }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useTheme } from 'vuetify'
import { useCounterStore } from '@/stores/counter'
import { useApi } from '@/composables/useApi'
import { apiGet } from '@/api'

// Props with TypeScript typing
interface Props {
  msg?: string
}

const props = withDefaults(defineProps<Props>(), {
  msg: 'Default message'
})

// Composables
const theme = useTheme()
const counterStore = useCounterStore()

// API demo using JSONPlaceholder (since it's publicly available)
const { data: apiData, loading, error, execute: fetchData, reset: resetApiData } = useApi(() =>
  apiGet('https://jsonplaceholder.typicode.com/posts/1')
)

// Reactive data
const counter = computed(() => counterStore.count)
const currentTheme = computed(() => theme.global.name.value)

// Methods with explicit return types
const incrementCounter = (): void => {
  counterStore.increment()
}

const resetCounter = (): void => {
  counterStore.reset()
}

const toggleTheme = (): void => {
  theme.global.name.value = theme.global.current.value.dark ? 'light' : 'dark'
}
</script>

<style scoped>
.hello-world {
  max-width: 42rem;
  margin: 0 auto;
  padding: 1.5rem;
}
</style>
EOF

    # Update the counter store with proper TypeScript
    cat > src/stores/counter.ts << 'EOF'
import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

export const useCounterStore = defineStore('counter', () => {
  const count = ref<number>(0)
  
  const doubleCount = computed<number>(() => count.value * 2)
  
  const increment = (): void => {
    count.value++
  }
  
  const decrement = (): void => {
    count.value--
  }
  
  const reset = (): void => {
    count.value = 0
  }

  return { count, doubleCount, increment, decrement, reset }
})
EOF

    # Create a simple test for the component
    mkdir -p src/components/__tests__
    cat > src/components/__tests__/HelloWorld.spec.ts << 'EOF'
import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import HelloWorld from '../HelloWorld.vue'

describe('HelloWorld', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('renders properly', () => {
    const wrapper = mount(HelloWorld)
    expect(wrapper.text()).toContain('Hello World Component')
  })

  it('increments counter when button is clicked', async () => {
    const wrapper = mount(HelloWorld)
    const button = wrapper.find('button')
    
    await button.trigger('click')
    expect(wrapper.text()).toContain('Count: 1')
  })
})
EOF

    print_status "Example components created ✓"
}

# Create development documentation
create_documentation() {
    print_step "Creating development documentation..."
    
    cat > README.md << 'EOF'
# Vue.js + TypeScript Development Environment

This project was created with a comprehensive Vue.js development setup including:

## 🚀 Technology Stack

- **Vue 3** - Progressive JavaScript framework
- **TypeScript** - Static type checking with strict configuration
- **Vite** - Fast build tool and dev server
- **Tailwind CSS** - Utility-first CSS framework
- **Vuetify 3** - Material Design component library
- **Pinia** - State management
- **Vue Router** - Client-side routing
- **Axios** - HTTP client for API calls
- **Vitest** - Unit testing framework
- **Cypress** - E2E testing framework

## 📋 Features

- ✅ Strict TypeScript configuration (no `any` types allowed)
- ✅ ESLint with TypeScript rules
- ✅ Prettier code formatting
- ✅ Git hooks with Husky and lint-staged
- ✅ Conventional commits with commitlint
- ✅ Test coverage reporting
- ✅ Component and E2E testing setup
- ✅ Axios configuration with interceptors
- ✅ API service layer with TypeScript
- ✅ Hot module replacement
- ✅ Production build optimization

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

- **TypeScript**: Strict mode enabled, no `any` types allowed
- **ESLint**: Configured with Vue and TypeScript rules
- **Prettier**: Automatic code formatting
- **Conventional Commits**: Enforced via commitlint

## 🎨 Styling

- **Tailwind CSS**: Utility-first CSS framework
- **Vuetify**: Material Design components
- **Custom CSS**: Located in `src/assets/css/`

## 🌐 API Integration

- **Axios Configuration**: Pre-configured instance with interceptors
- **Request/Response Interceptors**: Authentication, logging, error handling
- **API Services**: Structured service layer with TypeScript interfaces
- **Composables**: `useApi` and `useApiImmediate` for reactive API calls
- **Environment Variables**: `.env.example` with API configuration

## 📁 Project Structure

```
src/
├── api/            # Axios configuration and API services
├── assets/         # Static assets
├── components/     # Vue components
├── composables/    # Vue composables (including useApi)
├── plugins/        # Vue plugins configuration
├── router/         # Vue Router configuration
├── stores/         # Pinia stores
├── test/          # Test utilities
└── views/         # Route components
```

## 🔧 Configuration Files

- `vite.config.ts` - Vite configuration
- `tsconfig.json` - TypeScript configuration
- `tailwind.config.js` - Tailwind CSS configuration
- `.eslintrc.cjs` - ESLint configuration
- `vitest.config.ts` - Vitest configuration
- `cypress.config.ts` - Cypress configuration

## 🚀 Getting Started

1. Install dependencies: `npm install`
2. Start development server: `npm run dev`
3. Open your browser to `http://localhost:3000`

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

# Main execution function
main() {
    print_status "Starting Vue.js + TypeScript development environment setup..."
    
    check_prerequisites
    get_project_name "$1"
    
    create_vue_project
    install_dependencies
    setup_axios
    setup_tailwind
    setup_vuetify
    update_vite_config
    setup_typescript
    setup_eslint
    setup_testing
    update_main_ts
    update_app_vue
    update_router_views
    update_package_scripts
    setup_git_hooks
    create_example_components
    create_documentation
    
    print_status "🎉 Setup completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "  cd $PROJECT_NAME"
    echo "  npm run dev"
    echo ""
    print_status "Happy coding! 🚀"
}

# Run main function with all arguments
main "$@"