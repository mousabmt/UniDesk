import 'package:flutter/material.dart';
import 'package:unidesk/core/services/mockApi.dart';

class AnnoucProvider extends ChangeNotifier {
  List<Map<String, dynamic>>? _annouc;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>>? get ads => _annouc;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIfNeeded() async {
    if (_annouc != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _annouc = await MockApi.getAds();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> refresh() async {
  _annouc = null; // clear cache
  await loadIfNeeded();
}
}