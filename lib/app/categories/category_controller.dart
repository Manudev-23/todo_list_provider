import 'package:flutter/foundation.dart';
import 'package:todo_list_provider/app/models/category_model.dart';
import 'package:todo_list_provider/app/repositories/categories/category_repository.dart';

class CategoryController extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryController({required CategoryRepository repository})
      : _repository = repository;

  List<CategoryModel> _categories = [];
  bool _loading = false;
  String? _error;
  bool _initialized = false;

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  bool get loading => _loading;
  String? get error => _error;

  /// Carrega apenas se ainda não foi carregado (lazy init).
  Future<void> ensureLoaded() async {
    if (!_initialized) await loadCategories();
  }

  Future<void> loadCategories() async {
    _loading = true;
    _error = null;
    _initialized = true;
    notifyListeners();

    try {
      _categories = await _repository.findAll();
    } catch (e) {
      _error = 'Erro ao carregar categorias';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _repository.save(category);
      await loadCategories();
    } catch (e) {
      _error = 'Erro ao salvar categoria';
      notifyListeners();
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _repository.update(category);
      await loadCategories();
    } catch (e) {
      _error = 'Erro ao atualizar categoria';
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _repository.delete(id);
      await loadCategories();
    } catch (e) {
      _error = 'Erro ao excluir categoria';
      notifyListeners();
    }
  }
}
