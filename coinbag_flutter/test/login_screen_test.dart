import 'package:coinbag_flutter/screens/login_screen.dart';
import 'package:coinbag_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestAuthService extends AuthService {
  Exception? signInError;
  Exception? resetError;
  bool resetCalled = false;

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    if (signInError != null) throw signInError!;
    return AuthResponse();
  }

  @override
  Future<void> resetPassword(String email) async {
    resetCalled = true;
    if (resetError != null) throw resetError!;
  }

  @override
  Future<AuthResponse> signUp(String email, String password) async {
    return AuthResponse();
  }
}

void main() {
  testWidgets('shows error when sign in fails', (tester) async {
    final auth = TestAuthService()
      ..signInError = AuthException('Invalid credentials');
    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(authService: auth, onLogin: () {}),
    ));
    await tester.enterText(find.byKey(const Key('emailField')), 'a@a.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'pass');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid credentials'), findsOneWidget);
  });

  testWidgets('reset password triggers service call', (tester) async {
    final auth = TestAuthService();
    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(authService: auth, onLogin: () {}),
    ));
    await tester.enterText(find.byKey(const Key('emailField')), 'a@a.com');
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    expect(auth.resetCalled, isTrue);
  });
}
