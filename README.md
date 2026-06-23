# Todo Flow — Flutter Internship Assessment

A clean, modern Todo management application built with Flutter, integrating a live REST API for authentication and task management.

## 🔗 Live API

- **Base URL:** `https://karyana.shop`
- Postman collection provided by the assessment was used for endpoint reference and testing.

## 🏗️ Architecture

This project follows the **MVVM (Model-View-ViewModel)** architecture pattern, with a clear separation of concerns:
View → ViewModel → Repository → Service → API

- **Views** — UI screens, no business logic
- **ViewModels** — hold state, expose data/actions to the UI via `Provider`
- **Repositories** — handle error translation and orchestrate service calls
- **Services** — make raw API calls using Dio

**State Management:** Provider

## 📂 Project Structure
lib/

├── core/           # Constants, network setup, routing, theming, utilities

├── models/         # Data models (User, Todo, AuthResponse)

├── repositories/    # Error handling + business logic between services and viewmodels

├── services/        # Direct API calls via Dio

├── viewmodels/      # State management (Provider)

├── views/           # UI screens (auth, dashboard, todos, profile, splash)

└── widgets/          # Reusable UI components

## ✨ Features

### Authentication
- Register, Login, Get Profile
- Token persisted locally with SharedPreferences — stays logged in across app restarts
- Logout clears session completely

### Todo Management
- Create, view, edit, and delete tasks
- Mark tasks as complete/pending
- Priority selection (High / Medium / Low)
- Due date selection
- Fetch a single todo by ID (used on the detail screen to always show the freshest data)

### Dashboard
- Task statistics: total, completed, pending, overdue
- Progress overview
- Recent tasks list

### Additional
- Client-side search/filter on the todo list
- Pull-to-refresh
- Health check on app startup — detects if the server is unreachable and shows a retry screen instead of failing silently
- Proper loading, empty, and error states throughout
- Graceful error handling for network failures, timeouts, and invalid responses

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio or VS Code
- An Android device or emulator

### Setup

```bash
git clone https://github.com/AfzalVirk/todo-assessment.git
cd todo-assessment
flutter pub get
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## 📦 Packages Used

- `provider` — state management
- `dio` — networking
- `shared_preferences` — local token/session storage

## 📸 Screenshots

## 🧪 Testing

The application was manually tested end-to-end against the live API, with all responses cross-verified using Postman, including:
- Auth flow (register/login/token persistence/logout)
- Full Todo CRUD lifecycle
- Error states (offline handling, server unreachable)
- Release build verification on a physical device