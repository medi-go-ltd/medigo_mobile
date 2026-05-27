import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/patient_booking_view_model.dart';
import 'package:medigo_mobile/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class PatientPaymentsScreen extends StatelessWidget {
  const PatientPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final payments = context.watch<PatientBookingViewModel>().payments;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payments', style: AppTypography.pageTitle),
          const SizedBox(height: 8),
          const Text(
            'Payment history for consultations',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: payments.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.payment_outlined,
                    title: 'No payments yet',
                    subtitle: 'Payments appear after completed visits.',
                  )
                : ListView.builder(
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return _PaymentCard(payment: payment);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final PaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final date =
        '${payment.date.day}/${payment.date.month}/${payment.date.year}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.highlight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.doctorName,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(payment.description, style: AppTypography.bodySecondary),
                  const SizedBox(height: 4),
                  Text(
                    '$date · ${payment.methodLabel}',
                    style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '£${payment.amount.toStringAsFixed(0)}',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
