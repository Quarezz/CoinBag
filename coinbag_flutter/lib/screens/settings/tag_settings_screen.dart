import 'package:flutter/material.dart';
import '../../models/tag.dart';

class TagSettingsScreen extends StatefulWidget {
  const TagSettingsScreen({Key? key}) : super(key: key);

  @override
  State<TagSettingsScreen> createState() => _TagSettingsScreenState();
}

class _TagSettingsScreenState extends State<TagSettingsScreen> {
  final List<Tag> _tags = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _tags.addAll([
        Tag(id: '1', name: 'Work', colorValue: Colors.blue.value),
        Tag(id: '2', name: 'Personal', colorValue: Colors.green.value),
      ]);
      _loading = false;
    });
  }

  Future<void> _showAddDialog() async {
    final tag = await showDialog<Tag>(
      context: context,
      builder: (context) => const _AddTagDialog(),
    );
    if (tag != null) {
      setState(() => _tags.add(tag));
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
      appBar: AppBar(title: const Text('Tags')),
      body: ListView(
        children: _tags
            .map(
              (t) => ListTile(
                leading: CircleAvatar(backgroundColor: Color(t.colorValue)),
                title: Text(t.name),
              ),
            )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddTagDialog extends StatefulWidget {
  const _AddTagDialog();

  @override
  State<_AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<_AddTagDialog> {
  final _nameController = TextEditingController();
  final List<Color> _colors = [
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Tag'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: List.generate(_colors.length, (i) {
              final color = _colors[i];
              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: CircleAvatar(
                  backgroundColor: color,
                  child: _selected == i
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            final tag = Tag(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
              colorValue: _colors[_selected].value,
            );
            Navigator.of(context).pop(tag);
          },
          child: const Text('Save'),
        )
      ],
    );
  }
}
