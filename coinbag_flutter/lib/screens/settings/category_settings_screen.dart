import 'package:coinbag_flutter/core/app_decorations.dart';
import 'package:flutter/material.dart';
import '../../core/service_locator.dart';
import '../../data/models/category.dart';
import '../../domain/repositories/categories/category_repository.dart';

class CategorySettingsScreen extends StatefulWidget {
  const CategorySettingsScreen({Key? key}) : super(key: key);

  @override
  State<CategorySettingsScreen> createState() => _CategorySettingsScreenState();
}

class _CategorySettingsScreenState extends State<CategorySettingsScreen> {
  late final CategoryRepository _categoryRepository;

  List<Category> _categories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _categoryRepository = getIt<CategoryRepository>();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final categories = await _categoryRepository.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load categories: ${e.toString()}";
          _loading = false;
        });
      }
    }
  }

  Future<void> _openCategoryDialog({Category? existingCategory}) async {
    final Category? result = await showDialog<Category>(
      context: context,
      builder: (context) => _CategoryDialog(
        existingCategory: existingCategory,
        icons: AppDecorations.icons,
        displayColors: AppDecorations.displayColors,
      ),
    );

    if (result != null) {
      setState(() => _loading = true);
      try {
        if (existingCategory == null) {
          await _categoryRepository.addCategory(result);
        } else {
          await _categoryRepository.updateCategory(result);
        }
        await _loadCategories();
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = "Failed to save category: ${e.toString()}";
            _loading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_error!)));
        }
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      setState(() => _loading = true);
      try {
        await _categoryRepository.deleteCategory(category.id);
        await _loadCategories();
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = "Failed to delete category: ${e.toString()}";
            _loading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_error!)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_loading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_categories.isEmpty) {
      bodyContent = const Center(child: Text('No categories yet. Add one!'));
    } else {
      bodyContent = ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ListTile(
            leading: Icon(
              AppDecorations.icons[category.iconName] ?? Icons.help,
              color: AppDecorations.hexToColor(category.colorHex),
              size: 36,
            ),
            title: Text(category.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      _openCategoryDialog(existingCategory: category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCategory(category),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Categories Management')),
      body: bodyContent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCategoryDialog(),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final Category? existingCategory;
  final Map<String, IconData> icons;
  final Map<String, Color> displayColors;

  const _CategoryDialog({
    this.existingCategory,
    required this.icons,
    required this.displayColors,
    Key? key,
  }) : super(key: key);

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedIconName;
  late String _selectedColorName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingCategory?.name ?? '',
    );

    _selectedIconName =
        widget.existingCategory?.iconName ?? widget.icons.keys.first;

    if (widget.existingCategory?.colorHex != null) {
      final existingColorHex = widget.existingCategory!.colorHex;
      _selectedColorName = widget.displayColors.entries
          .firstWhere(
            (entry) =>
                AppDecorations.colorToHex(entry.value) == existingColorHex,
            orElse: () => widget.displayColors.entries.first,
          )
          .key;
    } else {
      _selectedColorName = widget.displayColors.keys.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingCategory == null ? 'Add Category' : 'Edit Category',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Icon'),
                value: _selectedIconName,
                items: widget.icons.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value),
                        const SizedBox(width: 8),
                        Text(entry.key),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedIconName = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Color'),
                value: _selectedColorName,
                items: widget.displayColors.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Container(width: 20, height: 20, color: entry.value),
                        const SizedBox(width: 8),
                        Text(entry.key),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedColorName = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final categoryToReturn = Category(
                id: widget.existingCategory?.id ?? '',
                name: _nameController.text,
                iconName: _selectedIconName,
                colorHex: AppDecorations.colorToHex(
                  widget.displayColors[_selectedColorName]!,
                ),
              );
              Navigator.of(context).pop(categoryToReturn);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
