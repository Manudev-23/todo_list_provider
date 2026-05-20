import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_list_provider/app/services/user_service.dart';

class AppAuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final UserService _userService;
  StreamSubscription? _authSubscription;

  User? _user;

  AppAuthProvider({
    required FirebaseAuth firebaseAuth,
    required UserService userService,
  })  : _firebaseAuth = firebaseAuth,
        _userService = userService {
    _loadListener();
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  String? get userEmail => _user?.email;

  void _loadListener() {
    _authSubscription = _firebaseAuth.userChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> logout() async {
    await _userService.logout();
  }

  Future<void> login(String email, String password) async {
    await _userService.login(email, password);
  }

  Future<void> googleLogin() async {
    await _userService.googleLogin();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
