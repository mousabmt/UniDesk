import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../features/auth/authProvider.dart';
import '../../features/entities/instructor/assignments/providers/instructor_assignments_provider.dart';
import '../../features/entities/instructor/course_management/providers/instructor_courses_provider.dart';
import '../../features/entities/student/materials/models/student_material_course_option.dart';
import '../../features/entities/student/materials/providers/student_materials_provider.dart';
import '../../features/entities/student/providers_std/annouc_provider.dart';
import '../../features/entities/student/providers_std/course_provider.dart';
import '../../features/entities/student/providers_std/currentSem_provider.dart';
import '../../features/entities/student/providers_std/prevSemesters_provider.dart';
import '../../features/entities/student/providers_std/profile_provider.dart';
import '../../features/language/langProvider.dart';
import 'langToggle.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const AppNavbar({super.key, this.navigatorKey});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<void> _refreshAllProviders(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final isStudent = auth.isStudent;
    final token = auth.token;
    final userId = auth.userId;
    final profileProvider = context.read<ProfileProvider>();
    final coursesProvider = context.read<CoursesProvider>();
    final announcementsProvider = context.read<AnnoucProvider>();
    final studentMaterialsProvider = context.read<StudentMaterialsProvider>();
    final prevSemestersProvider = context.read<PrevsemestersProvider>();
    final currentSemesterProvider = context.read<CurrentSemesterProvider>();
    final instructorCoursesProvider = context.read<InstructorCoursesProvider>();
    final instructorAssignmentsProvider = context
        .read<InstructorAssignmentsProvider>();

    if (isStudent) {
      // Refresh student providers
      await profileProvider.refresh();
      if (token != null) {
        await coursesProvider.refresh(token: token);
        await announcementsProvider.refresh(token: token);
      }
      await studentMaterialsProvider.refresh(
        courseOptions: _buildStudentMaterialCourseOptions(
          coursesProvider.courses ?? const [],
        ),
      );
      await prevSemestersProvider.refresh();
      await currentSemesterProvider.refresh();
    } else {
      // Refresh instructor providers
      if (userId != null) {
        await instructorCoursesProvider.refresh(instructorId: userId);
        await instructorAssignmentsProvider.refresh(instructorId: userId);
      }
    }
  }

  List<StudentMaterialCourseOption> _buildStudentMaterialCourseOptions(
    List<Map<String, dynamic>> courses,
  ) {
    final grouped = <String, StudentMaterialCourseOption>{};

    for (final course in courses) {
      final materialsCourseId =
          course['courseId']?.toString() ??
          course['rawCourseId']?.toString() ??
          '';
      final courseCode =
          course['courseCode']?.toString() ?? course['id']?.toString() ?? '';
      final courseName = course['name']?.toString() ?? '';
      final fallbackKey = [
        course['id']?.toString() ?? '',
        course['courseCode']?.toString() ?? '',
        course['name']?.toString() ?? '',
      ].join('|');

      final selectionValue = materialsCourseId.isNotEmpty
          ? materialsCourseId
          : fallbackKey;
      if (selectionValue.isEmpty) {
        continue;
      }

      final displayLabel = courseName.isNotEmpty
          ? '${courseCode.isNotEmpty ? courseCode : selectionValue} - $courseName'
          : (courseCode.isNotEmpty ? courseCode : selectionValue);

      grouped.putIfAbsent(
        selectionValue,
        () => StudentMaterialCourseOption(
          selectionValue: selectionValue,
          materialsCourseId: materialsCourseId,
          displayLabel: displayLabel,
        ),
      );
    }

    return grouped.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.select<LangProvider, bool>(
      (lang) => lang.isArabic,
    );
    final homeLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('home'),
    );
    final currentCoursesLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('current_courses'),
    );
    final filesLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('files'),
    );
    final assignmentsLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('assignments'),
    );
    final attendanceLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('attendance'),
    );
    final profileLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('profile'),
    );
    final logoutLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('logout'),
    );

    final isStudent = context.select<AuthProvider, bool>(
      (auth) => auth.isStudent,
    );
    final navigator = navigatorKey?.currentState;
    final canGoBack = navigator?.canPop() ?? context.canPop();

    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      leading: canGoBack
          ? IconButton(
              icon: Icon(
                isArabic ? Icons.arrow_forward : Icons.arrow_back,
                color: AppColors.black,
              ),
              onPressed: () {
                if (navigator?.canPop() ?? false) {
                  navigator!.pop();
                  return;
                }
                if (context.canPop()) {
                  context.pop();
                }
              },
            )
          : Padding(
              padding: const EdgeInsets.all(8),
              child: const LangToggle(),
            ),

      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.black,
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: AppColors.black),
          onSelected: (value) {
            switch (value) {
              case 'home':
                context.go(isStudent ? '/' : '/instructor/home');
                break;
              case 'courses':
                context.go(isStudent ? '/courses' : '/instructor/files');
                break;
              case 'assignments':
                context.go(
                  isStudent ? '/assignments' : '/instructor/attendance',
                );
                break;
              case 'profile':
                context.go(isStudent ? '/profile' : '/instructor/profile');
                break;

              case 'Refresh App':
                _refreshAllProviders(context);
                break;
              case 'logout':
                context.read<AuthProvider>().logout();
                context.go('/login');
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'home', child: Text(homeLabel)),
            PopupMenuItem(
              value: 'courses',
              child: Text(isStudent ? currentCoursesLabel : filesLabel),
            ),
            PopupMenuItem(
              value: 'schedule',
              child: Text(isStudent ? assignmentsLabel : attendanceLabel),
            ),
            PopupMenuItem(value: 'profile', child: Text(profileLabel)),
            PopupMenuItem(value: 'logout', child: Text(logoutLabel)),
          ],
        ),
      ],
    );
  }
}
