import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:waytowebs_app/features/products/domain/entities/product_entity.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    if (user?.role == UserRole.dealer) {
      _quantity = 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final isDealer = user?.role == UserRole.dealer;
    final product = widget.product;
    final displayPrice = isDealer ? product.dealerPrice : product.customerPrice;
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: isDealer ? AppColors.dealerColor : AppColors.primary,
        actions: [
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              color: Colors.grey.shade100,
              child: Center(
                child: Icon(
                  Icons.plumbing_rounded,
                  size: 96,
                  color: (isDealer ? AppColors.dealerColor : AppColors.primary).withValues(alpha: 0.4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDealer ? AppColors.dealerColor : AppColors.primary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.categoryName,
                          style: TextStyle(
                            color: isDealer ? AppColors.dealerColor : AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (isDealer)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: product.stockQuantity > 20 ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: product.stockQuantity > 20 ? AppColors.success : AppColors.warning),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.inventory, size: 14, color: product.stockQuantity > 20 ? AppColors.success : AppColors.warning),
                              const SizedBox(width: 4),
                              Text(
                                'Available Stock: ${product.stockQuantity} ${product.unit}s',
                                style: TextStyle(
                                  color: product.stockQuantity > 20 ? AppColors.success : AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: product.isInStock ? AppColors.success.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.isInStock ? 'Status: In Stock' : 'Status: Out of Stock',
                            style: TextStyle(
                              color: product.isInStock ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'SKU: ${product.sku}  •  Zoho Item ID: ${product.zohoItemId}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDealer ? AppColors.dealerColor.withValues(alpha: 0.05) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDealer ? AppColors.dealerColor.withValues(alpha: 0.3) : AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDealer ? 'Wholesale Partner Price' : 'Standard Retail Price',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Formatters.formatCurrency(displayPrice),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDealer ? AppColors.dealerColor : AppColors.primary,
                              ),
                            ),
                            if (isDealer) ...[
                              Text(
                                'Retail MRP: ${Formatters.formatCurrency(product.customerPrice)} (Save ${(100 - (product.dealerPrice / product.customerPrice * 100)).toStringAsFixed(0)}%)',
                                style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              const Text('Unit Type', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text(product.unit, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Product Overview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Technical Specifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: product.specifications.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton.outlined(
                        icon: const Icon(Icons.remove),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton.outlined(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                  if (isDealer) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ActionChip(
                          label: const Text('+10 Pcs'),
                          onPressed: () => setState(() => _quantity += 10),
                        ),
                        const SizedBox(width: 6),
                        ActionChip(
                          label: const Text('+25 Pcs'),
                          onPressed: () => setState(() => _quantity += 25),
                        ),
                        const SizedBox(width: 6),
                        ActionChip(
                          label: const Text('+50 Pcs'),
                          onPressed: () => setState(() => _quantity += 50),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDealer ? AppColors.dealerColor : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text(
                      'Add $_quantity ${product.unit}(s) to Cart • ${Formatters.formatCurrency(displayPrice * _quantity)}',
                    ),
                    onPressed: product.isInStock
                        ? () {
                            ref.read(cartProvider.notifier).addItem(product, _quantity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added $_quantity ${product.unit}(s) to Cart'),
                                action: SnackBarAction(
                                  label: 'View Cart',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const CartScreen()),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
