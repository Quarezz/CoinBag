class Account {
  final String id;
  final String name;
  double debitBalance;
  double creditBalance;

  Account({
    required this.id,
    required this.name,
    this.debitBalance = 0,
    this.creditBalance = 0,
  });
}
