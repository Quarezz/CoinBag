class Currency {
  final String code;
  final String name;

  Currency({required this.code, required this.name});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(code: json['code'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name};
  }

  @override
  String toString() => name;
}
