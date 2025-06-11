class TooManyRequestsException implements Exception {
  final String message;

  TooManyRequestsException(this.message);

  @override
  String toString() {
    return 'TooManyRequestsException: $message';
  }
}
