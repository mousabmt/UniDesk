# UniDesk - Project Documentation

## Table of Contents

1. [Project Overview](#project-overview)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [Dependencies](#dependencies)
5. [Installation & Setup](#installation--setup)
6. [Features Overview](#features-overview)
   - [Authentication](#authentication)
   - [Instructor Features](#instructor-features)
   - [Student Features](#student-features)
   - [Admin Features](#admin-features)
7. [Core Architecture](#core-architecture)
   - [State Management](#state-management)
   - [Routing](#routing)
   - [Services](#services)
8. [Shared Components](#shared-components)
9. [Styling & Theming](#styling--theming)
10. [File Structure Guide](#file-structure-guide)
11. [Development Guidelines](#development-guidelines)
12. [API Integration](#api-integration)
13. [Permissions](#permissions)
14. [Internationalization (i18n)](#internationalization-i18n)
15. [Building & Deployment](#building--deployment)

---

## Project Overview

**UniDesk** is a comprehensive educational platform application developed for AABU (Arab American University of Bethlehem). The application provides a multi-role system supporting different user types: Instructors, Students, and Administrators.

### Project Metadata
- **Name:** UniDesk
- **Version:** 1.0.0+1
- **Flutter SDK:** ^3.11.1
- **Type:** Private Package (not published to pub.dev)
- **Status:** In Development

### Purpose
UniDesk serves as a digital platform connecting instructors and students in an educational environment, providing tools for:
- Course management
- Assignment handling
- Attendance tracking
- Communication (announcements, messages)
- Performance analytics
- File management
- QR code scanning
- Schedule management

---

## Tech Stack

### Framework & Language
- **Flutter:** UI framework for cross-platform mobile and web development
- **Dart:** Programming language (v3.11.1+)

### Key Technologies
| Technology | Version | Purpose |
|-----------|---------|---------|
| go_router | ^17.1.0 | Navigation and routing |
| provider | ^6.0.0 | State management |
| http | ^1.2.1 | HTTP client for API calls |
| shared_preferences | ^2.2.0 | Local persistent storage |
| google_fonts | ^8.0.2 | Custom font support |
| intl | ^0.20.2 | Internationalization (i18n) |
| permission_handler | ^11.3.0 | Runtime permissions management |
| file_picker | ^8.1.2 | File selection from device |
| qr_flutter | ^4.1.0 | QR code generation |
| mobile_scanner | ^5.0.0 | QR code scanning |
| open_filex | ^4.6.0 | File opening functionality |
| carousel_slider | ^5.1.2 | Image carousel component |
| flutter_native_splash | ^2.3.0 | Native splash screen |
| cupertino_icons | ^1.0.8 | iOS-style icons |

### Development Dependencies
- **flutter_test:** Testing framework
- **flutter_lints:** Code quality and style linting

---

## Project Structure

```
unidesk/
├── lib/                           # Main application source code
│   ├── main.dart                  # Application entry point
│   ├── app.dart                   # App configuration and theme
│   ├── core/                      # Core utilities and services
│   │   ├── constants/             # App-wide constants
│   │   │   ├── colors.dart        # Color definitions
│   │   │   ├── sizes.dart         # Size constants
│   │   │   ├── strings.dart       # String constants
│   │   │   ├── navIndexes.dart    # Navigation indices
│   │   │   └── constants.dart     # General constants
│   │   ├── services/              # API and utility services
│   │   │   ├── mockApi.dart       # Mock API service
│   │   │   ├── student_api.dart   # Student API integration
│   │   │   └── textLimiter.dart   # Text utility services
│   │   └── core.md                # Core module documentation
│   ├── features/                  # Feature modules
│   │   ├── auth/                  # Authentication feature
│   │   │   ├── authProvider.dart  # Auth state provider
│   │   │   ├── mock_auth.dart     # Mock auth data
│   │   │   └── pages/             # Auth related pages
│   │   ├── language/              # Internationalization
│   │   │   └── langProvider.dart  # Language state management
│   │   ├── entities/              # User role-specific features
│   │   │   ├── instructor/        # Instructor module
│   │   │   ├── student/           # Student module
│   │   │   ├── admin/             # Admin module (empty)
│   │   │   ├── widgets_std/       # Standard widgets for entities
│   │   │   └── home.md            # Entity home documentation
│   │   └── features.md            # Features documentation
│   ├── shared/                    # Shared utilities and widgets
│   │   ├── widgets/               # Reusable UI components
│   │   ├── shared.md              # Shared module documentation
│   ├── assets/                    # Static assets
│   │   ├── images/                # Image files
│   │   └── fonts/                 # Custom fonts (Plus Jakarta Sans)
│   ├── android/                   # Android native code
│   ├── ios/                       # iOS native code
│   ├── web/                       # Web platform files
│   ├── windows/                   # Windows platform files
│   ├── linux/                     # Linux platform files
│   ├── macos/                     # macOS platform files
│   └── test/                      # Unit and widget tests
├── pubspec.yaml                   # Project dependencies and config
├── analysis_options.yaml          # Dart analyzer settings
├── devtools_options.yaml          # DevTools configuration
├── flutter_native_splash.yaml     # Splash screen configuration
└── README.md                      # Quick project description
```

---

## Dependencies

### Production Dependencies

#### State Management & Provider
- **provider (^6.0.0)** - Dependency injection and state management
  - Manages authentication state
  - Manages language preferences
  - Manages course and assignment data
  - Manages attendance data

#### Navigation & Routing
- **go_router (^17.1.0)** - Type-safe routing and navigation
  - Handles deep linking
  - Manages nested navigation
  - State restoration

#### HTTP & Networking
- **http (^1.2.1)** - Making HTTP requests to backend APIs
  - Student API calls
  - Attendance API integration
  - File upload/download

#### Storage
- **shared_preferences (^2.2.0)** - Local data persistence
  - User preferences
  - Login tokens
  - Application settings

#### UI & Design
- **google_fonts (^8.0.2)** - Custom font support
- **cupertino_icons (^1.0.8)** - iOS style icons
- **carousel_slider (^5.1.2)** - Image carousel widget

#### File Management
- **file_picker (^8.1.2)** - Select files from device storage
- **open_filex (^4.6.0)** - Open files with default applications

#### Scanning & QR
- **mobile_scanner (^5.0.0)** - QR code scanning camera
- **qr_flutter (^4.1.0)** - QR code generation

#### Permissions
- **permission_handler (^11.3.0)** - Handle runtime permissions
  - Camera permissions (for QR scanning)
  - File storage permissions
  - Microphone/camera for media

#### Internationalization
- **intl (^0.20.2)** - Date, number, and string formatting
- Supports multiple languages

#### Splash Screen
- **flutter_native_splash (^2.3.0)** - Native splash screen configuration

### Development Dependencies
- **flutter_test** - Widget and unit testing
- **flutter_lints (^6.0.0)** - Code quality standards

---

## Installation & Setup

### Prerequisites
- Flutter SDK: ^3.11.1
- Dart SDK: Included with Flutter
- Android SDK (for Android development)
- Xcode (for iOS development)
- Git

### Initial Setup

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd unidesk
   ```

2. **Get Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Splash Screen**
   ```bash
   flutter pub run flutter_native_splash:create
   ```

4. **Run the Application**
   ```bash
   # For Android
   flutter run -d android

   # For iOS
   flutter run -d ios

   # For Web
   flutter run -d web

   # For Desktop (Windows/Linux/macOS)
   flutter run -d windows
   ```

### Environment Configuration

1. **Android Setup** (if needed)
   - Ensure `android/local.properties` contains Android SDK path
   - Configure API keys in AndroidManifest.xml if required

2. **iOS Setup** (if needed)
   - Run `flutter pub get` to update pods
   - Open `ios/Runner.xcworkspace` in Xcode if manual signing required

3. **Permissions Configuration**
   - Android: Configured in `android/app/src/main/AndroidManifest.xml`
   - iOS: Configured in `ios/Runner/Info.plist`

---

## Features Overview

### Authentication

**Location:** `lib/features/auth/`

**Files:**
- `authProvider.dart` - Authentication state provider using Provider
- `mock_auth.dart` - Mock user data for testing
- `pages/` - Login and authentication UI pages

**Features:**
- User login/logout
- Session management
- Role-based access (Instructor, Student, Admin)
- User authentication state persistence

**Key Provider:** `AuthProvider` - Manages login state and user information

### Instructor Features

**Location:** `lib/features/entities/instructor/`

**Sub-modules:**

#### 1. **Course Management**
   - **Location:** `course_management/`
   - **Features:**
     - View list of courses
     - Create new courses
     - Edit course details
     - Delete courses
     - Course materials management
   - **Files:**
     - `data/instructor_courses_repository.dart`
     - `data/mock_instructor_courses_data_source.dart`
     - `providers/instructor_courses_provider.dart`

#### 2. **Assignments**
   - **Location:** `assignments/`
   - **Features:**
     - Create and manage assignments
     - Set deadlines
     - Upload assignment materials
     - View student submissions
     - Grade submissions
   - **Files:**
     - `data/instructor_assignments_repository.dart`
     - `data/mock_instructor_assignments_data_source.dart`
     - `providers/instructor_assignments_provider.dart`
   - **Pages:**
     - `assignments_page.dart`
     - `add_assignment.dart`

#### 3. **Attendance Tracking**
   - **Location:** `attendance/`
   - **Features:**
     - QR code based attendance
     - Session management
     - Attendance reports
     - Student presence tracking
   - **Files:**
     - `data/attendance_repository.dart`
     - `providers/attendance_courses_provider.dart`
     - `providers/attendance_session_provider.dart`
     - `providers/attendance_students_provider.dart`
   - **Pages:**
     - `attendance_page.dart`
     - `Attendance_Report.dart`

#### 4. **Additional Pages**
   - **Profile** (`Profile.dart`) - Instructor profile management
   - **Announcements** (`Announcements.dart`) - Create and manage announcements
   - **Messages** (`Messages.dart`) - Messaging with students
   - **Schedule** (`Schedule.dart`) - Course schedule management
   - **Reports & Analytics** (`Reports_Analytics.dart`) - Performance metrics
   - **File Management** (`addfiles.dart`) - Upload and manage course files

#### 5. **Widgets & UI**
   - `widgets/` - Reusable instructor-specific UI components
   - `instr_providers/` - Instructor-specific state providers

### Student Features

**Location:** `lib/features/entities/student/`

**Features:**
- View enrolled courses
- View assignments and submissions
- Attend classes (via QR code)
- View grades
- Download course materials
- Communicate with instructors
- View schedule

**Sub-modules:**
- `pages/` - Student-specific pages (view assignments, view courses, etc.)
- `providers_std/` - Student-specific state providers
- API integration with student services

### Admin Features

**Location:** `lib/features/entities/admin/`

**Status:** Currently empty (planned for future implementation)

**Planned Features:**
- User management
- System analytics
- Content moderation
- System settings
- Reports generation

---

## Core Architecture

### State Management

**Framework:** Provider (v6.0.0)

**Key Providers:**
1. **AuthProvider** - User authentication and login state
2. **LanguageProvider** - Application language preferences
3. **InstructorCoursesProvider** - Instructor's courses list
4. **InstructorAssignmentsProvider** - Instructor's assignments
5. **AttendanceCoursesProvider** - Courses for attendance
6. **AttendanceSessionProvider** - Current attendance session
7. **AttendanceStudentsProvider** - Students in attendance

**Provider Architecture:**
```dart
// Example Provider Pattern
class MyProvider with ChangeNotifier {
  MyData _data;
  
  MyData get data => _data;
  
  void updateData(NewData) {
    _data = newData;
    notifyListeners();
  }
}

// Usage in Widget
Consumer<MyProvider>(
  builder: (context, provider, child) {
    return Text(provider.data.toString());
  },
)
```

### Routing

**Framework:** go_router (v17.1.0)

**Route Structure:**
- Nested navigation for multi-level flows
- Deep linking support
- Automatic state restoration
- Role-based route guards

**Key Routes:**
- `/login` - Authentication
- `/instructor/home` - Instructor dashboard
- `/instructor/courses` - Course management
- `/instructor/assignments` - Assignment management
- `/instructor/attendance` - Attendance tracking
- `/student/home` - Student dashboard
- `/student/courses` - Student courses
- `/admin/home` - Admin dashboard (future)

### Services

**Location:** `lib/core/services/`

#### 1. **Mock API Service** (`mockApi.dart`)
   - Provides mock data for development
   - Simulates backend responses
   - Used for testing without real backend

#### 2. **Student API** (`student_api.dart`)
   - Real API integration for student endpoints
   - HTTP client configuration
   - Request/response handling
   - Error handling

#### 3. **Text Limiter** (`textLimiter.dart`)
   - Text truncation utilities
   - Character limit handling
   - String formatting helpers

---

## Shared Components

**Location:** `lib/shared/`

### Reusable Widgets

#### 1. **App Layout** (`app_layout.dart`)
   - Responsive layout wrapper
   - Main application shell

#### 2. **App Navigation** (`app_navbar.dart`)
   - Bottom navigation bar
   - Navigation menu
   - Tab-based navigation

#### 3. **App Footer** (`app_footer.dart`)
   - Bottom footer component
   - Copyright and additional links

#### 4. **Responsive Layout** (`responsive_layout.dart`)
   - Mobile vs tablet/desktop layouts
   - Breakpoint management
   - Adaptive UI components

#### 5. **Custom Theme Widgets**
   - `custom_tealBottom.dart` - Teal-colored bottom navigation
   - `custom_tealIcon.dart` - Teal-colored icon components

#### 6. **Language Toggle** (`langToggle.dart`)
   - Language selection UI
   - Internationalization switcher

#### 7. **Icons** (`cupertino_icons`)
   - iOS style icons library

---

## Styling & Theming

**Location:** `lib/core/constants/`

### Color Scheme (`colors.dart`)
- **Primary Colors:** Teal/Cyan theme
- **Secondary Colors:** Accent colors
- **Neutral Colors:** Grays for backgrounds and borders
- **Status Colors:** Success, error, warning states

### Size Constants (`sizes.dart`)
- **Padding:** Standard spacing values
- **Border Radius:** Standard corner radius values
- **Font Sizes:** Typography scale
- **Icon Sizes:** Standard icon dimensions

### Typography

**Font Family:** Plus Jakarta Sans
- **Regular Weight:** Standard text
- **SemiBold Weight (600):** Emphasized text
- **Bold Weight (700):** Headings

**Location:** `assets/fonts/`

### Theme Configuration (`app.dart`)
- Material Design 3 support
- Light/Dark mode support (if implemented)
- Custom theme colors
- Typography customization

---

## File Structure Guide

### Adding New Features

1. **Create Feature Folder**
   ```
   lib/features/[feature-name]/
   ├── data/
   │   ├── repositories/
   │   ├── data_sources/
   │   └── models/
   ├── providers/
   ├── pages/
   ├── widgets/
   └── [feature-name].md
   ```

2. **Create Provider**
   ```dart
   class MyFeatureProvider extends ChangeNotifier {
     // State
     // Getters
     // Methods
   }
   ```

3. **Create Pages**
   ```dart
   class MyFeaturePage extends StatelessWidget {
     // UI Implementation
   }
   ```

### Code Organization

**Imports Organization:**
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/...'; // Project imports
```

**File Naming:**
- Pages: `page_name.dart` (lowercase with underscores)
- Widgets: `widget_name.dart`
- Providers: `entity_provider.dart`
- Models: `model_name.dart`

---

## Development Guidelines

### Best Practices

1. **State Management**
   - Use Provider for shared state
   - Keep providers focused on single responsibility
   - Use `notifyListeners()` efficiently

2. **Widget Structure**
   - Break large widgets into smaller, reusable components
   - Use `const` constructors where possible
   - Separate stateful and stateless widgets appropriately

3. **Error Handling**
   ```dart
   try {
     // API call or operation
   } catch (e) {
     // Handle error with user feedback
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Error: $e')),
     );
   }
   ```

4. **Null Safety**
   - Use null-coalescing operators (`??`)
   - Use null-assertion sparingly
   - Enable strict null-checking

5. **Performance**
   - Use `ListView.builder` for long lists
   - Implement image caching
   - Debounce frequent operations

6. **Documentation**
   - Add doc comments to classes and functions
   - Include usage examples in complex code
   - Update module documentation files

### Code Quality

- Run linter: `flutter analyze`
- Format code: `dart format lib/`
- Fix issues: `dart fix`

### Testing

**Test Location:** `test/`

**Test Files:**
- `widget_test.dart` - Widget tests
- `instructor_courses_flow_test.dart` - Feature flow tests

**Running Tests:**
```bash
flutter test
flutter test --coverage  # With coverage report
```

---

## API Integration

### Backend Communication

**HTTP Client:** `http` package (v1.2.1)

**Configuration:**
- Base URL: [Configure in student_api.dart]
- Timeout: [Configure as needed]
- Headers: Content-Type, Authorization

### API Endpoints (Example Structure)

```
POST /api/auth/login
GET /api/instructor/courses
POST /api/instructor/courses
GET /api/assignments
POST /api/assignments
GET /api/attendance/sessions
POST /api/attendance/mark
GET /api/student/enrollments
```

### Error Handling

```dart
try {
  final response = await http.get(
    Uri.parse('$baseUrl/endpoint'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  if (response.statusCode == 200) {
    // Success
  } else if (response.statusCode == 401) {
    // Unauthorized - refresh token or logout
  } else {
    // Handle other errors
  }
} catch (e) {
  // Network error handling
}
```

### Mock Data for Development

**Location:** `lib/core/services/mockApi.dart`

Use mock API for development without backend:
```dart
// In providers
final apiService = MockApiService();
```

---

## Permissions

### Android Permissions

**Location:** `android/app/src/main/AndroidManifest.xml`

**Required Permissions:**
- `CAMERA` - For QR code scanning
- `READ_EXTERNAL_STORAGE` - File access
- `WRITE_EXTERNAL_STORAGE` - File download/upload
- `INTERNET` - Network requests

**Usage:**
```dart
import 'package:permission_handler/permission_handler.dart';

final status = await Permission.camera.request();
if (status.isGranted) {
  // Camera permission granted
}
```

### iOS Permissions

**Location:** `ios/Runner/Info.plist`

**Required Keys:**
- `NSCameraUsageDescription` - Camera access reason
- `NSPhotoLibraryUsageDescription` - Photo library access

### Runtime Permission Handling

```dart
Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  
  if (status.isDenied) {
    // Permission denied
  } else if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    // Permanently denied - open app settings
    openAppSettings();
  }
  return false;
}
```

---

## Internationalization (i18n)

### Language Support

**Provider:** `lib/features/language/langProvider.dart`

**Supported Languages:**
- English
- Arabic (and others as configured)

### Implementation

**Strings:** `lib/core/constants/strings.dart`
```dart
const String welcomeMessage = "Welcome to UniDesk";
```

**Date/Number Formatting:** `intl` package
```dart
import 'package:intl/intl.dart';

final formatter = DateFormat('dd/MM/yyyy');
String formatted = formatter.format(DateTime.now());
```

### Adding New Languages

1. Create string maps for new language in `strings.dart`
2. Update `LanguageProvider` with new language option
3. Test language switching in app

---

## Building & Deployment

### Build Configuration

**Version:** `pubspec.yaml`
```yaml
version: 1.0.0+1
```

### Building for Release

#### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Build for specific ABI
flutter build apk --release --target-platform android-arm64
```

#### iOS
```bash
# Build iOS app
flutter build ios --release

# Build without code signing (simulator)
flutter build ios --release --no-codesign
```

#### Web
```bash
flutter build web --release
```

#### Desktop (Windows/Linux/macOS)
```bash
# Windows
flutter build windows --release

# Linux
flutter build linux --release

# macOS
flutter build macos --release
```

### Release Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update build number
- [ ] Test all features
- [ ] Run `flutter analyze`
- [ ] Run `flutter test`
- [ ] Generate splash screens
- [ ] Update README if necessary
- [ ] Build release artifacts
- [ ] Sign apps (if required)
- [ ] Test on real devices
- [ ] Create release notes

### CI/CD Integration

**Recommended Tools:**
- GitHub Actions
- GitLab CI
- Fastlane (for iOS/Android release automation)

---

## Project Configuration Files

### pubspec.yaml
- Project metadata
- Dependencies management
- Asset and font configuration
- Version management

### analysis_options.yaml
- Dart analyzer rules
- Lint settings
- Code quality thresholds

### devtools_options.yaml
- DevTools configuration
- Debugging tools setup

### flutter_native_splash.yaml
- Splash screen configuration
- Branding assets
- Display settings

### gradle.properties (Android)
- Android build configuration
- Kotlin settings
- Build optimization flags

### Podfile (iOS)
- iOS dependency management
- Platform configuration
- Pod repository settings

---

## Troubleshooting

### Common Issues

1. **Build Failures**
   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Package Import Errors**
   ```bash
   # Regenerate packages
   flutter pub get
   flutter pub upgrade
   ```

3. **Platform-Specific Issues**
   - Android: Check `android/local.properties`
   - iOS: Run `pod install` in ios directory
   - Web: Clear browser cache

4. **State Management Issues**
   - Ensure providers are wrapped in `MultiProvider`
   - Check `notifyListeners()` is called
   - Verify providers are registered in app

5. **Permission Issues**
   - Check AndroidManifest.xml
   - Verify Info.plist keys
   - Test on real device (simulator may not honor all permissions)

---

## Resources & Documentation

### Official Documentation
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)
- [go_router](https://pub.dev/packages/go_router)

### Learning Resources
- Flutter Codelabs
- Dart Language Tour
- Material Design Guidelines

### Project Documentation
- Module-specific docs: `[module-name].md`
- API documentation in code comments
- Inline code examples

---

## Contacts & Support

**Project:** UniDesk for AABU
**Version:** 1.0.0
**Last Updated:** 2026

### Documentation Maintenance

When updating project features or structure, please maintain this documentation file to reflect changes and keep it current.

---

**End of Documentation**
