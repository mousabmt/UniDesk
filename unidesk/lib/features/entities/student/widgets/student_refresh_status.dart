import 'package:flutter/material.dart';

class StudentRefreshStatus extends StatelessWidget {
  const StudentRefreshStatus({
    super.key,
    required this.isRefreshing,
    this.message = 'Refreshing...',
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final bool isRefreshing;
  final String message;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isRefreshing
          ? Padding(
              key: const ValueKey('student-refresh-status'),
              padding: padding,
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
