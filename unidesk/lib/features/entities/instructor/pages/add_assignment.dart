import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_attachment.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/create_assignment_request.dart';
import 'package:unidesk/features/entities/instructor/assignments/providers/instructor_assignments_provider.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_surface_card.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_wave_header_card.dart';

class AddAssignmentPage extends StatefulWidget {
  const AddAssignmentPage({
    super.key,
    this.initialCourseId,
    this.initialSectionId,
    this.lockCourseSelection = false,
  });

  final String? initialCourseId;
  final String? initialSectionId;
  final bool lockCourseSelection;

  @override
  State<AddAssignmentPage> createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  static const Color kTeal = Color(0xff0bb4b1);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController(text: '100');

  DateTime? _dueDate;
  AssignmentAttachment? _attachment;
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncRouteState());
  }

  @override
  void didUpdateWidget(covariant AddAssignmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCourseId != widget.initialCourseId ||
        oldWidget.initialSectionId != widget.initialSectionId ||
        oldWidget.lockCourseSelection != widget.lockCourseSelection) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncRouteState());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
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

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                InstructorWaveHeaderCard(
                  compact: compact,
                  minHeightCompact: 160,
                  minHeightRegular: 130,
                  leadingCompact: _InitialsAvatar(
                    name: instructorName,
                    radius: 36,
                  ),
                  leadingRegular: _InitialsAvatar(
                    name: instructorName,
                    radius: 40,
                  ),
                  content: _HeaderContent(
                    title: 'Create Assignment',
                    subtitle: selectedCourse == null
                        ? 'Select a course and section, then publish when ready.'
                        : 'Publishing to ${selectedCourse.displayLabel}${provider.sectionLabelFor(selectedCourse) == null ? '' : ' • ${provider.sectionLabelFor(selectedCourse)!}'}.',
                  ),
                ),
                const SizedBox(height: 20),
                if (provider.coursesError != null && provider.courses.isEmpty)
                  _InlineMessage(
                    message: provider.coursesError!,
                    color: Colors.red,
                  )
                else if (provider.isCoursesLoading && provider.courses.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  InstructorSurfaceCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('Select Course'),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final useStackedSelectors =
                                  constraints.maxWidth < 560;
                              final courseDropdown =
                                  DropdownButtonFormField<String>(
                                    key: ValueKey(
                                      provider.selectedCourseGroupKey,
                                    ),
                                    initialValue:
                                        provider.selectedCourseGroupKey,
                                    isExpanded: true,
                                    decoration: _inputDecoration(
                                      'Choose a course',
                                    ),
                                    selectedItemBuilder: (context) {
                                      return provider.availableCourses.map((
                                        course,
                                      ) {
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            course.displayLabel,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList();
                                    },
                                    items: provider.availableCourses
                                        .map(
                                          (course) => DropdownMenuItem<String>(
                                            value: provider
                                                .courseSelectionValueFor(
                                                  course,
                                                ),
                                            child: Text(
                                              course.displayLabel,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) async {
                                      if (value == null) {
                                        return;
                                      }
                                      final instructorId =
                                          context.read<AuthProvider>().userId ??
                                          'D001';
                                      await provider.selectCourse(
                                        instructorId: instructorId,
                                        courseId: value,
                                      );
                                    },
                                    validator: (value) {
                                      if ((value ?? '').trim().isEmpty) {
                                        return 'Please choose a course.';
                                      }
                                      return null;
                                    },
                                  );
                              final sectionDropdown =
                                  DropdownButtonFormField<String>(
                                    key: ValueKey(
                                      '${provider.selectedCourseId}-${provider.selectedSectionSelectionKey}',
                                    ),
                                    initialValue:
                                        provider.selectedSectionSelectionKey,
                                    isExpanded: true,
                                    decoration: _inputDecoration(
                                      'Choose a section',
                                    ),
                                    selectedItemBuilder: (context) {
                                      return provider.availableSections.map((
                                        course,
                                      ) {
                                        final label =
                                            provider.sectionLabelFor(course) ??
                                            _fallbackSectionLabel(course);
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList();
                                    },
                                    items: provider.availableSections
                                        .map(
                                          (course) => DropdownMenuItem<String>(
                                            value: course.selectionKey,
                                            child: Text(
                                              provider.sectionLabelFor(
                                                    course,
                                                  ) ??
                                                  _fallbackSectionLabel(course),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) async {
                                      if (value == null) {
                                        return;
                                      }
                                      final instructorId =
                                          context.read<AuthProvider>().userId ??
                                          'D001';
                                      await provider.selectSection(
                                        instructorId: instructorId,
                                        sectionId: value,
                                      );
                                    },
                                    validator: (value) {
                                      if ((value ?? '').trim().isEmpty) {
                                        return 'Please choose a section.';
                                      }
                                      return null;
                                    },
                                  );

                              if (useStackedSelectors) {
                                return Column(
                                  children: [
                                    courseDropdown,
                                    const SizedBox(height: 12),
                                    sectionDropdown,
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(flex: 3, child: courseDropdown),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: sectionDropdown),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          _SectionLabel('Title'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            decoration: _inputDecoration('Assignment title'),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Please enter a title.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _SectionLabel('Description'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: _inputDecoration(
                              'Describe what students need to do',
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Please enter a description.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _SectionLabel('Due Date'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: _inputDecoration('Select a due date'),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _dueDate == null
                                          ? 'Choose a due date'
                                          : DateFormat(
                                              'MMMM dd, yyyy',
                                            ).format(_dueDate!),
                                      style: TextStyle(
                                        color: _dueDate == null
                                            ? Colors.grey.shade600
                                            : const Color(0xff222222),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_showValidationErrors && _dueDate == null)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Please choose a due date.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 18),
                          _SectionLabel('Total Points'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pointsController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('100'),
                            validator: (value) {
                              final points = int.tryParse((value ?? '').trim());
                              if (points == null || points <= 0) {
                                return 'Enter a valid points value.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _SectionLabel('Attachment'),
                          const SizedBox(height: 8),
                          _AttachmentPicker(
                            attachment: _attachment,
                            onPick: _pickAttachment,
                            onRemove: () => setState(() => _attachment = null),
                          ),
                          if (provider.createError != null) ...[
                            const SizedBox(height: 16),
                            _InlineMessage(
                              message: provider.createError!,
                              color: Colors.red,
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kTeal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: provider.isCreating
                                  ? null
                                  : () => _submitForm(provider),
                              child: Text(
                                provider.isCreating
                                    ? 'Publishing...'
                                    : 'Publish Assignment',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: kTeal)),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickAttachment() async {
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.any,
    );

    if (!mounted || picked == null || picked.files.isEmpty) {
      return;
    }

    final file = picked.files.single;
    final extension = (file.extension ?? file.name.split('.').last)
        .toUpperCase();
    String? localPath;
    if (!kIsWeb) {
      localPath = file.path;
    }
    setState(() {
      _attachment = AssignmentAttachment(
        id: '',
        name: file.name,
        extensionLabel: extension,
        sizeLabel: _formatBytes(file.size),
        localPath: localPath,
        bytes: file.bytes,
      );
    });
  }

  Future<void> _submitForm(InstructorAssignmentsProvider provider) async {
    final formIsValid = _formKey.currentState?.validate() ?? false;
    if (!formIsValid ||
        _dueDate == null ||
        provider.selectedCourse == null ||
        provider.selectedSectionId == null) {
      setState(() => _showValidationErrors = true);
      return;
    }

    setState(() => _showValidationErrors = false);

    final request = CreateAssignmentRequest(
      courseId: provider.selectedCourse!.id,
      sectionId: provider.selectedSectionId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate!,
      maxScore: int.parse(_pointsController.text.trim()),
      isActive: true,
      attachment: _attachment,
    );

    final success = await provider.createAssignment(request);
    if (!mounted || !success) {
      return;
    }

    context.goNamed(
      'instructor-assignments-list',
      queryParameters: <String, String>{
        'courseId': provider.selectedCourse!.id,
        'sectionId': provider.selectedSectionId!,
      },
      extra: 'Assignment created successfully.',
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kTeal, width: 1.4),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) {
      return '0 B';
    }
    if (bytes < 1024) {
      return '$bytes B';
    }
    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xff333333),
      ),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
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
          color: _AddAssignmentPageState.kTeal,
          fontSize: radius * 0.45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AttachmentPicker extends StatelessWidget {
  const _AttachmentPicker({
    required this.attachment,
    required this.onPick,
    required this.onRemove,
  });

  final AssignmentAttachment? attachment;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (attachment == null) {
      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _AddAssignmentPageState.kTeal),
          foregroundColor: _AddAssignmentPageState.kTeal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPick,
        icon: const Icon(Icons.attach_file),
        label: const Text('Select File'),
      );
    }

    return InstructorSurfaceCard(
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xffe8f8f7),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              attachment!.extensionLabel,
              style: const TextStyle(
                color: _AddAssignmentPageState.kTeal,
                fontSize: 11,
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
                  attachment!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  attachment!.sizeLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InstructorSurfaceCard(
      child: Text(message, style: TextStyle(color: color)),
    );
  }
}
