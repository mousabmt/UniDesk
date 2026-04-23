import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/attendance/data/attendance_repository.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_courses_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_session_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_students_provider.dart';
import 'package:unidesk/features/entities/instructor/pages/attendance_page.dart';

void main() {
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
}
