import 'package:coinbag_flutter/data/models/account.dart';

abstract class AccountRepository {
  Future<void> addAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String accountId);
  Future<List<Account>> fetchAccounts();
}
