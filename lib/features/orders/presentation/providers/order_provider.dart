import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:waytowebs_app/features/orders/data/datasources/order_local_data_source.dart';
import 'package:waytowebs_app/features/orders/data/repositories/order_repository_impl.dart';
import 'package:waytowebs_app/features/orders/domain/entities/order_entity.dart';
import 'package:waytowebs_app/features/orders/domain/repositories/order_repository.dart';
import 'package:waytowebs_app/features/products/presentation/providers/product_provider.dart';

final orderLocalDataSourceProvider = Provider<OrderLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final zohoClient = ref.watch(zohoApiClientProvider);
  return OrderLocalDataSourceImpl(
    sharedPreferences: prefs,
    zohoApiClient: zohoClient,
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dataSource = ref.watch(orderLocalDataSourceProvider);
  return OrderRepositoryImpl(localDataSource: dataSource);
});

class OrdersState {
  final List<OrderEntity> userOrders;
  final List<OrderEntity> allOrders;
  final bool isLoading;
  final String? errorMessage;
  final OrderEntity? lastPlacedOrder;

  const OrdersState({
    this.userOrders = const [],
    this.allOrders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastPlacedOrder,
  });

  OrdersState copyWith({
    List<OrderEntity>? userOrders,
    List<OrderEntity>? allOrders,
    bool? isLoading,
    String? errorMessage,
    OrderEntity? lastPlacedOrder,
    bool clearError = false,
  }) {
    return OrdersState(
      userOrders: userOrders ?? this.userOrders,
      allOrders: allOrders ?? this.allOrders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastPlacedOrder: lastPlacedOrder ?? this.lastPlacedOrder,
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrderRepository repository;
  final Ref ref;

  OrdersNotifier({required this.repository, required this.ref}) : super(const OrdersState()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = ref.read(authStateProvider).user;
      final all = await repository.getAllOrders();
      List<OrderEntity> userList = [];
      if (user != null) {
        userList = all.where((o) => o.userId == user.id).toList();
      }
      state = state.copyWith(
        allOrders: all,
        userOrders: userList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load orders: ${e.toString()}',
      );
    }
  }

  Future<OrderEntity?> createOrder({
    required PaymentMethod paymentMethod,
    required String shippingAddress,
  }) async {
    final user = ref.read(authStateProvider).user;
    final cart = ref.read(cartProvider);

    if (user == null || cart.items.isEmpty) return null;

    if (user.role == UserRole.dealer &&
        (paymentMethod == PaymentMethod.dealerCredit30Days || paymentMethod == PaymentMethod.dealerCredit90Days)) {
      if (cart.grandTotal > user.availableCredit) {
        state = state.copyWith(
          errorMessage: 'Order total (₹${cart.grandTotal.toStringAsFixed(2)}) exceeds available credit limit (₹${user.availableCredit.toStringAsFixed(2)}).',
        );
        return null;
      }
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final orderId = 'WTW-ORD-${const Uuid().v4().substring(0, 8).toUpperCase()}';
      final now = DateTime.now();
      DateTime? creditDueDate;

      String paymentStatus = 'Paid via ${paymentMethod.displayName}';
      if (paymentMethod == PaymentMethod.dealerCredit30Days) {
        creditDueDate = now.add(const Duration(days: 30));
        paymentStatus = 'Credit Term: Net 30 Days (Due on ${creditDueDate.day}/${creditDueDate.month}/${creditDueDate.year})';
      } else if (paymentMethod == PaymentMethod.dealerCredit90Days) {
        creditDueDate = now.add(const Duration(days: 90));
        paymentStatus = 'Credit Term: Net 90 Days (Due on ${creditDueDate.day}/${creditDueDate.month}/${creditDueDate.year})';
      } else if (paymentMethod == PaymentMethod.cashOnDelivery) {
        paymentStatus = 'Payment Pending (COD on delivery)';
      }

      final trackingSteps = [
        TrackingStep(
          title: 'Order Placed',
          description: 'Order successfully submitted and registered in Zoho.',
          timestamp: now,
          isCompleted: true,
        ),
        TrackingStep(
          title: 'Zoho Inventory Sync',
          description: 'Inventory items reserved and workbook updated.',
          timestamp: now.add(const Duration(minutes: 10)),
          isCompleted: false,
        ),
        TrackingStep(
          title: 'Dispatched from Hub',
          description: 'Package packaged and handed over to logistics.',
          timestamp: now.add(const Duration(hours: 4)),
          isCompleted: false,
        ),
        TrackingStep(
          title: 'Out for Delivery',
          description: 'Courier agent will arrive at your address.',
          timestamp: now.add(const Duration(hours: 8)),
          isCompleted: false,
        ),
        TrackingStep(
          title: 'Delivered',
          description: 'Package delivered and confirmed.',
          timestamp: now.add(const Duration(hours: 12)),
          isCompleted: false,
        ),
      ];

      final newOrder = OrderEntity(
        id: orderId,
        userId: user.id,
        userName: user.name,
        userPhone: user.phone,
        userRole: user.role,
        items: cart.items,
        subtotal: cart.subtotal,
        gstAmount: cart.gstTaxAmount,
        deliveryFee: cart.deliveryFee,
        totalAmount: cart.grandTotal,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        orderStatus: OrderStatus.placed,
        createdAt: now,
        creditDueDate: creditDueDate,
        shippingAddress: shippingAddress,
        trackingSteps: trackingSteps,
      );

      final saved = await repository.placeOrder(newOrder);

      for (final item in cart.items) {
        final currentStock = item.product.stockQuantity;
        final newStock = (currentStock - item.quantity).clamp(0, 999999);
        await ref.read(productsProvider.notifier).updateStock(item.product.id, newStock);
      }

      if (user.role == UserRole.dealer &&
          (paymentMethod == PaymentMethod.dealerCredit30Days || paymentMethod == PaymentMethod.dealerCredit90Days)) {
        await ref.read(authRepositoryProvider).updateDealerCreditPermissions(
              dealerId: user.id,
              credit30Approved: user.credit30DaysApproved,
              credit90Approved: user.credit90DaysApproved,
              creditLimit: user.creditLimit,
              isZohoVerified: user.isZohoVerified,
            );
        ref.read(authStateProvider.notifier).checkInitialAuthStatus();
      }

      ref.read(cartProvider.notifier).clearCart();

      state = state.copyWith(
        userOrders: [saved, ...state.userOrders],
        allOrders: [saved, ...state.allOrders],
        lastPlacedOrder: saved,
        isLoading: false,
      );

      return saved;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to complete order: ${e.toString()}',
      );
      return null;
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await repository.updateOrderStatus(orderId, status);
    await loadOrders();
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return OrdersNotifier(repository: repo, ref: ref);
});
