#!/bin/bash

# Function for setting up testing configurations (Vitest and Cypress)

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
      reporter: ['text', 'json', 'html', 'lcov'],
      include: ['src/**/*.{js,ts,vue}'],
      exclude: [
        'node_modules/',
        'src/test/',
        'src/main.ts',
        'src/plugins/',
        'src/router/',
        '**/*.d.ts',
        '**/*.config.*',
        'dist/',
        'cypress/',
        '**/*.spec.*',
        '**/*.test.*',
      ],
      all: true,
      reportsDirectory: './coverage',
      thresholds: {
        statements: 100,
        branches: 100,
        functions: 100,
        lines: 100
      }
    },
    // Handle CSS and other static imports
    css: true,
    // Configure server options for dependencies
    server: {
      deps: {
        inline: ['vuetify']
      }
    },
    // Mock CSS and asset files
    mockReset: true,
    clearMocks: true,
    restoreMocks: true,
    // Isolate modules for better testing
    isolate: true
  },
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  // Define how to handle different file types during testing
  define: {
    'import.meta.vitest': 'undefined',
  },
  // Handle CSS imports by transforming them
  css: {
    modules: {
      classNameStrategy: 'stable'
    }
  }
})
EOF

    # Create test setup file
    mkdir -p src/test
    cat > src/test/setup.ts << 'EOF'
import { vi } from 'vitest'
import { config } from '@vue/test-utils'

// Mock all necessary browser APIs before any components are loaded
beforeAll(() => {
  // Mock CSS
  Object.defineProperty(window, 'CSS', {
    value: null
  })

  // Mock matchMedia - this is crucial for Vuetify
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: vi.fn().mockImplementation(query => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  })

  // Mock getComputedStyle
  Object.defineProperty(window, 'getComputedStyle', {
    value: vi.fn().mockImplementation(() => ({
      getPropertyValue: vi.fn().mockReturnValue(''),
      width: '1024px',
      height: '768px',
    })),
  })

  // Mock IntersectionObserver
  global.IntersectionObserver = vi.fn().mockImplementation(() => ({
    observe: vi.fn(),
    unobserve: vi.fn(),
    disconnect: vi.fn(),
  }))

  // Mock ResizeObserver
  vi.stubGlobal('ResizeObserver', vi.fn(() => ({
    observe: vi.fn(),
    unobserve: vi.fn(),
    disconnect: vi.fn(),
  })))

  // Mock requestAnimationFrame
  global.requestAnimationFrame = vi.fn().mockImplementation(cb => setTimeout(cb, 0))
  global.cancelAnimationFrame = vi.fn()

  // Mock HTMLElement methods that Vuetify uses
  Object.defineProperty(HTMLElement.prototype, 'offsetHeight', {
    configurable: true,
    value: 50,
  })
  Object.defineProperty(HTMLElement.prototype, 'offsetWidth', {
    configurable: true,
    value: 50,
  })
  Object.defineProperty(HTMLElement.prototype, 'scrollHeight', {
    configurable: true,
    value: 50,
  })
  Object.defineProperty(HTMLElement.prototype, 'scrollWidth', {
    configurable: true,
    value: 50,
  })
})
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