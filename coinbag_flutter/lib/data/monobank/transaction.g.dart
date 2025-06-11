// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String,
  time: (json['time'] as num).toInt(),
  description: json['description'] as String,
  mcc: (json['mcc'] as num).toInt(),
  originalMcc: (json['originalMcc'] as num).toInt(),
  hold: json['hold'] as bool,
  amount: (json['amount'] as num).toInt(),
  operationAmount: (json['operationAmount'] as num).toInt(),
  currencyCode: (json['currencyCode'] as num).toInt(),
  commissionRate: (json['commissionRate'] as num).toInt(),
  cashbackAmount: (json['cashbackAmount'] as num).toInt(),
  balance: (json['balance'] as num).toInt(),
  comment: json['comment'] as String?,
  receiptId: json['receiptId'] as String?,
  invoiceId: json['invoiceId'] as String?,
  counterEdrpou: json['counterEdrpou'] as String?,
  counterIban: json['counterIban'] as String?,
  counterName: json['counterName'] as String?,
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time,
      'description': instance.description,
      'mcc': instance.mcc,
      'originalMcc': instance.originalMcc,
      'hold': instance.hold,
      'amount': instance.amount,
      'operationAmount': instance.operationAmount,
      'currencyCode': instance.currencyCode,
      'commissionRate': instance.commissionRate,
      'cashbackAmount': instance.cashbackAmount,
      'balance': instance.balance,
      'comment': instance.comment,
      'receiptId': instance.receiptId,
      'invoiceId': instance.invoiceId,
      'counterEdrpou': instance.counterEdrpou,
      'counterIban': instance.counterIban,
      'counterName': instance.counterName,
    };
