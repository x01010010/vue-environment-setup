#!/bin/bash

# Functions for creating example components, tests, and documentation

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
          data-testid="count-button"
        >
          Count: {{ counter }}
        </v-btn>
        <v-spacer></v-spacer>
        <v-btn 
          color="secondary" 
          @click="resetCounter"
          variant="outlined"
          data-testid="reset-count-button"
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
          data-testid="reset-api-button"
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

    # Create comprehensive tests for the component
    mkdir -p src/components/__tests__
    cat > src/components/__tests__/HelloWorld.spec.ts << 'EOF'
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { createVuetify } from 'vuetify'
import HelloWorld from '../HelloWorld.vue'
import * as api from '@/api'

// Mock the entire api module
vi.mock('@/api')

describe('HelloWorld', () => {
  let vuetify: any
  let pinia: any

  beforeEach(() => {
    vi.resetModules()
    // Create fresh instances for each test
    pinia = createPinia()
    setActivePinia(pinia)
    
    vuetify = createVuetify({
      ssr: true,
      theme: {
        defaultTheme: 'light',
        themes: {
          light: { dark: false },
          dark: { dark: true }
        }
      }
    })

    // Reset mocks before each test
    vi.clearAllMocks()
  })

  const createWrapper = () => {
    return mount(HelloWorld, {
      global: {
        plugins: [pinia, vuetify],
        stubs: {
          'v-progress-circular': true,
          'v-card': { template: '<div class="v-card-stub"><slot /></div>' },
          'v-card-title': { template: '<div class="v-card-title-stub"><slot /></div>' },
          'v-card-text': { template: '<div class="v-card-text-stub"><slot /></div>' },
          'v-card-actions': { template: '<div class="v-card-actions-stub"><slot /></div>' },
          'v-btn': { 
            template: '<button class="v-btn-stub" @click="$emit(\'click\')" :loading="$attrs.loading" :data-testid="$attrs[\'data-testid\']"><slot /></button>',
            emits: ['click']
          },
          'v-spacer': { template: '<div class="v-spacer-stub"></div>' }
        }
      }
    })
  }

  it('renders properly', () => {
    const wrapper = createWrapper()
    expect(wrapper.text()).toContain('Hello World Component')
  })

  it('increments and resets counter', async () => {
    const wrapper = createWrapper()
    const countButton = wrapper.find('[data-testid="count-button"]')
    
    expect(wrapper.text()).toContain('Count: 0')
    await countButton.trigger('click')
    expect(wrapper.text()).toContain('Count: 1')
    
    const resetButton = wrapper.find('[data-testid="reset-count-button"]')
    await resetButton.trigger('click')
    expect(wrapper.text()).toContain('Count: 0')
  })

  it('shows loading state, fetches data successfully, and resets data', async () => {
    const mockApiGet = vi.spyOn(api, 'apiGet')
    
    // Use a promise that we can resolve manually
    let resolve: (value: unknown) => void
    const promise = new Promise(r => { resolve = r })
    mockApiGet.mockReturnValue(promise)

    const wrapper = createWrapper()
    
    // Initial state
    expect(wrapper.text()).toContain('Click the button to test API call')

    // Trigger API call and check loading state
    const fetchButton = wrapper.findAll('button').find(btn => btn.text().includes('Fetch Data'))
    await fetchButton.trigger('click')
    
    expect(mockApiGet).toHaveBeenCalledWith('https://jsonplaceholder.typicode.com/posts/1')
    expect(wrapper.find('v-progress-circular-stub').exists()).toBe(true)
    expect(wrapper.text()).toContain('Loading...')

    // Resolve promise and check success state
    const mockData = { id: 1, title: 'Fetched Post' }
    resolve({ data: mockData })
    await flushPromises()
    
    expect(wrapper.text()).toContain(JSON.stringify(mockData, null, 2))

    // Reset API data
    const resetApiButton = wrapper.find('[data-testid="reset-api-button"]')
    await resetApiButton.trigger('click')
    await flushPromises()
    expect(wrapper.text()).toContain('Click the button to test API call')
  })
  
  it('handles API error state', async () => {
    const mockApiGet = vi.spyOn(api, 'apiGet').mockRejectedValue(new Error('Network Failure'))
    const wrapper = createWrapper()

    const fetchButton = wrapper.findAll('button').find(btn => btn.text().includes('Fetch Data'))
    await fetchButton.trigger('click')
    await flushPromises()

    expect(wrapper.text()).toContain('Error: Network Failure')
  })

  it('toggles theme', async () => {
    const wrapper = createWrapper()
    const themeButton = wrapper.findAll('button').find(btn => btn.text().includes('Toggle Theme'))
    
    expect(wrapper.text()).toContain('Current theme: light')
    await themeButton.trigger('click')
    expect(wrapper.text()).toContain('Current theme: dark')
    await themeButton.trigger('click')
    expect(wrapper.text()).toContain('Current theme: light')
  })
})
EOF

    # Create tests for Pinia store
    mkdir -p src/stores/__tests__
    cat > src/stores/__tests__/counter.spec.ts << 'EOF'
import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useCounterStore } from '../counter'

describe('Counter Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('initializes with count 0', () => {
    const store = useCounterStore()
    expect(store.count).toBe(0)
  })

  it('computes double count correctly', () => {
    const store = useCounterStore()
    expect(store.doubleCount).toBe(0)
    
    store.count = 5
    expect(store.doubleCount).toBe(10)
  })

  it('increments count', () => {
    const store = useCounterStore()
    
    store.increment()
    expect(store.count).toBe(1)
    expect(store.doubleCount).toBe(2)
    
    store.increment()
    expect(store.count).toBe(2)
    expect(store.doubleCount).toBe(4)
  })

  it('decrements count', () => {
    const store = useCounterStore()
    
    store.count = 5
    store.decrement()
    expect(store.count).toBe(4)
    expect(store.doubleCount).toBe(8)
    
    store.decrement()
    expect(store.count).toBe(3)
    expect(store.doubleCount).toBe(6)
  })

  it('resets count to 0', () => {
    const store = useCounterStore()
    
    store.count = 10
    expect(store.count).toBe(10)
    
    store.reset()
    expect(store.count).toBe(0)
    expect(store.doubleCount).toBe(0)
  })

  it('handles multiple operations', () => {
    const store = useCounterStore()
    
    store.increment()
    store.increment()
    store.increment()
    expect(store.count).toBe(3)
    
    store.decrement()
    expect(store.count).toBe(2)
    
    store.reset()
    expect(store.count).toBe(0)
  })
})
EOF

    # Create tests for useApi composable
    mkdir -p src/composables/__tests__
    cat > src/composables/__tests__/useApi.spec.ts << 'EOF'
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useApi, useApiImmediate } from '../useApi'

describe('useApi composable', () => {
  beforeEach(() => {
    vi.resetModules()
    vi.clearAllMocks()
  })

  describe('useApi', () => {
    it('initializes with default state', () => {
      const mockApiCall = vi.fn()
      const { data, loading, error } = useApi(mockApiCall)

      expect(data.value).toBe(null)
      expect(loading.value).toBe(false)
      expect(error.value).toBe(null)
    })

    it('handles successful API call', async () => {
      const mockResponse = { data: { id: 1, name: 'Test' } }
      const mockApiCall = vi.fn().mockResolvedValue(mockResponse)
      
      const { data, loading, error, execute } = useApi(mockApiCall)

      expect(loading.value).toBe(false)
      
      const executePromise = execute()
      expect(loading.value).toBe(true)
      expect(error.value).toBe(null)

      await executePromise

      expect(loading.value).toBe(false)
      expect(data.value).toEqual(mockResponse.data)
      expect(error.value).toBe(null)
      expect(mockApiCall).toHaveBeenCalledTimes(1)
    })

    it('handles API call with error response', async () => {
      const mockError = {
        response: {
          data: {
            message: 'Custom error message'
          }
        }
      }
      const mockApiCall = vi.fn().mockRejectedValue(mockError)
      
      const { data, loading, error, execute } = useApi(mockApiCall)

      await execute()

      expect(loading.value).toBe(false)
      expect(data.value).toBe(null)
      expect(error.value).toBe('Custom error message')
    })

    it('handles API call with generic error', async () => {
      const mockError = new Error('Network error')
      const mockApiCall = vi.fn().mockRejectedValue(mockError)
      
      const { data, loading, error, execute } = useApi(mockApiCall)

      await execute()

      expect(loading.value).toBe(false)
      expect(data.value).toBe(null)
      expect(error.value).toBe('Network error')
    })

    it('handles API call with unknown error', async () => {
      const mockError = {}
      const mockApiCall = vi.fn().mockRejectedValue(mockError)
      
      const { data, loading, error, execute } = useApi(mockApiCall)

      await execute()

      expect(loading.value).toBe(false)
      expect(data.value).toBe(null)
      expect(error.value).toBe('An error occurred')
    })

    it('resets state correctly', () => {
      const mockApiCall = vi.fn()
      const { data, loading, error, reset } = useApi(mockApiCall)

      // Set some state
      data.value = { test: 'data' }
      loading.value = true
      error.value = 'test error'

      reset()

      expect(data.value).toBe(null)
      expect(loading.value).toBe(false)
      expect(error.value).toBe(null)
    })

    it('clears error when new API call starts', async () => {
      const mockApiCall = vi.fn()
        .mockRejectedValueOnce(new Error('First error'))
        .mockResolvedValueOnce({ data: 'success' })
      
      const { data, loading, error, execute } = useApi(mockApiCall)

      // First call with error
      await execute()
      expect(error.value).toBe('First error')

      // Second call should clear error
      const executePromise = execute()
      expect(error.value).toBe(null)
      await executePromise
      expect(data.value).toBe('success')
    })
  })

  describe('useApiImmediate', () => {
    it('executes API call immediately', async () => {
      const mockResponse = { data: { immediate: true } }
      const mockApiCall = vi.fn().mockResolvedValue(mockResponse)
      
      const { data, loading } = useApiImmediate(mockApiCall)

      // Should start loading immediately
      expect(loading.value).toBe(true)
      expect(mockApiCall).toHaveBeenCalledTimes(1)

      // Wait for completion
      await vi.waitFor(() => {
        expect(loading.value).toBe(false)
      })

      expect(data.value).toEqual(mockResponse.data)
    })

    it('handles immediate execution errors', async () => {
      const mockError = new Error('Immediate error')
      const mockApiCall = vi.fn().mockRejectedValue(mockError)
      
      const { error, loading } = useApiImmediate(mockApiCall)

      await vi.waitFor(() => {
        expect(loading.value).toBe(false)
      })

      expect(error.value).toBe('Immediate error')
    })
  })
})
EOF

    # Create tests for API utilities
    mkdir -p src/api/__tests__
    cat > src/api/__tests__/index.spec.ts << 'EOF'
import { describe, it, expect, beforeEach, vi } from 'vitest'

// Mock axios before any imports
const mockAxiosInstance = {
  interceptors: {
    request: { use: vi.fn() },
    response: { use: vi.fn() }
  },
  get: vi.fn(),
  post: vi.fn(),
  put: vi.fn(),
  patch: vi.fn(),
  delete: vi.fn()
}

const mockAxios = {
  create: vi.fn(() => mockAxiosInstance)
}

vi.mock('axios', () => ({
  default: mockAxios
}))

describe('API utilities', () => {
  beforeEach(() => {
    vi.resetModules() // Reset modules to ensure side-effects are re-triggered
    vi.clearAllMocks()
    
    // Reset mock return values
    mockAxiosInstance.get.mockResolvedValue({ data: 'default' })
    mockAxiosInstance.post.mockResolvedValue({ data: 'default' })
    mockAxiosInstance.put.mockResolvedValue({ data: 'default' })
    mockAxiosInstance.patch.mockResolvedValue({ data: 'default' })
    mockAxiosInstance.delete.mockResolvedValue({ data: 'default' })
    
    // Mock localStorage
    Object.defineProperty(window, 'localStorage', {
      value: {
        getItem: vi.fn(),
        setItem: vi.fn(),
        removeItem: vi.fn()
      },
      writable: true
    })
  })

  it('creates and exports API functions', async () => {
    // Import after mocking
    const { apiGet, apiPost, apiPut, apiPatch, apiDelete } = await import('../index')
    
    // Test that functions exist and can be called
    expect(typeof apiGet).toBe('function')
    expect(typeof apiPost).toBe('function')
    expect(typeof apiPut).toBe('function')
    expect(typeof apiPatch).toBe('function')
    expect(typeof apiDelete).toBe('function')
  })

  it('apiGet calls underlying axios get method', async () => {
    const mockResponse = { data: 'test' }
    mockAxiosInstance.get.mockResolvedValue(mockResponse)
    
    const { apiGet } = await import('../index')
    const result = await apiGet('/test', { config: 'test' })
    
    expect(mockAxiosInstance.get).toHaveBeenCalledWith('/test', { config: 'test' })
    expect(result).toBe(mockResponse)
  })

  it('apiPost calls underlying axios post method', async () => {
    const mockResponse = { data: 'test' }
    const postData = { name: 'test' }
    mockAxiosInstance.post.mockResolvedValue(mockResponse)
    
    const { apiPost } = await import('../index')
    const result = await apiPost('/test', postData, { config: 'test' })
    
    expect(mockAxiosInstance.post).toHaveBeenCalledWith('/test', postData, { config: 'test' })
    expect(result).toBe(mockResponse)
  })

  it('apiPut calls underlying axios put method', async () => {
    const mockResponse = { data: 'test' }
    const putData = { name: 'updated' }
    mockAxiosInstance.put.mockResolvedValue(mockResponse)
    
    const { apiPut } = await import('../index')
    const result = await apiPut('/test/1', putData, { config: 'test' })
    
    expect(mockAxiosInstance.put).toHaveBeenCalledWith('/test/1', putData, { config: 'test' })
    expect(result).toBe(mockResponse)
  })

  it('apiPatch calls underlying axios patch method', async () => {
    const mockResponse = { data: 'test' }
    const patchData = { name: 'patched' }
    mockAxiosInstance.patch.mockResolvedValue(mockResponse)
    
    const { apiPatch } = await import('../index')
    const result = await apiPatch('/test/1', patchData, { config: 'test' })
    
    expect(mockAxiosInstance.patch).toHaveBeenCalledWith('/test/1', patchData, { config: 'test' })
    expect(result).toBe(mockResponse)
  })

  it('apiDelete calls underlying axios delete method', async () => {
    const mockResponse = { data: 'test' }
    mockAxiosInstance.delete.mockResolvedValue(mockResponse)
    
    const { apiDelete } = await import('../index')
    const result = await apiDelete('/test/1', { config: 'test' })
    
    expect(mockAxiosInstance.delete).toHaveBeenCalledWith('/test/1', { config: 'test' })
    expect(result).toBe(mockResponse)
  })

  it('API functions work without optional parameters', async () => {
    const mockResponse = { data: 'test' }
    mockAxiosInstance.get.mockResolvedValue(mockResponse)
    mockAxiosInstance.post.mockResolvedValue(mockResponse)
    
    const { apiGet, apiPost } = await import('../index')
    
    await apiGet('/test')
    expect(mockAxiosInstance.get).toHaveBeenCalledWith('/test', undefined)
    
    await apiPost('/test')
    expect(mockAxiosInstance.post).toHaveBeenCalledWith('/test', undefined, undefined)
  })

  it('handles axios instance creation', async () => {
    // This will trigger the create call because modules are reset
    await import('../index')
    expect(mockAxios.create).toHaveBeenCalled()
  })
})

describe('API Interceptors', () => {
  let requestHandler: (config: any) => any
  let requestErrorHandler: (error: any) => Promise<any>
  let responseHandler: (response: any) => any
  let responseErrorHandler: (error: any) => Promise<any>
  const mockConsoleLog = vi.fn()
  const mockConsoleError = vi.fn()

  beforeEach(async () => {
    vi.resetModules()
    vi.clearAllMocks()

    // Mock console and location
    vi.stubGlobal('console', { log: mockConsoleLog, error: mockConsoleError })
    Object.defineProperty(window, 'location', { value: { href: '' }, writable: true })
    
    // Capture the interceptor functions
    vi.mocked(mockAxiosInstance.interceptors.request.use).mockImplementation((req, err) => {
      requestHandler = req
      requestErrorHandler = err
    })
    vi.mocked(mockAxiosInstance.interceptors.response.use).mockImplementation((res, err) => {
      responseHandler = res
      responseErrorHandler = err
    })

    // Import the module to trigger setup
    await import('../index')
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('request interceptor adds auth token and logs in dev', () => {
    vi.stubGlobal('localStorage', { getItem: vi.fn(() => 'test-token') })
    const config = { headers: {} }
    
    const result = requestHandler(config)
    
    expect(result.headers.Authorization).toBe('Bearer test-token')
    expect(mockConsoleLog).toHaveBeenCalledWith('API Request:', undefined, undefined)
  })

  it('request interceptor handles missing token', () => {
    vi.stubGlobal('localStorage', { getItem: vi.fn(() => null) })
    const config = { headers: {} }
    
    const result = requestHandler(config)
    
    expect(result.headers.Authorization).toBeUndefined()
  })
  
  it('request interceptor error handler returns promise rejection', async () => {
    const error = new Error('Request error')
    await expect(requestErrorHandler(error)).rejects.toThrow('Request error')
  })
  
  it('response interceptor handles success and logs in dev', () => {
    const response = { status: 200, config: { url: '/test' } }
    
    const result = responseHandler(response)
    
    expect(result).toEqual(response)
    expect(mockConsoleLog).toHaveBeenCalledWith('API Response:', 200, '/test')
  })
  
  it('response interceptor handles 401 error', async () => {
    const mockRemoveItem = vi.fn()
    vi.stubGlobal('localStorage', { getItem: vi.fn(), removeItem: mockRemoveItem })
    
    const error = { response: { status: 401 } }
    
    await expect(responseErrorHandler(error)).rejects.toEqual(error)
    expect(mockRemoveItem).toHaveBeenCalledWith('auth_token')
    expect(window.location.href).toBe('/login')
  })
  
  it('response interceptor handles 403 error', async () => {
    const error = { response: { status: 403 } }
    
    await expect(responseErrorHandler(error)).rejects.toEqual(error)
    expect(mockConsoleError).toHaveBeenCalledWith('Access denied')
  })
  
  it('response interceptor handles 500 server error', async () => {
    const error = { response: { status: 500 } }
    
    await expect(responseErrorHandler(error)).rejects.toEqual(error)
    expect(mockConsoleError).toHaveBeenCalledWith('Server error:', 500)
  })

  it('response interceptor passes through non-response errors', async () => {
    const error = new Error('Network cable unplugged')
    await expect(responseErrorHandler(error)).rejects.toEqual(error)
  })
})
EOF

    cat > src/api/__tests__/services.spec.ts << 'EOF'
import { describe, it, expect, vi } from 'vitest'
import { userService, authService } from '../services'
import * as apiUtils from '../index'

// Mock the API utilities
vi.mock('../index', () => ({
  apiGet: vi.fn(),
  apiPost: vi.fn(),
  apiPut: vi.fn(),
  apiDelete: vi.fn()
}))

describe('API Services', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('userService', () => {
    it('getUsers calls apiGet with correct parameters', () => {
      userService.getUsers(2, 20)
      expect(apiUtils.apiGet).toHaveBeenCalledWith('/users?page=2&per_page=20')
    })

    it('getUsers uses default parameters', () => {
      userService.getUsers()
      expect(apiUtils.apiGet).toHaveBeenCalledWith('/users?page=1&per_page=10')
    })

    it('getUser calls apiGet with user ID', () => {
      userService.getUser(123)
      expect(apiUtils.apiGet).toHaveBeenCalledWith('/users/123')
    })

    it('createUser calls apiPost with user data', () => {
      const userData = { name: 'John', email: 'john@example.com' }
      userService.createUser(userData)
      expect(apiUtils.apiPost).toHaveBeenCalledWith('/users', userData)
    })

    it('updateUser calls apiPut with user ID and data', () => {
      const userData = { name: 'Jane' }
      userService.updateUser(123, userData)
      expect(apiUtils.apiPut).toHaveBeenCalledWith('/users/123', userData)
    })

    it('deleteUser calls apiDelete with user ID', () => {
      userService.deleteUser(123)
      expect(apiUtils.apiDelete).toHaveBeenCalledWith('/users/123')
    })
  })

  describe('authService', () => {
    it('login calls apiPost with credentials', () => {
      const credentials = { email: 'test@example.com', password: 'password' }
      authService.login(credentials)
      expect(apiUtils.apiPost).toHaveBeenCalledWith('/auth/login', credentials)
    })

    it('register calls apiPost with user data', () => {
      const userData = { name: 'John', email: 'john@example.com', password: 'password' }
      authService.register(userData)
      expect(apiUtils.apiPost).toHaveBeenCalledWith('/auth/register', userData)
    })

    it('logout calls apiPost', () => {
      authService.logout()
      expect(apiUtils.apiPost).toHaveBeenCalledWith('/auth/logout')
    })

    it('refreshToken calls apiPost', () => {
      authService.refreshToken()
      expect(apiUtils.apiPost).toHaveBeenCalledWith('/auth/refresh')
    })

    it('getProfile calls apiGet', () => {
      authService.getProfile()
      expect(apiUtils.apiGet).toHaveBeenCalledWith('/auth/profile')
    })
  })
})
EOF

    # Create integration test
    mkdir -p src/__tests__
    cat > src/__tests__/integration.spec.ts << 'EOF'
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { createVuetify } from 'vuetify'
import HelloWorld from '@/components/HelloWorld.vue'
import { useCounterStore } from '@/stores/counter'
import { useApi } from '@/composables/useApi'

describe('Integration Tests', () => {
  let pinia: any

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)
  })

  it('integrates store, composables, and components', async () => {
    const store = useCounterStore()
    
    // Test store integration
    expect(store.count).toBe(0)
    store.increment()
    expect(store.count).toBe(1)
    expect(store.doubleCount).toBe(2)
    
    // Test composable integration
    const mockApiCall = vi.fn().mockResolvedValue({ data: 'test' })
    const { data, loading, execute } = useApi(mockApiCall)
    
    expect(loading.value).toBe(false)
    await execute()
    expect(data.value).toBe('test')
  })

  it('tests component with all features', async () => {
    const testVuetify = createVuetify({ ssr: true })
    const wrapper = mount(HelloWorld, {
      global: {
        plugins: [pinia, testVuetify],
        stubs: {
          'v-card': { template: '<div><slot /></div>' },
          'v-card-title': { template: '<div><slot /></div>' },
          'v-card-text': { template: '<div><slot /></div>' },
          'v-card-actions': { template: '<div><slot /></div>' },
          'v-btn': { 
            template: '<button @click="$emit(\'click\')" :data-testid="$attrs[\'data-testid\']"><slot /></button>',
            emits: ['click']
          },
          'v-spacer': { template: '<div></div>' },
          'v-progress-circular': { template: '<div></div>' }
        }
      }
    })

    // Test component rendering
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.text()).toContain('Hello World Component')

    // Test all interactive elements
    const buttons = wrapper.findAll('button')
    expect(buttons.length).toBeGreaterThan(0)

    // Test counter functionality
    const countButton = wrapper.find('[data-testid="count-button"]')
    if (countButton.exists()) {
      await countButton.trigger('click')
      expect(wrapper.text()).toContain('Count: 1')
    }
  })

  it('handles error states gracefully', async () => {
    const mockErrorCall = vi.fn().mockRejectedValue(new Error('Test error'))
    const { error, execute } = useApi(mockErrorCall)
    
    await execute()
    expect(error.value).toBe('Test error')
  })

  it('handles all store operations', () => {
    const store = useCounterStore()
    
    // Test all operations
    store.increment()
    store.increment()
    expect(store.count).toBe(2)
    
    store.decrement()
    expect(store.count).toBe(1)
    
    store.reset()
    expect(store.count).toBe(0)
    
    // Test computed
    store.count = 5
    expect(store.doubleCount).toBe(10)
  })
})
EOF

    # Create tests for App.vue and Views
    cat > src/__tests__/App.spec.ts << 'EOF'
import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createVuetify, type Vuetify } from 'vuetify'
import App from '@/App.vue'

describe('App.vue', () => {
  let vuetify: Vuetify

  beforeEach(() => {
    vuetify = createVuetify()
  })

  it('renders and toggles theme correctly', async () => {
    const wrapper = mount(App, {
      global: {
        plugins: [vuetify],
        stubs: {
          HelloWorld: true,
          'v-app-bar': { template: '<div><slot/></div>' },
          'v-main': { template: '<div><slot/></div>' },
          'v-container': { template: '<div><slot/></div>' },
          'v-btn': {
            template: '<button @click="$emit(\'click\')"><slot/></button>',
            emits: ['click'],
          },
        },
      },
    })

    expect(wrapper.text()).toContain('Vue Development Environment')
    expect(vuetify.theme.global.name.value).toBe('light')

    const themeButton = wrapper.find('button')
    await themeButton.trigger('click')
    expect(vuetify.theme.global.name.value).toBe('dark')

    await themeButton.trigger('click')
    expect(vuetify.theme.global.name.value).toBe('light')
  })
})
EOF

    mkdir -p src/views/__tests__
    cat > src/views/__tests__/HomeView.spec.ts << 'EOF'
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import HomeView from '../HomeView.vue'

describe('HomeView.vue', () => {
  it('renders correctly', () => {
    const wrapper = mount(HomeView, {
      global: {
        stubs: {
          HelloWorld: true
        }
      }
    })
    expect(wrapper.text()).toContain('Welcome to Vue.js Development Environment')
  })
})
EOF

    cat > src/views/__tests__/AboutView.spec.ts << 'EOF'
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import AboutView from '../AboutView.vue'

describe('AboutView.vue', () => {
  it('renders correctly', () => {
    const wrapper = mount(AboutView)
    expect(wrapper.text()).toContain('About This Project')
    expect(wrapper.text()).toContain('Frontend Framework')
    expect(wrapper.text()).toContain('Styling & UI')
    expect(wrapper.text()).toContain('Development Tools')
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

This project was created with a comprehensive Vue.js development setup script that provides a complete, production-ready development environment.

## 📋 Prerequisites

- **Node.js 18+** - [Download here](https://nodejs.org/)
- **npm** - Comes with Node.js
- **Git** - For version control hooks

## 🛠️ Setup Script Features

The `vue_setup.sh` script creates a complete Vue.js development environment with:

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

## 📋 Features

- ✅ Strict TypeScript configuration (no `any` types allowed)
- ✅ Modern ESLint flat config with Vue and TypeScript rules
- ✅ Prettier code formatting
- ✅ Git hooks with Husky v9+ and lint-staged
- ✅ Conventional commits with commitlint
- ✅ Test coverage reporting with Vitest
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
chmod +x vue_setup.sh
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