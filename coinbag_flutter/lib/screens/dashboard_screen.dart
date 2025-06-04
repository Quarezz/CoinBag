import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bill.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  List<double> get _spending => [500, 400, 350, 600, 450, 700];

  List<Bill> get _upcomingBills => [
        Bill(
            id: '1',
            description: 'Rent',
            amount: 1200,
            dueDate: DateTime.now().add(const Duration(days: 7))),
        Bill(
            id: '2',
            description: 'Internet',
            amount: 60,
            dueDate: DateTime.now().add(const Duration(days: 12))),
      ];

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
                      '\$${b.amount.toStringAsFixed(2)} due ${b.dueDate.month}/${b.dueDate.day}/${b.dueDate.year}'),
                ),
              ),
            ],
          ),
        );
      },
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
