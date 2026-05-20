import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_provider/app/categories/category_controller.dart';
import 'package:todo_list_provider/app/categories/widgets/category_form_dialog.dart';
import 'package:todo_list_provider/app/models/category_model.dart';

const _kPrimary = Color(0xFF7E57C2);

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryController>().loadCategories();
    });
  }

  Future<void> _openForm({CategoryModel? category}) async {
    final result = await showDialog<CategoryModel>(
      context: context,
      builder: (_) => CategoryFormDialog(category: category),
    );
    if (result == null || !mounted) return;

    final controller = context.read<CategoryController>();
    if (category == null) {
      await controller.addCategory(result);
    } else {
      await controller.updateCategory(result);
    }
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Excluir categoria'),
        content: Text(
          'Excluir "${category.nome}"?\n\n'
          'As tarefas associadas perderão a categoria, mas não serão excluídas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && category.id != null && mounted) {
      await context.read<CategoryController>().deleteCategory(category.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Categorias',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
      ),
      body: Consumer<CategoryController>(
        builder: (_, controller, __) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.categories.isEmpty) {
            return _buildEmpty();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final cat = controller.categories[index];
              return _buildCategoryTile(cat);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _kPrimary,
        onPressed: _openForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma categoria ainda.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _openForm,
            icon: const Icon(Icons.add, color: _kPrimary),
            label: const Text('Criar primeira categoria',
                style: TextStyle(color: _kPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(CategoryModel category) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: category.cor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(category.icone, color: category.cor, size: 24),
        ),
        title: Text(
          category.nome,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: Colors.grey,
              onPressed: () => _openForm(category: category),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red.shade400,
              onPressed: () => _confirmDelete(category),
              tooltip: 'Excluir',
            ),
          ],
        ),
      ),
    );
  }
}
