import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/orders/domain/entities/order_entity.dart';
import 'package:waytowebs_app/features/orders/presentation/providers/order_provider.dart';

class AdminOrdersManagementScreen extends ConsumerWidget {
  const AdminOrdersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Fulfillment Pipeline'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: ordersState.allOrders.isEmpty
          ? const Center(child: Text('No orders in the system.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ordersState.allOrders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = ordersState.allOrders[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.orderStatus).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
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
                        const SizedBox(height: 6),
                        Text(
                          'Buyer: ${order.userName} (${order.userPhone}) • Role: ${order.userRole.name.toUpperCase()}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Payment: ${order.paymentMethod.displayName} • ${order.paymentStatus}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Items: ${order.items.map((i) => '${i.product.name} (x${i.quantity})').join(', ')}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Formatters.formatCurrency(order.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                            ),
                            PopupMenuButton<OrderStatus>(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: const Row(
                                  children: [
                                    Text('Update Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_drop_down, size: 16, color: Colors.blue),
                                  ],
                                ),
                              ),
                              onSelected: (newStatus) {
                                ref.read(ordersProvider.notifier).updateStatus(order.id, newStatus);
                              },
                              itemBuilder: (context) => OrderStatus.values.map((status) {
                                return PopupMenuItem<OrderStatus>(
                                  value: status,
                                  child: Text(status.displayName),
                                );
                              }).toList(),
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
