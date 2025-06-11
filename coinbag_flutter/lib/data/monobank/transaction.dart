import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  final String id;
  final int time;
  final String description;
  final int mcc;
  final int originalMcc;
  final bool hold;
  final int amount;
  final int operationAmount;
  final int currencyCode;
  final int commissionRate;
  final int cashbackAmount;
  final int balance;
  final String? comment;
  final String? receiptId;
  final String? invoiceId;
  final String? counterEdrpou;
  final String? counterIban;
  final String? counterName;

  Transaction({
    required this.id,
    required this.time,
    required this.description,
    required this.mcc,
    required this.originalMcc,
    required this.hold,
    required this.amount,
    required this.operationAmount,
    required this.currencyCode,
    required this.commissionRate,
    required this.cashbackAmount,
    required this.balance,
    this.comment,
    this.receiptId,
    this.invoiceId,
    this.counterEdrpou,
    this.counterIban,
    this.counterName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
