import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/plumber/presentation/providers/plumber_provider.dart';

class PlumberProfileScreen extends ConsumerWidget {
  const PlumberProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final plumberState = ref.watch(plumberProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plumber Partner Profile'),
        backgroundColor: AppColors.plumberColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.plumberColor.withValues(alpha: 0.15),
                    child: const Icon(Icons.plumbing, size: 40, color: AppColors.plumberColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Certified Plumber',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+91 ${user?.phone ?? ""}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 14, color: AppColors.success),
                        SizedBox(width: 4),
                        Text('Certified & Verified Technician', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                  const Text('Professional Credentials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  _buildDetailRow('License Number', user?.plumberLicenseNumber ?? 'PLUMB-IN-2024-889'),
                  const Divider(height: 16),
                  _buildDetailRow('Customer Rating', '${user?.rating ?? 4.9} / 5.0 (142 reviews)'),
                  const Divider(height: 16),
                  _buildDetailRow('Completed Activities', '${plumberState.completedJobsCount} Tasks'),
                  const Divider(height: 16),
                  _buildDetailRow('Verification Status', 'Zoho CRM Verified', isSuccess: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                  const Text('Earnings Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Realized Earnings', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(
                        Formatters.formatCurrency(plumberState.totalEarnings),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pending Payouts', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(
                        Formatters.formatCurrency(plumberState.pendingPayout),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Notification Preferences'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Instant SMS and Push notifications for new jobs enabled.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isSuccess = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isSuccess ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
