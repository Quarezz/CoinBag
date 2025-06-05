import './iap_service.dart'; // Path will need to be adjusted if IapService moves too

class BankSyncService {
  final IapService iapService;
  final int freeLimit;

  BankSyncService({required this.iapService, this.freeLimit = 1});

  final List<String> _linkedAccounts = [];

  List<String> get linkedAccounts => List.unmodifiable(_linkedAccounts);

  /// Attempts to link a new bank account. Returns `true` if the account was
  /// linked or `false` if the user has reached the free limit without premium.
  Future<bool> linkBankAccount(String accountId) async {
    if (!iapService.hasPremium && _linkedAccounts.length >= freeLimit) {
      return false;
    }
    _linkedAccounts.add(accountId);
    // TODO: Implement real bank linking with external provider
    return true;
  }

  Future<void> syncTransactions() async {
    // TODO: Fetch transactions from linked bank
  }
}
