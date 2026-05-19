# UniDesk Frontend Documentation

## Overview

UniDesk is a Flutter frontend for an academic platform used by students and instructors. The application provides authenticated, role-aware access to academic records, course materials, assignments, announcements, attendance, notifications, profiles, and supporting university services.

The frontend is built as a cross-platform Flutter application with a feature-first structure. It uses Provider for state management, GoRouter for declarative navigation, Firebase Cloud Messaging for push notifications, local notifications for in-app delivery, secure token storage, and repository/data-source layers for API integration.

## Frontend Technology Stack

| Area | Technology |
| --- | --- |
| UI framework | Flutter |
| Language | Dart |
| Routing | `go_router` |
| State management | `provider` |
| API client | `http` |
| Persistent preferences | `shared_preferences` |
| Secure token storage | `flutter_secure_storage` on native platforms |
| Push notifications | `firebase_core`, `firebase_messaging` |
| Local notifications | `flutter_local_notifications` |
| File selection | `file_picker` |
| File opening | `open_filex`, `url_launcher` |
| QR generation | `qr_flutter` |
| QR scanning | `mobile_scanner` |
| Localization utilities | `intl` |
| Loading polish | `shimmer` |
| Splash screen | `flutter_native_splash` |
| Typography | Bundled `PlusJakartaSans` font family |

## Project Structure

```text
lib/
  main.dart
  firebase_options.dart
  core/
    constants/
    services/
  features/
    auth/
    language/
    notifications/
    entities/
      student/
      instructor/
      widgets_std/
  shared/
    widgets/
```

### Main Areas

| Area | Responsibility |
| --- | --- |
| `lib/main.dart` | App bootstrap, Firebase setup, notification setup, providers, and routes. |
| `lib/core/constants` | Shared colors, sizing, navigation indexes, strings, and app constants. |
| `lib/core/services` | API access, text utilities, notification services, and mock/demo data support. |
| `lib/features/auth` | Login, token lifecycle, role resolution, and logout. |
| `lib/features/language` | Runtime English/Arabic language switching. |
| `lib/features/notifications` | Device token sync, notification history, unread count, and read state. |
| `lib/features/entities/student` | Student dashboard, courses, materials, assignments, grades, semesters, profile, support, and QR attendance registration. |
| `lib/features/entities/instructor` | Instructor dashboard, course management, files, attendance, assignments, grading, announcements, reports, schedule, messages, and profile. |
| `lib/shared/widgets` | App layout, navigation bar, footer navigation, language toggle, responsive helpers, and reusable buttons/icons. |

## Application Startup

The app starts in `lib/main.dart` and performs these frontend initialization steps:

1. Ensures Flutter bindings are ready.
2. Preserves the native splash screen during initialization.
3. Initializes Firebase using platform-specific Firebase options.
4. Registers the Firebase Messaging background handler.
5. Initializes Firebase notification handling and local notifications.
6. Initializes English and Arabic date formatting.
7. Creates the app-level provider tree.
8. Builds `MaterialApp.router` with GoRouter.
9. Removes the splash screen after the first frame is ready.

## Provider Tree

The frontend registers global services and feature state through `MultiProvider`.

### Global Providers

| Provider | Purpose |
| --- | --- |
| `LangProvider` | Tracks current language and resolves translated strings. |
| `AuthProvider` | Stores auth token, user data, role, loading state, and logout/login actions. |
| `NotificationProvider` | Loads notification history, unread counts, and read status. |

### Student Providers

| Provider | Purpose |
| --- | --- |
| `ProfileProvider` | Loads and normalizes student profile details. |
| `CoursesProvider` | Loads current courses and academic progress. |
| `PrevsemestersProvider` | Provides completed courses grouped by previous semesters. |
| `CurrentSemesterProvider` | Provides the current schedule grouped by day. |
| `AnnoucProvider` | Exposes student announcements through the student announcements provider. |
| `StudentAssignmentsProvider` | Manages assignment list, assignment detail, submissions, and upload state. |
| `StudentMaterialsProvider` | Manages course material selection and course file lists. |

### Instructor Providers

| Provider | Purpose |
| --- | --- |
| `InstructorCoursesProvider` | Manages instructor course selection, sections, details, students, files, and uploads. |
| `InstructorAssignmentsProvider` | Manages course/section selection, assignment creation, submissions, and grading. |
| `InstructorAnnouncementsProvider` | Manages course/section selection, announcement types, creation, and recent announcements. |
| `AttendanceCoursesProvider` | Loads attendance-capable instructor courses. |
| `AttendanceStudentsProvider` | Loads section rosters and attendance status. |
| `AttendanceSessionProvider` | Starts, tracks, and closes attendance sessions. |

### Repository Providers

Repositories are injected separately from UI providers so screens consume feature state while data access remains replaceable.

| Repository | Backing data source |
| --- | --- |
| `InstructorCoursesRepository` | `ApiInstructorCoursesDataSource` |
| `InstructorAssignmentsRepository` | `ApiInstructorAssignmentsDataSource` |
| `InstructorAnnouncementsRepository` | `ApiInstructorAnnouncementsDataSource` |
| `StudentAssignmentsRepository` | `ApiStudentAssignmentsDataSource` |
| `StudentMaterialsRepository` | `ApiStudentMaterialsDataSource` |
| `StudentAnnouncementsRepository` | `ApiStudentAnnouncementsDataSource` |
| `NotificationRepository` | `ApiNotificationHistoryDataSource` |
| `AttendanceRepository` | `StudentApi` with mock-data support for local/demo use |

## Routing

Routing is handled with `GoRouter`. The app starts at `/login` and redirects authenticated users to the proper role home.

### Route Guards

The router uses role-aware guards:

| Role | Guard behavior |
| --- | --- |
| Guest | Redirected to `/login` when opening authenticated routes. |
| Student | Allowed into student route tree and student standalone pages. |
| Instructor | Allowed into instructor route tree. |
| Admin | Recognized by auth role helpers and routed to authorized areas as configured. |

### Student Routes

| Route | Screen |
| --- | --- |
| `/` | Student home dashboard |
| `/courses-files` | Student course materials |
| `/courses` | Current courses |
| `/assignments` | Student assignments |
| `/profile` | Student profile |
| `/current-semester` | Current semester schedule |
| `/completed-courses` | Previous semesters |
| `/courses-grades` | Grades |
| `/technical-support` | Technical support |
| `/register-attendance` | QR attendance scanner |
| `/notifications` | Notification history |

### Instructor Routes

| Route | Screen |
| --- | --- |
| `/instructor/home` | Instructor home dashboard |
| `/instructor/files` | Upload and manage course files |
| `/instructor/course-details` | Course details, files, assignments, and students |
| `/instructor/attendance` | Attendance session management |
| `/instructor/attendance-report` | Attendance report |
| `/instructor/schedule` | Schedule |
| `/instructor/assignments-list` | Assignment list, submissions, and grading |
| `/instructor/add-assignment` | Create assignment |
| `/instructor/announcements` | Create and view announcements |
| `/instructor/profile` | Instructor profile |
| `/instructor/messages` | Messages |
| `/instructor/reports` | Reports and analytics |
| `/notifications` | Notification history |

## Layout and Navigation

### Shared App Layout

`AppLayout` wraps student pages with:

- `AppNavbar` for top actions.
- Main page content.
- `AppFooter` for bottom navigation.

`InstructorLayout` provides the instructor shell with role-specific bottom navigation and shared layout behavior.

### Top Navigation

`AppNavbar` provides:

- Back navigation when the current navigator can pop.
- Language toggle when the route is at the shell root.
- Notification icon with unread count badge.
- Menu actions for home, course/file area, attendance/assignment area, profile, refresh, and logout.
- Role-aware route targets for student and instructor users.

### Bottom Navigation

`AppFooter` switches item sets based on the authenticated role.

Student items:

- Home
- Files
- Courses
- Assignments
- Profile

Instructor items:

- Home
- Courses/files
- Attendance
- Assignments
- More/profile

## Authentication

`AuthProvider` is the central authentication state object.

### Login Flow

1. User enters university email and password.
2. Login form validates required fields and email-like format.
3. `AuthProvider.login` calls `StudentApi.login`.
4. API login attempts role-aware endpoints when needed.
5. Token, user id, user payload, and role are stored locally.
6. Device notification token is registered for the authenticated user.
7. Router redirects by role:
   - Instructor to `/instructor/home`
   - Student to `/`
   - Other recognized state to `/unauthorized`

### Session Restore

On app startup, `AuthProvider.loadToken`:

- Initializes shared preferences.
- Reads the token from secure/native storage or web preferences.
- Reads cached user id, role, and user payload.
- Syncs the current notification token when a valid auth token exists.
- Notifies listeners so GoRouter can refresh route access.

### Logout Flow

Logout:

- Removes the current device token from the backend.
- Calls the logout API.
- Clears auth token, role, user id, user payload, and message state.
- Removes persisted auth keys.
- Notifies listeners so routes return to `/login`.

## Security and Privacy

The frontend includes the following security-oriented behaviors:

- Bearer tokens are attached to authenticated API calls through the centralized `StudentApi` header builder.
- Native platforms store auth tokens in `flutter_secure_storage`.
- Web builds use shared preferences for token persistence in the browser environment.
- Role-specific route guards keep student and instructor route trees separate.
- Login validates required credentials before sending requests.
- Email-style input is validated before login submission.
- Password input uses obscured text with a visibility toggle.
- Stored user JSON is decoded defensively and refreshed from the API when available.
- Device push tokens are registered only when an auth token is available.
- Device push tokens are removed during logout.
- File upload and assignment submission requests use authenticated multipart requests.
- Notification history and unread-count requests use authenticated API calls.
- QR attendance registration sends the scanned token through the authenticated attendance endpoint.
- Backend-originated data is normalized into typed models before reaching the UI in repository-backed features.

## Performance

The frontend uses several patterns that support responsive rendering and efficient data loading:

- `StatefulShellRoute.indexedStack` preserves tab state while switching between navigation branches.
- Providers expose `loadIfNeeded` methods so screens can avoid duplicate network requests.
- Provider refresh methods update only the related feature state.
- `context.select` and `Selector` are used for targeted rebuilds, such as auth role, language labels, unread counts, and loading states.
- Repository layers return model objects or normalized maps, reducing transformation work in widgets.
- Notification history is sorted once after loading and stored as an unmodifiable list.
- Course, section, assignment, and announcement selections are cached inside providers.
- The login background and logo are wrapped in `RepaintBoundary`.
- Login images use lower filter quality where appropriate for smoother rendering.
- Skeleton and shimmer states are available for content loading.
- `RefreshIndicator` gives explicit user-triggered refresh without rebuilding the full app tree.
- Date formatting is initialized once at startup for supported locales.
- Static constants centralize colors, sizes, and labels, reducing repeated object setup in screens.
- Native splash screen remains visible until initialization finishes, keeping startup visually polished.

## Data Flow

### High-Level Data Flow

```text
Screen widget
  -> Provider / ChangeNotifier
  -> Repository
  -> Data source
  -> StudentApi
  -> HTTP request
  -> API response
  -> Normalized model/map
  -> Provider state
  -> Widget rebuild
```

### Authentication Data Flow

```text
LoginPage
  -> AuthProvider.login(email, password)
  -> StudentApi.login()
  -> /login, /login/student, or /login/instructor
  -> token + user + role
  -> secure storage/shared preferences
  -> notification device-token registration
  -> GoRouter redirect by role
```

### Student Course Data Flow

```text
Student page
  -> CoursesProvider.loadIfNeeded()
  -> StudentApi.getCourses()
  -> StudentApi.getAcademicProgress()
  -> course list enriched with grade/progress data
  -> current courses, grades, progress, and semester UI
```

### Student Materials Data Flow

```text
Course materials page
  -> builds course options from current courses
  -> StudentMaterialsProvider.selectCourse()
  -> StudentMaterialsRepository.getMaterialsByCourse()
  -> ApiStudentMaterialsDataSource
  -> StudentApi materials endpoints
  -> StudentCourseMaterial list
  -> material cards grouped by selected course/category
```

### Student Assignment Data Flow

```text
AssignmentPage
  -> StudentAssignmentsProvider.loadAssignments()
  -> StudentAssignmentsRepository
  -> ApiStudentAssignmentsDataSource
  -> StudentApi.getStudentAssignments()
  -> assignment cards

Assignment detail / submit
  -> loadAssignmentDetail(assignmentId)
  -> submitAssignment(fileName, localPath/fileBytes)
  -> multipart upload
  -> detail refresh
```

### Instructor Course Data Flow

```text
Instructor files/course pages
  -> InstructorCoursesProvider.loadIfNeeded(instructorId)
  -> InstructorCoursesRepository.getInstructorCourses()
  -> selected course and section
  -> getCourseDetails()
  -> files, students, summary metrics, and upcoming lecture data
```

### Instructor Assignment Data Flow

```text
AssignmentsPage / AddAssignmentPage
  -> InstructorAssignmentsProvider.loadIfNeeded()
  -> course and section selection
  -> getAssignments()
  -> selected assignment
  -> getAssignmentSubmissions()
  -> gradeSubmission() or createAssignment()
  -> refreshed assignment/submission state
```

### Instructor Announcement Data Flow

```text
AnnouncementsPage
  -> InstructorAnnouncementsProvider.loadIfNeeded()
  -> course and section selection
  -> getAnnouncements()
  -> filtered announcement list
  -> createAnnouncement()
  -> refreshed announcement list
```

### Attendance Data Flow

```text
Instructor AttendancePage
  -> AttendanceCoursesProvider
  -> AttendanceStudentsProvider
  -> AttendanceSessionProvider.startSession()
  -> API attendance session token
  -> QR display
  -> student scans QR
  -> QRScannerPage
  -> AttendanceRepository.registerAttendance()
  -> refreshed student attendance state
```

### Notification Data Flow

```text
FirebaseMessaging
  -> FirebaseNotificationService
  -> LocalNotificationService
  -> visible local notification

NotificationHistoryPage
  -> NotificationProvider.loadHistory()
  -> NotificationRepository.fetchHistory()
  -> StudentApi.getNotificationsHistory()
  -> sorted notification list
  -> markAsRead() / markAllAsRead()
  -> unread count refresh
```

## Feature Catalog

### Login and Account Access

- Full-screen branded login experience.
- University email and password fields.
- Password visibility toggle.
- Language toggle on the login page.
- Loading state during authentication.
- Role-based landing after login.
- Secure session restore on app restart.
- Logout from the shared top menu.

### Student Home

- Personalized welcome area.
- Profile-driven student summary.
- Academic metrics such as GPA, credits, completion, and course progress.
- Announcement carousel/section.
- Quick actions for academic and support flows.
- Loading skeletons and refresh behavior.

### Student Courses

- Current course list.
- Course cards with code, name, instructor/teaching mode, credits, grade, and absence information.
- Academic progress summary.
- Integration with grade data from academic progress.
- Refresh support through the navbar and screen-level actions.

### Student Course Materials

- Course selector built from enrolled courses.
- Course material list per selected course.
- File/category presentation for material discovery.
- Open/download behavior through URL and file-opening support where applicable.
- Centered state messages for loading and empty content.

### Student Assignments

- Assignment list.
- Assignment detail sheet.
- Assignment metadata such as title, description, due date, score, course, section, and submission state.
- Attachment display for assignment files.
- Submission history display.
- File picker integration for assignment submission.
- Multipart submission using local path or in-memory bytes.
- Submit state and success messaging.

### Student Grades and Semesters

- Current semester schedule grouped by day.
- Previous semesters grouped into semester sections.
- Course grades view.
- Academic progress data sourced from the central student API.

### Student Profile

- Student information page.
- Name, student number, email, major, year, credits, total hours, personal email, address, and identifiers.
- Personal information sheets and reusable profile field widgets.
- Cached profile support with API refresh.

### Student Attendance Registration

- QR scanner page using `mobile_scanner`.
- Scanned attendance token submission.
- Authenticated attendance registration through the attendance repository.

### Student Technical Support

- Dedicated technical support page.
- Form-style support experience using the shared visual system.

### Instructor Home

- Instructor welcome area.
- Today overview metrics.
- Next lecture card.
- Quick action grid for files, attendance, reports, and announcements.
- Course summary cards.
- Loading skeletons and refresh behavior.

### Instructor Course Management

- Course and section selection.
- Course detail page with overview, files, assignments, and students.
- Course summary metrics including attendance, assignments, and file counts.
- Upcoming lecture information.
- Student roster list.
- Course file sections and file item widgets.

### Instructor File Management

- File upload page scoped to course and section.
- Category selection for uploaded material.
- File picker/dropzone-style upload interaction.
- Upload state and course detail refresh after upload.
- File metadata such as name, extension, size, category, and upload date.

### Instructor Attendance

- Course and lecture selection.
- Attendance session start and close actions.
- QR code generation for active attendance sessions.
- Student list with attendance status.
- Attendance metrics and report-oriented tab content.
- Integration with live API sessions and local/demo data support.

### Instructor Assignments

- Course and section selectors.
- Assignment list for selected section.
- Assignment creation screen.
- Optional attachment picker for assignment creation.
- Submission list for selected assignment.
- Submission attachment opening through local file or remote URL.
- Score entry and grading flow.
- Validation against assignment maximum score.
- Refreshed submission status after grading.

### Instructor Announcements

- Course and section scoped announcement creation.
- Announcement type selector with visual type badges.
- Supported announcement types:
  - General
  - Project guidelines
  - New assignment
  - Class cancelled
  - Exam schedule
- Recent announcements list sorted by creation date.
- Creation state and refreshed list after publishing.

### Instructor Reports, Schedule, Messages, and Profile

- Reports and analytics page.
- Instructor schedule page.
- Messages page.
- Instructor profile page.
- Shared shell navigation for all instructor surfaces.

### Notifications

- Firebase Cloud Messaging initialization.
- Foreground notification handling.
- Background notification handler.
- Local notification display with Android notification channel and iOS settings.
- Device token registration and token refresh handling.
- Notification history page.
- Unread count badge in the app bar.
- Mark single notification as read.
- Mark all notifications as read.
- Pull-to-refresh notification list.

### Language Support

- English and Arabic translation maps.
- Runtime language toggle.
- Language-aware labels in navigation, login, home, courses, profile, announcements, and shared controls.
- Date formatting initialized for English and Arabic.
- Direction-aware back icon selection in the app bar.

## API Integration

The frontend centralizes HTTP access in `StudentApi`.

### API Configuration

The API base URL is configured by Dart environment variable:

```dart
const String.fromEnvironment(
  'UNIDESK_API_BASE_URL',
  defaultValue: 'https://anguished-ankle-footprint.ngrok-free.dev/api',
)
```

This supports environment-specific builds while keeping the frontend API surface centralized.

### Shared Request Behavior

`StudentApi` provides:

- Base URI construction.
- Query parameter serialization.
- JSON decoding.
- Success status detection.
- Bearer token header injection.
- Standard `Accept: application/json` request headers.
- Multipart requests for file upload and submission.
- Response normalization for backend payload variants.

### Main API Areas

| Area | Client capabilities |
| --- | --- |
| Authentication | Login, logout, token persistence helpers. |
| Device tokens | Register and remove FCM device tokens. |
| Notifications | History, mark read, mark all read, unread count. |
| Student courses | Current courses and academic progress. |
| Student schedule | Current semester schedule grouped by day. |
| Student profile | Profile details and normalized student display fields. |
| Student materials | Materials by course and category. |
| Student assignments | List, detail, submit assignment, submissions. |
| Student attendance | Register attendance from scanned QR token. |
| Instructor profile | Instructor profile details. |
| Instructor courses | Managed courses, section students, course files, course details. |
| Instructor files | Course file upload and file metadata normalization. |
| Instructor assignments | Assignment list, creation, submissions, grading. |
| Instructor announcements | Announcement list and creation. |
| Attendance sessions | Start, close, and inspect session details. |

## Models and Normalization

The frontend uses typed models for repository-backed features and normalized maps for shared API compatibility.

### Typed Model Areas

| Area | Model examples |
| --- | --- |
| Student assignments | `StudentAssignment`, `StudentSubmission`, `CourseData`, `FileData`, `SectionData` |
| Student materials | `StudentCourseMaterial`, `StudentMaterialCourseOption` |
| Student announcements | `StudentAnnouncement` |
| Instructor courses | `InstructorManagedCourse`, `InstructorCourseDetails`, `InstructorCourseFile` |
| Instructor assignments | `Assignment`, `AssignmentSubmission`, `AssignmentAttachment`, `CreateAssignmentRequest` |
| Instructor announcements | `InstructorAnnouncement`, `CreateAnnouncementRequest` |
| Attendance | `AttendanceCourse`, `AttendanceSession`, `AttendanceStudent` |
| Notifications | `NotificationItem` |

### Normalized Data Examples

- Student profile names are resolved from English first/last names or fallback name fields.
- Course identifiers support course code, course id, raw id, and normalized display labels.
- Grade data is merged into course cards by course code.
- File metadata includes extension label, size label, upload date label, category, local path, and remote URL.
- Announcement images are resolved from absolute URLs, root-relative paths, file names, or API paths.
- Instructor course selections group courses by code/name/semester/term and keep section selection separate.

## File and Attachment Handling

The frontend supports file handling in both student and instructor flows:

- Instructors can upload course files with category metadata.
- Instructors can create assignments with optional attachments.
- Students can submit assignment files.
- Multipart requests support both local paths and in-memory bytes.
- Attachment opening supports local files through `OpenFilex`.
- Remote attachments open through `url_launcher`.
- File cards display user-friendly extension, size, category, and date labels.

## QR Attendance

The attendance workflow uses QR generation and scanning:

- Instructor starts an attendance session for a course/lecture.
- The frontend receives an attendance token/session payload.
- The instructor UI renders a QR code for the active token.
- The student QR scanner reads the token.
- The student app submits the token and course context to the attendance repository.
- Attendance state is refreshed for instructor visibility.

## Notification System

### Firebase Messaging

`FirebaseNotificationService` handles:

- Permission request.
- Initial FCM token retrieval.
- Foreground presentation options.
- Foreground message handling.
- Notification tap handling.
- Token refresh listener.
- Initial message handling when the app opens from a terminated state.

### Local Notifications

`LocalNotificationService` handles:

- Android and iOS notification initialization.
- Android notification channel creation.
- Visible local notification display.
- JSON payload encoding.
- Notification tap callback.
- Cancel single notification.
- Cancel all notifications.

### Device Token Repository

`NotificationTokenRepository` handles:

- Resolving platform device type.
- Registering the current FCM token after authentication.
- Tracking the last registered token in preferences.
- Removing the registered token on logout.

## Localization

Localization is implemented with `LangProvider` and `AppStrings.translations`.

Supported languages:

- English (`en`)
- Arabic (`ar`)

Frontend localization covers:

- Login labels.
- Navigation labels.
- Student dashboard labels.
- Course and semester labels.
- Profile labels.
- Instructor home labels.
- Announcement form labels and announcement type labels.
- Shared action labels such as refresh, retry, cancel, save, and logout.

## Visual Design System

The frontend uses a consistent Flutter Material visual language:

- Centralized color constants in `AppColors`.
- Centralized sizing constants in `AppSizes`.
- `PlusJakartaSans` bundled as the primary custom font family.
- Role-aware bottom navigation.
- Reusable surface cards for student and instructor areas.
- Wave header cards for high-priority page headers.
- Reusable teal button and icon box widgets.
- Shared loading skeleton components on key pages.
- Standardized card, badge, selector, and row widgets across feature areas.

## Responsive Behavior

`ResponsiveLayout` supports compact-layout decisions. Screens use:

- `MediaQuery` for viewport-aware sizing.
- `LayoutBuilder` for constrained content.
- Scroll views for keyboard and smaller-screen support.
- Safe areas for navigation and device insets.
- Constrained widths for login content and forms.
- Adaptive placement for course selectors, file lists, panels, and detail sheets.

## State Lifecycle

Feature providers use a consistent lifecycle pattern:

1. Hold feature data, loading state, and user-facing message state.
2. Load data through `loadIfNeeded` for first render.
3. Refresh data through explicit `refresh` methods.
4. Keep selected entities in provider state.
5. Clear or replace dependent data when selections change.
6. Notify listeners after state transitions.
7. Rebuild only subscribed widgets.

## Build and Runtime Configuration

### Assets

The app includes image assets from:

```yaml
assets:
  - assets/images/
```

### Fonts

The app bundles:

```yaml
fonts:
  - family: PlusJakartaSans
    fonts:
      - asset: assets/fonts/PlusJakartaSans-Regular.ttf
      - asset: assets/fonts/PlusJakartaSans-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/PlusJakartaSans-Bold.ttf
        weight: 700
```

### API Base URL Override

The API base URL can be overridden at build/run time:

```bash
flutter run --dart-define=UNIDESK_API_BASE_URL=https://example.com/api
```

### Supported Platforms

The repository contains Flutter platform folders for:

- Android
- iOS
- Web
- Windows
- macOS
- Linux

## Frontend Summary

The UniDesk frontend is organized around clear academic roles, protected navigation, repository-backed feature modules, responsive shared layouts, secure session handling, notification integration, file workflows, QR attendance, and bilingual UI support. The result is a complete student and instructor experience with centralized data access and focused state management for each academic workflow.
