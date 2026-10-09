import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:waytowebs_app/features/orders/domain/entities/order_entity.dart';
import 'package:waytowebs_app/features/products/data/models/product_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String userRole;
  final List<Map<String, dynamic>> itemsJson;
  final double subtotal;
  final double gstAmount;
  final double deliveryFee;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String createdAtIso;
  final String? creditDueDateIso;
  final String shippingAddress;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userRole,
    required this.itemsJson,
    required this.subtotal,
    required this.gstAmount,
    required this.deliveryFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAtIso,
    this.creditDueDateIso,
    required this.shippingAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['itemsJson'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userPhone: json['userPhone'] as String? ?? '',
      userRole: json['userRole'] as String? ?? 'customer',
      itemsJson: rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? 'directUpi',
      paymentStatus: json['paymentStatus'] as String? ?? 'Paid',
      orderStatus: json['orderStatus'] as String? ?? 'placed',
      createdAtIso: json['createdAtIso'] as String? ?? DateTime.now().toIso8601String(),
      creditDueDateIso: json['creditDueDateIso'] as String?,
      shippingAddress: json['shippingAddress'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userRole': userRole,
      'itemsJson': itemsJson,
      'subtotal': subtotal,
      'gstAmount': gstAmount,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'createdAtIso': createdAtIso,
      'creditDueDateIso': creditDueDateIso,
      'shippingAddress': shippingAddress,
    };
  }

  OrderEntity toEntity() {
    UserRole role;
    switch (userRole.toLowerCase()) {
      case 'dealer':
        role = UserRole.dealer;
        break;
      case 'plumber':
        role = UserRole.plumber;
        break;
      case 'admin':
        role = UserRole.admin;
        break;
      default:
        role = UserRole.customer;
    }

    PaymentMethod method;
    switch (paymentMethod) {
      case 'dealerUpfront':
        method = PaymentMethod.dealerUpfront;
        break;
      case 'dealerCredit30Days':
        method = PaymentMethod.dealerCredit30Days;
        break;
      case 'dealerCredit90Days':
        method = PaymentMethod.dealerCredit90Days;
        break;
      case 'directCard':
        method = PaymentMethod.directCard;
        break;
      case 'directNetBanking':
        method = PaymentMethod.directNetBanking;
        break;
      case 'cashOnDelivery':
        method = PaymentMethod.cashOnDelivery;
        break;
      default:
        method = PaymentMethod.directUpi;
    }

    OrderStatus status;
    switch (orderStatus) {
      case 'confirmed':
        status = OrderStatus.confirmed;
        break;
      case 'shipped':
        status = OrderStatus.shipped;
        break;
      case 'outForDelivery':
        status = OrderStatus.outForDelivery;
        break;
      case 'delivered':
        status = OrderStatus.delivered;
        break;
      case 'cancelled':
        status = OrderStatus.cancelled;
        break;
      default:
        status = OrderStatus.placed;
    }

    final parsedItems = itemsJson.map((item) {
      final prodModel = ProductModel.fromJson(item['product'] as Map<String, dynamic>);
      return CartItemEntity(
        product: prodModel.toEntity(),
        quantity: item['quantity'] as int? ?? 1,
        unitPrice: (item['unitPrice'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    final createdDate = DateTime.tryParse(createdAtIso) ?? DateTime.now();

    final trackingSteps = [
      TrackingStep(
        title: 'Order Placed',
        description: 'Order successfully submitted and registered.',
        timestamp: createdDate,
        isCompleted: true,
      ),
      TrackingStep(
        title: 'Zoho Sync & Confirmation',
        description: 'Validated in Zoho Inventory and reserved.',
        timestamp: createdDate.add(const Duration(minutes: 15)),
        isCompleted: status != OrderStatus.placed,
      ),
      TrackingStep(
        title: 'Dispatched from Warehouse',
        description: 'Packed and handed over to logistics.',
        timestamp: createdDate.add(const Duration(hours: 4)),
        isCompleted: status == OrderStatus.shipped || status == OrderStatus.outForDelivery || status == OrderStatus.delivered,
      ),
      TrackingStep(
        title: 'Out for Delivery',
        description: 'Courier agent is on the way to your address.',
        timestamp: createdDate.add(const Duration(hours: 8)),
        isCompleted: status == OrderStatus.outForDelivery || status == OrderStatus.delivered,
      ),
      TrackingStep(
        title: 'Delivered',
        description: 'Package delivered and received.',
        timestamp: createdDate.add(const Duration(hours: 12)),
        isCompleted: status == OrderStatus.delivered,
      ),
    ];

    return OrderEntity(
      id: id,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      userRole: role,
      items: parsedItems,
      subtotal: subtotal,
      gstAmount: gstAmount,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      paymentMethod: method,
      paymentStatus: paymentStatus,
      orderStatus: status,
      createdAt: createdDate,
      creditDueDate: creditDueDateIso != null ? DateTime.tryParse(creditDueDateIso!) : null,
      shippingAddress: shippingAddress,
      trackingSteps: trackingSteps,
    );
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    final itemsJson = entity.items.map((item) {
      return {
        'product': ProductModel.fromEntity(item.product).toJson(),
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
      };
    }).toList();

    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      userPhone: entity.userPhone,
      userRole: entity.userRole.name,
      itemsJson: itemsJson,
      subtotal: entity.subtotal,
      gstAmount: entity.gstAmount,
      deliveryFee: entity.deliveryFee,
      totalAmount: entity.totalAmount,
      paymentMethod: entity.paymentMethod.name,
      paymentStatus: entity.paymentStatus,
      orderStatus: entity.orderStatus.name,
      createdAtIso: entity.createdAt.toIso8601String(),
      creditDueDateIso: entity.creditDueDate?.toIso8601String(),
      shippingAddress: entity.shippingAddress,
    );
  }
}
