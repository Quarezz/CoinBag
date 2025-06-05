import 'package:coinbag_flutter/data/models/account.dart';
import 'package:coinbag_flutter/gateway/network_data_source.dart';
import 'account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final NetworkDataSource _networkDataSource;

  AccountRepositoryImpl(this._networkDataSource);

  @override
  Future<void> addAccount(Account account) {
    return _networkDataSource.addAccount(account);
  }

  @override
  Future<void> updateAccount(Account account) {
    return _networkDataSource.updateAccount(account);
  }

  @override
  Future<void> deleteAccount(String accountId) {
    return _networkDataSource.deleteAccount(accountId);
  }

  @override
  Future<List<Account>> fetchAccounts() {
    return _networkDataSource.fetchAccounts();
  }
}
