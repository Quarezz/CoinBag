import 'package:coinbag_flutter/domain/repositories/categories/category_repository.dart';
import 'package:coinbag_flutter/domain/repositories/auth/auth_repository.dart';
import 'package:coinbag_flutter/gateway/network_data_source.dart';
import '../../../data/models/category.dart';
import 'dart:developer' as developer;

class CategoryRepositoryImpl implements CategoryRepository {
  final NetworkDataSource _networkDataSource;
  final AuthRepository _authRepository;

  CategoryRepositoryImpl(this._networkDataSource, this._authRepository);

  @override
  Future<List<Category>> getCategories() async {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      developer.log(
        'User not logged in, cannot fetch categories.',
        name: 'CategoryRepositoryImpl',
      );
      return [];
    }
    try {
      return await _networkDataSource.fetchCategories(userId: userId);
    } catch (e, s) {
      developer.log(
        'Error fetching categories: $e',
        stackTrace: s,
        name: 'CategoryRepositoryImpl',
        error: e,
      );
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<Category?> addCategory(Category category) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      developer.log(
        'User not logged in, cannot add category.',
        name: 'CategoryRepositoryImpl',
      );
      throw Exception('User not authenticated to add category.');
    }

    final categoryCreationDTO = CategoryCreationDTO(
      name: category.name,
      icon: category.iconName,
      color: category.colorHex,
    );

    try {
      return await _networkDataSource.addCategory(categoryCreationDTO);
    } catch (e, s) {
      developer.log(
        'Error adding category: $e',
        stackTrace: s,
        name: 'CategoryRepositoryImpl',
        error: e,
      );
      throw Exception('Failed to add category: $e');
    }
  }

  @override
  Future<Category?> updateCategory(Category category) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      developer.log(
        'User not logged in, cannot update category.',
        name: 'CategoryRepositoryImpl',
      );
      throw Exception('User not authenticated to update category.');
    }
    if (category.id.isEmpty) {
      developer.log(
        'Category ID is missing, cannot update.',
        name: 'CategoryRepositoryImpl',
      );
      throw Exception('Category ID is required for update.');
    }

    final categoryUpdateDTO = CategoryUpdateDTO(
      id: category.id,
      name: category.name,
      iconName: category.iconName,
      colorHex: category.colorHex,
    );

    try {
      return await _networkDataSource.updateCategory(categoryUpdateDTO);
    } catch (e, s) {
      developer.log(
        'Error updating category: $e',
        stackTrace: s,
        name: 'CategoryRepositoryImpl',
        error: e,
      );
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    if (categoryId.isEmpty) {
      developer.log(
        'Category ID is missing, cannot delete.',
        name: 'CategoryRepositoryImpl',
      );
      throw Exception('Category ID is required for deletion.');
    }

    try {
      await _networkDataSource.deleteCategory(categoryId);
    } catch (e, s) {
      developer.log(
        'Error deleting category: $e',
        stackTrace: s,
        name: 'CategoryRepositoryImpl',
        error: e,
      );
      throw Exception('Failed to delete category: $e');
    }
  }
}
