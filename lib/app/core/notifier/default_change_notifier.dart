import 'package:flutter/foundation.dart';

class DefaultChangeNotifier extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  bool _success = false;

  bool get loading => _loading;
  String? get error => _error;
  bool get hasError => _error != null && _error!.isNotEmpty;
  bool get success => _success;

  void showLoading() {
    _loading = true;
    notifyListeners();
  }
  
  void hideLoading() {
    _loading = false;
    notifyListeners();
  }

  void setSuccess() {
    _success = true;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void resetState() {
    _loading = false;
    _error = null;
    _success = false;
    notifyListeners();
  }
}