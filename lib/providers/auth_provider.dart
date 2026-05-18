import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _appUser;
  bool _loading = false;
  String? _error;

  AppUser? get appUser => _appUser;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _appUser != null;

  void listenToAuthState() {
    _authService.authStateChanges.listen((User? user) async {
      if (user == null) {
        _appUser = null;
      } else {
        _appUser = await _authService.fetchAppUser(user.uid);
      }
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String countryCode,
    required String mobile,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    _setLoading(true);
    try {
      _appUser = await _authService.signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        countryCode: countryCode,
        mobile: mobile,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _appUser = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithMobile({
    required String countryCode,
    required String mobile,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _appUser = await _authService.signInWithMobile(
        countryCode: countryCode,
        mobile: mobile,
        password: password,
      );
      return _appUser != null;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordReset(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      _appUser = await _authService.signInWithGoogle();
      return _appUser != null;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (_appUser == null) return false;
    _setLoading(true);
    try {
      await _authService.updateProfile(
          uid: _appUser!.uid, name: name, phone: phone);
      final parts = name.trim().split(RegExp(r'\s+'));
      final first = parts.isNotEmpty ? parts.first : '';
      final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      _appUser = _appUser!.copyWith(
        firstName: first,
        lastName: last,
        phone: phone,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _appUser = null;
    notifyListeners();
  }

  void refreshUser(AppUser updated) {
    _appUser = updated;
    notifyListeners();
  }

  Future<void> refreshUserFromFirestore() async {
    if (_appUser == null) return;
    final updated = await _authService.fetchAppUser(_appUser!.uid);
    if (updated != null) {
      _appUser = updated;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'No account found.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
