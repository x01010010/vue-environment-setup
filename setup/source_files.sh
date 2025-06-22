#!/bin/bash

# Functions for updating the source files (main.ts, App.vue, views)

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