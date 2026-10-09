import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waytowebs_app/core/network/zoho_api_client.dart';
import 'package:waytowebs_app/features/products/data/models/category_model.dart';
import 'package:waytowebs_app/features/products/data/models/product_model.dart';

abstract class ZohoWorkbookSyncService {
  Future<List<ProductModel>> fetchAndSyncWorkbookProducts();
  Future<List<CategoryModel>> getCategories();
  Future<void> updateLocalProductStock(String productId, int newStock);
  Future<void> updateLocalProductPrices(String productId, double customerPrice, double dealerPrice);
}

class ZohoWorkbookSyncServiceImpl implements ZohoWorkbookSyncService {
  final ZohoApiClient zohoApiClient;
  final SharedPreferences sharedPreferences;

  static const String _cachedProductsKey = 'zoho_synced_products_store';
  static const String _lastSyncTimeKey = 'zoho_last_sync_timestamp';

  ZohoWorkbookSyncServiceImpl({
    required this.zohoApiClient,
    required this.sharedPreferences,
  });

  @override
  Future<List<ProductModel>> fetchAndSyncWorkbookProducts() async {
    final cached = sharedPreferences.getString(_cachedProductsKey);
    if (cached != null) {
      try {
        final decoded = jsonDecode(cached) as List<dynamic>;
        return decoded.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    final data = await zohoApiClient.fetchWorkbookData();
    final rawItems = data['workbook_items'] as List<dynamic>;
    final now = DateTime.now().toIso8601String();

    final products = rawItems.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      map['lastSyncedAtIso'] = now;
      map['isSyncedWithZoho'] = true;
      return ProductModel.fromJson(map);
    }).toList();

    await _saveProductsToStorage(products);
    await sharedPreferences.setString(_lastSyncTimeKey, now);

    return products;
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    return const [
      CategoryModel(
        id: 'cat_pipes',
        name: 'Pipes & Fittings',
        description: 'CPVC, UPVC, and SWR pipes and specialized brass fittings',
        iconCode: 'plumbing',
      ),
      CategoryModel(
        id: 'cat_faucets',
        name: 'Faucets & Taps',
        description: 'Quarter turn, sensor, pillar, and bib cock taps',
        iconCode: 'water_drop',
      ),
      CategoryModel(
        id: 'cat_sanitary',
        name: 'Sanitaryware',
        description: 'Showers, health faucets, drainers, and bathroom accessories',
        iconCode: 'shower',
      ),
      CategoryModel(
        id: 'cat_pumps',
        name: 'Pumps & Motors',
        description: 'Openwell submersible, monoblock, and pressure booster pumps',
        iconCode: 'electric_bolt',
      ),
      CategoryModel(
        id: 'cat_adhesives',
        name: 'Solvents & Adhesives',
        description: 'Heavy duty pipe jointing solvent cements and thread seal tapes',
        iconCode: 'format_paint',
      ),
      CategoryModel(
        id: 'cat_tools',
        name: 'Plumbing Tools',
        description: 'Professional pipe wrenches, cutters, and flaring toolkits',
        iconCode: 'build',
      ),
    ];
  }

  @override
  Future<void> updateLocalProductStock(String productId, int newStock) async {
    final products = await fetchAndSyncWorkbookProducts();
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final old = products[index];
      products[index] = ProductModel(
        id: old.id,
        zohoItemId: old.zohoItemId,
        name: old.name,
        categoryId: old.categoryId,
        categoryName: old.categoryName,
        customerPrice: old.customerPrice,
        dealerPrice: old.dealerPrice,
        stockQuantity: newStock,
        sku: old.sku,
        unit: old.unit,
        description: old.description,
        imageUrl: old.imageUrl,
        specifications: old.specifications,
        isSyncedWithZoho: true,
        lastSyncedAtIso: DateTime.now().toIso8601String(),
      );
      await _saveProductsToStorage(products);
    }
  }

  @override
  Future<void> updateLocalProductPrices(String productId, double customerPrice, double dealerPrice) async {
    final products = await fetchAndSyncWorkbookProducts();
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final old = products[index];
      products[index] = ProductModel(
        id: old.id,
        zohoItemId: old.zohoItemId,
        name: old.name,
        categoryId: old.categoryId,
        categoryName: old.categoryName,
        customerPrice: customerPrice,
        dealerPrice: dealerPrice,
        stockQuantity: old.stockQuantity,
        sku: old.sku,
        unit: old.unit,
        description: old.description,
        imageUrl: old.imageUrl,
        specifications: old.specifications,
        isSyncedWithZoho: true,
        lastSyncedAtIso: DateTime.now().toIso8601String(),
      );
      await _saveProductsToStorage(products);
    }
  }

  Future<void> _saveProductsToStorage(List<ProductModel> products) async {
    final encoded = jsonEncode(products.map((p) => p.toJson()).toList());
    await sharedPreferences.setString(_cachedProductsKey, encoded);
  }
}
