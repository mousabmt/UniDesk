import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/course_management/providers/instructor_courses_provider.dart';
import 'package:unidesk/features/entities/instructor/course_management/widgets/course_file_list_item.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_surface_card.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_wave_header_card.dart';

class AddFilesPage extends StatefulWidget {
  const AddFilesPage({
    super.key,
    this.initialCourseId,
  });

  final String? initialCourseId;

  @override
  State<AddFilesPage> createState() => _AddFilesPageState();
}

class _AddFilesPageState extends State<AddFilesPage> {
  InstructorCourseFileCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final instructorId = context.read<AuthProvider>().userId ?? 'D001';
      context.read<InstructorCoursesProvider>().loadIfNeeded(
        instructorId: instructorId,
        preferredCourseId: widget.initialCourseId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final instructorName = context.select<AuthProvider, String>(
      (auth) => auth.user?['name']?.toString() ?? 'Instructor',
    );

    return ColoredBox(
      color: const Color(0xfff0f4f8),
      child: SafeArea(
        bottom: false,
        child: Consumer<InstructorCoursesProvider>(
          builder: (context, provider, _) {
            final selectedCourse = provider.selectedCourse;
            final files = provider.visibleFiles.where((file) {
              if (_selectedCategory == null) {
                return true;
              }
              return file.category == _selectedCategory;
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                InstructorWaveHeaderCard(
                  compact: MediaQuery.sizeOf(context).width < 600,
                  compactBreakpoint: 360,
                  minHeightCompact: 150,
                  minHeightRegular: 120,
                  waveWidthCompact: 110,
                  waveWidthRegular: 120,
                  leadingCompact: _InstructorInitialsAvatar(name: instructorName, radius: 36),
                  leadingRegular: _InstructorInitialsAvatar(name: instructorName, radius: 40),
                  content: _FilesGreetingText(
                    instructorName: instructorName,
                    selectedCourseLabel: selectedCourse?.displayLabel ?? 'Choose a course',
                  ),
                ),
                const SizedBox(height: 20),
                if (provider.isCoursesLoading && provider.courses.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (provider.coursesError != null && provider.courses.isEmpty)
                  _InlineError(message: provider.coursesError!)
                else ...[
                  const Text(
                    'Select Course',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  InstructorSurfaceCard(
                    radius: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCourse?.id,
                        hint: const Text('Choose a course'),
                        isExpanded: true,
                        items: provider.courses
                            .map(
                              (course) => DropdownMenuItem<String>(
                                value: course.id,
                                child: Text(course.displayLabel),
                              ),
                            )
                            .toList(),
                        onChanged: (value) async {
                          if (value == null) {
                            return;
                          }
                          final instructorId =
                              context.read<AuthProvider>().userId ?? 'D001';
                          await provider.selectCourse(
                            instructorId: instructorId,
                            courseId: value,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedCourse != null)
                    _CourseMetaCard(
                      term: selectedCourse.term,
                      sectionLabel: selectedCourse.sectionLabel,
                      studentsEnrolled: selectedCourse.studentsEnrolled,
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'File Category',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                        _CategoryRow(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                  const SizedBox(height: 20),
                  _UploadDropzone(
                    isUploading: provider.isUploading,
                    onUploadPressed: selectedCourse == null
                        ? null
                        : () => _pickAndUploadFile(
                              context,
                              instructorId:
                                  context.read<AuthProvider>().userId ?? 'D001',
                              provider: provider,
                            ),
                  ),
                  if (provider.uploadError != null) ...[
                    const SizedBox(height: 12),
                    _InlineError(message: provider.uploadError!),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Files',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: selectedCourse == null
                            ? null
                            : () => context.push(
                                  '/instructor/course-details?courseId=${selectedCourse.id}',
                                ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(color: Color(0xff0bb4b1)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (provider.isDetailsLoading && provider.currentCourseDetails == null)
                    const Center(child: CircularProgressIndicator())
                  else if (provider.detailsError != null &&
                      provider.currentCourseDetails == null)
                    _InlineError(message: provider.detailsError!)
                  else if (files.isEmpty)
                    const InstructorSurfaceCard(
                      child: Text(
                        'No files match the selected category yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    InstructorSurfaceCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: List.generate(files.length, (index) {
                          final file = files[index];
                          return Column(
                            children: [
                              CourseFileListItem(file: file),
                              if (index < files.length - 1)
                                const Divider(height: 1, indent: 16, endIndent: 16),
                            ],
                          );
                        }),
                      ),
                    ),
                ],
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFile(
    BuildContext context, {
    required String instructorId,
    required InstructorCoursesProvider provider,
  }) async {
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
      type: FileType.any,
    );

    if (!mounted || picked == null || picked.files.isEmpty) {
      return;
    }

    final selectedFile = picked.files.single;
    final result = await showDialog<_UploadRequest>(
      context: context,
      builder: (_) => _UploadFileDialog(file: selectedFile),
    );

    if (!mounted || result == null) {
      return;
    }

    final success = await provider.uploadCourseFile(
      instructorId: instructorId,
      fileName: result.fileName,
      category: result.category,
      extensionLabel: result.extensionLabel,
      localPath: selectedFile.path,
    );

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'File uploaded to ${provider.selectedCourse?.displayLabel ?? 'the selected course'}.'
              : (provider.uploadError ?? 'Upload failed. Please try again.'),
        ),
      ),
    );
  }
}

class _FilesGreetingText extends StatelessWidget {
  const _FilesGreetingText({
    required this.instructorName,
    required this.selectedCourseLabel,
  });

  final String instructorName;
  final String selectedCourseLabel;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Hello $instructorName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage uploads for $selectedCourseLabel.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}

class _InstructorInitialsAvatar extends StatelessWidget {
  const _InstructorInitialsAvatar({
    required this.name,
    required this.radius,
  });

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
          color: const Color(0xff0bb4b1),
          fontSize: radius * 0.45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CourseMetaCard extends StatelessWidget {
  const _CourseMetaCard({
    required this.term,
    required this.sectionLabel,
    required this.studentsEnrolled,
  });

  final String term;
  final String sectionLabel;
  final int studentsEnrolled;

  @override
  Widget build(BuildContext context) {
    return InstructorSurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: _MetaColumn(label: 'Term', value: term),
          ),
          Expanded(
            child: _MetaColumn(label: 'Section', value: sectionLabel),
          ),
          Expanded(
            child: _MetaColumn(
              label: 'Students',
              value: studentsEnrolled.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaColumn extends StatelessWidget {
  const _MetaColumn({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final InstructorCourseFileCategory? selectedCategory;
  final ValueChanged<InstructorCourseFileCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final categories = <MapEntry<String, InstructorCourseFileCategory?>>[
      const MapEntry('All', null),
      const MapEntry('Lecture', InstructorCourseFileCategory.lecture),
      const MapEntry('Exam', InstructorCourseFileCategory.exam),
    ];

    return Row(
      children: List.generate(categories.length, (index) {
        final item = categories[index];
        final isSelected = item.value == selectedCategory;
        return Expanded(
          child: GestureDetector(
            onTap: () => onCategorySelected(item.value),
            child: Container(
              margin: EdgeInsets.only(right: index < categories.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xff0bb4b1) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                item.key,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _UploadDropzone extends StatelessWidget {
  const _UploadDropzone({
    required this.onUploadPressed,
    required this.isUploading,
  });

  final VoidCallback? onUploadPressed;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff0bb4b1), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            size: 60,
            color: Color(0xff0bb4b1),
          ),
          const SizedBox(height: 10),
          const Text(
            'Browse or drag & drop files here',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0bb4b1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.upload, color: Colors.white),
              label: Text(
                isUploading ? 'Uploading...' : 'Upload File',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: isUploading ? null : onUploadPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadRequest {
  const _UploadRequest({
    required this.fileName,
    required this.category,
    required this.extensionLabel,
  });

  final String fileName;
  final InstructorCourseFileCategory category;
  final String extensionLabel;
}

class _UploadFileDialog extends StatefulWidget {
  const _UploadFileDialog({required this.file});

  final PlatformFile file;

  @override
  State<_UploadFileDialog> createState() => _UploadFileDialogState();
}

class _UploadFileDialogState extends State<_UploadFileDialog> {
  InstructorCourseFileCategory _category = InstructorCourseFileCategory.lecture;

  @override
  Widget build(BuildContext context) {
    final extensionLabel = (widget.file.extension ?? 'FILE').toUpperCase();
    final fileName = widget.file.name.trim().isEmpty
        ? 'selected_file.${extensionLabel.toLowerCase()}'
        : widget.file.name.trim();

    return AlertDialog(
      title: const Text('Choose File Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              extensionLabel,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<InstructorCourseFileCategory>(
              value: _category,
              items: const [
                DropdownMenuItem(
                  value: InstructorCourseFileCategory.lecture,
                  child: Text('Lecture'),
                ),
                DropdownMenuItem(
                  value: InstructorCourseFileCategory.exam,
                  child: Text('Exam'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            const Text(
              'The selected file will be added to the current course using this category.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(
              _UploadRequest(
                fileName: fileName,
                category: _category,
                extensionLabel: extensionLabel,
              ),
            );
          },
          child: const Text('Upload'),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return InstructorSurfaceCard(
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
