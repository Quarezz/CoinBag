import 'package:flutter/material.dart';

class CategorySettingsScreen extends StatelessWidget {
  const CategorySettingsScreen({Key? key}) : super(key: key);

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
        final items = List.generate(
          10,
          (i) => ListTile(title: Text('Category ${i + 1}')),
        );
        return Scaffold(
          appBar: AppBar(title: const Text('Categories')),
          body: ListView(children: items),
        );
      },
    );
  }
}
