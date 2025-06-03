class Expense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String accountId;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.accountId,
  });
}
