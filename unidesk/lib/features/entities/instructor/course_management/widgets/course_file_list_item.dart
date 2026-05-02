import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_file_item.dart';

class CourseFileListItem extends StatelessWidget {
  const CourseFileListItem({
    super.key,
    required this.file,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final InstructorCourseFile file;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return InstructorFileItem(
      color: file.badgeColor,
      label: file.extensionLabel,
      name: file.name,
      date: file.uploadedAtLabel,
      size: file.sizeLabel,
      padding: padding,
      isInteractive: file.hasLocalFile,
      onTap: () => _handleTap(context),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    if (!file.hasLocalFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This file is available in the course list, but no local device file is attached yet.',
          ),
        ),
      );
      return;
    }

    final localPath = file.localPath!;
    final exists = await File(localPath).exists();
    if (!context.mounted) {
      return;
    }

    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The selected file is no longer available on this device.',
          ),
        ),
      );
      return;
    }

    OpenResult result;
    try {
      result = await OpenFilex.open(localPath);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open the selected file on this device.'),
        ),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message.isNotEmpty
                ? result.message
                : 'Unable to open the selected file.',
          ),
        ),
      );
    }
  }
}
