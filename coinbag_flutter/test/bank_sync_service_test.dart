import 'package:flutter_test/flutter_test.dart';
import 'package:coinbag_flutter/services/bank_sync_service.dart';
import 'package:coinbag_flutter/services/iap_service.dart';

void main() {
  group('BankSyncService', () {
    test('limits linking without premium purchase', () async {
      final iap = IapService();
      final service = BankSyncService(iapService: iap);

      expect(await service.linkBankAccount('acc1'), isTrue);
      expect(await service.linkBankAccount('acc2'), isFalse);
      expect(service.linkedAccounts.length, 1);

      await iap.buyPremium();
      expect(await service.linkBankAccount('acc2'), isTrue);
      expect(service.linkedAccounts.length, 2);
    });
  });
}
