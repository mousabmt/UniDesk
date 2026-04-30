import 'package:flutter/material.dart';

class InstructorSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;

  const InstructorSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class InstructorMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final bool compact;

  const InstructorMetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return InstructorSurfaceCard(
      radius: 14,
      padding: EdgeInsets.symmetric(
        vertical: compact ? 16 : 18,
        horizontal: compact ? 12 : 8,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
