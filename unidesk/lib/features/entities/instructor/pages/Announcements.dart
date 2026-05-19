import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/announcements/models/create_announcement_request.dart';
import 'package:unidesk/features/entities/instructor/announcements/models/instructor_announcement.dart';
import 'package:unidesk/features/entities/instructor/announcements/providers/instructor_announcements_provider.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_surface_card.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_wave_header_card.dart';
import 'package:unidesk/features/language/langProvider.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({
    super.key,
    this.initialCourseId,
    this.initialSectionId,
  });

  final String? initialCourseId;
  final String? initialSectionId;

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  static const Color kTeal = Color(0xff0bb4b1);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType =
      InstructorAnnouncementsProvider.defaultAnnouncementType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncRouteState());
  }

  @override
  void didUpdateWidget(covariant AnnouncementsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCourseId != widget.initialCourseId ||
        oldWidget.initialSectionId != widget.initialSectionId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncRouteState());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final compact = MediaQuery.sizeOf(context).width < 640;
    final instructorName = context.select<AuthProvider, String>(
      (auth) =>
          auth.user?['name']?.toString() ??
          lang.translate('instructor_fallback_name'),
    );

    return Directionality(
      textDirection: lang.isArabic
          ? ui.TextDirection.rtl
          : ui.TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xfff0f4f8),
        child: SafeArea(
          bottom: false,
          child: Consumer<InstructorAnnouncementsProvider>(
            builder: (context, provider, _) {
              final selectedCourse = provider.selectedCourse;

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
                      content: _AnnouncementsHeader(
                        lang: lang,
                        course: selectedCourse,
                        sectionLabel: selectedCourse == null
                            ? null
                            : provider.sectionLabelFor(selectedCourse),
                        announcementCount: provider.announcements.length,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (provider.isCoursesLoading && provider.courses.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (provider.coursesError != null &&
                        provider.courses.isEmpty)
                      _PageStateMessage(
                        message: provider.coursesError!,
                        actionLabel: lang.translate('announcement_retry'),
                        onRetry: _refreshPage,
                      )
                    else ...[
                      _CourseSectionSelector(
                        lang: lang,
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
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final singleColumn = constraints.maxWidth < 820;
                          final form = _AnnouncementForm(
                            formKey: _formKey,
                            titleController: _titleController,
                            descriptionController: _descriptionController,
                            selectedType: _selectedType,
                            lang: lang,
                            provider: provider,
                            onTypeChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() => _selectedType = value);
                            },
                            onSubmit: () => _submitForm(provider, lang),
                          );
                          final list = _AnnouncementsList(
                            lang: lang,
                            provider: provider,
                            onRetry: _refreshPage,
                          );

                          if (singleColumn) {
                            return Column(
                              children: [
                                form,
                                const SizedBox(height: 20),
                                list,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: form),
                              const SizedBox(width: 20),
                              Expanded(flex: 6, child: list),
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
      ),
    );
  }

  Future<void> _syncRouteState() async {
    if (!mounted) {
      return;
    }
    final instructorId = context.read<AuthProvider>().userId ?? 'D001';
    await context.read<InstructorAnnouncementsProvider>().loadIfNeeded(
      instructorId: instructorId,
      preferredCourseId: widget.initialCourseId,
      preferredSectionId: widget.initialSectionId,
    );
  }

  Future<void> _refreshPage() async {
    if (!mounted) {
      return;
    }
    final instructorId = context.read<AuthProvider>().userId ?? 'D001';
    final provider = context.read<InstructorAnnouncementsProvider>();
    await provider.refresh(
      instructorId: instructorId,
      preferredCourseId: provider.selectedCourseId ?? widget.initialCourseId,
      preferredSectionId: provider.selectedSectionId ?? widget.initialSectionId,
    );
  }

  Future<void> _submitForm(
    InstructorAnnouncementsProvider provider,
    LangProvider lang,
  ) async {
    provider.clearCreateError();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final selectedCourse = provider.selectedCourse;
    final selectedSectionId = provider.selectedSectionId;
    if (selectedCourse == null || selectedSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.translate('announcement_select_target'))),
      );
      return;
    }

    final success = await provider.createAnnouncement(
      CreateAnnouncementRequest(
        courseId: selectedCourse.id,
        sectionId: selectedSectionId,
        title: _titleController.text.trim(),
        type: _selectedType,
        description: _descriptionController.text.trim(),
      ),
    );
    if (!mounted || !success) {
      return;
    }

    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    setState(
      () => _selectedType =
          InstructorAnnouncementsProvider.defaultAnnouncementType,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(lang.translate('announcement_created'))),
    );
  }
}

class _AnnouncementsHeader extends StatelessWidget {
  const _AnnouncementsHeader({
    required this.lang,
    required this.course,
    required this.sectionLabel,
    required this.announcementCount,
  });

  final LangProvider lang;
  final InstructorManagedCourse? course;
  final String? sectionLabel;
  final int announcementCount;

  @override
  Widget build(BuildContext context) {
    final courseLabel = course?.displayLabel.trim();
    final countLabel =
        '$announcementCount ${lang.translate('announcements_subtitle_count')}';
    final subtitle = courseLabel == null || courseLabel.isEmpty
        ? lang.translate('announcements_subtitle_empty')
        : '$countLabel - $courseLabel${sectionLabel == null ? '' : ' - $sectionLabel'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          lang.translate('announcements_title'),
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

class _CourseSectionSelector extends StatelessWidget {
  const _CourseSectionSelector({
    required this.lang,
    required this.provider,
    required this.onCourseChanged,
    required this.onSectionChanged,
  });

  final LangProvider lang;
  final InstructorAnnouncementsProvider provider;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<String?> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useStackedSelectors = constraints.maxWidth < 560;
        final courseSelector = _SelectorCard(
          label: lang.translate('announcement_course'),
          value: provider.selectedCourseGroupKey,
          hint: lang.translate('announcement_choose_course'),
          items: provider.availableCourses
              .map(
                (course) => DropdownMenuItem<String>(
                  value: provider.courseSelectionValueFor(course),
                  child: Text(
                    course.displayLabel.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          selectedLabels: provider.availableCourses
              .map((course) => course.displayLabel.trim())
              .toList(),
          onChanged: onCourseChanged,
        );
        final sectionSelector = _SelectorCard(
          label: lang.translate('announcement_section'),
          value: provider.selectedSectionSelectionKey,
          hint: lang.translate('announcement_choose_section'),
          items: provider.availableSections
              .map(
                (course) => DropdownMenuItem<String>(
                  value: course.selectionKey,
                  child: Text(
                    provider.sectionLabelFor(course) ??
                        _fallbackSectionLabel(lang, course),
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
                    _fallbackSectionLabel(lang, course),
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

  static String _fallbackSectionLabel(
    LangProvider lang,
    InstructorManagedCourse course,
  ) {
    final section = lang.translate('section');
    if (course.sectionId.isNotEmpty) {
      return '$section ${course.sectionId}';
    }
    if (course.lectureId.isNotEmpty) {
      return '$section ${course.lectureId}';
    }
    return section;
  }
}

class _SelectorCard extends StatelessWidget {
  const _SelectorCard({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.selectedLabels,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final List<String> selectedLabels;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InstructorSurfaceCard(
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          DropdownButtonHideUnderline(
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
        ],
      ),
    );
  }
}

class _AnnouncementForm extends StatelessWidget {
  const _AnnouncementForm({
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.selectedType,
    required this.lang,
    required this.provider,
    required this.onTypeChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String selectedType;
  final LangProvider lang;
  final InstructorAnnouncementsProvider provider;
  final ValueChanged<String?> onTypeChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return InstructorSurfaceCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.translate('announcement_form_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            _SectionLabel(lang.translate('announcement_type')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              isExpanded: true,
              decoration: _inputDecoration(''),
              items: InstructorAnnouncementsProvider.announcementTypes
                  .map(
                    (type) => DropdownMenuItem<String>(
                      value: type.value,
                      child: Row(
                        children: [
                          Icon(type.icon, color: type.color, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lang.translate(type.labelKey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: provider.isCreating ? null : onTypeChanged,
            ),
            const SizedBox(height: 18),
            _SectionLabel(lang.translate('announcement_title_label')),
            const SizedBox(height: 8),
            TextFormField(
              controller: titleController,
              enabled: !provider.isCreating,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                lang.translate('announcement_title_hint'),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return lang.translate('announcement_required_title');
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _SectionLabel(lang.translate('announcement_description_label')),
            const SizedBox(height: 8),
            TextFormField(
              controller: descriptionController,
              enabled: !provider.isCreating,
              minLines: 4,
              maxLines: 6,
              decoration: _inputDecoration(
                lang.translate('announcement_description_hint'),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return lang.translate('announcement_required_description');
                }
                return null;
              },
            ),
            if (provider.createError != null) ...[
              const SizedBox(height: 14),
              Text(
                provider.createError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isCreating ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AnnouncementsPageState.kTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: provider.isCreating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add, size: 18),
                label: Text(
                  provider.isCreating
                      ? lang.translate('announcement_publishing')
                      : lang.translate('announcement_publish'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText.isEmpty ? null : hintText,
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
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: _AnnouncementsPageState.kTeal,
          width: 1.4,
        ),
      ),
    );
  }
}

class _AnnouncementsList extends StatelessWidget {
  const _AnnouncementsList({
    required this.lang,
    required this.provider,
    required this.onRetry,
  });

  final LangProvider lang;
  final InstructorAnnouncementsProvider provider;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.translate('announcement_recent_title'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InstructorSurfaceCard(padding: EdgeInsets.zero, child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (provider.isAnnouncementsLoading && provider.announcements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.announcementsError != null && provider.announcements.isEmpty) {
      return _PageStateMessage(
        message:
            '${lang.translate('announcement_load_failed')}: ${provider.announcementsError!}',
        actionLabel: lang.translate('announcement_retry'),
        onRetry: onRetry,
      );
    }

    if (provider.announcements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          lang.translate('announcement_empty'),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: List.generate(provider.announcements.length, (index) {
        final announcement = provider.announcements[index];
        return Column(
          children: [
            _AnnouncementTile(
              announcement: announcement,
              type: provider.typeFor(announcement.type),
              lang: lang,
            ),
            if (index < provider.announcements.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        );
      }),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({
    required this.announcement,
    required this.type,
    required this.lang,
  });

  final InstructorAnnouncement announcement;
  final InstructorAnnouncementType type;
  final LangProvider lang;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: type.backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(type.icon, color: type.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        announcement.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff222222),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TypeBadge(
                      label: lang.translate(type.labelKey),
                      type: type,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  announcement.previewText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff666666),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _formatDate(lang, announcement.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(LangProvider lang, DateTime? value) {
    if (value == null) {
      return lang.translate('announcement_date_unavailable');
    }
    final locale = lang.isArabic ? 'ar' : 'en';
    return DateFormat.yMMMd(locale).add_jm().format(value.toLocal());
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.type});

  final String label;
  final InstructorAnnouncementType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: type.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: type.color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name, required this.radius});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length > 1
        ? '${parts.first[0]}${parts.last[0]}'
        : (parts.isEmpty || parts.first.isEmpty ? 'I' : parts.first[0]);

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xffe0f7f6),
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: _AnnouncementsPageState.kTeal,
          fontSize: radius * 0.45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
