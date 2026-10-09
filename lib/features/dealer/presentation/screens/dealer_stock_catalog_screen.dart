import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:waytowebs_app/features/products/presentation/providers/product_provider.dart';
import 'package:waytowebs_app/features/products/presentation/screens/product_detail_screen.dart';

class DealerStockCatalogScreen extends ConsumerWidget {
  const DealerStockCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stock & Wholesale Rates'),
        backgroundColor: AppColors.dealerColor,
        actions: [
          IconButton(
            icon: productsState.isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Sync Zoho Workbook',
            onPressed: () => ref.read(productsProvider.notifier).triggerZohoWorkbookSync(),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cartState.totalItemsCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartState.totalItemsCount}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.dealerColor.withValues(alpha: 0.08),
            child: const Row(
              children: [
                Icon(Icons.inventory, color: AppColors.dealerColor, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Zoho Inventory Live Stock View: Dealers have direct visibility of actual unit availability.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dealerColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: productsState.products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = productsState.products[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.dealerColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.plumbing, color: AppColors.dealerColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'SKU: ${product.sku} • Zoho ID: ${product.zohoItemId}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: product.stockQuantity > 20
                                    ? AppColors.success.withValues(alpha: 0.15)
                                    : AppColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: product.stockQuantity > 20 ? AppColors.success : AppColors.warning,
                                ),
                              ),
                              child: Text(
                                '${product.stockQuantity} ${product.unit}s in stock',
                                style: TextStyle(
                                  color: product.stockQuantity > 20 ? AppColors.success : AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wholesale: ${Formatters.formatCurrency(product.dealerPrice)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.dealerColor,
                                  ),
                                ),
                                Text(
                                  'Retail MRP: ${Formatters.formatCurrency(product.customerPrice)}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(60, 34),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(product: product),
                                      ),
                                    );
                                  },
                                  child: const Text('Specs', style: TextStyle(fontSize: 11)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.dealerColor,
                                    minimumSize: const Size(90, 34),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  icon: const Icon(Icons.add_shopping_cart, size: 14),
                                  label: const Text('+10 Pcs', style: TextStyle(fontSize: 11)),
                                  onPressed: () {
                                    ref.read(cartProvider.notifier).addItem(product, 10);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Added 10 units of ${product.name} to cart'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
