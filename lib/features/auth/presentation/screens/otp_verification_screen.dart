import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/constants/app_constants.dart';
import 'package:waytowebs_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/customer/presentation/screens/customer_dashboard_screen.dart';
import 'package:waytowebs_app/features/dealer/presentation/screens/dealer_dashboard_screen.dart';
import 'package:waytowebs_app/features/plumber/presentation/screens/plumber_dashboard_screen.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  final UserRole role;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.role,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  late final TextEditingController _otpController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController(text: AppConstants.defaultOtp);
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final otp = _otpController.text.trim();
    final success = await ref.read(authStateProvider.notifier).verifyOtpAndLogin(
          phone: widget.phone,
          otp: otp,
          role: widget.role,
        );

    if (success && mounted) {
      final user = ref.read(authStateProvider).user;
      final actualRole = user?.role ?? widget.role;
      Widget destination;
      switch (actualRole) {
        case UserRole.customer:
          destination = const CustomerDashboardScreen();
          break;
        case UserRole.dealer:
          destination = const DealerDashboardScreen();
          break;
        case UserRole.plumber:
          destination = const PlumberDashboardScreen();
          break;
        case UserRole.admin:
          destination = const AdminDashboardScreen();
          break;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 36,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Verify Your Phone',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Verification code generated for\n+91 ${widget.phone} (${widget.role.name.toUpperCase()})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.key, size: 18, color: Colors.orange),
                          SizedBox(width: 6),
                          Text(
                            'Template OTP Code: ${AppConstants.defaultOtp}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.brown),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _otpController.text = AppConstants.defaultOtp;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber.shade400),
                          ),
                          child: const Text(
                            'Tap to Auto-Fill 123456',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Enter 6-Digit OTP',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '123456',
                    counterText: '',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length != 6) {
                      return 'Enter the 6-digit OTP';
                    }
                    return null;
                  },
                ),
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleVerifyOtp,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify & Proceed to Dashboard'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      ref.read(authStateProvider.notifier).sendOtp(
                            phone: widget.phone,
                            role: widget.role,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Template OTP (${AppConstants.defaultOtp}) generated for +91 ${widget.phone}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Resend OTP'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
