import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/screens/checkout_screen.dart';
import 'package:waytowebs_app/features/products/presentation/screens/product_list_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final user = ref.watch(authStateProvider).user;
    final isDealer = user?.role == UserRole.dealer;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDealer ? 'Wholesale Cart' : 'Shopping Cart'),
        backgroundColor: isDealer ? AppColors.dealerColor : AppColors.primary,
        actions: [
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Cart',
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
              },
            ),
        ],
      ),
      body: cartState.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your cart is currently empty',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explore our catalog of pipes, faucets, sanitaryware, and tools.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDealer ? AppColors.dealerColor : AppColors.primary,
                        minimumSize: const Size(200, 48),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductListScreen()),
                        );
                      },
                      child: const Text('Browse Products'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                if (isDealer)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.dealerColor.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, size: 16, color: AppColors.dealerColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dealer Wholesale Pricing Applied • Available Credit: ${Formatters.formatCurrency(user?.availableCredit ?? 0.0)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dealerColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.plumbing, color: AppColors.primaryLight),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${Formatters.formatCurrency(item.unitPrice)} / ${item.product.unit}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDealer ? AppColors.dealerColor : AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 22),
                                    onPressed: () {
                                      ref.read(cartProvider.notifier).updateQuantity(
                                            item.product.id,
                                            item.quantity - 1,
                                          );
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 22),
                                    onPressed: () {
                                      ref.read(cartProvider.notifier).updateQuantity(
                                            item.product.id,
                                            item.quantity + 1,
                                          );
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
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:', style: TextStyle(color: AppColors.textSecondary)),
                          Text(Formatters.formatCurrency(cartState.subtotal)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('GST (18%):', style: TextStyle(color: AppColors.textSecondary)),
                          Text(Formatters.formatCurrency(cartState.gstTaxAmount)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Logistics:', style: TextStyle(color: AppColors.textSecondary)),
                          Text(
                            cartState.deliveryFee == 0 ? 'FREE' : Formatters.formatCurrency(cartState.deliveryFee),
                            style: TextStyle(
                              color: cartState.deliveryFee == 0 ? AppColors.success : AppColors.textPrimary,
                              fontWeight: cartState.deliveryFee == 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            Formatters.formatCurrency(cartState.grandTotal),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDealer ? AppColors.dealerColor : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDealer ? AppColors.dealerColor : AppColors.primary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                          );
                        },
                        child: const Text('Proceed to Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
