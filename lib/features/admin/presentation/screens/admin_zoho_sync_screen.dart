import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/constants/app_constants.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/products/presentation/providers/product_provider.dart';

class AdminZohoSyncScreen extends ConsumerWidget {
  const AdminZohoSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoho Workbook & CRM Integration'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cloud_done, color: Colors.indigo, size: 24),
                      SizedBox(width: 8),
                      Text('Zoho API Endpoint & Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Workbook Rest API:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const SelectableText(
                      AppConstants.zohoWorkbookEndpoint,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Connection Status: Active (SSL 256-bit)', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          minimumSize: const Size(120, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        icon: productsState.isSyncing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.sync, size: 16),
                        label: const Text('Sync Now', style: TextStyle(fontSize: 12)),
                        onPressed: productsState.isSyncing
                            ? null
                            : () async {
                                await ref.read(productsProvider.notifier).triggerZohoWorkbookSync();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Zoho Workbook items synchronised successfully!')),
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Synchronized Zoho Inventory Sheet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
                columns: const [
                  DataColumn(label: Text('Item ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Retail Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Dealer Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Sync Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
                rows: productsState.products.map((p) {
                  return DataRow(
                    cells: [
                      DataCell(Text(p.zohoItemId, style: const TextStyle(fontSize: 11))),
                      DataCell(Text(p.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                      DataCell(Text('${p.stockQuantity} ${p.unit}s', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataCell(Text(Formatters.formatCurrency(p.customerPrice), style: const TextStyle(fontSize: 11))),
                      DataCell(Text(Formatters.formatCurrency(p.dealerPrice), style: const TextStyle(fontSize: 11, color: AppColors.dealerColor))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Live Synced', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
