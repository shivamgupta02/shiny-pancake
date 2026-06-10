import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({super.key});

  static Future<Category?> show(BuildContext context) {
    return showModalBottomSheet<Category?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider(
        create: (_) => CategoryBloc()..add(const LoadCategories()),
        child: const CategoryPicker(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Category',
                    style: theme.textTheme.titleLarge,
                  ),
                  IconButton(
                    key: const Key('close-category-picker-button'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is CategoryLoaded) {
                    return _buildCategoryList(
                      context,
                      state.categories,
                      scrollController,
                    );
                  }
                  if (state is CategoryError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<Category> categories,
    ScrollController scrollController,
  ) {
    final theme = Theme.of(context);

    return ListView.builder(
      controller: scrollController,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Semantics(
          label: 'Category: ${category.name}',
          child: ListTile(
            key: Key('category-picker-item-${category.uid}'),
            onTap: () => Navigator.of(context).pop(category),
            leading: CircleAvatar(
              backgroundColor: Color(category.color),
              radius: 16,
              child: Icon(
                _getIconData(category.icon),
                color: Colors.white,
                size: 18,
              ),
            ),
            title: Text(
              category.name,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    return iconMap[iconName] ?? Icons.category;
  }

  static const Map<String, IconData> iconMap = {
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
  };
}
