import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  final CategoryRepository _categoryRepository = getIt<CategoryRepository>();

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      final categories = await _categoryRepository.getAll();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.create(
        name: event.name,
        icon: event.icon,
        color: event.color,
      );
      add(const LoadCategories());
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.update(event.category);
      add(const LoadCategories());
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.delete(event.uid, reassignToId: event.reassignToId);
      add(const LoadCategories());
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }
}
