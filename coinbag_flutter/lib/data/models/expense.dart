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
}
