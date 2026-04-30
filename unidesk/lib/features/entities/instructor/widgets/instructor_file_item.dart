import 'package:flutter/material.dart';

class InstructorFileItem extends StatelessWidget {
  final Color color;
  final String label;
  final String name;
  final String date;
  final String size;
  final EdgeInsetsGeometry padding;

  const InstructorFileItem({
    super.key,
    required this.color,
    required this.label,
    required this.name,
    required this.date,
    required this.size,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 380;
          final metaText = Text(
            '$date - $size',
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InstructorFileBadge(color: color, label: label),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.more_vert, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 8),
                metaText,
              ],
            );
          }

          return Row(
            children: [
              InstructorFileBadge(color: color, label: label),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    metaText,
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          );
        },
      ),
    );
  }
}

class InstructorFileBadge extends StatelessWidget {
  final Color color;
  final String label;

  const InstructorFileBadge({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
