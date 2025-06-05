class Expense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String userId;
  final String accountId;
  final String? categoryId;
  final List<String> tags;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.userId,
    required this.accountId,
    this.categoryId,
    this.tags = const [],
  });

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    String? userId,
    String? accountId,
    String? categoryId,
    List<String>? tags,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
    );
  }
}
