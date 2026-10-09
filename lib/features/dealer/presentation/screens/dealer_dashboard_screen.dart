import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/core/widgets/app_drawer.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:waytowebs_app/features/dealer/presentation/screens/dealer_credit_ledger_screen.dart';
import 'package:waytowebs_app/features/dealer/presentation/screens/dealer_stock_catalog_screen.dart';
import 'package:waytowebs_app/features/orders/presentation/providers/order_provider.dart';
import 'package:waytowebs_app/features/orders/presentation/screens/order_history_screen.dart';
import 'package:waytowebs_app/features/products/presentation/providers/product_provider.dart';
import 'package:waytowebs_app/features/products/presentation/widgets/product_card.dart';

class DealerDashboardScreen extends ConsumerWidget {
  const DealerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final productsState = ref.watch(productsProvider);
    final cartState = ref.watch(cartProvider);
    final ordersState = ref.watch(ordersProvider);

    final creditLimit = user?.creditLimit ?? 0.0;
    final availableCredit = user?.availableCredit ?? 0.0;
    final usedCredit = (creditLimit - availableCredit).clamp(0.0, creditLimit);
    final creditPercentage = creditLimit > 0 ? (usedCredit / creditLimit).clamp(0.0, 1.0) : 0.0;

    final dealerOrders = ordersState.allOrders.where((o) => o.userId == user?.id || o.userPhone == user?.phone).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Dealer Partner Portal'),
        backgroundColor: AppColors.dealerColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_score),
            tooltip: 'Credit Ledger',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DealerCreditLedgerScreen()),
              );
            },
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
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(productsProvider.notifier).loadProductsAndCategories();
          await ref.read(ordersProvider.notifier).loadOrders();
          await ref.read(authStateProvider.notifier).checkInitialAuthStatus();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.dealerColor, Color(0xFF4C1D95)],
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
                            Text(
                              user?.companyName ?? 'Authorized Wholesale Dealer',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'GST: ${user?.gstNumber ?? "33AAAAA0000A1Z5"} • ${user?.phone}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.greenAccent),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified, size: 14, color: Colors.greenAccent),
                              SizedBox(width: 4),
                              Text('Zoho Verified', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Credit Facility Summary',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                              ),
                              Row(
                                children: [
                                  if (user?.credit30DaysApproved == true)
                                    Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('30-Day', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                                    ),
                                  if (user?.credit90DaysApproved == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('90-Day VIP', style: TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Available Credit', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                    Formatters.formatCurrency(availableCredit),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.success),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Credit Limit', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                    Formatters.formatCurrency(creditLimit),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: creditPercentage,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              creditPercentage > 0.8 ? AppColors.error : AppColors.dealerColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Used: ${Formatters.formatCurrency(usedCredit)}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                              Text(
                                '${((1 - creditPercentage) * 100).toStringAsFixed(0)}% available',
                                style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionTile(
                        title: 'Stock Inventory',
                        subtitle: 'View live quantities',
                        icon: Icons.inventory_2,
                        color: AppColors.dealerColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DealerStockCatalogScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionTile(
                        title: 'Credit Ledger',
                        subtitle: 'Invoices & terms',
                        icon: Icons.receipt_long,
                        color: Colors.blue.shade700,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DealerCreditLedgerScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Live Wholesale Inventory',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DealerStockCatalogScreen()),
                        );
                      },
                      child: const Text('View All Stock'),
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
              const SizedBox(height: 20),
              if (dealerOrders.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Wholesale Orders',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                          );
                        },
                        child: const Text('All Orders'),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dealerOrders.take(2).length,
                  itemBuilder: (context, index) {
                    final order = dealerOrders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.dealerColor,
                          child: Icon(Icons.store, color: Colors.white, size: 20),
                        ),
                        title: Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(
                          '${order.paymentMethod.displayName}\n${Formatters.formatCurrency(order.totalAmount)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Text(
                            order.orderStatus.displayName,
                            style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
