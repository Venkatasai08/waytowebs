import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';

class AdminDealerManagementScreen extends ConsumerWidget {
  const AdminDealerManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer & Credit Permissions'),
        backgroundColor: AppColors.dealerColor,
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (users) {
          final dealers = users.where((u) => u.role == UserRole.dealer).toList();

          if (dealers.isEmpty) {
            return const Center(child: Text('No registered dealers found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: dealers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final dealer = dealers[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dealer.companyName ?? dealer.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  'Phone: ${dealer.phone} • GST: ${dealer.gstNumber ?? "N/A"}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: dealer.isZohoVerified ? AppColors.success.withValues(alpha: 0.15) : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: dealer.isZohoVerified ? AppColors.success : Colors.orange),
                            ),
                            child: Text(
                              dealer.isZohoVerified ? 'Zoho Verified' : 'Unverified',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: dealer.isZohoVerified ? AppColors.success : Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Credit Limit:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            Formatters.formatCurrency(dealer.creditLimit),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available Credit Balance:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            Formatters.formatCurrency(dealer.availableCredit),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildPermissionChip('30-Day Credit', dealer.credit30DaysApproved),
                          const SizedBox(width: 8),
                          _buildPermissionChip('90-Day Credit', dealer.credit90DaysApproved),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.dealerColor,
                            side: const BorderSide(color: AppColors.dealerColor),
                            minimumSize: const Size(140, 36),
                          ),
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text('Edit Permissions', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            _showEditPermissionsDialog(context, ref, dealer);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPermissionChip(String label, bool isApproved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isApproved ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isApproved ? Colors.green : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isApproved ? Icons.check_circle : Icons.cancel, size: 12, color: isApproved ? Colors.green : Colors.grey),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isApproved ? Colors.green.shade900 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPermissionsDialog(BuildContext context, WidgetRef ref, UserEntity dealer) {
    bool isZohoVerified = dealer.isZohoVerified;
    bool credit30 = dealer.credit30DaysApproved;
    bool credit90 = dealer.credit90DaysApproved;
    final limitController = TextEditingController(text: dealer.creditLimit.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit ${dealer.companyName ?? dealer.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Zoho Verified Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Allows dealer to authenticate via OTP', style: TextStyle(fontSize: 11)),
                  value: isZohoVerified,
                  onChanged: (val) => setState(() => isZohoVerified = val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('30-Day Credit Terms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Enable standard Net 30 B2B credit', style: TextStyle(fontSize: 11)),
                  value: credit30,
                  onChanged: (val) => setState(() => credit30 = val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('90-Day Credit Terms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Exclusive VIP Net 90 credit terms', style: TextStyle(fontSize: 11)),
                  value: credit90,
                  onChanged: (val) => setState(() => credit90 = val),
                ),
                const SizedBox(height: 8),
                const Text('Credit Limit (₹):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                TextField(
                  controller: limitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    hintText: 'Enter maximum credit limit',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.dealerColor),
              onPressed: () async {
                final newLimit = double.tryParse(limitController.text) ?? dealer.creditLimit;
                await ref.read(authRepositoryProvider).updateDealerCreditPermissions(
                      dealerId: dealer.id,
                      credit30Approved: credit30,
                      credit90Approved: credit90,
                      creditLimit: newLimit,
                      isZohoVerified: isZohoVerified,
                    );
                ref.invalidate(allUsersProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}
