import 'package:flutter/material.dart';

class StudentSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color? borderColor;
  final double blurRadius;
  final Offset shadowOffset;
  final Color shadowColor;

  const StudentSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.color = Colors.white,
    this.borderColor,
    this.blurRadius = 4,
    this.shadowOffset = const Offset(0, 2),
    this.shadowColor = const Color(0x12000000),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: blurRadius,
            offset: shadowOffset,
          ),
        ],
      ),
      child: child,
    );
  }
}
