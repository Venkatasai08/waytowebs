import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/plumber/domain/entities/service_job_entity.dart';
import 'package:waytowebs_app/features/plumber/presentation/providers/plumber_provider.dart';

class AdminPlumberManagementScreen extends ConsumerWidget {
  const AdminPlumberManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final plumberState = ref.watch(plumberProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plumber Verification & Tasks'),
        backgroundColor: AppColors.plumberColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Assign New Service Job',
            onPressed: () => _showCreateJobDialog(context, ref),
          ),
        ],
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (users) {
          final plumbers = users.where((u) => u.role == UserRole.plumber).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Registered Technicians & Verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...plumbers.map((plumber) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.plumberColor.withValues(alpha: 0.1),
                      child: const Icon(Icons.plumbing, color: AppColors.plumberColor),
                    ),
                    title: Text(plumber.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('License: ${plumber.plumberLicenseNumber ?? "Pending"} • +91 ${plumber.phone}', style: const TextStyle(fontSize: 11)),
                    trailing: Switch(
                      value: plumber.isZohoVerified,
                      onChanged: (val) async {
                        await ref.read(authRepositoryProvider).updatePlumberStatus(
                              plumberId: plumber.id,
                              isVerified: val,
                            );
                        ref.invalidate(allUsersProvider);
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              const Text('All Service Activities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...plumberState.jobs.map((job) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: Text('Customer: ${job.customerName} • ${job.address}', style: const TextStyle(fontSize: 11)),
                    trailing: Text(job.status.displayName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.plumberColor)),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  void _showCreateJobDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final customerController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final payoutController = TextEditingController(text: '750');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign New Service Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Job Title / Requirement'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: customerController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Customer Phone'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Service Address'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: payoutController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Payout Amount (₹)'),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.plumberColor),
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                final newJob = ServiceJobEntity(
                  id: 'JOB-PLM-${DateTime.now().millisecondsSinceEpoch % 10000}',
                  title: titleController.text.trim(),
                  customerName: customerController.text.trim().isNotEmpty ? customerController.text.trim() : 'Customer',
                  customerPhone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : '9876543210',
                  address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : 'Bengaluru',
                  issueDescription: 'Direct assignment from administrator dispatch.',
                  status: ServiceJobStatus.assigned,
                  scheduledDate: DateTime.now().add(const Duration(hours: 3)),
                  estimatedPayout: double.tryParse(payoutController.text) ?? 750.0,
                  requiredParts: const ['Pipe Fitting', 'Teflon Tape'],
                );
                ref.read(plumberProvider.notifier).assignNewJob(newJob);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Dispatch Task'),
          ),
        ],
      ),
    );
  }
}
