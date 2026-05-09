import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_file_item.dart';
import 'package:url_launcher/url_launcher.dart';

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
      isInteractive: file.hasLocalFile || file.hasRemoteFile,
      onTap: () => _handleTap(context),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    if (!file.hasLocalFile && !file.hasRemoteFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This file is available in the course list, but no local device file is attached yet.',
          ),
        ),
      );
      return;
    }

    if (file.hasLocalFile) {
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

      await _openTarget(context, localPath);
      return;
    }

    await _openRemoteTarget(context, file.remoteUrl!);
  }

  Future<void> _openTarget(BuildContext context, String target) async {
    OpenResult result;
    try {
      result = await OpenFilex.open(target);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open the selected file on this device.'),
          ),
        );
      }
      return;
    }

    if (context.mounted && result.type != ResultType.done) {
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

  Future<void> _openRemoteTarget(BuildContext context, String target) async {
    final uri = Uri.tryParse(target);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The file link is invalid.')),
        );
      }
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
          const SnackBar(content: Text('Unable to open the selected file.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open the selected file link.'),
          ),
        );
      }
    }
  }
}
