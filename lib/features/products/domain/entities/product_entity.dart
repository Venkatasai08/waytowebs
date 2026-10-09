class ProductEntity {
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
  final DateTime lastSyncedAt;

  const ProductEntity({
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
    required this.lastSyncedAt,
  });

  bool get isInStock => stockQuantity > 0;

  ProductEntity copyWith({
    String? id,
    String? zohoItemId,
    String? name,
    String? categoryId,
    String? categoryName,
    double? customerPrice,
    double? dealerPrice,
    int? stockQuantity,
    String? sku,
    String? unit,
    String? description,
    String? imageUrl,
    Map<String, String>? specifications,
    bool? isSyncedWithZoho,
    DateTime? lastSyncedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      zohoItemId: zohoItemId ?? this.zohoItemId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      customerPrice: customerPrice ?? this.customerPrice,
      dealerPrice: dealerPrice ?? this.dealerPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      sku: sku ?? this.sku,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      specifications: specifications ?? this.specifications,
      isSyncedWithZoho: isSyncedWithZoho ?? this.isSyncedWithZoho,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
