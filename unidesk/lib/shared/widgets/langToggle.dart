import 'package:flutter/material.dart';
import 'package:provider/provider.dart';    // ← add this
import '../../features/language/langProvider.dart';
import '../../../core/constants/colors.dart';
class LangToggle extends StatelessWidget {
  const LangToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LangProvider>(context);

    return TextButton(
      onPressed: lang.toggleLanguage,
      child: Text(
        lang.isArabic ? 'EN' : 'ع',
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}