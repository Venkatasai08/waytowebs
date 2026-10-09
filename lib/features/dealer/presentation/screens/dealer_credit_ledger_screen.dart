import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/orders/domain/entities/order_entity.dart';
import 'package:waytowebs_app/features/orders/presentation/providers/order_provider.dart';

class DealerCreditLedgerScreen extends ConsumerWidget {
  const DealerCreditLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final ordersState = ref.watch(ordersProvider);

    final creditOrders = ordersState.allOrders.where((o) {
      final isMine = o.userId == user?.id || o.userPhone == user?.phone;
      final isCredit = o.paymentMethod == PaymentMethod.dealerCredit30Days || o.paymentMethod == PaymentMethod.dealerCredit90Days;
      return isMine && isCredit;
    }).toList();

    final creditLimit = user?.creditLimit ?? 0.0;
    final availableCredit = user?.availableCredit ?? 0.0;
    final usedCredit = (creditLimit - availableCredit).clamp(0.0, creditLimit);

    return Scaffold(
      appBar: AppBar(
        title: const Text('B2B Credit Facility & Ledger'),
        backgroundColor: AppColors.dealerColor,
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
                  const Text('Assigned Credit Terms & Permissions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: user?.credit30DaysApproved == true ? Colors.blue.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: user?.credit30DaysApproved == true ? Colors.blue.shade300 : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('30-Day Credit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                user?.credit30DaysApproved == true ? 'Active & Approved' : 'Not Approved',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: user?.credit30DaysApproved == true ? Colors.blue.shade900 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: user?.credit90DaysApproved == true ? Colors.purple.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: user?.credit90DaysApproved == true ? Colors.purple.shade300 : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('90-Day Credit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                user?.credit90DaysApproved == true ? 'Active (VIP Dealer)' : 'Requires Admin Grant',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: user?.credit90DaysApproved == true ? Colors.purple.shade900 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Credit Line:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(Formatters.formatCurrency(creditLimit), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Outstanding Balance:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(
                        Formatters.formatCurrency(usedCredit),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Remaining Available Balance:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(
                        Formatters.formatCurrency(availableCredit),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.success),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Credit Invoices & Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (creditOrders.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text('No credit invoices recorded yet.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...creditOrders.map((order) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: const Text('Credit Due', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(order.paymentStatus, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Invoice Date: ${Formatters.formatShortDate(order.createdAt)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              Formatters.formatCurrency(order.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.dealerColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
