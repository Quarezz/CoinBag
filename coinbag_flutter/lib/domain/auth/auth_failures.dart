abstract class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsAuthFailure extends AuthFailure {
  const InvalidCredentialsAuthFailure()
    : super('Invalid email or password. Please try again.');
}

class EmailAlreadyInUseAuthFailure extends AuthFailure {
  const EmailAlreadyInUseAuthFailure()
    : super(
        'This email address is already in use. Please try a different one.',
      );
}

class PasswordTooShortAuthFailure extends AuthFailure {
  const PasswordTooShortAuthFailure({
    String customMessage =
        'Password is too short. It should be at least 6 characters.',
  }) : super(customMessage);
}

class WeakPasswordAuthFailure extends AuthFailure {
  const WeakPasswordAuthFailure()
    : super('The password is too weak. Please choose a stronger one.');
}

class UserNotFoundAuthFailure extends AuthFailure {
  const UserNotFoundAuthFailure()
    : super(
        'No user found for this email. Please check your email or sign up.',
      );
}

class EmailNotConfirmedAuthFailure extends AuthFailure {
  const EmailNotConfirmedAuthFailure()
    : super(
        'Your email address has not been confirmed. Please check your inbox.',
      );
}

class GenericAuthFailure extends AuthFailure {
  const GenericAuthFailure({
    String message =
        'An unexpected error occurred during authentication. Please try again.',
  }) : super(message);
}

class NetworkAuthFailure extends AuthFailure {
  const NetworkAuthFailure()
    : super(
        'A network error occurred. Please check your connection and try again.',
      );
}
