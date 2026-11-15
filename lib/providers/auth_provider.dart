import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? user;
  bool loading = true;
  bool _busy = false;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((fu) async {
      if (_busy) return;
      user = fu == null ? null : await AuthService.profile(fu.uid);
      loading = false;
      notifyListeners();
    });
  }

  Future<void> login(String email, String pw, {required bool admin}) async {
    _busy = true;
    try {
      final cred = await AuthService.signIn(email, pw);
      final p = await AuthService.profile(cred.user!.uid);
      if (p == null || p.isAdmin != admin) {
        await AuthService.signOut();
        throw 'This account cannot log in here. Choose the correct login option.';
      }
      user = p;
    } finally {
      _busy = false;
    }
    notifyListeners();
  }

  Future<void> register(AppUser u, String pw) async {
    _busy = true;
    try {
      user = await AuthService.register(u, pw);
    } finally {
      _busy = false;
    }
    notifyListeners();
  }

  Future<void> updateProfile(AppUser u) async {
    await AuthService.updateProfile(u);
    user = u;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.signOut();
    user = null;
    notifyListeners();
  }
}