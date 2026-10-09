import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/features/products/presentation/providers/product_provider.dart';
import 'package:waytowebs_app/features/products/presentation/screens/product_list_screen.dart';

class CustomerCategoriesScreen extends ConsumerWidget {
  const CustomerCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final categories = productsState.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Categories'),
        backgroundColor: AppColors.primary,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final productCount = productsState.products.where((p) => p.categoryId == cat.id).length;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ref.read(productsProvider.notifier).selectCategory(cat.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductListScreen(initialCategoryId: cat.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.12),
                      child: Icon(_getCategoryIcon(cat.id), size: 30, color: AppColors.primary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      cat.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$productCount products',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String id) {
    switch (id) {
      case 'cat_pipes':
        return Icons.plumbing;
      case 'cat_faucets':
        return Icons.water_drop;
      case 'cat_sanitary':
        return Icons.shower;
      case 'cat_pumps':
        return Icons.electric_bolt;
      case 'cat_adhesives':
        return Icons.format_paint;
      case 'cat_tools':
        return Icons.build;
      default:
        return Icons.category;
    }
  }
}
