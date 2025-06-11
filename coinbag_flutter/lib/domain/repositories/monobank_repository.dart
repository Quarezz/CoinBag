import '../../data/monobank/client_info.dart';
import '../../data/monobank/transaction.dart';

abstract class MonobankRepository {
  Future<ClientInfo> getClientInfo(String token);

  Future<List<Transaction>> getTransactions(
    String token,
    String account,
    DateTime from,
    DateTime to,
  );
}
