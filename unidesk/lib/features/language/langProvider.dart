import 'package:flutter/material.dart';
import '../../../core/constants/strings.dart';

class LangProvider extends ChangeNotifier {
  String _currentLang = 'en';

  String get currentLang => _currentLang;

  // like isRTL in JS
  bool get isArabic => _currentLang == 'ar';

  void toggleLanguage() {
    _currentLang = isArabic ? 'en' : 'ar';
    notifyListeners(); // like setState but global
  }

  // helper to get any string
  String translate(String key) {
    return AppStrings.translations[_currentLang]?[key] ?? key;
  }
}