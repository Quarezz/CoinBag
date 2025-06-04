import 'package:flutter/material.dart';
import '../../models/category.dart';

class CategorySettingsScreen extends StatefulWidget {
  const CategorySettingsScreen({Key? key}) : super(key: key);

  @override
  State<CategorySettingsScreen> createState() => _CategorySettingsScreenState();
}

class _CategorySettingsScreenState extends State<CategorySettingsScreen> {
  static const Map<String, IconData> _icons = {
    'Shopping': Icons.shopping_cart,
    'Food': Icons.fastfood,
    'Car': Icons.directions_car,
    'Home': Icons.home,
    'Movie': Icons.movie,
    'Medical': Icons.local_hospital,
  };

  static const Map<String, Color> _colors = {
    'Red': Colors.red,
    'Green': Colors.green,
    'Blue': Colors.blue,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Pink': Colors.pink,
  };

  final List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addCategory() async {
    final Category? category = await showDialog<Category>(
      context: context,
      builder: (context) => const _AddCategoryDialog(),
    );
    if (category != null) {
      setState(() => _categories.add(category));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView(
        children: _categories
            .map(
              (c) => ListTile(
                leading: Icon(c.icon, color: c.color),
                title: Text(c.name),
              ),
            )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _nameController = TextEditingController();
  String _iconKey = _CategorySettingsScreenState._icons.keys.first;
  String _colorKey = _CategorySettingsScreenState._colors.keys.first;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _iconKey,
            decoration: const InputDecoration(labelText: 'Icon'),
            items: _CategorySettingsScreenState._icons.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Row(
                      children: [
                        Icon(e.value),
                        const SizedBox(width: 8),
                        Text(e.key),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _iconKey = v ?? _iconKey),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _colorKey,
            decoration: const InputDecoration(labelText: 'Color'),
            items: _CategorySettingsScreenState._colors.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: e.value),
                        const SizedBox(width: 8),
                        Text(e.key),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _colorKey = v ?? _colorKey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isEmpty) return;
            final category = Category(
              name: _nameController.text,
              icon: _CategorySettingsScreenState._icons[_iconKey]!,
              color: _CategorySettingsScreenState._colors[_colorKey]!,
            );
            Navigator.of(context).pop(category);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
