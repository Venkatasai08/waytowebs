import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:waytowebs_app/features/products/presentation/providers/product_provider.dart';
import 'package:waytowebs_app/features/products/presentation/widgets/product_card.dart';

class ProductListScreen extends ConsumerWidget {
  final String? initialCategoryId;

  const ProductListScreen({super.key, this.initialCategoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final cartState = ref.watch(cartProvider);
    final user = ref.watch(authStateProvider).user;
    final isDealer = user?.role == UserRole.dealer;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDealer ? 'Wholesale Inventory' : 'Products Catalog'),
        backgroundColor: isDealer ? AppColors.dealerColor : AppColors.primary,
        actions: [
          IconButton(
            icon: productsState.isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Sync with Zoho Workbook',
            onPressed: productsState.isSyncing
                ? null
                : () async {
                    await ref.read(productsProvider.notifier).triggerZohoWorkbookSync();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Synchronised with Zoho Workbook successfully')),
                      );
                    }
                  },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cartState.totalItemsCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartState.totalItemsCount}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => ref.read(productsProvider.notifier).updateSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search products, SKU or categories...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          Container(
            height: 48,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                  child: FilterChip(
                    label: const Text('All Categories'),
                    selected: productsState.selectedCategoryId == null,
                    onSelected: (_) => ref.read(productsProvider.notifier).selectCategory(null),
                    selectedColor: isDealer ? AppColors.dealerColor.withValues(alpha: 0.2) : AppColors.primaryLight.withValues(alpha: 0.2),
                  ),
                ),
                ...productsState.categories.map((cat) {
                  final isSelected = productsState.selectedCategoryId == cat.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                    child: FilterChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (_) => ref.read(productsProvider.notifier).selectCategory(cat.id),
                      selectedColor: isDealer ? AppColors.dealerColor.withValues(alpha: 0.2) : AppColors.primaryLight.withValues(alpha: 0.2),
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: isDealer ? AppColors.dealerColor.withValues(alpha: 0.08) : Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${productsState.filteredProducts.length} items available',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  isDealer ? 'Wholesale Pricing Active' : 'Retail Pricing Active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDealer ? AppColors.dealerColor : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: productsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productsState.filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            const Text('No products found matching your search.'),
                            TextButton(
                              onPressed: () {
                                ref.read(productsProvider.notifier).updateSearchQuery('');
                                ref.read(productsProvider.notifier).selectCategory(null);
                              },
                              child: const Text('Reset filters'),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: productsState.filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = productsState.filteredProducts[index];
                          return ProductCard(product: product);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
