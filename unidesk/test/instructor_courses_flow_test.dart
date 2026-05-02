import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_attachment.dart';
import 'package:unidesk/features/entities/instructor/assignments/data/instructor_assignments_repository.dart';
import 'package:unidesk/features/entities/instructor/assignments/data/mock_instructor_assignments_data_source.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/create_assignment_request.dart';
import 'package:unidesk/features/entities/instructor/assignments/providers/instructor_assignments_provider.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/instructor_courses_repository.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/mock_instructor_courses_data_source.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/course_management/providers/instructor_courses_provider.dart';
import 'package:unidesk/features/entities/instructor/pages/addfiles.dart';
import 'package:unidesk/features/entities/instructor/pages/assignments_page.dart';

void main() {
  const repository = InstructorCoursesRepositoryImpl(
    MockInstructorCoursesDataSource(),
  );
  const assignmentsRepository = InstructorAssignmentsRepositoryImpl(
    MockInstructorAssignmentsDataSource(),
  );

  test('mock instructor courses repository returns typed courses', () async {
    final courses = await repository.getInstructorCourses('D001');

    expect(courses, isNotEmpty);
    expect(courses.first.id, '120414');
    expect(courses.first.term, isNotEmpty);
  });

  test('mock instructor courses repository returns course details', () async {
    final details = await repository.getCourseDetails(
      instructorId: 'D001',
      courseId: '120414',
    );

    expect(details.course.id, '120414');
    expect(details.files, isNotEmpty);
    expect(details.students, isNotEmpty);
    expect(details.summary.filesCount, greaterThan(0));
  });

  test('instructor courses provider loads list and details', () async {
    final provider = InstructorCoursesProvider(repository);

    await provider.loadIfNeeded(instructorId: 'D001');

    expect(provider.courses, isNotEmpty);
    expect(provider.selectedCourseId, isNotNull);
    expect(provider.currentCourseDetails, isNotNull);
    expect(provider.coursesError, isNull);
    expect(provider.detailsError, isNull);
  });

  test('instructor courses provider switches selected course', () async {
    final provider = InstructorCoursesProvider(repository);

    await provider.loadIfNeeded(instructorId: 'D001');
    await provider.selectCourse(instructorId: 'D001', courseId: '132120');

    expect(provider.selectedCourseId, '132120');
    expect(provider.currentCourseDetails?.course.id, '132120');
  });

  test(
    'instructor courses provider uploads a file to the selected course',
    () async {
      final provider = InstructorCoursesProvider(repository);

      await provider.loadIfNeeded(instructorId: 'D001');
      final beforeCount = provider.currentCourseDetails?.files.length ?? 0;

      final success = await provider.uploadCourseFile(
        instructorId: 'D001',
        fileName: 'Lecture 9 Notes.pdf',
        category: InstructorCourseFileCategory.lecture,
        extensionLabel: 'PDF',
      );

      expect(success, isTrue);
      expect(provider.uploadError, isNull);
      expect(provider.currentCourseDetails?.files.length, beforeCount + 1);
      expect(
        provider.currentCourseDetails?.files.first.name,
        'Lecture 9 Notes.pdf',
      );
    },
  );

  testWidgets('add files page hides assignment category button', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          Provider<InstructorCoursesRepository>.value(value: repository),
          ChangeNotifierProvider(
            create: (_) => InstructorCoursesProvider(repository),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: AddFilesPage())),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Assignment'), findsNothing);
    expect(find.text('Lecture'), findsOneWidget);
    expect(find.text('Exam'), findsOneWidget);
  });

  test(
    'mock instructor assignments repository returns typed assignments',
    () async {
      final assignments = await assignmentsRepository.getAssignments(
        courseId: '120414',
      );

      expect(assignments, isNotEmpty);
      expect(assignments.first.courseId, '120414');
      expect(assignments.first.title, isNotEmpty);
    },
  );

  test(
    'assignment attachment reports open capability for local and remote',
    () {
      const localAttachment = AssignmentAttachment(
        id: '1',
        name: 'assignment.pdf',
        extensionLabel: 'PDF',
        sizeLabel: '1.2 MB',
        localPath: 'C:\\temp\\assignment.pdf',
      );
      const remoteAttachment = AssignmentAttachment(
        id: '2',
        name: 'assignment.pdf',
        extensionLabel: 'PDF',
        sizeLabel: '1.2 MB',
        url: 'https://example.com/assignment.pdf',
      );
      const unavailableAttachment = AssignmentAttachment(
        id: '3',
        name: 'assignment.pdf',
        extensionLabel: 'PDF',
        sizeLabel: '1.2 MB',
      );

      expect(localAttachment.canOpen, isTrue);
      expect(remoteAttachment.canOpen, isTrue);
      expect(unavailableAttachment.canOpen, isFalse);
    },
  );

  test(
    'instructor assignments provider loads assignments and submissions',
    () async {
      final provider = InstructorAssignmentsProvider(
        assignmentsRepository,
        repository,
      );

      await provider.loadIfNeeded(
        instructorId: 'D001',
        preferredCourseId: '120414',
      );

      expect(provider.selectedCourseId, '120414');
      expect(provider.assignments, isNotEmpty);
      expect(provider.selectedAssignmentId, isNotNull);
      expect(provider.submissionsError, isNull);
    },
  );

  test(
    'instructor assignments provider creates assignment and refreshes list',
    () async {
      final provider = InstructorAssignmentsProvider(
        assignmentsRepository,
        repository,
      );

      await provider.loadIfNeeded(
        instructorId: 'D001',
        preferredCourseId: '120414',
      );
      final beforeCount = provider.assignments.length;
      final selectedCourse = provider.selectedCourse!;

      final success = await provider.createAssignment(
        CreateAssignmentRequest(
          courseId: selectedCourse.id,
          title: 'Provider Test Assignment',
          description: 'Validate creation flow.',
          dueDate: DateTime(2026, 5, 20),
          totalPoints: 25,
        ),
      );

      expect(success, isTrue);
      expect(provider.createError, isNull);
      expect(provider.assignments.length, beforeCount + 1);
      expect(provider.assignments.last.title, 'Provider Test Assignment');
    },
  );

  testWidgets('assignments page respects course-scoped entry point', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          Provider<InstructorCoursesRepository>.value(value: repository),
          Provider<InstructorAssignmentsRepository>.value(
            value: assignmentsRepository,
          ),
          ChangeNotifierProvider(
            create: (_) => InstructorAssignmentsProvider(
              assignmentsRepository,
              repository,
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AssignmentsPage(initialCourseId: '132120')),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('132120 - Calculus I'), findsWidgets);
    expect(find.text('Assignment 1'), findsWidgets);
    expect(find.text('limits_worksheet.pdf'), findsOneWidget);
  });
}
