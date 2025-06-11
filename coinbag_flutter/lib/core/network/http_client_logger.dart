import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;
  static const String _logName = 'HttpClient';

  LoggingHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    developer.log('--> ${request.method} ${request.url}', name: _logName);
    developer.log('Headers: ${request.headers}', name: _logName);

    if (request is http.Request) {
      if (request.body.isNotEmpty) {
        _logJsonBody('Body', request.body);
      }
    }

    try {
      final response = await _inner.send(request);
      stopwatch.stop();

      final bytes = await response.stream.toBytes();
      final bodyString = utf8.decode(bytes, allowMalformed: true);

      developer.log(
        '<-- ${response.statusCode} ${response.reasonPhrase} (${stopwatch.elapsedMilliseconds}ms) ${request.url}',
        name: _logName,
      );
      developer.log('Response Headers: ${response.headers}', name: _logName);
      if (bodyString.isNotEmpty) {
        _logJsonBody('Response Body', bodyString);
      }

      final stream = http.ByteStream.fromBytes(bytes);

      return http.StreamedResponse(
        stream,
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (e, s) {
      stopwatch.stop();
      developer.log(
        '!!! HTTP Error (${stopwatch.elapsedMilliseconds}ms): ${request.method} ${request.url}',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  void _logJsonBody(String name, String body) {
    try {
      final decoded = json.decode(body);
      final prettyString = const JsonEncoder.withIndent('  ').convert(decoded);
      developer.log('$name:\n$prettyString', name: _logName);
    } catch (e) {
      developer.log('$name: $body', name: _logName);
    }
  }
}
