# Vue.js + TypeScript Development Environment Setup Script

A comprehensive bash script that creates a production-ready Vue.js development environment with TypeScript, Tailwind CSS, Vuetify, Pinia, Axios, and complete testing setup.

## 🚀 Features

This script automatically sets up a modern Vue.js development environment with:

- **Vue 3** with Composition API
- **TypeScript** with strict configuration
- **Vite** for fast development and building
- **Tailwind CSS** with Vite plugin integration
- **Vuetify 3** Material Design components
- **Pinia** for state management
- **Vue Router** for routing
- **Axios** with interceptors and API service layer
- **Vitest** for unit testing
- **Cypress** for E2E testing
- **ESLint** with TypeScript rules
- **Prettier** for code formatting
- **Husky v9+** with Git hooks
- **Commitlint** for conventional commits
- **Example components** demonstrating all features

## 📋 Prerequisites

Before running the script, ensure you have:

- **Node.js 18+** installed
- **npm** package manager
- **Git** (optional, but recommended)

### Check Prerequisites

```bash
# Check Node.js version (should be 18+)
node --version

# Check npm
npm --version

# Check git (optional)
git --version
```

## 🛠️ Installation & Usage

### Method 1: Download and Run

```bash
# Download the script
curl -O https://raw.githubusercontent.com/your-repo/vue-setup/main/vue_setup.sh

# Make it executable
chmod +x vue_setup.sh

# Run the script
./vue_setup.sh my-project-name
```

### Method 2: Clone Repository

```bash
# Clone this repository
git clone https://github.com/your-repo/vue-setup.git
cd vue-setup

# Make script executable
chmod +x vue_setup.sh

# Run the script
./vue_setup.sh my-project-name
```

### Method 3: Direct Execution

```bash
# Run directly with bash
bash vue_setup.sh my-project-name
```

## 📝 Usage Examples

### Basic Usage

```bash
# Create a new project called "my-app"
./vue_setup.sh my-app
```

### Interactive Mode

```bash
# Run without project name - script will prompt for it
./vue_setup.sh
```

## 🏗️ What Gets Created

After running the script, you'll have a complete project structure:

```
my-project/
├── .husky/                 # Git hooks
├── cypress/                # E2E tests
├── src/
│   ├── api/               # Axios configuration & services
│   ├── assets/            # Static assets & CSS
│   ├── components/        # Vue components
│   ├── composables/       # Vue composables (useApi, etc.)
│   ├── plugins/           # Vuetify & other plugins
│   ├── router/            # Vue Router setup
│   ├── stores/            # Pinia stores
│   ├── test/              # Test utilities
│   └── views/             # Page components
├── .env.example           # Environment variables
├── .eslintrc.cjs          # ESLint configuration
├── .gitignore             # Git ignore rules
├── .lintstagedrc.json     # Lint-staged configuration
├── cypress.config.ts      # Cypress configuration
├── package.json           # Dependencies & scripts
├── README.md              # Project documentation
├── tailwind.config.js     # Tailwind CSS configuration
├── tsconfig.*.json        # TypeScript configurations
├── vite.config.ts         # Vite configuration
└── vitest.config.ts       # Vitest configuration
```

## 🎯 Next Steps

After the script completes:

1. **Navigate to your project:**
   ```bash
   cd my-project-name
   ```

2. **Start development server:**
   ```bash
   npm run dev
   ```

3. **Open your browser:**
   - The dev server will automatically open `http://localhost:3000`
   - You'll see the example component demonstrating all features

4. **Optional - Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your API URL and other settings
   ```

## 📚 Available Scripts

The generated project includes these npm scripts:

```bash
# Development
npm run dev              # Start development server
npm run build            # Build for production
npm run preview          # Preview production build

# Testing
npm run test:unit        # Run unit tests
npm run test:unit:ui     # Run unit tests with UI
npm run test:e2e         # Run E2E tests
npm run test:e2e:dev     # Run E2E tests in dev mode
npm run test:coverage    # Generate test coverage

# Code Quality
npm run lint             # Lint and fix code
npm run format           # Format code with Prettier
npm run type-check       # TypeScript type checking
```

## 🔧 Configuration

### API Configuration

Edit `.env` file to configure your API:

```env
VITE_API_BASE_URL=http://localhost:8000/api
VITE_APP_TITLE=My Vue App
```

### Tailwind CSS

Customize `tailwind.config.js`:

```javascript
export default {
  content: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx}"],
  theme: {
    extend: {
      // Your custom theme extensions
    },
  },
  plugins: ['@tailwindcss/forms', '@tailwindcss/typography'],
}
```

### Vuetify Theming

Edit `src/plugins/vuetify.ts` to customize Material Design theme:

```typescript
export default createVuetify({
  theme: {
    themes: {
      light: {
        colors: {
          primary: '#your-color',
          // ... other colors
        },
      },
    },
  },
})
```

## 🧪 Testing

### Unit Tests

```bash
# Run all unit tests
npm run test:unit

# Run tests with UI
npm run test:unit:ui

# Run with coverage
npm run test:coverage
```

### E2E Tests

```bash
# Run E2E tests (headless)
npm run test:e2e

# Run E2E tests (interactive)
npm run test:e2e:dev
```

## 🔍 What's Included

### TypeScript Configuration
- Strict mode enabled
- No `any` types allowed
- Comprehensive type checking

### ESLint Rules
- Vue 3 specific rules
- TypeScript strict rules
- Prettier integration

### Git Hooks
- Pre-commit: Runs linting and formatting
- Commit-msg: Enforces conventional commits

### API Layer
- Axios with interceptors
- Request/response logging
- Authentication handling
- Error handling
- TypeScript interfaces

## 🐛 Troubleshooting

### Common Issues

**Node.js version error:**
```bash
# Install Node.js 18+ using nvm
nvm install 18
nvm use 18
```

**Permission denied:**
```bash
# Make script executable
chmod +x vue_setup.sh
```

**Port already in use:**
```bash
# Change port in vite.config.ts or kill process
lsof -ti:3000 | xargs kill
```

**Husky hooks not working:**
```bash
# Reinstall Husky hooks
npx husky init
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Vue.js](https://vuejs.org/) team for the amazing framework
- [Vite](https://vitejs.dev/) for the lightning-fast build tool
- [Tailwind CSS](https://tailwindcss.com/) for utility-first styling
- [Vuetify](https://vuetifyjs.com/) for Material Design components
- All the open-source contributors who made this possible

---

**Happy coding!** 🚀

If you find this script helpful, please give it a ⭐ star! 