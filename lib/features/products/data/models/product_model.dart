import 'package:waytowebs_app/features/products/domain/entities/product_entity.dart';

class ProductModel {
  final String id;
  final String zohoItemId;
  final String name;
  final String categoryId;
  final String categoryName;
  final double customerPrice;
  final double dealerPrice;
  final int stockQuantity;
  final String sku;
  final String unit;
  final String description;
  final String imageUrl;
  final Map<String, String> specifications;
  final bool isSyncedWithZoho;
  final String lastSyncedAtIso;

  const ProductModel({
    required this.id,
    required this.zohoItemId,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.customerPrice,
    required this.dealerPrice,
    required this.stockQuantity,
    required this.sku,
    required this.unit,
    required this.description,
    required this.imageUrl,
    required this.specifications,
    this.isSyncedWithZoho = true,
    required this.lastSyncedAtIso,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> specs = {};
    if (json['specifications'] != null) {
      final rawSpecs = json['specifications'] as Map<String, dynamic>;
      specs = rawSpecs.map((k, v) => MapEntry(k, v.toString()));
    }

    return ProductModel(
      id: json['id'] as String? ?? '',
      zohoItemId: json['zohoItemId'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      customerPrice: (json['customerPrice'] as num?)?.toDouble() ?? 0.0,
      dealerPrice: (json['dealerPrice'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      sku: json['sku'] as String? ?? '',
      unit: json['unit'] as String? ?? 'Piece',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      specifications: specs,
      isSyncedWithZoho: json['isSyncedWithZoho'] as bool? ?? true,
      lastSyncedAtIso: json['lastSyncedAtIso'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zohoItemId': zohoItemId,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'customerPrice': customerPrice,
      'dealerPrice': dealerPrice,
      'stockQuantity': stockQuantity,
      'sku': sku,
      'unit': unit,
      'description': description,
      'imageUrl': imageUrl,
      'specifications': specifications,
      'isSyncedWithZoho': isSyncedWithZoho,
      'lastSyncedAtIso': lastSyncedAtIso,
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      zohoItemId: zohoItemId,
      name: name,
      categoryId: categoryId,
      categoryName: categoryName,
      customerPrice: customerPrice,
      dealerPrice: dealerPrice,
      stockQuantity: stockQuantity,
      sku: sku,
      unit: unit,
      description: description,
      imageUrl: imageUrl,
      specifications: specifications,
      isSyncedWithZoho: isSyncedWithZoho,
      lastSyncedAt: DateTime.tryParse(lastSyncedAtIso) ?? DateTime.now(),
    );
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      zohoItemId: entity.zohoItemId,
      name: entity.name,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      customerPrice: entity.customerPrice,
      dealerPrice: entity.dealerPrice,
      stockQuantity: entity.stockQuantity,
      sku: entity.sku,
      unit: entity.unit,
      description: entity.description,
      imageUrl: entity.imageUrl,
      specifications: entity.specifications,
      isSyncedWithZoho: entity.isSyncedWithZoho,
      lastSyncedAtIso: entity.lastSyncedAt.toIso8601String(),
    );
  }
}
