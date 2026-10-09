import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/cart/domain/entities/cart_item_entity.dart';

enum OrderStatus {
  placed,
  confirmed,
  shipped,
  outForDelivery,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed by Zoho';
      case OrderStatus.shipped:
        return 'Dispatched / In Transit';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum PaymentMethod {
  directUpi,
  directCard,
  directNetBanking,
  cashOnDelivery,
  dealerUpfront,
  dealerCredit30Days,
  dealerCredit90Days;

  String get displayName {
    switch (this) {
      case PaymentMethod.directUpi:
        return 'UPI / QR Payment';
      case PaymentMethod.directCard:
        return 'Credit / Debit Card';
      case PaymentMethod.directNetBanking:
        return 'Net Banking';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery (COD)';
      case PaymentMethod.dealerUpfront:
        return 'Upfront Bank Transfer';
      case PaymentMethod.dealerCredit30Days:
        return 'Credit Facility (Net 30 Days)';
      case PaymentMethod.dealerCredit90Days:
        return 'Credit Facility (Net 90 Days)';
    }
  }
}

class TrackingStep {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  const TrackingStep({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
  });
}

class OrderEntity {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final UserRole userRole;
  final List<CartItemEntity> items;
  final double subtotal;
  final double gstAmount;
  final double deliveryFee;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final String paymentStatus;
  final OrderStatus orderStatus;
  final DateTime createdAt;
  final DateTime? creditDueDate;
  final String shippingAddress;
  final List<TrackingStep> trackingSteps;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userRole,
    required this.items,
    required this.subtotal,
    required this.gstAmount,
    required this.deliveryFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
    this.creditDueDate,
    required this.shippingAddress,
    required this.trackingSteps,
  });

  OrderEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    UserRole? userRole,
    List<CartItemEntity>? items,
    double? subtotal,
    double? gstAmount,
    double? deliveryFee,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    String? paymentStatus,
    OrderStatus? orderStatus,
    DateTime? createdAt,
    DateTime? creditDueDate,
    String? shippingAddress,
    List<TrackingStep>? trackingSteps,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userRole: userRole ?? this.userRole,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      gstAmount: gstAmount ?? this.gstAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt ?? this.createdAt,
      creditDueDate: creditDueDate ?? this.creditDueDate,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingSteps: trackingSteps ?? this.trackingSteps,
    );
  }
}
