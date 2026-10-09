import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/products/domain/entities/product_entity.dart';
import 'package:waytowebs_app/features/products/presentation/providers/product_provider.dart';

class AdminProductsManagementScreen extends ConsumerWidget {
  const AdminProductsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products & Price Master'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: productsState.products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = productsState.products[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.stockQuantity > 20 ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: product.stockQuantity > 20 ? AppColors.success : AppColors.warning),
                        ),
                        child: Text(
                          'Stock: ${product.stockQuantity} ${product.unit}s',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: product.stockQuantity > 20 ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${product.sku} • Zoho Item: ${product.zohoItemId} • ${product.categoryName}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Retail: ${Formatters.formatCurrency(product.customerPrice)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text('Wholesale: ${Formatters.formatCurrency(product.dealerPrice)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dealerColor)),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(100, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text('Edit Item', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          _showEditProductDialog(context, ref, product);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, WidgetRef ref, ProductEntity product) {
    final stockController = TextEditingController(text: product.stockQuantity.toString());
    final retailController = TextEditingController(text: product.customerPrice.toStringAsFixed(2));
    final dealerController = TextEditingController(text: product.dealerPrice.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${product.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stock Quantity (${product.unit}s)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: retailController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Retail Price (₹)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dealerController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Wholesale Dealer Price (₹)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              final newStock = int.tryParse(stockController.text) ?? product.stockQuantity;
              final newRetail = double.tryParse(retailController.text) ?? product.customerPrice;
              final newDealer = double.tryParse(dealerController.text) ?? product.dealerPrice;

              await ref.read(productsProvider.notifier).updateStock(product.id, newStock);
              await ref.read(productsProvider.notifier).updatePrices(product.id, newRetail, newDealer);

              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save & Sync'),
          ),
        ],
      ),
    );
  }
}
