import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/entities/student/providers_std/course_provider.dart';
import 'package:unidesk/features/entities/widgets_std/courseWidgets/custom_card.dart';
import 'package:unidesk/features/language/langProvider.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import '../../../../shared/widgets/custom_tealBottom.dart';
import '../../widgets_std/courseWidgets/custom_progessCard.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final token = context.read<AuthProvider>().token;
    context.read<CoursesProvider>().loadIfNeeded(token: token);
  });
}
  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CoursesProvider>();
    final lang = context.watch<LangProvider>();

    return Scaffold(
      body: Directionality(
        textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          color: const Color(0xFFEDF0EE),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.translate('absence_record'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (courseProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (courseProvider.error != null)
                    const Center(child: Text('Failed to load courses'))
                  else
                    AbsenceCard(courses: courseProvider.courses ?? const []),
                  const SizedBox(height: 12),
                  TealButton(
                    label: lang.translate('attendance_policy'),
                    onTap: () => context.push('/register-attendance'),
                  ),
                  const SizedBox(height: 10),
                  TealButton(
                    label: lang.translate('request_excuse'),
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  Text(
                    lang.translate('academic_progress'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (courseProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (courseProvider.error != null)
                    const Center(child: Text('Failed to load academic progress'))
                  else if (courseProvider.academicProgress != null)
                    AcademicProgressCard(
                      progress: courseProvider.academicProgress!,
                      completedCourses: courseProvider.courses ?? const [],
                    )
                  else
                    const Center(
                      child: Text('No academic progress data available'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
