import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/orders/domain/entities/order_entity.dart';
import 'package:waytowebs_app/features/orders/presentation/providers/order_provider.dart';
import 'package:waytowebs_app/features/products/presentation/providers/product_provider.dart';

class AdminDashboardMetrics {
  final double totalRevenue;
  final int totalOrdersCount;
  final int totalCustomersCount;
  final int totalDealersCount;
  final int totalPlumbersCount;
  final double totalCreditOutstanding;
  final int pendingOrdersCount;
  final int lowStockProductsCount;

  const AdminDashboardMetrics({
    required this.totalRevenue,
    required this.totalOrdersCount,
    required this.totalCustomersCount,
    required this.totalDealersCount,
    required this.totalPlumbersCount,
    required this.totalCreditOutstanding,
    required this.pendingOrdersCount,
    required this.lowStockProductsCount,
  });
}

final adminMetricsProvider = Provider<AdminDashboardMetrics>((ref) {
  final usersAsync = ref.watch(allUsersProvider);
  final ordersState = ref.watch(ordersProvider);
  final productsState = ref.watch(productsProvider);

  final users = usersAsync.value ?? [];
  final customers = users.where((u) => u.role == UserRole.customer).length;
  final dealers = users.where((u) => u.role == UserRole.dealer).toList();
  final plumbers = users.where((u) => u.role == UserRole.plumber).length;

  double totalRev = 0.0;
  int pending = 0;
  for (final o in ordersState.allOrders) {
    totalRev += o.totalAmount;
    if (o.orderStatus == OrderStatus.placed || o.orderStatus == OrderStatus.confirmed) {
      pending++;
    }
  }

  double totalCreditOut = 0.0;
  for (final d in dealers) {
    totalCreditOut += (d.creditLimit - d.availableCredit).clamp(0.0, d.creditLimit);
  }

  final lowStock = productsState.products.where((p) => p.stockQuantity < 50).length;

  return AdminDashboardMetrics(
    totalRevenue: totalRev,
    totalOrdersCount: ordersState.allOrders.length,
    totalCustomersCount: customers,
    totalDealersCount: dealers.length,
    totalPlumbersCount: plumbers,
    totalCreditOutstanding: totalCreditOut,
    pendingOrdersCount: pending,
    lowStockProductsCount: lowStock,
  );
});
