import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/instructor_courses_repository.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/mock_instructor_courses_data_source.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/course_management/providers/instructor_courses_provider.dart';
import 'package:unidesk/features/entities/instructor/pages/addfiles.dart';

void main() {
  const repository = InstructorCoursesRepositoryImpl(
    MockInstructorCoursesDataSource(),
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
    await provider.selectCourse(
      instructorId: 'D001',
      courseId: '132120',
    );

    expect(provider.selectedCourseId, '132120');
    expect(provider.currentCourseDetails?.course.id, '132120');
  });

  test('instructor courses provider uploads a file to the selected course', () async {
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
  });

  testWidgets('add files page hides assignment category button', (tester) async {
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
        child: const MaterialApp(
          home: Scaffold(
            body: AddFilesPage(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Assignment'), findsNothing);
    expect(find.text('Lecture'), findsOneWidget);
    expect(find.text('Exam'), findsOneWidget);
  });
}
