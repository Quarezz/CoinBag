// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientInfo _$ClientInfoFromJson(Map<String, dynamic> json) => ClientInfo(
  clientId: json['clientId'] as String,
  name: json['name'] as String,
  webHookUrl: json['webHookUrl'] as String,
  permissions: json['permissions'] as String,
  accounts: (json['accounts'] as List<dynamic>)
      .map((e) => Account.fromJson(e as Map<String, dynamic>))
      .toList(),
  jars: (json['jars'] as List<dynamic>)
      .map((e) => Jar.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ClientInfoToJson(ClientInfo instance) =>
    <String, dynamic>{
      'clientId': instance.clientId,
      'name': instance.name,
      'webHookUrl': instance.webHookUrl,
      'permissions': instance.permissions,
      'accounts': instance.accounts,
      'jars': instance.jars,
    };

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  id: json['id'] as String,
  sendId: json['sendId'] as String,
  balance: (json['balance'] as num).toInt(),
  creditLimit: (json['creditLimit'] as num).toInt(),
  type: json['type'] as String,
  currencyCode: (json['currencyCode'] as num).toInt(),
  cashbackType: json['cashbackType'] as String,
  maskedPan: (json['maskedPan'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  iban: json['iban'] as String,
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'id': instance.id,
  'sendId': instance.sendId,
  'balance': instance.balance,
  'creditLimit': instance.creditLimit,
  'type': instance.type,
  'currencyCode': instance.currencyCode,
  'cashbackType': instance.cashbackType,
  'maskedPan': instance.maskedPan,
  'iban': instance.iban,
};

Jar _$JarFromJson(Map<String, dynamic> json) => Jar(
  id: json['id'] as String,
  sendId: json['sendId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  currencyCode: (json['currencyCode'] as num).toInt(),
  balance: (json['balance'] as num).toInt(),
  goal: (json['goal'] as num?)?.toInt(),
);

Map<String, dynamic> _$JarToJson(Jar instance) => <String, dynamic>{
  'id': instance.id,
  'sendId': instance.sendId,
  'title': instance.title,
  'description': instance.description,
  'currencyCode': instance.currencyCode,
  'balance': instance.balance,
  'goal': instance.goal,
};
