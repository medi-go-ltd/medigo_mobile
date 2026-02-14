import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/payment_transaction.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/transaction_card.dart';
import 'package:medigo_mobile/widgets/scale_on_tap.dart';

class PaymentHistorySection extends StatelessWidget {
  const PaymentHistorySection({
    super.key,
    required this.history,
    required this.totalInPeriod,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<PaymentTransaction> history;
  final double totalInPeriod;
  final PaymentHistoryPeriod filter;
  final ValueChanged<PaymentHistoryPeriod> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _HistoryChip(
                  label: 'All',
                  value: PaymentHistoryPeriod.all,
                  selected: filter == PaymentHistoryPeriod.all,
                  onTap: () => onFilterChanged(PaymentHistoryPeriod.all),
                ),
                const SizedBox(width: 8),
                _HistoryChip(
                  label: 'This month',
                  value: PaymentHistoryPeriod.thisMonth,
                  selected: filter == PaymentHistoryPeriod.thisMonth,
                  onTap: () => onFilterChanged(PaymentHistoryPeriod.thisMonth),
                ),
                const SizedBox(width: 8),
                _HistoryChip(
                  label: 'Last 3 months',
                  value: PaymentHistoryPeriod.last3Months,
                  selected: filter == PaymentHistoryPeriod.last3Months,
                  onTap: () =>
                      onFilterChanged(PaymentHistoryPeriod.last3Months),
                ),
              ],
            ),
            if (history.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${history.length} ${history.length == 1 ? 'payment' : 'payments'} · £${totalInPeriod.toStringAsFixed(2)}',
                style: AppTypography.bodySecondary.copyWith(fontSize: 13),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.highlight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'No transactions in this period.',
                    style: AppTypography.bodySecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...history.map((t) => TransactionCard(transaction: t)),
      ],
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final PaymentHistoryPeriod value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
