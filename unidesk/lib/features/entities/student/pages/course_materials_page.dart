import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_file_item.dart';
import 'package:unidesk/features/entities/student/materials/models/student_material_course_option.dart';
import 'package:unidesk/features/entities/student/materials/models/student_course_material.dart';
import 'package:unidesk/features/entities/student/materials/providers/student_materials_provider.dart';
import 'package:unidesk/features/entities/student/providers_std/course_provider.dart';
import 'package:unidesk/features/entities/student/widgets/student_refresh_status.dart';
import 'package:unidesk/features/language/langProvider.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentCourseMaterialsPage extends StatefulWidget {
  const StudentCourseMaterialsPage({super.key});

  @override
  State<StudentCourseMaterialsPage> createState() =>
      _StudentCourseMaterialsPageState();
}

class _StudentCourseMaterialsPageState
    extends State<StudentCourseMaterialsPage> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = context.read<AuthProvider>().token;
      final coursesProvider = context.read<CoursesProvider>();
      final materialsProvider = context.read<StudentMaterialsProvider>();

      await coursesProvider.loadIfNeeded(token: token);
      if (!mounted) {
        return;
      }

      await materialsProvider.loadIfNeeded(
        courseOptions: _buildCourseOptions(coursesProvider.courses ?? const []),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final coursesProvider = context.watch<CoursesProvider>();

    return Directionality(
      textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        color: const Color(0xfff9fbfc),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          bottom: false,
          child: Consumer<StudentMaterialsProvider>(
            builder: (context, materialsProvider, _) {
              final courses = coursesProvider.courses ?? const [];
              final courseOptions = _buildCourseOptions(courses);
              final selectedCourseSelectionValue =
                  materialsProvider.selectedCourseSelectionValue;

              if (coursesProvider.isLoading && courseOptions.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (coursesProvider.error != null && courseOptions.isEmpty) {
                return _CenteredState(
                  icon: Icons.error_outline,
                  title: 'Unable to load courses',
                  message: coursesProvider.error!,
                  actionLabel: lang.translate('retry'),
                  onPressed: () async {
                    final token = context.read<AuthProvider>().token;
                    await coursesProvider.refresh(token: token);
                    if (!context.mounted) {
                      return;
                    }
                    await context.read<StudentMaterialsProvider>().refresh(
                      courseOptions: _buildCourseOptions(
                        coursesProvider.courses ?? const [],
                      ),
                    );
                  },
                );
              }

              if (courseOptions.isEmpty) {
                return const _CenteredState(
                  icon: Icons.menu_book_outlined,
                  title: 'No courses available',
                  message: 'Your enrolled courses will appear here.',
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.translate('files'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'View the materials uploaded for your selected course.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _CourseDropdown(
                      courseOptions: courseOptions,
                      value: selectedCourseSelectionValue,
                      onChanged: (selectionValue) async {
                        await context
                            .read<StudentMaterialsProvider>()
                            .selectCourse(
                              selectionValue: selectionValue,
                              courseOptions: courseOptions,
                            );
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildBody(
                        context: context,
                        provider: materialsProvider,
                        courseOptions: courseOptions,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _refreshMaterials({
    required List<StudentMaterialCourseOption> courseOptions,
  }) async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await context.read<StudentMaterialsProvider>().refresh(
        courseOptions: courseOptions,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Widget _buildBody({
    required BuildContext context,
    required StudentMaterialsProvider provider,
    required List<StudentMaterialCourseOption> courseOptions,
  }) {
    if (provider.isLoading && provider.materials.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.materials.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _refreshMaterials(courseOptions: courseOptions),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            StudentRefreshStatus(
              isRefreshing: _isRefreshing,
              message: 'Refreshing materials...',
              padding: EdgeInsets.zero,
            ),
            SizedBox(
              height: 420,
              child: _CenteredState(
                icon: Icons.cloud_off_outlined,
                title: 'Unable to load materials',
                message: provider.error!,
                actionLabel: 'Retry',
                onPressed: () => provider.refresh(courseOptions: courseOptions),
              ),
            ),
          ],
        ),
      );
    }

    if (provider.materials.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _refreshMaterials(courseOptions: courseOptions),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            StudentRefreshStatus(
              isRefreshing: _isRefreshing,
              message: 'Refreshing materials...',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(
              height: 420,
              child: _CenteredState(
                icon: Icons.folder_open_outlined,
                title: 'No materials yet',
                message: 'Course materials will show up here when uploaded.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshMaterials(courseOptions: courseOptions),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.materials.length + 1,
        separatorBuilder: (_, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            return StudentRefreshStatus(
              isRefreshing: _isRefreshing,
              message: 'Refreshing materials...',
              padding: EdgeInsets.zero,
            );
          }

          final material = provider.materials[index - 1];
          return _MaterialListItem(
            material: material,
            onTap: () => _openMaterial(context, material),
          );
        },
      ),
    );
  }

  Future<void> _openMaterial(
    BuildContext context,
    StudentCourseMaterial material,
  ) async {
    if (!material.hasDownloadUrl) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This material has no download link yet.'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(material.downloadUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The material link is invalid.')),
      );
      return;
    }

    try {
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank',
      );
      if (!didLaunch && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open the selected material.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the material link.')),
        );
      }
    }
  }

  List<StudentMaterialCourseOption> _buildCourseOptions(
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
}

class _CourseDropdown extends StatelessWidget {
  const _CourseDropdown({
    required this.courseOptions,
    required this.value,
    required this.onChanged,
  });

  final List<StudentMaterialCourseOption> courseOptions;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final itemValues = courseOptions
        .map((option) => option.selectionValue)
        .where((selectionValue) => selectionValue.isNotEmpty)
        .toSet();
    final safeValue = value != null && itemValues.contains(value)
        ? value
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffdbe4ec)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: safeValue,
          hint: const Text('Select course'),
          items: courseOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option.selectionValue,
              child: Text(option.displayLabel, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _MaterialListItem extends StatelessWidget {
  const _MaterialListItem({required this.material, required this.onTap});

  final StudentCourseMaterial material;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = material.uploadedAtLabel.isNotEmpty
        ? material.uploadedAtLabel
        : 'Recently uploaded';
    final sizeLabel = material.sizeLabel.isNotEmpty
        ? material.sizeLabel
        : 'Unknown size';
    final uploadedBy = material.uploadedBy.isNotEmpty
        ? material.uploadedBy
        : 'Unknown uploader';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InstructorFileItem(
          color: material.badgeColor,
          label: material.extensionLabel,
          name: material.name,
          date: dateLabel,
          size: sizeLabel,
          padding: const EdgeInsets.symmetric(vertical: 12),
          onTap: onTap,
          isInteractive: material.hasDownloadUrl,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Uploaded by $uploadedBy${material.fileType.isNotEmpty ? ' • ${material.fileType}' : ''}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onPressed, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
