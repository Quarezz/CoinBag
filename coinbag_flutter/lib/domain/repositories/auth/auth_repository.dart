import 'package:coinbag_flutter/domain/auth/authentication_status.dart';

abstract class AuthRepository {
  bool get isLoggedIn;
  String? get currentUserId;
  String? get currentUserEmail;
  Stream<AuthenticationStatus> get authenticationStatus;

  Future<void> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> resetPassword(String email);
  Future<void> signOut();

  // Mock functionality, can be conditionally compiled or handled via DI
  Future<void> signInMock(String email);
}
