// ignore: depend_on_referenced_packages
import 'dart:developer' as developer;

import 'package:coinbag_flutter/core/network/http_client_logger.dart';
import 'package:coinbag_flutter/core/network/parsing_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'monobank_repository.dart';
import '../../data/monobank/client_info.dart';
import '../../data/monobank/transaction.dart';
import 'package:coinbag_flutter/core/network/too_many_requests_exception.dart';

class MonobankRepositoryImpl implements MonobankRepository {
  final String _baseUrl = 'https://api.monobank.ua';
  final client = LoggingHttpClient(http.Client());

  @override
  Future<ClientInfo> getClientInfo(String token) async {
    developer.log('Getting client info from Monobank');
    final response = await client.get(
      Uri.parse('$_baseUrl/personal/client-info'),
      headers: {'X-Token': token},
    );
    developer.log('Client info: ${response.body}');

    if (response.statusCode == 200) {
      return parseWithLogging(
        () => ClientInfo.fromJson(json.decode(response.body)),
        'ClientInfo',
      );
    } else {
      throw Exception('Failed to load client info');
    }
  }

  @override
  Future<List<Transaction>> getTransactions(
    String token,
    String account,
    DateTime from,
    DateTime to,
  ) async {
    final fromTimestamp = from.millisecondsSinceEpoch ~/ 1000;
    final toTimestamp = to.millisecondsSinceEpoch ~/ 1000;

    developer.log(
      'Getting transactions from Monobank for account: $account, from: $fromTimestamp, to: $toTimestamp',
    );
    final response = await client.get(
      Uri.parse(
        '$_baseUrl/personal/statement/$account/$fromTimestamp/$toTimestamp',
      ),
      headers: {'X-Token': token},
    );
    if (response.statusCode == 200) {
      final List<dynamic> transactionsJson = json.decode(response.body);
      return transactionsJson
          .map(
            (json) => parseWithLogging(
              () => Transaction.fromJson(json),
              'Transaction',
            ),
          )
          .toList();
    } else if (response.statusCode == 429) {
      throw TooManyRequestsException('Too many requests');
    } else {
      throw Exception('Failed to load transactions');
    }
  }
}
