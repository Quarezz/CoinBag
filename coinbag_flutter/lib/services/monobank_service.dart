import 'dart:async';
import 'dart:developer' as developer;

import 'package:coinbag_flutter/data/monobank/transaction.dart' as monobank;
import 'package:coinbag_flutter/services/monobank_sync_progress.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/repositories/monobank_repository.dart';
import '../data/monobank/client_info.dart' as monobank;
import 'package:coinbag_flutter/core/network/too_many_requests_exception.dart';

class MonobankService {
  final MonobankRepository _monobankRepository;
  final SupabaseClient _supabaseClient;

  final _progressController = StreamController<SyncProgress>.broadcast();
  Stream<SyncProgress> get progressStream => _progressController.stream;

  MonobankService(this._monobankRepository, this._supabaseClient);

  Future<monobank.ClientInfo> getClientInfo(String token) async {
    developer.log('Getting client info from Monobank with token: $token');
    final clientInfo = await _monobankRepository.getClientInfo(token);
    developer.log('Client info: ${clientInfo.toJson()}');
    return clientInfo;
  }

  Future<void> setupSync(
    String token,
    monobank.ClientInfo clientInfo,
    List<String> selectedAccountIds,
  ) async {
    _progressController.add(SyncProgress('Setting up sync...'));
    // 1. Setup sync in Supabase (store token, create accounts)
    developer.log('Setting up Monobank sync for accounts: $selectedAccountIds');

    final accountsToCreate = clientInfo.accounts
        .where((acc) => selectedAccountIds.contains(acc.id))
        .map((acc) => acc.toJson())
        .toList();

    final jarsToCreate = clientInfo.jars
        .where((jar) => selectedAccountIds.contains(jar.id))
        .map((jar) => jar.toJson())
        .toList();

    final bankAccessTokenId = await _supabaseClient.rpc(
      'setup_monobank_sync',
      params: {
        'p_user_id': _supabaseClient.auth.currentUser!.id,
        'p_x_token': token,
        'p_client_id': clientInfo.clientId,
        'p_accounts': accountsToCreate,
        'p_jars': jarsToCreate,
      },
    );

    // 2. Fetch and store transactions for each selected account
    for (final accountId in selectedAccountIds) {
      developer.log('Syncing transactions for account: $accountId');
      await _syncTransactionsForAccount(token, bankAccessTokenId, accountId);
    }
    _progressController.add(SyncProgress('Sync complete!', isCompleted: true));
  }

  Future<void> _syncTransactionsForAccount(
    String token,
    String bankAccessTokenId,
    String providerAccountId,
  ) async {
    DateTime chunkEndDate = DateTime.now();

    // Loop indefinitely to fetch chunks of transactions until no more are found.
    while (true) {
      final DateTime chunkStartDate = chunkEndDate.subtract(
        const Duration(days: 30),
      );

      final progressMessage =
          'Syncing data from ${DateFormat('MMMM yyyy').format(chunkStartDate)}';
      _progressController.add(SyncProgress(progressMessage));

      developer.log(
        'Fetching transactions for account $providerAccountId from $chunkStartDate to $chunkEndDate',
      );

      // This inner loop handles the Monobank API's 500-item pagination limit
      // within the current 30-day chunk.
      DateTime paginationToDate = chunkEndDate;
      int transactionsInChunk = 0;
      await Future.delayed(const Duration(milliseconds: 1000));

      while (true) {
        await Future.delayed(const Duration(milliseconds: 1000));

        List<monobank.Transaction> transactions;
        int retryCount = 0;
        while (true) {
          try {
            transactions = await _monobankRepository.getTransactions(
              token,
              providerAccountId,
              chunkStartDate,
              paginationToDate,
            );
            break; // Success, exit retry loop
          } on TooManyRequestsException {
            if (retryCount < 3) {
              retryCount++;
              developer.log(
                'Too many requests. Retrying in 5 seconds... (Attempt $retryCount)',
              );
              await Future.delayed(const Duration(seconds: 5));
            } else {
              developer.log('Too many requests. Max retries reached.');
              rethrow;
            }
          }
        }

        if (transactions.isNotEmpty) {
          transactionsInChunk += transactions.length;
          await _supabaseClient.rpc(
            'add_monobank_transactions',
            params: {
              'p_user_id': _supabaseClient.auth.currentUser!.id,
              'p_bank_access_token_id': bankAccessTokenId,
              'p_provider_account_id': providerAccountId,
              'p_transactions': transactions.map((t) => t.toJson()).toList(),
            },
          );
        }

        // If we get less than 500 items, we've finished this 30-day chunk.
        if (transactions.length < 500) {
          break; // Exit the inner pagination loop.
        } else {
          // Otherwise, update the `to` date to fetch the next page in the same chunk.
          paginationToDate = DateTime.fromMillisecondsSinceEpoch(
            transactions.last.time * 1000,
          ).subtract(const Duration(seconds: 1));
        }
      }

      // If the last 30-day chunk had no transactions, we've reached the end.
      if (transactionsInChunk == 0) {
        break; // Exit the outer chunk-fetching loop.
      } else {
        // Move to the previous 30-day chunk for the next iteration.
        chunkEndDate = chunkStartDate.subtract(const Duration(seconds: 1));
      }
    }
  }
}
