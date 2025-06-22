#!/bin/bash

# Functions for creating example components and stores

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
    print_status "Example components created ✓"
}
