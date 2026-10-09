import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/products/presentation/providers/product_provider.dart';

class PlumberCatalogScreen extends ConsumerWidget {
  const PlumberCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spares, Tools & Manuals'),
        backgroundColor: AppColors.plumberColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.menu_book, color: AppColors.plumberColor, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Technical reference specifications, spare part dimensions, and installation guidelines.',
                      style: TextStyle(fontSize: 12, color: AppColors.plumberColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Compatible Replacement Spares',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...productsState.products.map((product) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.plumberColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.build_outlined, color: AppColors.plumberColor, size: 20),
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('SKU: ${product.sku} • Category: ${product.categoryName}', style: const TextStyle(fontSize: 11)),
                  trailing: Text(
                    Formatters.formatCurrency(product.customerPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                  ),
                  childrenPadding: const EdgeInsets.all(14),
                  children: [
                    Text(product.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    const Text('Technical Specs:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    ...product.specifications.entries.map((spec) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(spec.key, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(spec.value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
