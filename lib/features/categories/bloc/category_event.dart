import 'package:equatable/equatable.dart';

import '../../../data/models/category.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

class CreateCategory extends CategoryEvent {
  const CreateCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final String icon;
  final int color;

  @override
  List<Object?> get props => [name, icon, color];
}

class UpdateCategory extends CategoryEvent {
  const UpdateCategory({required this.category});

  final Category category;

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  const DeleteCategory({
    required this.uid,
    required this.reassignToId,
  });

  final String uid;
  final String reassignToId;

  @override
  List<Object?> get props => [uid, reassignToId];
}
