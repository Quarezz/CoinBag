import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/supabase_api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final SupabaseApiService _api;
  List<double> _spending = const [];
  List<Bill> _upcomingBills = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _api = SupabaseApiService(
      supabaseUrl: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: '',
      ),
      supabaseAnonKey: const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '',
      ),
    );
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.fetchDashboardSummary();
      setState(() {
        _spending = (data['spending'] as List<dynamic>? ?? [])
            .map((e) => (e as num).toDouble())
            .toList();
        _upcomingBills = (data['upcoming_bills'] as List<dynamic>? ?? [])
            .map(
              (e) => Bill(
                id: e['id'] as String,
                description: e['description'] as String,
                amount: (e['amount'] as num).toDouble(),
                dueDate: DateTime.parse(e['due_date'] as String),
              ),
            )
            .toList();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Spending Over Time',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 200, child: SpendingChart(data: _spending)),
          const SizedBox(height: 16),
          const Text(
            'Upcoming Bills',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ..._upcomingBills.map(
            (b) => ListTile(
              title: Text(b.description),
              subtitle: Text(
                '\$${b.amount.toStringAsFixed(2)} due ${b.dueDate.month}/${b.dueDate.day}/${b.dueDate.year}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpendingChart extends StatelessWidget {
  final List<double> data;
  const SpendingChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
        data: data,
        lineColor: Theme.of(context).colorScheme.primary,
      ),
      child: Container(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  _LineChartPainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final maxValue = data.reduce(max);
    final stepX = size.width / (data.length - 1);
    final path = Path()
      ..moveTo(0, size.height - (data[0] / maxValue) * size.height);
    for (int i = 1; i < data.length; i++) {
      final x = stepX * i;
      final y = size.height - (data[i] / maxValue) * size.height;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.data != data;
}
