import 'dart:typed_data';

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
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_details.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/mock_instructor_courses_data_source.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';
import 'package:unidesk/features/entities/instructor/course_management/providers/instructor_courses_provider.dart';
import 'package:unidesk/features/entities/instructor/pages/addfiles.dart';
import 'package:unidesk/features/entities/instructor/pages/assignments_page.dart';

class _FakeInstructorCoursesRepository implements InstructorCoursesRepository {
  const _FakeInstructorCoursesRepository({
    required this.courses,
    required this.detailsBySelectionKey,
  });

  final List<InstructorManagedCourse> courses;
  final Map<String, InstructorCourseDetails> detailsBySelectionKey;

  @override
  Future<List<InstructorManagedCourse>> getInstructorCourses(
    String instructorId,
  ) async {
    return courses;
  }

  @override
  Future<InstructorCourseDetails> getCourseDetails({
    required String instructorId,
    required String courseId,
    String? sectionId,
  }) async {
    final selectionKey = sectionId == null || sectionId.isEmpty
        ? courseId
        : '$courseId::$sectionId';
    final details = detailsBySelectionKey[selectionKey];
    if (details == null) {
      throw const InstructorCoursesRepositoryException('Course not found');
    }
    return details;
  }

  @override
  Future<InstructorCourseFile> uploadCourseFile({
    required String instructorId,
    required String courseId,
    required String fileName,
    required InstructorCourseFileCategory category,
    required String extensionLabel,
    String? localPath,
    Uint8List? fileBytes,
  }) async {
    throw UnimplementedError();
  }
}

InstructorCourseDetails _buildCourseDetails(InstructorManagedCourse course) {
  return InstructorCourseDetails(
    course: course,
    summary: const InstructorCourseSummary(
      averageAttendanceLabel: '90%',
      assignmentsCount: 0,
      filesCount: 0,
    ),
    upcomingLecture: const InstructorUpcomingLecture(
      title: 'Upcoming class',
      dateLabel: 'May 13, 2026',
      timeLabel: '10:00 AM',
      locationLabel: 'Room 101',
    ),
    files: const [],
    students: const [],
  );
}

InstructorCourseDetails _buildCourseDetailsWithFiles(
  InstructorManagedCourse course,
  List<InstructorCourseFile> files,
) {
  return InstructorCourseDetails(
    course: course,
    summary: InstructorCourseSummary(
      averageAttendanceLabel: '90%',
      assignmentsCount: 0,
      filesCount: files.length,
    ),
    upcomingLecture: const InstructorUpcomingLecture(
      title: 'Upcoming class',
      dateLabel: 'May 13, 2026',
      timeLabel: '10:00 AM',
      locationLabel: 'Room 101',
    ),
    files: files,
    students: const [],
  );
}

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
    'instructor courses provider groups duplicate course names and filters sections',
    () async {
      const sectionA = InstructorManagedCourse(
        id: '120414',
        name: 'Introduction to Programming',
        credits: 3,
        studentsEnrolled: 20,
        lectureId: '1',
        courseCode: 'CS101',
        sectionId: '1',
        term: 'Spring 2026',
        sectionLabel: 'Section A',
        semesterId: '2026S',
      );
      const sectionB = InstructorManagedCourse(
        id: '120414',
        name: 'Introduction to Programming',
        credits: 3,
        studentsEnrolled: 18,
        lectureId: '2',
        courseCode: 'CS101',
        sectionId: '2',
        term: 'Spring 2026',
        sectionLabel: 'Section B',
        semesterId: '2026S',
      );
      const calculus = InstructorManagedCourse(
        id: '132120',
        name: 'Calculus I',
        credits: 3,
        studentsEnrolled: 25,
        lectureId: '3',
        courseCode: 'MATH101',
        sectionId: '3',
        term: 'Spring 2026',
        sectionLabel: 'Section C',
        semesterId: '2026S',
      );

      final fakeRepository = _FakeInstructorCoursesRepository(
        courses: const [sectionA, sectionB, calculus],
        detailsBySelectionKey: {
          sectionA.selectionKey: _buildCourseDetails(sectionA),
          sectionB.selectionKey: _buildCourseDetails(sectionB),
          calculus.selectionKey: _buildCourseDetails(calculus),
        },
      );
      final provider = InstructorCoursesProvider(fakeRepository);

      await provider.loadIfNeeded(instructorId: 'D001');

      expect(provider.availableCourses.length, 2);
      expect(
        provider.availableCourses
            .where((course) => course.name == 'Introduction to Programming')
            .length,
        1,
      );
      expect(provider.availableSections.length, 2);

      await provider.selectSection(
        instructorId: 'D001',
        sectionId: sectionB.selectionKey,
      );

      expect(provider.selectedCourse?.selectionKey, sectionB.selectionKey);
      expect(provider.selectedSectionId, '2');
      expect(provider.currentCourseDetails?.course.sectionLabel, 'Section B');
    },
  );

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
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.scrollUntilVisible(find.text('File Category'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Assignment'), findsNothing);
    expect(find.text('Lecture'), findsOneWidget);
    expect(find.text('Exam'), findsOneWidget);
  });

  testWidgets('add files page renders separate course and section dropdowns', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    const sectionA = InstructorManagedCourse(
      id: '120414',
      name: 'Introduction to Programming',
      credits: 3,
      studentsEnrolled: 20,
      lectureId: '1',
      courseCode: 'CS101',
      sectionId: '1',
      term: 'Spring 2026',
      sectionLabel: 'Section A',
      semesterId: '2026S',
    );
    const sectionB = InstructorManagedCourse(
      id: '120414',
      name: 'Introduction to Programming',
      credits: 3,
      studentsEnrolled: 18,
      lectureId: '2',
      courseCode: 'CS101',
      sectionId: '2',
      term: 'Spring 2026',
      sectionLabel: 'Section B',
      semesterId: '2026S',
    );
    const calculus = InstructorManagedCourse(
      id: '132120',
      name: 'Calculus I',
      credits: 3,
      studentsEnrolled: 25,
      lectureId: '3',
      courseCode: 'MATH101',
      sectionId: '3',
      term: 'Spring 2026',
      sectionLabel: 'Section C',
      semesterId: '2026S',
    );

    final fakeRepository = _FakeInstructorCoursesRepository(
      courses: const [sectionA, sectionB, calculus],
      detailsBySelectionKey: {
        sectionA.selectionKey: _buildCourseDetails(sectionA),
        sectionB.selectionKey: _buildCourseDetails(sectionB),
        calculus.selectionKey: _buildCourseDetails(calculus),
      },
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          Provider<InstructorCoursesRepository>.value(value: fakeRepository),
          ChangeNotifierProvider(
            create: (_) => InstructorCoursesProvider(fakeRepository),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: AddFilesPage())),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.byType(DropdownButton<String>), findsNWidgets(2));
    expect(find.text('Select Course'), findsOneWidget);
  });

  testWidgets('add files page only shows lecture and exam files', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    const course = InstructorManagedCourse(
      id: '120414',
      name: 'Introduction to Programming',
      credits: 3,
      studentsEnrolled: 20,
      lectureId: '1',
      courseCode: 'CS101',
      sectionId: '1',
      term: 'Spring 2026',
      sectionLabel: 'Section A',
      semesterId: '2026S',
    );
    const lectureFile = InstructorCourseFile(
      id: 'f-1',
      courseId: '120414',
      name: 'Lecture 1.pdf',
      extensionLabel: 'PDF',
      sizeLabel: '1 MB',
      uploadedAtLabel: 'May 13, 2026',
      category: InstructorCourseFileCategory.lecture,
    );
    const examFile = InstructorCourseFile(
      id: 'f-2',
      courseId: '120414',
      name: 'Midterm Review.pdf',
      extensionLabel: 'PDF',
      sizeLabel: '1 MB',
      uploadedAtLabel: 'May 13, 2026',
      category: InstructorCourseFileCategory.exam,
    );
    const assignmentFile = InstructorCourseFile(
      id: 'f-3',
      courseId: '120414',
      name: 'Assignment Sheet.pdf',
      extensionLabel: 'PDF',
      sizeLabel: '1 MB',
      uploadedAtLabel: 'May 13, 2026',
      category: InstructorCourseFileCategory.assignment,
    );

    final fakeRepository = _FakeInstructorCoursesRepository(
      courses: const [course],
      detailsBySelectionKey: {
        course.selectionKey: _buildCourseDetailsWithFiles(course, const [
          lectureFile,
          examFile,
          assignmentFile,
        ]),
      },
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          Provider<InstructorCoursesRepository>.value(value: fakeRepository),
          ChangeNotifierProvider(
            create: (_) => InstructorCoursesProvider(fakeRepository),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: AddFilesPage())),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.scrollUntilVisible(find.text('Recent Files'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Lecture 1.pdf'), findsOneWidget);
    expect(find.text('Midterm Review.pdf'), findsOneWidget);
    expect(find.text('Assignment Sheet.pdf'), findsNothing);
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
      'category_id': 1,
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
    expect(assignment.categoryId, 1);
  });

  test('course file parses category_id from shared backend shape', () {
    final file = InstructorCourseFile.fromMap({
      'id': 1,
      'courseId': '2',
      'name': 'course_material.pdf',
      'extensionLabel': 'PDF',
      'sizeLabel': '1.2 MB',
      'uploadedAtLabel': 'May 13, 2026',
      'category_id': 3,
      'file_url': 'https://example.com/files/course_material.pdf',
    });

    expect(file.category, InstructorCourseFileCategory.lecture);
    expect(file.remoteUrl, 'https://example.com/files/course_material.pdf');
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
    'api attachment uses remote url when file_path is a storage-relative path',
    () {
      final assignment = Assignment.fromMap({
        'id': 3,
        'course_id': 7,
        'section_id': 16,
        'instructor_id': 1,
        'title': 'test assignments',
        'description': 'test test',
        'due_date': '2026-05-20 23:59:59',
        'max_score': 10,
        'is_active': true,
        'file': {
          'file_name': 'Controller.php',
          'file_path': 'assignments/BbzUxDCUcc1khycUxvPdtl4KyPHGMKow8oQA8a1i',
          'file_url':
              'https://anguished-ankle-footprint.ngrok-free.dev/storage/assignments/BbzUxDCUcc1khycUxvPdtl4KyPHGMKow8oQA8a1i',
        },
      });

      expect(assignment.attachment, isNotNull);
      expect(assignment.attachment!.hasLocalFile, isFalse);
      expect(assignment.attachment!.hasRemoteUrl, isTrue);
      expect(assignment.attachment!.canOpen, isTrue);
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

  test(
    'instructor assignments provider switches course from dropdown selection key',
    () async {
      final provider = InstructorAssignmentsProvider(
        assignmentsRepository,
        repository,
      );

      await provider.loadIfNeeded(instructorId: 'D001');
      final firstSelection = provider.selectedCourseGroupKey;
      final targetCourse = provider.availableCourses.firstWhere(
        (course) => provider.courseSelectionValueFor(course) != firstSelection,
      );

      await provider.selectCourse(
        instructorId: 'D001',
        courseId: provider.courseSelectionValueFor(targetCourse),
      );

      expect(
        provider.selectedCourseGroupKey,
        provider.courseSelectionValueFor(targetCourse),
      );
      expect(provider.selectedCourse?.id, targetCourse.id);
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
