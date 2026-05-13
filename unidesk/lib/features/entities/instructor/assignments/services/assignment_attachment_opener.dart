import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_attachment.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentAttachmentOpenResult {
  const AssignmentAttachmentOpenResult({
    required this.didOpen,
    this.message = '',
  });

  final bool didOpen;
  final String message;
}

class AssignmentAttachmentOpener {
  const AssignmentAttachmentOpener();

  Future<AssignmentAttachmentOpenResult> open(
    AssignmentAttachment attachment,
  ) async {
    if (attachment.hasLocalFile) {
      final localPath = attachment.localPath!;
      final exists = await File(localPath).exists();
      if (!exists) {
        if (attachment.hasRemoteUrl) {
          return _openRemoteTarget(attachment.url!);
        }
        return const AssignmentAttachmentOpenResult(
          didOpen: false,
          message: 'The selected file is no longer available on this device.',
        );
      }

      return _openTarget(localPath);
    }

    if (attachment.hasRemoteUrl) {
      return _openRemoteTarget(attachment.url!);
    }

    return const AssignmentAttachmentOpenResult(
      didOpen: false,
      message: 'This attachment is not available yet.',
    );
  }

  Future<AssignmentAttachmentOpenResult> _openTarget(String target) async {
    try {
      final result = await OpenFilex.open(target);
      if (result.type == ResultType.done) {
        return const AssignmentAttachmentOpenResult(didOpen: true);
      }

      return AssignmentAttachmentOpenResult(
        didOpen: false,
        message: result.message.isNotEmpty
            ? result.message
            : 'Unable to open the selected attachment.',
      );
    } catch (_) {
      return const AssignmentAttachmentOpenResult(
        didOpen: false,
        message: 'Unable to open the selected attachment on this device.',
      );
    }
  }

  Future<AssignmentAttachmentOpenResult> _openRemoteTarget(
    String target,
  ) async {
    final uri = Uri.tryParse(target);
    if (uri == null) {
      return const AssignmentAttachmentOpenResult(
        didOpen: false,
        message: 'The attachment link is invalid.',
      );
    }

    try {
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank',
      );
      if (didLaunch) {
        return const AssignmentAttachmentOpenResult(didOpen: true);
      }

      return const AssignmentAttachmentOpenResult(
        didOpen: false,
        message: 'Unable to open the selected attachment.',
      );
    } catch (_) {
      return const AssignmentAttachmentOpenResult(
        didOpen: false,
        message: 'Unable to open the selected attachment link.',
      );
    }
  }
}
