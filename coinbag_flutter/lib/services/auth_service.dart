import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  String? _mockEmail;

  bool get isLoggedIn => _mockEmail != null || _client.auth.currentUser != null;

  String? get currentEmail => _mockEmail ?? _client.auth.currentUser?.email;

  Future<AuthResponse> signUp(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signInMock(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockEmail = email;
  }

  Future<void> signOut() async {
    _mockEmail = null;
    await _client.auth.signOut();
  }
}
