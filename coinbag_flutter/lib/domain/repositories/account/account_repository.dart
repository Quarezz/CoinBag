import 'package:coinbag_flutter/data/models/account.dart';

abstract class AccountRepository {
  Future<void> addAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<List<Account>> fetchAccounts();
}
