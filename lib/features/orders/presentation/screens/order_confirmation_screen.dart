import 'package:flutter/material.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/customer/presentation/screens/customer_dashboard_screen.dart';
import 'package:waytowebs_app/features/dealer/presentation/screens/dealer_dashboard_screen.dart';
import 'package:waytowebs_app/features/orders/domain/entities/order_entity.dart';
import 'package:waytowebs_app/features/orders/presentation/screens/order_tracking_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderEntity order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDealer = order.userRole == UserRole.dealer;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _navigateToDashboard(context, order.userRole);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Order Confirmed'),
          backgroundColor: isDealer ? AppColors.dealerColor : AppColors.primary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your order has been recorded and synced with Zoho Inventory.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildRow('Order Reference', order.id, isBold: true),
                    const Divider(height: 16),
                    _buildRow('Total Items', '${order.items.fold(0, (s, i) => s + i.quantity)} Items'),
                    const SizedBox(height: 6),
                    _buildRow('Payment Type', order.paymentMethod.displayName),
                    const SizedBox(height: 6),
                    _buildRow('Payment Status', order.paymentStatus),
                    if (order.creditDueDate != null) ...[
                      const SizedBox(height: 6),
                      _buildRow('Credit Due Date', Formatters.formatShortDate(order.creditDueDate!)),
                    ],
                    const Divider(height: 16),
                    _buildRow(
                      'Total Amount',
                      Formatters.formatCurrency(order.totalAmount),
                      isBold: true,
                      highlightColor: isDealer ? AppColors.dealerColor : AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDealer ? AppColors.dealerColor : AppColors.primary,
                ),
                icon: const Icon(Icons.location_searching),
                label: const Text('Track Live Order Status'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(order: order),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _navigateToDashboard(context, order.userRole),
                child: const Text('Return to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, UserRole role) {
    Widget screen;
    if (role == UserRole.dealer) {
      screen = const DealerDashboardScreen();
    } else {
      screen = const CustomerDashboardScreen();
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: highlightColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
