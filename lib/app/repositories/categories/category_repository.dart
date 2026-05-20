import 'package:todo_list_provider/app/models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> findAll();
  Future<void> save(CategoryModel category);
  Future<void> update(CategoryModel category);
  Future<void> delete(int id);
}
