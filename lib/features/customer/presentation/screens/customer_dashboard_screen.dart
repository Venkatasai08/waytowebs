import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/widgets/app_drawer.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:waytowebs_app/features/customer/presentation/screens/customer_categories_screen.dart';
import 'package:waytowebs_app/features/orders/domain/entities/order_entity.dart';
import 'package:waytowebs_app/features/orders/presentation/providers/order_provider.dart';
import 'package:waytowebs_app/features/orders/presentation/screens/order_tracking_screen.dart';
import 'package:waytowebs_app/features/products/presentation/providers/product_provider.dart';
import 'package:waytowebs_app/features/products/presentation/screens/product_list_screen.dart';
import 'package:waytowebs_app/features/products/presentation/widgets/product_card.dart';

class CustomerDashboardScreen extends ConsumerWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final productsState = ref.watch(productsProvider);
    final cartState = ref.watch(cartProvider);
    final ordersState = ref.watch(ordersProvider);

    final activeOrder = ordersState.allOrders.where((o) {
      final isMine = o.userId == user?.id || o.userPhone == user?.phone;
      final isActive = o.orderStatus != OrderStatus.delivered && o.orderStatus != OrderStatus.cancelled;
      return isMine && isActive;
    }).firstOrNull;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        backgroundColor: AppColors.customerColor,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
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
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(productsProvider.notifier).loadProductsAndCategories();
          await ref.read(ordersProvider.notifier).loadOrders();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.customerColor, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome Back,',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            Text(
                              user?.name ?? 'Valued Customer',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shield, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Customer Portal', style: TextStyle(color: Colors.white, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductListScreen()),
                        );
                      },
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Search pipes, valves, taps, pumps...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (activeOrder != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.local_shipping, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Order: ${activeOrder.id}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'Status: ${activeOrder.orderStatus.displayName}',
                              style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(80, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderTrackingScreen(order: activeOrder),
                            ),
                          );
                        },
                        child: const Text('Track', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Browse Categories',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CustomerCategoriesScreen()),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: productsState.categories.length,
                  itemBuilder: (context, index) {
                    final cat = productsState.categories[index];
                    return Container(
                      width: 90,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          ref.read(productsProvider.notifier).selectCategory(cat.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductListScreen(initialCategoryId: cat.id),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
                              child: Icon(_getCatIcon(cat.id), color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Products',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(productsProvider.notifier).selectCategory(null);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductListScreen()),
                        );
                      },
                      child: const Text('See All Products'),
                    ),
                  ],
                ),
              ),
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: productsState.products.take(4).length,
                itemBuilder: (context, index) {
                  final prod = productsState.products[index];
                  return ProductCard(product: prod);
                },
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: AppColors.primaryDark,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.support_agent, size: 40, color: Colors.white),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need Plumbing Assistance?',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                'Book a certified WayToWebs plumber for quick home installation.',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCatIcon(String id) {
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
