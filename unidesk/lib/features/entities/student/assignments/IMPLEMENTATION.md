# Student Assignments Module - Implementation Guide

## Overview
This document describes the complete implementation of the Student Assignments module with clean architecture principles for the UniDesk student dashboard.

## Architecture Structure

```
lib/features/entities/student/assignments/
├── models/
│   ├── student_assignment.dart          (Main assignment model)
│   ├── student_submission.dart          (Submission details)
│   ├── file_data.dart                   (File object)
│   ├── course_data.dart                 (Course information)
│   └── section_data.dart                (Section information)
├── data/
│   ├── student_assignments_data_source.dart      (Abstract data source)
│   ├── api_student_assignments_data_source.dart  (API implementation)
│   └── student_assignments_repository.dart       (Repository pattern)
└── providers/
    └── student_assignments_provider.dart         (State management)
```

## Models

### StudentAssignment
The main model representing an assignment with all its details:
- **Properties**: id, courseId, sectionId, instructorId, title, description, file, dueDate, maxScore, isActive, course, section, submission
- **Computed Properties**: 
  - `hasSubmission` - Check if assignment has a submission
  - `isSubmitted` - Check if already submitted
  - `isGraded` - Check if graded
  - `isOverdue` - Check if past due date
  - `statusLabel` - Human-readable status
  - `dueDateLabel` - Formatted due date

### StudentSubmission
Represents a student's submission:
- **Properties**: id, assignmentId, studentId, fileUrl, score, feedback, submittedAt
- **Computed Properties**:
  - `isGraded` - Check if instructor has graded
  - `submittedAtLabel` - Formatted submission date/time

### Supporting Models
- **FileData**: Assignment or submission file details
- **CourseData**: Course information embedded in assignments
- **SectionData**: Section information embedded in assignments

## Data Layer

### StudentAssignmentsDataSource (Interface)
Defines the contract for data operations:
- `getAssignments()` - List all assignments
- `getAssignmentDetail(assignmentId)` - Get single assignment details
- `submitAssignment(...)` - Submit assignment file
- `getSubmissions()` - List all submissions

### ApiStudentAssignmentsDataSource (Implementation)
Implements the data source using the StudentApi service

### StudentAssignmentsRepository (Pattern)
Mediates between data source and business logic:
- Abstract interface definition
- Concrete implementation (`StudentAssignmentsRepositoryImpl`)
- Custom exception class

## API Integration

### Added Methods to `StudentApi`

#### 1. `getStudentAssignments()`
- **Endpoint**: `GET /student/assignments`
- **Returns**: List of all active assignments for enrolled sections

#### 2. `getStudentAssignmentDetail(assignmentId)`
- **Endpoint**: `GET /student/assignments/{id}`
- **Returns**: Single assignment with full details and submission status

#### 3. `submitAssignment(assignmentId, fileName, localPath)`
- **Endpoint**: `POST /student/assignments/{id}/submit`
- **Method**: Multipart form data
- **Returns**: Submission confirmation with details

#### 4. `getStudentSubmissions()`
- **Endpoint**: `GET /student/submissions`
- **Returns**: All submissions across all assignments

## State Management

### StudentAssignmentsProvider (ChangeNotifier)

#### State Properties
- `assignments` - List of all assignments
- `selectedAssignment` - Currently viewed assignment detail
- `submissions` - All student submissions
- `isLoadingAssignments` - Loading state for list
- `isLoadingAssignmentDetail` - Loading state for detail
- `isLoadingSubmissions` - Loading state for submissions
- `isSubmitting` - Loading state for submission form
- `submitError` - Error message for submission
- `submitSuccess` - Success message for submission

#### Methods
- `loadAssignments()` - Fetch all assignments
- `loadAssignmentDetail(assignmentId)` - Fetch single assignment
- `submitAssignment(...)` - Submit assignment file
- `loadSubmissions()` - Fetch all submissions
- `clearSubmitMessage()` - Clear success/error messages
- `clearErrors()` - Clear all error states

## UI Components

### AssignmentPage (Main Page)
- **Features**:
  - Assignment list with pull-to-refresh
  - Status badges (Active, Overdue, Submitted, Graded)
  - Error handling with retry button
  - Empty state handling

### AssignmentCard
- Display assignment summary in list
- Shows status, due date, max score
- Displays grade if graded
- Shows "Pending Grade" if submitted but not graded

### AssignmentDetailSheet
- Bottom sheet modal for detailed view
- Shows full assignment information
- Displays file attachment with download option
- Shows submission status and feedback
- Contains submission form if not submitted

### _SubmitAssignmentForm
- File picker integration (max 10MB)
- Visual feedback for selected file
- Error and success messaging
- Loading state during submission
- Auto-close on successful submission

### _SubmissionCard
- Displays submission status
- Shows score and feedback if graded
- Shows submission timestamp

## Integration Steps

### 1. Provider Registration (main.dart)
```dart
// Add imports
import 'package:unidesk/features/entities/student/assignments/data/api_student_assignments_data_source.dart';
import 'package:unidesk/features/entities/student/assignments/data/student_assignments_repository.dart';
import 'package:unidesk/features/entities/student/assignments/providers/student_assignments_provider.dart';

// Add providers
Provider<StudentAssignmentsRepository>(
  create: (_) => const StudentAssignmentsRepositoryImpl(
    ApiStudentAssignmentsDataSource(),
  ),
),
ChangeNotifierProvider(
  create: (context) => StudentAssignmentsProvider(
    context.read<StudentAssignmentsRepository>(),
  ),
),
```

### 2. UI Usage
The AssignmentPage automatically:
- Initializes the provider in initState
- Loads assignments on first build
- Provides pull-to-refresh functionality
- Handles loading, error, and success states

## Error Handling

### Data Layer Errors
- `StudentAssignmentsDataSourceException` - Custom exception for data source errors
- `StudentAssignmentsRepositoryException` - Custom exception for repository errors

### UI Error Handling
- Error messages displayed in snackbars
- Error details shown in error widgets
- Retry button for failed operations
- User-friendly error messages

## Features Implemented

✅ List all assignments for enrolled sections
✅ View assignment details
✅ Download assignment files
✅ Submit assignments with file upload
✅ View submission status
✅ View grades and feedback
✅ List all submissions
✅ Overdue detection
✅ Pull-to-refresh
✅ Error handling and retry
✅ Loading states
✅ File size validation (10MB max)
✅ Success/error messaging

## Response Handling

### Assignment List Response
```json
[
  {
    "id": 2,
    "course_id": 2,
    "section_id": 13,
    "instructor_id": 1,
    "title": "test assignments",
    "description": "test test",
    "file": { ... },
    "due_date": "2026-05-20 23:59:59",
    "max_score": 10,
    "is_active": true,
    "created_at": "2026-05-09 16:30:56",
    "updated_at": "2026-05-09 16:30:56",
    "course": { ... },
    "section": { ... },
    "submission": null or { ... }
  }
]
```

### Submission Response
```json
{
  "success": true,
  "message": "Assignment submitted successfully",
  "data": {
    "id": 5,
    "assignment_id": 2,
    "student_id": 10,
    "file_url": "http://./storage/submissions/abc123",
    "score": null,
    "feedback": null,
    "submitted_at": "2026-05-15 10:00:00"
  }
}
```

## Usage Example

```dart
// In a widget
Consumer<StudentAssignmentsProvider>(
  builder: (context, provider, _) {
    // Access state
    List<StudentAssignment> assignments = provider.assignments;
    bool isLoading = provider.isLoadingAssignments;
    String? error = provider.assignmentsError;
    
    // Trigger actions
    provider.loadAssignments();
    provider.submitAssignment(
      assignmentId: '2',
      fileName: 'solution.pdf',
      localPath: '/path/to/file',
    );
  },
)
```

## Testing Considerations

- Mock the `StudentAssignmentsRepository` for unit tests
- Mock `StudentApi` calls for data source tests
- Test state transitions in provider
- Test UI rendering with different states
- Test error scenarios

## Future Enhancements

- Offline support with local caching
- Bulk file upload
- Drag-and-drop file upload
- Rich text assignment descriptions
- Assignment reminders
- Grade statistics
- Assignment history/archive
