class Expense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String accountId;
  final String? category;
  final List<String> tags;
  final int? recurringIntervalDays;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.accountId,
    this.category,
    this.tags = const [],
    this.recurringIntervalDays,
  });
}
