import 'package:json_annotation/json_annotation.dart';

part 'client_info.g.dart';

@JsonSerializable()
class ClientInfo {
  final String clientId;
  final String name;
  final String webHookUrl;
  final String permissions;
  final List<Account> accounts;
  final List<Jar> jars;

  ClientInfo({
    required this.clientId,
    required this.name,
    required this.webHookUrl,
    required this.permissions,
    required this.accounts,
    required this.jars,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) =>
      _$ClientInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ClientInfoToJson(this);
}

@JsonSerializable()
class Account {
  final String id;
  final String sendId;
  final int balance;
  final int creditLimit;
  final String type;
  final int currencyCode;
  final String cashbackType;
  final List<String> maskedPan;
  final String iban;

  Account({
    required this.id,
    required this.sendId,
    required this.balance,
    required this.creditLimit,
    required this.type,
    required this.currencyCode,
    required this.cashbackType,
    required this.maskedPan,
    required this.iban,
  });

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@JsonSerializable()
class Jar {
  final String id;
  final String sendId;
  final String title;
  final String description;
  final int currencyCode;
  final int balance;
  final int? goal;

  Jar({
    required this.id,
    required this.sendId,
    required this.title,
    required this.description,
    required this.currencyCode,
    required this.balance,
    this.goal,
  });

  factory Jar.fromJson(Map<String, dynamic> json) => _$JarFromJson(json);

  Map<String, dynamic> toJson() => _$JarToJson(this);
}
