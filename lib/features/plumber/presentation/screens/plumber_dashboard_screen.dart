import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/core/widgets/app_drawer.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/plumber/domain/entities/service_job_entity.dart';
import 'package:waytowebs_app/features/plumber/presentation/providers/plumber_provider.dart';
import 'package:waytowebs_app/features/plumber/presentation/screens/plumber_catalog_screen.dart';
import 'package:waytowebs_app/features/plumber/presentation/screens/plumber_jobs_screen.dart';
import 'package:waytowebs_app/features/plumber/presentation/screens/plumber_profile_screen.dart';

class PlumberDashboardScreen extends ConsumerWidget {
  const PlumberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final plumberState = ref.watch(plumberProvider);

    final assignedJobs = plumberState.jobs.where((j) => j.status == ServiceJobStatus.assigned).toList();
    final inProgressJobs = plumberState.jobs.where((j) => j.status == ServiceJobStatus.inProgress).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Plumber Service Portal'),
        backgroundColor: AppColors.plumberColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlumberProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.plumberColor, Color(0xFF0369A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Certified Plumber',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'License: ${user?.plumberLicenseNumber ?? "PLUMB-IN-2024-889"}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${user?.rating ?? 4.9} ★',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Earnings', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                Formatters.formatCurrency(plumberState.totalEarnings),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Completed Jobs', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                '${plumberState.completedJobsCount} Tasks',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      title: 'Assigned Activities',
                      subtitle: '${assignedJobs.length + inProgressJobs.length} active tasks',
                      icon: Icons.assignment,
                      color: AppColors.plumberColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PlumberJobsScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionTile(
                      title: 'Spares & Manuals',
                      subtitle: 'Technical guide',
                      icon: Icons.menu_book,
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PlumberCatalogScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Service Assignments',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlumberJobsScreen()),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            if (plumberState.jobs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No assigned jobs currently.')),
              )
            else
              ...plumberState.jobs.map((job) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(job.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getJobStatusColor(job.status).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: _getJobStatusColor(job.status)),
                              ),
                              child: Text(
                                job.status.displayName,
                                style: TextStyle(
                                  color: _getJobStatusColor(job.status),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(job.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(job.customerName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(width: 12),
                            const Icon(Icons.phone, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(job.customerPhone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(job.address, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Payout: ${Formatters.formatCurrency(job.estimatedPayout)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success),
                            ),
                            if (job.status == ServiceJobStatus.assigned)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.plumberColor,
                                  minimumSize: const Size(90, 32),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                onPressed: () {
                                  ref.read(plumberProvider.notifier).updateJobStatus(job.id, ServiceJobStatus.inProgress);
                                },
                                child: const Text('Start Work', style: TextStyle(fontSize: 11)),
                              )
                            else if (job.status == ServiceJobStatus.inProgress)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  minimumSize: const Size(90, 32),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                onPressed: () {
                                  ref.read(plumberProvider.notifier).updateJobStatus(
                                        job.id,
                                        ServiceJobStatus.completed,
                                        notes: 'Work completed and validated.',
                                      );
                                },
                                child: const Text('Complete Job', style: TextStyle(fontSize: 11)),
                              )
                            else
                              const Text('Completed ✓', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Color _getJobStatusColor(ServiceJobStatus status) {
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

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
