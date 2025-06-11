import 'dart:async'; // For StreamController
import 'dart:io'; // For SocketException
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_repository.dart';
import '../../auth/auth_failures.dart'; // Import new failures
import '../../auth/authentication_status.dart'; // Import the enum
import 'dart:developer' as developer;

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;
  String? _mockEmail; // For mock sign-in
  static const String _logName = 'AuthRepository';

  final StreamController<AuthenticationStatus> _authStatusController =
      StreamController<AuthenticationStatus>.broadcast();
  late StreamSubscription<AuthState> _supabaseAuthSubscription;

  AuthRepositoryImpl(this._client) {
    // Emit initial status based on current Supabase auth state or mock state
    if (_mockEmail != null) {
      _authStatusController.add(AuthenticationStatus.mockAuthenticated);
    } else if (_client.auth.currentUser != null) {
      _authStatusController.add(AuthenticationStatus.authenticated);
    } else {
      _authStatusController.add(AuthenticationStatus.unauthenticated);
    }

    _supabaseAuthSubscription = _client.auth.onAuthStateChange.listen((
      AuthState data,
    ) {
      final event = data.event;
      final session = data.session;
      developer.log(
        'Supabase auth event: $event, session: ${session != null}',
        name: _logName,
      );
      if (_mockEmail != null) {
        // If mock user is active, ignore Supabase events until mock sign out
        _authStatusController.add(AuthenticationStatus.mockAuthenticated);
        return;
      }
      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          _authStatusController.add(AuthenticationStatus.authenticated);
          break;
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userDeleted:
          _authStatusController.add(AuthenticationStatus.unauthenticated);
          break;
        case AuthChangeEvent
            .passwordRecovery: // This is an intermediate state, user is still unauthenticated until they complete recovery
          _authStatusController.add(AuthenticationStatus.unauthenticated);
          break;
        case AuthChangeEvent
            .mfaChallengeVerified: // For MFA, not handled yet, treat as authenticated
          _authStatusController.add(AuthenticationStatus.authenticated);
          break;
        case AuthChangeEvent.initialSession:
          _authStatusController.add(AuthenticationStatus.authenticated);
          break;
      }
    });
  }

  // Dispose method to close stream controllers and subscriptions
  void dispose() {
    _authStatusController.close();
    _supabaseAuthSubscription.cancel();
  }

  @override
  Stream<AuthenticationStatus> get authenticationStatus =>
      _authStatusController.stream;

  @override
  bool get isLoggedIn => _mockEmail != null || _client.auth.currentUser != null;

  @override
  String? get currentUserId =>
      _mockEmail != null ? 'mock_user_id' : _client.auth.currentUser?.id;

  @override
  String? get currentUserEmail => _mockEmail ?? _client.auth.currentUser?.email;

  @override
  Future<void> signUp(String email, String password) async {
    developer.log('Attempting to sign up user: $email', name: _logName);
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null && response.session == null) {
        developer.log(
          'Sign up seemed to fail silently for: $email',
          name: _logName,
        );
        throw const GenericAuthFailure(
          message: 'Sign up failed. Please try again or contact support.',
        );
      }
      developer.log(
        'Sign up request processed for user: $email, User ID: ${response.user?.id}',
        name: _logName,
      );
    } on AuthException catch (e, s) {
      developer.log(
        'AuthException during sign up for user: $email',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      if (e.message.toLowerCase().contains('user already registered') ||
          e.statusCode == '400') {
        throw const EmailAlreadyInUseAuthFailure();
      } else if (e.message.toLowerCase().contains(
        'password should be at least 6 characters',
      )) {
        throw const PasswordTooShortAuthFailure();
      } else if (e.message.toLowerCase().contains('weak password')) {
        throw const WeakPasswordAuthFailure();
      }
      throw GenericAuthFailure(message: e.message);
    } on SocketException catch (e, s) {
      developer.log(
        'SocketException during sign up for user: $email',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      throw const NetworkAuthFailure();
    } catch (e, s) {
      developer.log(
        'Generic error during sign up for user: $email',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      throw const GenericAuthFailure();
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    developer.log('Attempting to sign in user: $email', name: _logName);
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        developer.log(
          'Sign in failed for user: $email. No user object returned.',
          name: _logName,
          error: 'Invalid credentials or user does not exist',
        );
        throw const InvalidCredentialsAuthFailure();
      }
      developer.log(
        'Successfully signed in user: $email, User ID: ${response.user!.id}',
        name: _logName,
      );
    } on AuthException catch (e, s) {
      developer.log(
        'AuthException during sign in for user: $email',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        throw const InvalidCredentialsAuthFailure();
      } else if (e.message.toLowerCase().contains('email not confirmed')) {
        throw const EmailNotConfirmedAuthFailure();
      }
      throw GenericAuthFailure(message: e.message);
    } on SocketException catch (e, s) {
      developer.log(
        'SocketException during sign in for user: $email',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      throw const NetworkAuthFailure();
    } catch (e, s) {
      developer.log(
        'Generic error during sign in for user: $email',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      throw const GenericAuthFailure();
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    developer.log(
      'Attempting to reset password for email: $email',
      name: _logName,
    );
    try {
      await _client.auth.resetPasswordForEmail(email);
      developer.log('Password reset email sent to: $email', name: _logName);
    } on AuthException catch (e, s) {
      developer.log(
        'AuthException sending password reset email to: $email',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      if (e.message.toLowerCase().contains('user not found') ||
          e.statusCode == '404') {
        throw const UserNotFoundAuthFailure();
      }
      throw GenericAuthFailure(message: e.message);
    } on SocketException catch (e, s) {
      developer.log(
        'SocketException during password reset for: $email',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      throw const NetworkAuthFailure();
    } catch (e, s) {
      developer.log(
        'Generic error sending password reset email to: $email',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      throw const GenericAuthFailure();
    }
  }

  @override
  Future<void> signInMock(String email) async {
    developer.log('Attempting mock sign in for email: $email', name: _logName);
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Simulate network delay
    _mockEmail = email;
    _authStatusController.add(AuthenticationStatus.mockAuthenticated);
    developer.log('Successfully mock signed in as: $email', name: _logName);
  }

  @override
  Future<void> signOut() async {
    developer.log(
      'Attempting to sign out user: ${currentUserEmail ?? 'N/A'}',
      name: _logName,
    );
    try {
      if (_mockEmail != null) {
        _mockEmail = null;
        _authStatusController.add(AuthenticationStatus.unauthenticated);
      } else {
        // Supabase onAuthStateChange should handle emitting the new state for real sign out.
        await _client.auth.signOut();
      }
      developer.log('Successfully signed out.', name: _logName);
    } on AuthException catch (e, s) {
      developer.log(
        'AuthException during sign out',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      _authStatusController.add(
        AuthenticationStatus.unauthenticated,
      ); // Ensure state is unauth on error
      throw GenericAuthFailure(message: e.message);
    } on SocketException catch (e, s) {
      developer.log(
        'SocketException during sign out',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      // The actual auth state might not have changed on server, but locally user might be stuck.
      // Consider what status to emit. If Supabase client retries, its stream might eventually correct this.
      // For now, keeping it as is, or emit current known state e.g. from isLoggedIn.
      throw const NetworkAuthFailure();
    } catch (e, s) {
      developer.log(
        'Generic error during sign out',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      if (_mockEmail == null) {
        // If it was a real sign out attempt that failed generically
        _authStatusController.add(AuthenticationStatus.unauthenticated);
      }
      throw const GenericAuthFailure();
    }
  }
}
