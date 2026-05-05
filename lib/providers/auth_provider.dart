import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final RealtimeDatabaseService _dbService = RealtimeDatabaseService();

  User? _user;
  AppUser? _profile;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  AuthProvider() {
    _authService.user.listen((user) {
      _user = user;
      _errorMessage = null;
      if (user != null) {
        _loadUserProfile(user);
      } else {
        _profile = null;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  AppUser? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.email == 'admin@foodgo.com'; // Simple check for now
  String? get errorMessage => _errorMessage;
  String? get displayName => _profile?.fullName ?? _user?.displayName ?? 'Mehmon';

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _loadUserProfile(User firebaseUser) async {
    try {
      final loaded = await _dbService.getUserProfile(firebaseUser.uid);
      _profile = loaded ??
          AppUser(
            uid: firebaseUser.uid,
            fullName: firebaseUser.displayName ?? 'Foydalanuvchi',
            email: firebaseUser.email ?? '',
            createdAt: DateTime.now(),
          );
      // Save profile if it was just created
      if (loaded == null) {
        await _dbService.saveUserProfile(_profile!);
      }
      notifyListeners();
    } catch (_) {
      // Profile load failed silently - auth still works
    }
  }

  /// Sign in with existing account
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _translateFirebaseError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Noma\'lum xatolik. Qaytadan urinib ko\'ring.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register a new account
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    String gender = 'Erkak',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(fullName);

      // Save profile to RTDB (non-blocking)
      if (credential.user != null) {
        try {
          await _dbService.saveUserProfile(AppUser(
            uid: credential.user!.uid,
            fullName: fullName,
            email: email,
            gender: gender,
            createdAt: DateTime.now(),
          ));
        } catch (_) {}
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _translateFirebaseError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Noma\'lum xatolik. Qaytadan urinib ko\'ring.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fallback: tries sign in first, then registers if user not found
  Future<bool> loginOrRegister(String email, String password, String? fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // If user not found or wrong password, try registration
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        try {
          final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          await credential.user?.updateDisplayName(
            fullName?.isNotEmpty == true ? fullName! : 'Lumière User',
          );
          _isLoading = false;
          notifyListeners();
          return true;
        } on FirebaseAuthException catch (e2) {
          _errorMessage = _translateFirebaseError(e2.code);
        }
      } else {
        _errorMessage = _translateFirebaseError(e.code);
      }
    } catch (_) {
      _errorMessage = 'Noma\'lum xatolik yuz berdi.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  String _translateFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu email bilan hisob topilmadi.';
      case 'wrong-password':
        return 'Parol noto\'g\'ri. Qaytadan urinib ko\'ring.';
      case 'invalid-email':
        return 'Email manzili noto\'g\'ri formatda.';
      case 'email-already-in-use':
        return 'Bu email allaqachon ro\'yxatdan o\'tgan.';
      case 'weak-password':
        return 'Parol juda zaif. Kamida 6 ta belgi kiriting.';
      case 'network-request-failed':
        return 'Internet aloqasi yo\'q. Tekshirib ko\'ring.';
      case 'too-many-requests':
        return 'Juda ko\'p urinish. Biroz kuting va qayta urinib ko\'ring.';
      case 'user-disabled':
        return 'Bu hisob bloklangan. Qo\'llab-quvvatlash xizmatiga murojaat qiling.';
      case 'invalid-credential':
        return 'Email yoki parol noto\'g\'ri.';
      case 'operation-not-allowed':
        return 'Firebase Console → Authentication → Sign-in method → Email/Password ni yoqing!';
      case 'identity-toolkit-api-has-not-been-used-in-project':
        return 'Firebase Authentication API yoqilmagan. Firebase Console → Authentication → Sign-in method → Email/Password ni faollashtiring.';
      default:
        if (code.contains('identity-toolkit') || code.contains('api-has-not-been-used')) {
          return '⚠️ Firebase Authentication yoqilmagan.\n\nFirebase Console → Authentication → Sign-in method → Email/Password → Enable qiling.';
        }
        return 'Xatolik yuz berdi. Qaytadan urinib ko\'ring. ($code)';
    }
  }
}
