import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/plumber/domain/entities/service_job_entity.dart';
import 'package:waytowebs_app/features/plumber/presentation/providers/plumber_provider.dart';

class PlumberJobsScreen extends ConsumerWidget {
  const PlumberJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plumberState = ref.watch(plumberProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Activities & Jobs'),
        backgroundColor: AppColors.plumberColor,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: plumberState.jobs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final job = plumberState.jobs[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(job.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getStatusColor(job.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _getStatusColor(job.status)),
                        ),
                        child: Text(
                          job.status.displayName,
                          style: TextStyle(
                            color: _getStatusColor(job.status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(
                    job.issueDescription,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_pin, size: 16, color: AppColors.plumberColor),
                            const SizedBox(width: 6),
                            Text('Customer: ${job.customerName} (${job.customerPhone})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(child: Text(job.address, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                          ],
                        ),
                        if (job.requiredParts.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.handyman_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text('Required Spares: ${job.requiredParts.join(", ")}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estimated Payout', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(
                            Formatters.formatCurrency(job.estimatedPayout),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.success),
                          ),
                        ],
                      ),
                      if (job.status == ServiceJobStatus.assigned)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.plumberColor),
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Start Work'),
                          onPressed: () {
                            ref.read(plumberProvider.notifier).updateJobStatus(job.id, ServiceJobStatus.inProgress);
                          },
                        )
                      else if (job.status == ServiceJobStatus.inProgress)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Mark Completed'),
                          onPressed: () {
                            _showCompletionDialog(context, ref, job.id);
                          },
                        )
                      else
                        const Row(
                          children: [
                            Icon(Icons.verified, color: AppColors.success, size: 18),
                            SizedBox(width: 4),
                            Text('Completed & Paid', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, WidgetRef ref, String jobId) {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Service Job'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter completion details and resolution notes:'),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g., Installation completed, joints tested at 6 bar pressure with zero leakage.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () {
              ref.read(plumberProvider.notifier).updateJobStatus(
                    jobId,
                    ServiceJobStatus.completed,
                    notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : 'Installation verified and tested.',
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Submit Completion'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ServiceJobStatus status) {
    switch (status) {
      case ServiceJobStatus.assigned:
        return Colors.blue;
      case ServiceJobStatus.inProgress:
        return Colors.orange;
      case ServiceJobStatus.completed:
        return AppColors.success;
      case ServiceJobStatus.cancelled:
        return AppColors.error;
    }
  }
}
