import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_attachment.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_submission.dart';
import 'package:unidesk/features/entities/instructor/assignments/providers/instructor_assignments_provider.dart';
import 'package:unidesk/features/entities/instructor/assignments/services/assignment_attachment_opener.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_file_item.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_surface_card.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_wave_header_card.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({
    super.key,
    this.initialCourseId,
    this.initialSectionId,
    this.lockCourseSelection = false,
    this.successMessage,
  });

  final String? initialCourseId;
  final String? initialSectionId;
  final bool lockCourseSelection;
  final String? successMessage;

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  static const Color kTeal = Color(0xff0bb4b1);
  static const AssignmentAttachmentOpener _attachmentOpener =
      AssignmentAttachmentOpener();

  bool _didShowSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncRouteState());
  }

  @override
  void didUpdateWidget(covariant AssignmentsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCourseId != widget.initialCourseId ||
        oldWidget.initialSectionId != widget.initialSectionId ||
        oldWidget.lockCourseSelection != widget.lockCourseSelection ||
        oldWidget.successMessage != widget.successMessage) {
      _didShowSuccessMessage = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncRouteState());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _showSuccessMessageIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final instructorName = context.select<AuthProvider, String>(
      (auth) => auth.user?['name']?.toString() ?? 'Instructor',
    );

    return ColoredBox(
      color: const Color(0xfff0f4f8),
      child: SafeArea(
        bottom: false,
        child: Consumer<InstructorAssignmentsProvider>(
          builder: (context, provider, _) {
            final selectedCourse = provider.selectedCourse;
            final selectedAssignment = provider.selectedAssignment;

            return RefreshIndicator(
              onRefresh: _refreshPage,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  InstructorWaveHeaderCard(
                    compact: compact,
                    minHeightCompact: 165,
                    minHeightRegular: 130,
                    leadingCompact: _InitialsAvatar(
                      name: instructorName,
                      radius: 36,
                    ),
                    leadingRegular: _InitialsAvatar(
                      name: instructorName,
                      radius: 40,
                    ),
                    content: _AssignmentsHeader(
                      courseLabel:
                          selectedCourse?.displayLabel ?? 'Choose a course',
                      assignmentCount: provider.assignments.length,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (provider.isCoursesLoading && provider.courses.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (provider.coursesError != null &&
                      provider.courses.isEmpty)
                    _PageStateMessage(
                      message: provider.coursesError!,
                      actionLabel: 'Retry',
                      onRetry: _refreshPage,
                    )
                  else ...[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final useStackedHeader = constraints.maxWidth < 720;
                        final selector = _CourseSectionSelector(
                          provider: provider,
                          onCourseChanged: (courseId) async {
                            if (courseId == null) {
                              return;
                            }
                            final instructorId =
                                context.read<AuthProvider>().userId ?? 'D001';
                            await provider.selectCourse(
                              instructorId: instructorId,
                              courseId: courseId,
                            );
                          },
                          onSectionChanged: (sectionId) async {
                            if (sectionId == null) {
                              return;
                            }
                            final instructorId =
                                context.read<AuthProvider>().userId ?? 'D001';
                            await provider.selectSection(
                              instructorId: instructorId,
                              sectionId: sectionId,
                            );
                          },
                        );
                        final addButton = ElevatedButton.icon(
                          onPressed: selectedCourse == null
                              ? null
                              : () => context.pushNamed(
                                  'instructor-add-assignment',
                                  queryParameters: <String, String>{
                                    'courseId': selectedCourse.id,
                                    'sectionId':
                                        provider.selectedSectionId ?? '',
                                  },
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                        );

                        if (useStackedHeader) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              selector,
                              const SizedBox(height: 12),
                              addButton,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: selector),
                            const SizedBox(width: 12),
                            addButton,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final useSingleColumn = constraints.maxWidth < 760;
                        if (useSingleColumn) {
                          return Column(
                            children: [
                              _AssignmentsListCard(
                                provider: provider,
                                onRetry: _refreshPage,
                                onAttachmentTap: (attachment) =>
                                    _handleAttachmentTap(context, attachment),
                              ),
                              const SizedBox(height: 20),
                              _SubmissionsPanel(
                                provider: provider,
                                selectedAssignment: selectedAssignment,
                                onSubmissionFileTap: (attachment) =>
                                    _handleAttachmentTap(context, attachment),
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _AssignmentsListCard(
                                provider: provider,
                                onRetry: _refreshPage,
                                onAttachmentTap: (attachment) =>
                                    _handleAttachmentTap(context, attachment),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 5,
                              child: _SubmissionsPanel(
                                provider: provider,
                                selectedAssignment: selectedAssignment,
                                onSubmissionFileTap: (attachment) =>
                                    _handleAttachmentTap(context, attachment),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSuccessMessageIfNeeded() {
    if (_didShowSuccessMessage || widget.successMessage == null || !mounted) {
      return;
    }

    _didShowSuccessMessage = true;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(widget.successMessage!)));
  }

  Future<void> _syncRouteState() async {
    if (!mounted) {
      return;
    }

    final instructorId = context.read<AuthProvider>().userId ?? 'D001';
    await context.read<InstructorAssignmentsProvider>().loadIfNeeded(
      instructorId: instructorId,
      preferredCourseId: widget.initialCourseId,
      preferredSectionId: widget.initialSectionId,
      lockCourseSelection: false,
    );
    _showSuccessMessageIfNeeded();
  }

  Future<void> _refreshPage() async {
    if (!mounted) {
      return;
    }

    final instructorId = context.read<AuthProvider>().userId ?? 'D001';
    final provider = context.read<InstructorAssignmentsProvider>();
    await provider.refresh(
      instructorId: instructorId,
      preferredCourseId: provider.selectedCourseId ?? widget.initialCourseId,
      preferredSectionId:
          provider.selectedSectionId ?? widget.initialSectionId,
      lockCourseSelection: provider.isCourseLocked || widget.lockCourseSelection,
    );
  }

  Future<void> _handleAttachmentTap(
    BuildContext context,
    AssignmentAttachment attachment,
  ) async {
    final result = await _attachmentOpener.open(attachment);
    if (!context.mounted || result.didOpen) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }
}

class _AssignmentsHeader extends StatelessWidget {
  const _AssignmentsHeader({
    required this.courseLabel,
    required this.assignmentCount,
  });

  final String courseLabel;
  final int assignmentCount;

  @override
  Widget build(BuildContext context) {
    final sectionLabel = context.select<InstructorAssignmentsProvider, String?>(
      (provider) {
        final course = provider.selectedCourse;
        return course == null ? null : provider.sectionLabelFor(course);
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Assignments',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          '${assignmentCount == 1 ? '1 assignment' : '$assignmentCount assignments'} in $courseLabel${sectionLabel == null ? '' : ' • $sectionLabel'}',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}

class _CourseSectionSelector extends StatelessWidget {
  const _CourseSectionSelector({
    required this.provider,
    required this.onCourseChanged,
    required this.onSectionChanged,
  });

  final InstructorAssignmentsProvider provider;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<String?> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useStackedSelectors = constraints.maxWidth < 560;
        final courseSelector = _SelectorCard(
          value: provider.selectedCourseGroupKey,
          hint: 'Choose a course',
          items: provider.availableCourses
              .map(
                (course) => DropdownMenuItem<String>(
                  value: provider.courseSelectionValueFor(course),
                  child: Text(
                    course.displayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          selectedLabels: provider.availableCourses
              .map((course) => course.displayLabel)
              .toList(),
          onChanged: onCourseChanged,
        );
        final sectionSelector = _SelectorCard(
          value: provider.selectedSectionSelectionKey,
          hint: 'Choose a section',
          items: provider.availableSections
              .map(
                (course) => DropdownMenuItem<String>(
                  value: course.selectionKey,
                  child: Text(
                    provider.sectionLabelFor(course) ??
                        _fallbackSectionLabel(course),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          selectedLabels: provider.availableSections
              .map(
                (course) =>
                    provider.sectionLabelFor(course) ??
                    _fallbackSectionLabel(course),
              )
              .toList(),
          onChanged: onSectionChanged,
        );

        if (useStackedSelectors) {
          return Column(
            children: [
              courseSelector,
              const SizedBox(height: 12),
              sectionSelector,
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: courseSelector),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: sectionSelector),
          ],
        );
      },
    );
  }

  static String _fallbackSectionLabel(InstructorManagedCourse course) {
    if (course.sectionId.isNotEmpty) {
      return 'Section ${course.sectionId}';
    }
    if (course.lectureId.isNotEmpty) {
      return 'Section ${course.lectureId}';
    }
    return 'Section';
  }
}

class _SelectorCard extends StatelessWidget {
  const _SelectorCard({
    required this.value,
    required this.hint,
    required this.items,
    required this.selectedLabels,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final List<String> selectedLabels;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InstructorSurfaceCard(
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint),
          selectedItemBuilder: (context) {
            return selectedLabels
                .map(
                  (label) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList();
          },
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AssignmentsListCard extends StatelessWidget {
  const _AssignmentsListCard({
    required this.provider,
    required this.onRetry,
    required this.onAttachmentTap,
  });

  final InstructorAssignmentsProvider provider;
  final VoidCallback onRetry;
  final ValueChanged<AssignmentAttachment> onAttachmentTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Assignments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InstructorSurfaceCard(padding: EdgeInsets.zero, child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (provider.isAssignmentsLoading && provider.assignments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.assignmentsError != null && provider.assignments.isEmpty) {
      return _PageStateMessage(
        message: provider.assignmentsError!,
        actionLabel: 'Retry',
        onRetry: onRetry,
      );
    }

    if (provider.assignments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No assignments published for this course section yet.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: List.generate(provider.assignments.length, (index) {
        final assignment = provider.assignments[index];
        final isSelected = provider.selectedAssignmentId == assignment.id;
        return Column(
          children: [
            _AssignmentTile(
              assignment: assignment,
              isSelected: isSelected,
              onTap: () => provider.selectAssignment(assignment.id),
              onAttachmentTap: onAttachmentTap,
            ),
            if (index < provider.assignments.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        );
      }),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({
    required this.assignment,
    required this.isSelected,
    required this.onTap,
    required this.onAttachmentTap,
  });

  final Assignment assignment;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<AssignmentAttachment> onAttachmentTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffeef9f8) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff1a1a1a),
                    ),
                  ),
                  if (assignment.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      assignment.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: Icons.calendar_today_outlined,
                        text: assignment.dueDateLabel.isEmpty
                            ? 'No due date'
                            : assignment.dueDateLabel,
                      ),
                      _MetaChip(
                        icon: Icons.grade_outlined,
                        text: '${assignment.maxScore} points',
                      ),
                      _MetaChip(
                        icon: assignment.isActive
                            ? Icons.check_circle_outline
                            : Icons.pause_circle_outline,
                        text: assignment.statusLabel,
                      ),
                    ],
                  ),
                  if (assignment.attachment != null) ...[
                    const SizedBox(height: 12),
                    _AssignmentAttachmentTile(
                      attachment: assignment.attachment!,
                      onTap: () => onAttachmentTap(assignment.attachment!),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: assignment.isActive
                    ? const Color(0xffe7f7ef)
                    : const Color(0xfff5f5f5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                assignment.statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: assignment.isActive
                      ? const Color(0xff237a44)
                      : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentAttachmentTile extends StatelessWidget {
  const _AssignmentAttachmentTile({
    required this.attachment,
    required this.onTap,
  });

  final AssignmentAttachment attachment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 134, 136, 137),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe6eef2)),
      ),
      child: InstructorFileItem(
        color: attachment.badgeColor,
        label: attachment.extensionLabel,
        name: attachment.name,
        date: attachment.hasLocalFile
            ? 'Attached from this device'
            : attachment.hasRemoteUrl
            ? 'Available from API attachment link'
            : 'Attachment unavailable',
        size: attachment.sizeLabel,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isInteractive: attachment.canOpen,
        onTap: attachment.canOpen ? onTap : null,
      ),
    );
  }
}

class _SubmissionsPanel extends StatelessWidget {
  const _SubmissionsPanel({
    required this.provider,
    required this.selectedAssignment,
    this.onSubmissionFileTap,
  });

  final InstructorAssignmentsProvider provider;
  final Assignment? selectedAssignment;
  final ValueChanged<AssignmentAttachment>? onSubmissionFileTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedAssignment == null
              ? 'Recent Submissions'
              : 'Submissions for ${selectedAssignment!.title}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InstructorSurfaceCard(padding: EdgeInsets.zero, child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (selectedAssignment == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Select an assignment to review submissions.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (provider.isSubmissionsLoading && provider.submissions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.submissionsError != null && provider.submissions.isEmpty) {
      return _PageStateMessage(message: provider.submissionsError!);
    }

    if (provider.submissions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No submissions have been received yet.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: List.generate(provider.submissions.length, (index) {
        final submission = provider.submissions[index];
        return Column(
          children: [
            _SubmissionTile(
              assignment: selectedAssignment!,
              provider: provider,
              submission: submission,
              onFileTap: submission.file != null
                  ? () => onSubmissionFileTap?.call(submission.file!)
                  : null,
            ),
            if (index < provider.submissions.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        );
      }),
    );
  }
}

class _SubmissionTile extends StatelessWidget {
  const _SubmissionTile({
    required this.assignment,
    required this.provider,
    required this.submission,
    this.onFileTap,
  });

  final Assignment assignment;
  final InstructorAssignmentsProvider provider;
  final AssignmentSubmission submission;
  final VoidCallback? onFileTap;

  @override
  Widget build(BuildContext context) {
    final isBusy =
        provider.isGrading && provider.gradingSubmissionId == submission.id;
    final score = submission.score;
    final double ratio =
        score != null && assignment.maxScore > 0
            ? score / assignment.maxScore
            : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xffe6f5f5),
            child: Text(
              submission.initials.isEmpty ? '?' : submission.initials,
              style: const TextStyle(
                color: _AssignmentsPageState.kTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  submission.studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  submission.submittedAtLabel.isEmpty
                      ? 'Submitted'
                      : 'Submitted on ${submission.submittedAtLabel}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (submission.file != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: submission.file!.canOpen ? onFileTap : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: submission.file!.badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: submission.file!.badgeColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: submission.file!.badgeColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              submission.file!.extensionLabel,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              submission.file!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            submission.file!.canOpen
                                ? Icons.open_in_new
                                : Icons.info_outline,
                            size: 12,
                            color: submission.file!.canOpen
                                ? submission.file!.badgeColor
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (submission.isGraded)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffeaf7ec),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${submission.score}/${assignment.maxScore}',
                    style: TextStyle(
                      color: ratio >= 0.6
                          ? const Color(0xff237a44)
                          : const Color(0xffe53935),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (submission.isGraded) const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: OutlinedButton(
                  onPressed: isBusy
                      ? null
                      : () => _showGradeSheet(context, assignment, submission),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _AssignmentsPageState.kTeal,
                    side: const BorderSide(color: _AssignmentsPageState.kTeal),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(submission.isGraded ? 'Edit Grade' : 'Grade'),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: submission.isSubmitted
                      ? const Color(0xff4caf50)
                      : const Color(0xffe53935),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  submission.isSubmitted ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showGradeSheet(
    BuildContext context,
    Assignment assignment,
    AssignmentSubmission submission,
  ) async {
    provider.clearGradeError();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: _GradeSubmissionSheet(
            assignment: assignment,
            submission: submission,
          ),
        );
      },
    );
  }
}

class _GradeSubmissionSheet extends StatefulWidget {
  const _GradeSubmissionSheet({
    required this.assignment,
    required this.submission,
  });

  final Assignment assignment;
  final AssignmentSubmission submission;

  @override
  State<_GradeSubmissionSheet> createState() => _GradeSubmissionSheetState();
}

class _GradeSubmissionSheetState extends State<_GradeSubmissionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _scoreController;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(
      text: widget.submission.scoreLabel == 'Ungraded'
          ? ''
          : widget.submission.scoreLabel,
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: Consumer<InstructorAssignmentsProvider>(
        builder: (context, provider, _) {
          final isBusy =
              provider.isGrading &&
              provider.gradingSubmissionId == widget.submission.id;
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.submission.isGraded
                      ? 'Edit Grade'
                      : 'Grade Submission',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.submission.studentName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.assignment.title,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xfff4f8fb),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Score must be between 0 and ${widget.assignment.maxScore} points.',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _scoreController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Grade',
                    hintText: 'Enter score',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    final trimmed = (value ?? '').trim();
                    if (trimmed.isEmpty) {
                      return 'Please enter a grade.';
                    }
                    final score = double.tryParse(trimmed);
                    if (score == null) {
                      return 'Grade must be a valid number.';
                    }
                    if (score < 0) {
                      return 'Grade cannot be negative.';
                    }
                    if (score > widget.assignment.maxScore) {
                      return 'Grade cannot exceed ${widget.assignment.maxScore}.';
                    }
                    return null;
                  },
                ),
                if (provider.gradeError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    provider.gradeError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isBusy
                            ? null
                            : () => _submit(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _AssignmentsPageState.kTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Grade'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    InstructorAssignmentsProvider provider,
  ) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final score = double.parse(_scoreController.text.trim());
    final success = await provider.gradeSubmission(
      submissionId: widget.submission.id,
      score: score,
    );
    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.submission.isGraded
                ? 'Grade updated successfully.'
                : 'Grade saved successfully.',
          ),
        ),
      );
    }
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xfff5f8fa),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name, required this.radius});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length > 1
        ? '${parts.first[0]}${parts.last[0]}'
        : (parts.isEmpty ? 'I' : parts.first[0]);

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xffe0f7f6),
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: _AssignmentsPageState.kTeal,
          fontSize: radius * 0.45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PageStateMessage extends StatelessWidget {
  const _PageStateMessage({
    required this.message,
    this.actionLabel,
    this.onRetry,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          if (actionLabel != null && onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
