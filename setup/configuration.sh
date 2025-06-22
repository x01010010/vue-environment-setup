#!/bin/bash

# Functions for setting up tool configurations

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