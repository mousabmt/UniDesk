import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment.dart';
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
      final assignments = await assignmentsRepository.getAssignments();

      expect(assignments, isNotEmpty);
      expect(assignments.first.courseId, '120414');
      expect(assignments.first.title, isNotEmpty);
    },
  );

  test('assignment parses nested file payload from API response', () {
    final assignment = Assignment.fromMap({
      'id': 3,
      'course_id': 7,
      'section_id': 16,
      'instructor_id': 1,
      'title': 'test assignments',
      'description': 'test test',
      'due_date': '2026-05-20 23:59:59',
      'max_score': 10,
      'file': {
        'id': 3,
        'file_name': 'Controller.php',
        'file_path': 'assignments/example',
        'file_url': 'https://example.com/storage/assignments/example',
      },
    });

    expect(assignment.fileName, 'Controller.php');
    expect(assignment.filePath, 'assignments/example');
    expect(
      assignment.fileUrl,
      'https://example.com/storage/assignments/example',
    );
    expect(assignment.attachment, isNotNull);
    expect(assignment.attachment!.name, 'Controller.php');
  });

  test('create assignment request matches backend date format', () {
    final request = CreateAssignmentRequest(
      courseId: '2',
      sectionId: '1',
      title: 'Midterm Project',
      description: 'Build a Laravel REST API for course management.',
      dueDate: DateTime(2026, 6, 1, 23, 59),
      maxScore: 100,
    );

      expect(request.toApiFields()['due_date'], '2026-06-01 23:59:00');
      expect(request.toApiFields()['course_id'], '2');
      expect(request.toApiFields()['section_id'], '1');
    });

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
        preferredSectionId: '1',
      );

      expect(provider.selectedCourseId, '120414');
      expect(provider.selectedSectionId, '1');
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
        preferredSectionId: '1',
      );
      final beforeCount = provider.assignments.length;
      final selectedCourse = provider.selectedCourse!;

      final success = await provider.createAssignment(
        CreateAssignmentRequest(
          courseId: selectedCourse.id,
          sectionId: provider.selectedSectionId!,
          title: 'Provider Test Assignment',
          description: 'Validate creation flow.',
          dueDate: DateTime(2026, 5, 20),
          maxScore: 25,
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
          home: Scaffold(
            body: AssignmentsPage(
              initialCourseId: '132120',
              initialSectionId: '3',
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Assignment 1'), findsWidgets);
    expect(find.text('limits_worksheet.pdf'), findsOneWidget);
  });
}
