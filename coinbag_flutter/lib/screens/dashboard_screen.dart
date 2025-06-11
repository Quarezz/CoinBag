import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

import '../domain/repositories/dashboard/dashboard_repository.dart';
import '../core/service_locator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardRepository _dashboardRepository;
  bool _loading = true;
  String? _error;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  double _overallBalance = 0;
  String _currency = '\$';
  List<BalanceChartData> _balanceChartData = [];
  List<Transaction> _latestTransactions = [];
  List<CategorySpending> _categorySpending = [];

  @override
  void initState() {
    super.initState();
    _dashboardRepository = getIt<DashboardRepository>();
    _load();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _dashboardRepository.fetchDashboardInfo(
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        setState(() {
          _overallBalance =
              (data['overall_balance'] as num?)?.toDouble() ?? 0.0;
          _currency = data['preferredCurrency'] as String? ?? _currency;
          _balanceChartData = (data['balance_chart'] as List<dynamic>? ?? [])
              .map((e) => BalanceChartData.fromJson(e))
              .toList();
          _latestTransactions =
              (data['latest_transactions'] as List<dynamic>? ?? [])
                  .map((e) => Transaction.fromJson(e))
                  .toList();
          _categorySpending =
              (data['category_spending'] as List<dynamic>? ?? [])
                  .map((e) => CategorySpending.fromJson(e))
                  .toList();
        });
      }
    } catch (e, s) {
      if (mounted) {
        setState(() {
          _error = "Failed to load dashboard data: $e";
        });
      }
      developer.log(
        "Error loading dashboard summary: $e\n$s",
        name: 'DashboardScreen',
        level: 900,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _load,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDateRangeSelector(),
          const SizedBox(height: 16),
          _buildOverallBalance(),
          const SizedBox(height: 16),
          _buildBalanceChart(),
          const SizedBox(height: 16),
          _buildCategorySpending(),
          const SizedBox(height: 16),
          _buildLatestTransactions(),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => _selectDate(context, true),
          child: Text('Start: ${DateFormat.yMd().format(_startDate)}'),
        ),
        ElevatedButton(
          onPressed: () => _selectDate(context, false),
          child: Text('End: ${DateFormat.yMd().format(_endDate)}'),
        ),
      ],
    );
  }

  Widget _buildOverallBalance() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Current Overall Balance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$_currency${_overallBalance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Balance Over Time',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _balanceChartData
                      .map(
                        (d) => FlSpot(
                          d.date.millisecondsSinceEpoch.toDouble(),
                          d.balance,
                        ),
                      )
                      .toList(),
                  isCurved: true,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySpending() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Spending',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _categorySpending
                  .asMap()
                  .map(
                    (index, data) => MapEntry(
                      index,
                      PieChartSectionData(
                        color: _hexToColor(data.color),
                        value: data.totalSpent,
                        title:
                            '${data.name}\n\$${data.totalSpent.toStringAsFixed(2)}',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  .values
                  .toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Latest Transactions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _latestTransactions.isEmpty
            ? const Text('No transactions in this period.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _latestTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _latestTransactions[index];
                  return ListTile(
                    title: Text(transaction.description),
                    subtitle: Text(DateFormat.yMd().format(transaction.date)),
                    trailing: Text(
                      '\$${transaction.amount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
      ],
    );
  }
}

class BalanceChartData {
  final DateTime date;
  final double balance;
  BalanceChartData({required this.date, required this.balance});

  factory BalanceChartData.fromJson(Map<String, dynamic> json) {
    return BalanceChartData(
      date: DateTime.parse(json['date'] as String),
      balance: (json['balance'] as num).toDouble(),
    );
  }
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class CategorySpending {
  final String id;
  final String name;
  final double totalSpent;
  final String color;

  CategorySpending({
    required this.id,
    required this.name,
    required this.totalSpent,
    required this.color,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      id: json['id'] as String,
      name: json['name'] as String,
      totalSpent: (json['total_spent'] as num).toDouble(),
      color:
          json['color'] as String? ?? '#808080', // Default to gray if no color
    );
  }
}

Color _hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
