import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/orders/domain/entities/order_entity.dart';
import 'package:waytowebs_app/features/orders/presentation/providers/order_provider.dart';
import 'package:waytowebs_app/features/orders/presentation/screens/order_tracking_screen.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final ordersState = ref.watch(ordersProvider);
    final isDealer = user?.role == UserRole.dealer;

    final userOrders = ordersState.allOrders.where((o) {
      if (user?.role == UserRole.admin) return true;
      return o.userId == user?.id || o.userPhone == user?.phone;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isDealer ? 'Wholesale Order History' : 'My Orders'),
        backgroundColor: isDealer ? AppColors.dealerColor : AppColors.primary,
      ),
      body: userOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No orders found yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Your placed orders and invoices will appear here.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: userOrders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = userOrders[index];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingScreen(order: order),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.id,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order.orderStatus).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: _getStatusColor(order.orderStatus)),
                                ),
                                child: Text(
                                  order.orderStatus.displayName,
                                  style: TextStyle(
                                    color: _getStatusColor(order.orderStatus),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${order.items.length} items: ${order.items.map((i) => '${i.product.name} (x${i.quantity})').join(', ')}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Formatters.formatShortDate(order.createdAt),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  Text(
                                    order.paymentMethod.displayName,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                              Text(
                                Formatters.formatCurrency(order.totalAmount),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDealer ? AppColors.dealerColor : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Track Order',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primaryLight),
                            ],
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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.outForDelivery:
        return Colors.deepPurple;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}
