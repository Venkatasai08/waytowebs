import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:waytowebs_app/features/products/domain/entities/product_entity.dart';
import 'package:waytowebs_app/features/products/presentation/screens/product_detail_screen.dart';

class ProductCard extends ConsumerWidget {
  final ProductEntity product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final isDealer = user?.role == UserRole.dealer;
    final displayPrice = isDealer ? product.dealerPrice : product.customerPrice;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(product.categoryId),
                      size: 48,
                      color: AppColors.primaryLight.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.categoryName,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                if (isDealer)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.stockQuantity > 20 ? AppColors.success : AppColors.warning,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Stock: ${product.stockQuantity} ${product.unit}s',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.isInStock ? AppColors.success : AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.isInStock ? 'In Stock' : 'Out of Stock',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${product.sku}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isDealer) ...[
                            Text(
                              'MRP: ${Formatters.formatCurrency(product.customerPrice)}',
                              style: const TextStyle(
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(displayPrice),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dealerColor,
                              ),
                            ),
                            const Text(
                              'Wholesale / Unit',
                              style: TextStyle(fontSize: 9, color: AppColors.dealerColor, fontWeight: FontWeight.bold),
                            ),
                          ] else ...[
                            Text(
                              Formatters.formatCurrency(displayPrice),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Text(
                              'Retail Price',
                              style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: isDealer ? AppColors.dealerColor : AppColors.primary,
                          minimumSize: const Size(32, 32),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        onPressed: product.isInStock
                            ? () {
                                final qty = isDealer ? 5 : 1;
                                ref.read(cartProvider.notifier).addItem(product, qty);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added $qty ${product.unit}(s) to cart'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
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
