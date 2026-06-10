import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/models/category.dart' as models;
import '../../../data/repositories/category_repository.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key, this.category});

  /// If provided, the screen is in edit mode.
  final models.Category? category;

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedIcon = 'category';
  int _selectedColor = 0xFF1E88E5;
  bool _isSaving = false;
  String? _nameError;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => CategoryBloc(),
      child: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryLoaded) {
            Navigator.of(context).pop(true);
          } else if (state is CategoryError) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Category' : 'New Category'),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Name Field
                TextFormField(
                  key: const Key('category-name-field'),
                  controller: _nameController,
                  maxLength: AppConstants.maxCategoryNameLength,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: const OutlineInputBorder(),
                    errorText: _nameError,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length > AppConstants.maxCategoryNameLength) {
                      return 'Name cannot exceed ${AppConstants.maxCategoryNameLength} characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Icon Picker
                Text('Icon', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                _buildIconPicker(theme),
                const SizedBox(height: 24),

                // Color Picker
                Text('Color', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                _buildColorPicker(),
                const SizedBox(height: 16),

                // Preview
                Text('Preview', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                _buildPreview(theme),
                const SizedBox(height: 32),

                // Save Button
                FilledButton(
                  key: const Key('save-category-button'),
                  onPressed: _isSaving ? null : () => _save(context),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Update Category' : 'Create Category'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconPicker(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: _availableIcons.length,
        itemBuilder: (context, index) {
          final entry = _availableIcons.entries.elementAt(index);
          final isSelected = _selectedIcon == entry.key;
          return InkWell(
            key: Key('icon-${entry.key}'),
            onTap: () => setState(() => _selectedIcon = entry.key),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
              ),
              child: Icon(
                entry.value,
                size: 24,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableColors.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          key: Key('color-$color'),
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(color),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(color).withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(_selectedColor),
          child: Icon(
            _availableIcons[_selectedIcon] ?? Icons.category,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          _nameController.text.isEmpty ? 'Category Name' : _nameController.text,
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    setState(() {
      _isSaving = true;
      _nameError = null;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _isSaving = false);
      return;
    }

    final name = _nameController.text.trim();

    // Check name uniqueness
    final categoryRepo = getIt<CategoryRepository>();
    final existing = await categoryRepo.getByName(name);
    if (existing != null &&
        (!_isEditing || existing.uid != widget.category!.uid)) {
      setState(() {
        _nameError = 'A category with this name already exists';
        _isSaving = false;
      });
      return;
    }

    if (!context.mounted) return;

    if (_isEditing) {
      final updated = widget.category!.copyWith(
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
      );
      context.read<CategoryBloc>().add(UpdateCategory(category: updated));
    } else {
      context.read<CategoryBloc>().add(CreateCategory(
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
      ));
    }
  }

  static const Map<String, IconData> _availableIcons = {
    'restaurant': Icons.restaurant,
    'shopping_cart': Icons.shopping_cart,
    'directions_car': Icons.directions_car,
    'local_gas_station': Icons.local_gas_station,
    'home': Icons.home,
    'bolt': Icons.bolt,
    'shopping_bag': Icons.shopping_bag,
    'movie': Icons.movie,
    'local_hospital': Icons.local_hospital,
    'school': Icons.school,
    'flight': Icons.flight,
    'subscriptions': Icons.subscriptions,
    'more_horiz': Icons.more_horiz,
    'pets': Icons.pets,
    'fitness_center': Icons.fitness_center,
    'phone': Icons.phone,
    'wifi': Icons.wifi,
    'coffee': Icons.coffee,
    'child_care': Icons.child_care,
    'card_giftcard': Icons.card_giftcard,
    'savings': Icons.savings,
    'sports_esports': Icons.sports_esports,
    'music_note': Icons.music_note,
    'build': Icons.build,
    'category': Icons.category,
    'work': Icons.work,
    'attach_money': Icons.attach_money,
    'checkroom': Icons.checkroom,
    'spa': Icons.spa,
    'local_cafe': Icons.local_cafe,
  };

  static const List<int> _availableColors = [
    0xFFE53935, // Red
    0xFFD81B60, // Pink
    0xFF8E24AA, // Purple
    0xFF5E35B1, // Deep Purple
    0xFF3949AB, // Indigo
    0xFF1E88E5, // Blue
    0xFF00ACC1, // Cyan
    0xFF00897B, // Teal
    0xFF43A047, // Green
    0xFF7CB342, // Light Green
    0xFFFB8C00, // Orange
    0xFFFFB300, // Amber
    0xFF6D4C41, // Brown
    0xFF757575, // Grey
    0xFF546E7A, // Blue Grey
  ];
}
