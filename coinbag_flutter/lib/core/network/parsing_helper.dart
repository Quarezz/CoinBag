import 'dart:developer' as developer;

T parseWithLogging<T>(T Function() parser, String modelName) {
  try {
    return parser();
  } catch (e, s) {
    developer.log(
      '!!! Failed to parse $modelName',
      name: 'Parsing',
      error: e,
      stackTrace: s,
    );
    rethrow;
  }
}
