import 'package:flutter/material.dart';

import '../../../../shared/widgets/responsive_layout.dart';

class StudentHomeWelcomeText extends StatelessWidget {
  final String name;
  final String subtitle;
  final String dateLabel;

  const StudentHomeWelcomeText({
    super.key,
    required this.name,
    required this.subtitle,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final compact = ResponsiveLayout.isCompact(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}
