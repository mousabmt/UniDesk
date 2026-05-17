import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_course.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_session.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_student.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_courses_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_session_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_students_provider.dart';

// ---------------------------------------------------------------------------
// Tab enum — only used inside this file.
// ---------------------------------------------------------------------------
enum _AttendanceTab { attendance, reports }

// ---------------------------------------------------------------------------
// _AttendanceController
//
// Owns all business logic: polling lifecycle, provider coordination, and
// session toggling. The page itself becomes a pure view with no logic.
// ---------------------------------------------------------------------------
class _AttendanceController {
  _AttendanceController({
    required this.coursesProvider,
    required this.studentsProvider,
    required this.sessionProvider,
  });

  final AttendanceCoursesProvider coursesProvider;
  final AttendanceStudentsProvider studentsProvider;
  final AttendanceSessionProvider sessionProvider;

  Timer? _pollingTimer;

  Future<void> refreshStudents() async {
    await studentsProvider.refreshForCourse(coursesProvider.selectedCourse);
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => refreshStudents(),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> onCourseSelected(String? courseKey) async {
    stopPolling();
    // selectCourse normalises the key via _resolveSelectionKey internally.
    coursesProvider.selectCourse(courseKey);
    sessionProvider.reset();
    // loadForCourse accepts null and calls clear() internally — safe to pass
    // selectedCourse directly after selectCourse updates it.
    await studentsProvider.loadForCourse(coursesProvider.selectedCourse);
  }

  Future<void> toggleSession() async {
    final selectedCourse = coursesProvider.selectedCourse;
    if (selectedCourse == null) return;

    if (sessionProvider.hasActiveSession) {
      stopPolling();
      await sessionProvider.closeCurrentSession();
      await refreshStudents();
      return;
    }

    await sessionProvider.startForCourse(selectedCourse);
    await refreshStudents();
    if (sessionProvider.hasActiveSession) {
      startPolling();
    }
  }

  void dispose() => stopPolling();
}

// ---------------------------------------------------------------------------
// AttendancePage
// ---------------------------------------------------------------------------
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
 _AttendanceTab _selectedTab = _AttendanceTab.attendance;
  late final _AttendanceController _controller;
  final ScrollController _scrollController = ScrollController(); // ← add this
  @override
  void initState() {
    super.initState();
    _controller = _AttendanceController(
      coursesProvider: context.read<AttendanceCoursesProvider>(),
      studentsProvider: context.read<AttendanceStudentsProvider>(),
      sessionProvider: context.read<AttendanceSessionProvider>(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      // AuthProvider.userId is backed by _prefs.getString('userId').
      context.read<AttendanceCoursesProvider>().loadIfNeeded(
            instructorId: auth.userId ?? '',
          );
    });
  }

@override
void dispose() {
  _controller.dispose();
  _scrollController.dispose(); // ← add this
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    // Rebuilds only when the name string inside user map changes —
    // not on token, role, isLoading, or any other AuthProvider field.
    final instructorName = context.select<AuthProvider, String>(
      (auth) => auth.user?['name']?.toString() ?? 'Instructor',
    );

    return Scaffold(
      backgroundColor: const Color(0xfff6f3f7),
      body: RefreshIndicator(
        onRefresh: _controller.refreshStudents,
        child: ListView(
          padding: const EdgeInsets.all(16),
          controller: _scrollController,

          children: [
            _AttendanceHeader(
              instructorName: instructorName,
              currentTab: _selectedTab,
              onTabChanged: (tab) => setState(() => _selectedTab = tab),
              onCourseChanged: _controller.onCourseSelected,
            ),
            const SizedBox(height: 24),
            if (_selectedTab == _AttendanceTab.attendance)
              _AttendanceContent(onToggleSession: _controller.toggleSession)
            else
              const _ReportsContent(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AttendanceHeader
// ---------------------------------------------------------------------------
class _AttendanceHeader extends StatelessWidget {
  const _AttendanceHeader({
    required this.instructorName,
    required this.currentTab,
    required this.onTabChanged,
    required this.onCourseChanged,
  });

  // Computed once at class-load time — date cannot change while the app runs.
  static final String _todayLabel = _buildTodayLabel();

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
            'Manage attendance with a cleaner workflow: select a course, '
            'load students, then launch a QR session.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          // Each child widget below uses its own context.select so it
          // rebuilds only when its specific slice of provider state changes.
          _CourseDropdown(onCourseChanged: onCourseChanged),
          const SizedBox(height: 12),
          const _LectureBox(),
          const SizedBox(height: 12),
          _SelectorBox(
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 10),
                Text(_todayLabel),
              ],
            ),
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

  static String _buildTodayLabel() {
    const months = [
      'January', 'February', 'March', 'April',
      'May',     'June',     'July',  'August',
      'September', 'October', 'November', 'December',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

// ---------------------------------------------------------------------------
// _CourseDropdown
//
// Selects only: isLoading, courses, selectedCourseKey, errorMessage.
// Unrelated provider changes (e.g. selectedCourse object) do not rebuild it.
// ---------------------------------------------------------------------------
class _CourseDropdown extends StatelessWidget {
  const _CourseDropdown({required this.onCourseChanged});

  final ValueChanged<String?> onCourseChanged;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AttendanceCoursesProvider, bool>(
      (p) => p.isLoading,
    );
    final courses = context.select<AttendanceCoursesProvider, List<AttendanceCourse>>(
      (p) => p.courses,
    );
    final selectedKey = context.select<AttendanceCoursesProvider, String?>(
      (p) => p.selectedCourseKey,
    );
    final error = context.select<AttendanceCoursesProvider, String?>(
      (p) => p.errorMessage,
    );

    if (isLoading && courses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && courses.isEmpty) {
      return _InlineState(
        icon: Icons.error_outline,
        tone: const Color(0xffd36b6b),
        message: error,
      );
    }

    return _SelectorBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedKey,
          hint: const Text('Select Course'),
          items: courses.map((course) {
            return DropdownMenuItem<String>(
              // selectionKey and displayLabel are getters on AttendanceCourse.
              value: course.selectionKey,
              child: Text(course.displayLabel),
            );
          }).toList(),
          onChanged: onCourseChanged,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _LectureBox
//
// Rebuilds only when selectedCourse changes.
// Uses lectureId — a required field on AttendanceCourse.
// ---------------------------------------------------------------------------
class _LectureBox extends StatelessWidget {
  const _LectureBox({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCourse = context.select<AttendanceCoursesProvider, AttendanceCourse?>(
      (p) => p.selectedCourse,
    );

    return _SelectorBox(
      child: Row(
        children: [
          const Icon(Icons.menu_book_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              selectedCourse == null
                  ? 'Lecture details will appear after course selection'
                  : 'Lecture ${selectedCourse.lectureId}',
              style: TextStyle(
                color: selectedCourse == null ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AttendanceContent
// ---------------------------------------------------------------------------
class _AttendanceContent extends StatelessWidget {
  const _AttendanceContent({required this.onToggleSession});

  final Future<void> Function() onToggleSession;

  @override
  Widget build(BuildContext context) {
    final selectedCourse = context.select<AttendanceCoursesProvider, AttendanceCourse?>(
      (p) => p.selectedCourse,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SessionPanel(
          selectedCourse: selectedCourse,
          onToggleSession: onToggleSession,
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

// ---------------------------------------------------------------------------
// _SessionPanel
//
// Each provider field is selected independently so e.g. a loading flag flip
// does not force the QR card subtree to rebuild.
// ---------------------------------------------------------------------------
class _SessionPanel extends StatelessWidget {
  const _SessionPanel({
    required this.selectedCourse,
    required this.onToggleSession,
  });

  final AttendanceCourse? selectedCourse;
  final Future<void> Function() onToggleSession;

  @override
  Widget build(BuildContext context) {
    // hasActiveSession — backed by _currentSession != null.
    final hasActiveSession = context.select<AttendanceSessionProvider, bool>(
      (p) => p.hasActiveSession,
    );
    // isLoading — true when status == AttendanceSessionStatus.loading.
    final isLoading = context.select<AttendanceSessionProvider, bool>(
      (p) => p.isLoading,
    );
    // hasError — true when status == AttendanceSessionStatus.error.
    final hasError = context.select<AttendanceSessionProvider, bool>(
      (p) => p.hasError,
    );
    final errorMessage = context.select<AttendanceSessionProvider, String?>(
      (p) => p.errorMessage,
    );
    // Only read currentSession when a session is actually active; avoids a
    // rebuild when the session resets to null on course change.
    final currentSession = context.select<AttendanceSessionProvider, AttendanceSession?>(
      (p) => p.hasActiveSession ? p.currentSession : null,
    );

    final hasSelection = selectedCourse != null;

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
                // name is a required field on AttendanceCourse.
                ? 'Generate a QR code for ${selectedCourse!.name} so students can register attendance.'
                : 'Choose a course first, then the QR session controls will unlock automatically.',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: hasSelection && !isLoading ? onToggleSession : null,
              icon: Icon(
                hasActiveSession
                    ? Icons.stop_circle_outlined
                    : Icons.play_arrow_rounded,
              ),
              label: Text(
                hasActiveSession
                    ? 'Close Attendance Session'
                    : 'Start Attendance Session',
              ),
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
          if (hasError && errorMessage != null) ...[
            const SizedBox(height: 12),
            _InlineState(
              icon: Icons.error_outline,
              tone: const Color(0xffd36b6b),
              message: errorMessage,
            ),
          ],
          // _SessionQrCard now receives only the AttendanceSession it renders.
          if (hasActiveSession && currentSession != null) ...[
            const SizedBox(height: 18),
            _SessionQrCard(session: currentSession),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ReportsContent
//
// Three independent context.select calls — changing presentStudents does not
// rebuild the Enrolled or Absent metric cards.
// ---------------------------------------------------------------------------
class _ReportsContent extends StatelessWidget {
  const _ReportsContent();

  @override
  Widget build(BuildContext context) {
    // totalStudents — students.length.
    final total = context.select<AttendanceStudentsProvider, int>(
      (p) => p.totalStudents,
    );
    // presentStudents — students where isPresent == true.
    final present = context.select<AttendanceStudentsProvider, int>(
      (p) => p.presentStudents,
    );
    // absentStudents — totalStudents - presentStudents.
    final absent = context.select<AttendanceStudentsProvider, int>(
      (p) => p.absentStudents,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Enrolled',
                value: total.toString(),
                tone: const Color(0xff0bb4b1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Present',
                value: present.toString(),
                tone: const Color(0xff4b8bff),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Absent',
                value: absent.toString(),
                tone: const Color(0xffd36b6b),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _StudentsSection(showAbsenceSummary: true),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _StudentsSection
//
// ListView.builder renders items lazily — only visible cards are built.
// ValueKey(student.id) lets Flutter reuse existing elements on poll refreshes
// instead of tearing down and rebuilding every card.
// ---------------------------------------------------------------------------
class _StudentsSection extends StatelessWidget {
  const _StudentsSection({required this.showAbsenceSummary});

  final bool showAbsenceSummary;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AttendanceStudentsProvider, bool>(
      (p) => p.isLoading,
    );
    final errorMessage = context.select<AttendanceStudentsProvider, String?>(
      (p) => p.errorMessage,
    );
    final students = context.select<AttendanceStudentsProvider, List<AttendanceStudent>>(
      (p) => p.students,
    );

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return _InlineState(
        icon: Icons.error_outline,
        tone: const Color(0xffd36b6b),
        message: errorMessage,
      );
    }

    if (students.isEmpty) {
      return const _InlineState(
        icon: Icons.groups_outlined,
        tone: Color(0xff8b98a5),
        message: 'Select a course to load enrolled students.',
      );
    }

    return _PanelCard(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          // subtitle built here so StudentAttendanceCard stays a pure renderer.
          final subtitle = showAbsenceSummary
              // absences and isPresent are fields on AttendanceStudent.
              ? '${student.absences} absences · ${student.isPresent ? 'Present' : 'Absent'}'
              // email is a field on AttendanceStudent.
              : '${student.email} · ${student.isPresent ? 'Present' : 'Absent'}';

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: StudentAttendanceCard(
              key: ValueKey(student.id),
              student: student,
              subtitle: subtitle,
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SessionQrCard
//
// Receives only the AttendanceSession it renders, not the full provider.
// Fields used: qrPayload (getter), token, expiresAt — all on AttendanceSession.
// ---------------------------------------------------------------------------
class _SessionQrCard extends StatelessWidget {
  const _SessionQrCard({required this.session});

  final AttendanceSession session;

  @override
  Widget build(BuildContext context) {
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
              // qrPayload encodes token + courseId as JSON — getter on AttendanceSession.
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

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ---------------------------------------------------------------------------
// StudentAttendanceCard
// ---------------------------------------------------------------------------
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
            // student.initials — add the late final getter to AttendanceStudent
            // (see patch at the bottom of this file).
            child: Text(
              student.initials,
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
              // isPresent and isAtRisk are fields/getters on AttendanceStudent.
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
}

// ---------------------------------------------------------------------------
// Shared primitives
// ---------------------------------------------------------------------------

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
          Expanded(child: Text(message, style: TextStyle(color: tone))),
        ],
      ),
    );
  }
}