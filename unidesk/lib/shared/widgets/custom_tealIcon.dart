import 'package:flutter/material.dart';

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
        color: const Color(0xFF1A7A6E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }
}