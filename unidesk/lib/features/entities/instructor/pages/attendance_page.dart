import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_course.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_student.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_courses_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_session_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_students_provider.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

enum _AttendanceTab { attendance, reports }

class _AttendancePageState extends State<AttendancePage> {
  _AttendanceTab _selectedTab = _AttendanceTab.attendance;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<AttendanceCoursesProvider>().loadIfNeeded(
        instructorId: auth.userId ?? '',
      );
    });
  }

  Future<void> _refreshStudentsForSelectedCourse() async {
    final selectedCourse = context
        .read<AttendanceCoursesProvider>()
        .selectedCourse;
    await context.read<AttendanceStudentsProvider>().refreshForCourse(
      selectedCourse,
    );
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshStudentsForSelectedCourse();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _onCourseSelected(String? courseId) async {
    final coursesProvider = context.read<AttendanceCoursesProvider>();
    final studentsProvider = context.read<AttendanceStudentsProvider>();
    final sessionProvider = context.read<AttendanceSessionProvider>();

    _stopPolling();
    coursesProvider.selectCourse(courseId);
    sessionProvider.reset();
    await studentsProvider.loadForCourse(coursesProvider.selectedCourse);
  }

  Future<void> _toggleSession() async {
    final sessionProvider = context.read<AttendanceSessionProvider>();
    final selectedCourse = context
        .read<AttendanceCoursesProvider>()
        .selectedCourse;
    if (selectedCourse == null) {
      return;
    }

    if (sessionProvider.hasActiveSession) {
      _stopPolling();
      await sessionProvider.closeCurrentSession();
      await _refreshStudentsForSelectedCourse();
      return;
    }

    await sessionProvider.startForCourse(selectedCourse);
    await _refreshStudentsForSelectedCourse();
    if (sessionProvider.hasActiveSession) {
      _startPolling();
    }
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instructorName = context.select<AuthProvider, String>(
      (auth) => auth.user?['name']?.toString() ?? 'Instructor',
    );

    return Scaffold(
      backgroundColor: const Color(0xfff6f3f7),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AttendanceHeader(
            instructorName: instructorName,
            currentTab: _selectedTab,
            onTabChanged: (tab) => setState(() => _selectedTab = tab),
            onCourseChanged: _onCourseSelected,
          ),
          const SizedBox(height: 24),
          if (_selectedTab == _AttendanceTab.attendance)
            _AttendanceContent(onToggleSession: _toggleSession)
          else
            const _ReportsContent(),
        ],
      ),
    );
  }
}

class _AttendanceHeader extends StatelessWidget {
  const _AttendanceHeader({
    required this.instructorName,
    required this.currentTab,
    required this.onTabChanged,
    required this.onCourseChanged,
  });

  final String instructorName;
  final _AttendanceTab currentTab;
  final ValueChanged<_AttendanceTab> onTabChanged;
  final ValueChanged<String?> onCourseChanged;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello $instructorName',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage attendance with a cleaner workflow: select a course, load students, then launch a QR session.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          Consumer<AttendanceCoursesProvider>(
            builder: (context, coursesProvider, _) {
              if (coursesProvider.isLoading &&
                  coursesProvider.courses.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (coursesProvider.errorMessage != null &&
                  coursesProvider.courses.isEmpty) {
                return _InlineState(
                  icon: Icons.error_outline,
                  tone: const Color(0xffd36b6b),
                  message: coursesProvider.errorMessage!,
                );
              }

              return Column(
                children: [
                  _SelectorBox(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: coursesProvider.selectedCourseKey,
                        hint: const Text('Select Course'),
                        items: coursesProvider.courses.map((course) {
                          return DropdownMenuItem<String>(
                            value: course.selectionKey,
                            child: Text(course.displayLabel),
                          );
                        }).toList(),
                        onChanged: onCourseChanged,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SelectorBox(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Text(_formatToday()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SelectorBox(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.menu_book_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            coursesProvider.selectedCourse == null
                                ? 'Lecture details will appear after course selection'
                                : 'Lecture ${coursesProvider.selectedCourse!.lectureId}',
                            style: TextStyle(
                              color: coursesProvider.selectedCourse == null
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _TabPill(
                  label: 'Attendance',
                  selected: currentTab == _AttendanceTab.attendance,
                  onTap: () => onTabChanged(_AttendanceTab.attendance),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TabPill(
                  label: 'Reports',
                  selected: currentTab == _AttendanceTab.reports,
                  onTap: () => onTabChanged(_AttendanceTab.reports),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatToday() {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

class _AttendanceContent extends StatelessWidget {
  const _AttendanceContent({required this.onToggleSession});

  final Future<void> Function() onToggleSession;

  @override
  Widget build(BuildContext context) {
    final selectedCourse = context
        .select<AttendanceCoursesProvider, AttendanceCourse?>(
          (provider) => provider.selectedCourse,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<AttendanceSessionProvider>(
          builder: (context, sessionProvider, _) {
            final hasSelection = selectedCourse != null;
            final buttonLabel = sessionProvider.hasActiveSession
                ? 'Close Attendance Session'
                : 'Start Attendance Session';

            return _PanelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Session',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasSelection
                        ? 'Generate a QR code for ${selectedCourse.name} so students can register attendance.'
                        : 'Choose a course first, then the QR session controls will unlock automatically.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: hasSelection && !sessionProvider.isLoading
                          ? onToggleSession
                          : null,
                      icon: Icon(
                        sessionProvider.hasActiveSession
                            ? Icons.stop_circle_outlined
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(buttonLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0bb4b1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  if (sessionProvider.hasError &&
                      sessionProvider.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _InlineState(
                      icon: Icons.error_outline,
                      tone: const Color(0xffd36b6b),
                      message: sessionProvider.errorMessage!,
                    ),
                  ],
                  if (sessionProvider.hasActiveSession &&
                      sessionProvider.currentSession != null) ...[
                    const SizedBox(height: 18),
                    _SessionQrCard(sessionProvider: sessionProvider),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Students List',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const _StudentsSection(showAbsenceSummary: false),
      ],
    );
  }
}

class _ReportsContent extends StatelessWidget {
  const _ReportsContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceStudentsProvider>(
      builder: (context, studentsProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Enrolled',
                    value: studentsProvider.totalStudents.toString(),
                    tone: const Color(0xff0bb4b1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Present',
                    value: studentsProvider.presentStudents.toString(),
                    tone: const Color(0xff4b8bff),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Absent',
                    value: studentsProvider.absentStudents.toString(),
                    tone: const Color(0xffd36b6b),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _StudentsSection(showAbsenceSummary: true),
          ],
        );
      },
    );
  }
}

class _StudentsSection extends StatelessWidget {
  const _StudentsSection({required this.showAbsenceSummary});

  final bool showAbsenceSummary;

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceStudentsProvider>(
      builder: (context, studentsProvider, _) {
        if (studentsProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (studentsProvider.errorMessage != null) {
          return _InlineState(
            icon: Icons.error_outline,
            tone: const Color(0xffd36b6b),
            message: studentsProvider.errorMessage!,
          );
        }

        if (studentsProvider.students.isEmpty) {
          return const _InlineState(
            icon: Icons.groups_outlined,
            tone: Color(0xff8b98a5),
            message: 'Select a course to load enrolled students.',
          );
        }

        return _PanelCard(
          child: Column(
            children: studentsProvider.students.map((student) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: StudentAttendanceCard(
                  student: student,
                  subtitle: showAbsenceSummary
                      ? '${student.absences} absences - ${student.isPresent ? 'Present' : 'Absent'}'
                      : '${student.email} - ${student.isPresent ? 'Present' : 'Absent'}',
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _SessionQrCard extends StatelessWidget {
  const _SessionQrCard({required this.sessionProvider});

  final AttendanceSessionProvider sessionProvider;

  @override
  Widget build(BuildContext context) {
    final session = sessionProvider.currentSession!;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xfff8fbfb),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffd9efee)),
        ),
        child: Column(
          children: [
            QrImageView(
              data: session.qrPayload,
              size: 190,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              'Token: ${session.token}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              'Expires: ${_formatTime(session.expiresAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SelectorBox extends StatelessWidget {
  const _SelectorBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xfff4f4f4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff0bb4b1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xff0bb4b1)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xff0bb4b1),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InlineState extends StatelessWidget {
  const _InlineState({
    required this.icon,
    required this.tone,
    required this.message,
  });

  final IconData icon;
  final Color tone;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: tone),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: tone)),
          ),
        ],
      ),
    );
  }
}

class StudentAttendanceCard extends StatelessWidget {
  const StudentAttendanceCard({
    super.key,
    required this.student,
    required this.subtitle,
  });

  final AttendanceStudent student;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xffd9efee),
            child: Text(
              _initialsFor(student.name),
              style: const TextStyle(
                color: Color(0xff0bb4b1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: student.isPresent
                  ? const Color(0xffd2f4f2)
                  : student.isAtRisk
                  ? const Color(0xffffe6e6)
                  : const Color(0xffeef2f5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              student.isPresent
                  ? Icons.check
                  : student.isAtRisk
                  ? Icons.warning_amber_rounded
                  : Icons.close_rounded,
              color: student.isPresent
                  ? const Color(0xff0bb4b1)
                  : student.isAtRisk
                  ? const Color(0xffd36b6b)
                  : const Color(0xff7c8a96),
            ),
          ),
        ],
      ),
    );
  }

  static String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }
    if (parts.length == 1 || parts.last.isEmpty) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
