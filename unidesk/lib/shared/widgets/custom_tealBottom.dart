import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class TealButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const TealButton({super.key, required this.label, required this.onTap});
 
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
