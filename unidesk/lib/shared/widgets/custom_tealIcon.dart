import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
// custom_tealIcon.dart
class TealIconBox extends StatelessWidget {
  final Widget child;
  const TealIconBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }
}