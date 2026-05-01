import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/attendance/data/attendance_repository.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_courses_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_session_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_students_provider.dart';
import 'package:unidesk/features/entities/instructor/pages/attendance_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('attendance page shows course selector', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          Provider(create: (_) => AttendanceRepository()),
          ChangeNotifierProvider(
            create: (context) => AttendanceCoursesProvider(
              context.read<AttendanceRepository>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => AttendanceStudentsProvider(
              context.read<AttendanceRepository>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => AttendanceSessionProvider(
              context.read<AttendanceRepository>(),
            ),
          ),
        ],
        child: const MaterialApp(
          home: AttendancePage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Attendance Session'), findsOneWidget);
    expect(find.text('Students List'), findsOneWidget);
  });

  test('attendance repository returns different rosters per course', () async {
    final repository = AttendanceRepository();

    final programmingStudents = await repository.getCourseStudents(
      courseId: '120414',
      lectureId: '1',
    );
    final calculusStudents = await repository.getCourseStudents(
      courseId: '132120',
      lectureId: '3',
    );

    expect(programmingStudents, isNotEmpty);
    expect(calculusStudents, isNotEmpty);
    expect(programmingStudents.first.id, isNot(calculusStudents.first.id));
  });

  test('attendance registration updates roster and blocks duplicate scans', () async {
    final repository = AttendanceRepository();
    final session = await repository.startAttendanceSession(
      courseId: '120414',
      lectureId: '1',
    );

    await repository.registerAttendance(
      token: session.token,
      courseId: '120414',
      studentId: '2021001',
    );

    final refreshedStudents = await repository.getCourseStudents(
      courseId: '120414',
      lectureId: '1',
    );

    expect(
      refreshedStudents.firstWhere((student) => student.id == '2021001').isPresent,
      isTrue,
    );

    await expectLater(
      () => repository.registerAttendance(
        token: session.token,
        courseId: '120414',
        studentId: '2021001',
      ),
      throwsA(isA<AttendanceRepositoryException>()),
    );
  });

  test('students provider refresh reflects live attendance updates', () async {
    final repository = AttendanceRepository();
    final coursesProvider = AttendanceCoursesProvider(repository);
    final studentsProvider = AttendanceStudentsProvider(repository);
    final sessionProvider = AttendanceSessionProvider(repository);

    await coursesProvider.load(instructorId: 'D001');
    final selectedCourse =
        coursesProvider.courses.firstWhere((course) => course.id == '120414');

    coursesProvider.selectCourse(selectedCourse.id);
    await studentsProvider.loadForCourse(selectedCourse);
    expect(studentsProvider.presentStudents, 0);

    await sessionProvider.startForCourse(selectedCourse);
    await repository.registerAttendance(
      token: sessionProvider.currentSession!.token,
      courseId: selectedCourse.id,
      studentId: '2021002',
    );
    await studentsProvider.refreshForCourse(selectedCourse);

    expect(studentsProvider.presentStudents, 1);
    expect(studentsProvider.absentStudents, selectedCourse.studentsEnrolled - 1);
    expect(
      studentsProvider.students.firstWhere((student) => student.id == '2021002').isPresent,
      isTrue,
    );
  });

  test('attendance registration handles wrong course and invalid token', () async {
    final repository = AttendanceRepository();
    final session = await repository.startAttendanceSession(
      courseId: '132120',
      lectureId: '3',
    );

    await expectLater(
      () => repository.registerAttendance(
        token: 'invalid-token',
        courseId: '132120',
        studentId: '2021010',
      ),
      throwsA(isA<AttendanceRepositoryException>()),
    );

    await expectLater(
      () => repository.registerAttendance(
        token: session.token,
        courseId: '120414',
        studentId: '2021010',
      ),
      throwsA(isA<AttendanceRepositoryException>()),
    );
  });
}
