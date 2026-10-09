import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/features/plumber/domain/entities/service_job_entity.dart';

class PlumberState {
  final List<ServiceJobEntity> jobs;
  final bool isLoading;
  final String? errorMessage;
  final double totalEarnings;
  final double pendingPayout;
  final int completedJobsCount;

  const PlumberState({
    this.jobs = const [],
    this.isLoading = false,
    this.errorMessage,
    this.totalEarnings = 14250.0,
    this.pendingPayout = 3200.0,
    this.completedJobsCount = 18,
  });

  PlumberState copyWith({
    List<ServiceJobEntity>? jobs,
    bool? isLoading,
    String? errorMessage,
    double? totalEarnings,
    double? pendingPayout,
    int? completedJobsCount,
  }) {
    return PlumberState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      pendingPayout: pendingPayout ?? this.pendingPayout,
      completedJobsCount: completedJobsCount ?? this.completedJobsCount,
    );
  }
}

class PlumberNotifier extends StateNotifier<PlumberState> {
  PlumberNotifier() : super(const PlumberState()) {
    _loadInitialJobs();
  }

  void _loadInitialJobs() {
    final now = DateTime.now();
    final defaultJobs = [
      ServiceJobEntity(
        id: 'JOB-PLM-701',
        title: 'Openwell Submersible Pump Installation & Testing',
        customerName: 'Kavita Sundaram',
        customerPhone: '9845123450',
        address: 'Villa 14, Palm Grove Enclave, Whitefield, Bengaluru',
        issueDescription: 'Installation of 1HP water pump with non-return valve and pressure testing.',
        status: ServiceJobStatus.assigned,
        scheduledDate: now.add(const Duration(hours: 2)),
        estimatedPayout: 850.0,
        requiredParts: const ['1HP Submersible Pump', '25mm CPVC Adapter', 'Solvent Cement 250ml'],
      ),
      ServiceJobEntity(
        id: 'JOB-PLM-702',
        title: 'Bathroom Overhead Rain Shower & Bib Cock Replacement',
        customerName: 'Anand Mohan',
        customerPhone: '9900112233',
        address: 'Flat 5B, Skyline Heights, Indiranagar, Bengaluru',
        issueDescription: 'Replace old rusted shower arm and install 8x8 inch rain shower with 2 bib cock taps.',
        status: ServiceJobStatus.inProgress,
        scheduledDate: now.subtract(const Duration(hours: 1)),
        estimatedPayout: 650.0,
        requiredParts: const ['Rain Shower 8x8', 'Quarter Turn Bib Cock (x2)', 'Teflon Tape'],
      ),
      ServiceJobEntity(
        id: 'JOB-PLM-703',
        title: 'Main Pipeline CPVC Joint Leakage Repair',
        customerName: 'Deepak Rao',
        customerPhone: '9877001122',
        address: 'No 45, 3rd Cross, Malleshwaram, Bengaluru',
        issueDescription: 'Persistent hairline fracture in overhead line joint requiring section replacement.',
        status: ServiceJobStatus.completed,
        scheduledDate: now.subtract(const Duration(days: 1)),
        estimatedPayout: 500.0,
        requiredParts: const ['CPVC Pipe 1 inch', 'CPVC Coupling', 'Solvent Heavy Duty'],
        completionNotes: 'Section replaced and pressure tested at 6 bar with zero leakage.',
        completedAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ];

    state = state.copyWith(jobs: defaultJobs);
  }

  void updateJobStatus(String jobId, ServiceJobStatus newStatus, {String? notes}) {
    final updatedList = state.jobs.map((job) {
      if (job.id == jobId) {
        return job.copyWith(
          status: newStatus,
          completionNotes: notes ?? job.completionNotes,
          completedAt: newStatus == ServiceJobStatus.completed ? DateTime.now() : job.completedAt,
        );
      }
      return job;
    }).toList();

    double total = 0.0;
    double pending = 0.0;
    int completedCount = 0;

    for (final job in updatedList) {
      if (job.status == ServiceJobStatus.completed) {
        total += job.estimatedPayout;
        completedCount++;
      } else if (job.status == ServiceJobStatus.inProgress || job.status == ServiceJobStatus.assigned) {
        pending += job.estimatedPayout;
      }
    }

    state = state.copyWith(
      jobs: updatedList,
      totalEarnings: 14250.0 + total,
      pendingPayout: pending,
      completedJobsCount: 18 + completedCount,
    );
  }

  void assignNewJob(ServiceJobEntity job) {
    state = state.copyWith(jobs: [job, ...state.jobs]);
  }
}

final plumberProvider = StateNotifierProvider<PlumberNotifier, PlumberState>((ref) {
  return PlumberNotifier();
});
