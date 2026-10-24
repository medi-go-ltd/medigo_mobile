import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/body_diagram_widget.dart';

class PatientVisitHistoryDetailScreen extends StatelessWidget {
  const PatientVisitHistoryDetailScreen({super.key, required this.booking});

  final PatientBooking booking;

  static const _pageBackground = Color(0xFFF4F6F8);

  @override
  Widget build(BuildContext context) {
    final doctor = booking.doctor;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Visit Details',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DoctorHeroCard(
              name: doctor.fullName,
              specialty: doctor.specialty,
              rating: doctor.rating,
              initial: doctor.firstName.isNotEmpty
                  ? doctor.firstName[0]
                  : '?',
              status: booking.status,
            ),
            const SizedBox(height: 16),
            _QuickFactsRow(
              dateLabel: _formatDate(booking.createdAt),
              timeLabel: _formatTime(booking.createdAt),
              amount: booking.amount,
            ),
            for (final patient in booking.patients) ...[
              const SizedBox(height: 20),
              _SectionCard(
                icon: Icons.event_note_outlined,
                iconColor: AppColors.primary,
                iconBackground: AppColors.highlight,
                title: booking.patients.length > 1
                    ? 'Visit summary · ${patient.member?.firstName ?? 'You'}'
                    : 'Visit summary',
                children: [
                  _InfoTile(
                    icon: Icons.person_outline,
                    label: 'Appointment for',
                    value: patient.label,
                  ),
                  if (patient.bodyAreas.isNotEmpty)
                    _InfoTile(
                      icon: Icons.accessibility_new_outlined,
                      label: patient.bodyAreas.length == 1
                          ? 'Area of concern'
                          : 'Areas of concern',
                      value: BodyDiagramWidget.formatAreas(patient.bodyAreas),
                    ),
                  if (patient.description.isNotEmpty)
                    _InfoTile(
                      icon: Icons.notes_outlined,
                      label: 'Description',
                      value: patient.description,
                      multiline: true,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _TriageSection(triage: patient.triage),
            ],
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.payments_outlined,
              iconColor: AppColors.earnings,
              iconBackground: AppColors.earningsHighlight,
              title: 'Payment',
              children: [
                _PaymentHighlight(
                  amount: booking.amount,
                  method: booking.paymentMethodLabel,
                ),
              ],
            ),
            if (doctor.location.address != null) ...[
              const SizedBox(height: 16),
              _SectionCard(
                icon: Icons.location_on_outlined,
                iconColor: AppColors.info,
                iconBackground: AppColors.infoHighlight,
                title: 'Visit location',
                children: [
                  _InfoTile(
                    icon: Icons.place_outlined,
                    label: 'Address',
                    value: doctor.location.address!,
                    multiline: true,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _RatingSection(rating: booking.rating, review: booking.review),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _DoctorHeroCard extends StatelessWidget {
  const _DoctorHeroCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.initial,
    required this.status,
  });

  final String name;
  final String specialty;
  final double rating;
  final String initial;
  final PatientBookingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F6F9), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        specialty,
                        style: AppTypography.bodySecondary.copyWith(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final PatientBookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      PatientBookingStatus.completed => (
        'Completed',
        AppColors.earnings,
        AppColors.earningsHighlight,
      ),
      PatientBookingStatus.declined => (
        'Declined',
        AppColors.warning,
        AppColors.warningHighlight,
      ),
      PatientBookingStatus.pending => (
        'Pending',
        AppColors.time,
        AppColors.timeHighlight,
      ),
      _ => (
        status.name,
        AppColors.primary,
        AppColors.highlight,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _QuickFactsRow extends StatelessWidget {
  const _QuickFactsRow({
    required this.dateLabel,
    required this.timeLabel,
    required this.amount,
  });

  final String dateLabel;
  final String timeLabel;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickFactChip(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: dateLabel,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickFactChip(
            icon: Icons.schedule_outlined,
            label: 'Time',
            value: timeLabel,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickFactChip(
            icon: Icons.paid_outlined,
            label: 'Fee',
            value: '£${amount.toInt()}',
          ),
        ),
      ],
    );
  }
}

class _QuickFactChip extends StatelessWidget {
  const _QuickFactChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.bodySecondary.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TriageSection extends StatelessWidget {
  const _TriageSection({required this.triage});

  final TriageAnswers triage;

  @override
  Widget build(BuildContext context) {
    final symptoms = <(IconData, String)>[];
    if (triage.severeChestPain) {
      symptoms.add((Icons.favorite_border, 'Severe chest pain'));
    }
    if (triage.difficultyBreathing) {
      symptoms.add((Icons.air_outlined, 'Difficulty breathing'));
    }
    if (triage.severePain) {
      symptoms.add((Icons.healing_outlined, 'Severe pain'));
    }
    if (triage.lossOfConsciousness) {
      symptoms.add((Icons.psychology_outlined, 'Loss of consciousness'));
    }

    return _SectionCard(
      icon: Icons.medical_information_outlined,
      iconColor: triage.isUrgent ? AppColors.warning : AppColors.primary,
      iconBackground:
          triage.isUrgent ? AppColors.warningHighlight : AppColors.highlight,
      title: 'Triage',
      children: [
        if (triage.isUrgent)
          Container(
            margin: const EdgeInsets.fromLTRB(8, 4, 8, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningHighlight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Urgent symptoms were reported',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.earnings, size: 20),
                SizedBox(width: 10),
                Text(
                  'No urgent symptoms reported',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.earnings,
                  ),
                ),
              ],
            ),
          ),
        if (symptoms.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symptoms.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningHighlight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.$1, size: 16, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        s.$2,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _PaymentHighlight extends StatelessWidget {
  const _PaymentHighlight({required this.amount, required this.method});

  final double amount;
  final String method;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.earningsHighlight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.receipt_long_outlined, color: AppColors.earnings),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '£${amount.toInt()}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  method,
                  style: AppTypography.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  const _RatingSection({this.rating, this.review});

  final int? rating;
  final String? review;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star_outline, color: Colors.amber, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Your rating',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(20),
            child: rating == null
                ? Row(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'No rating submitted',
                        style: AppTypography.bodySecondary,
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              i < rating! ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: Colors.amber.shade600,
                              size: 32,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$rating out of 5',
                        style: AppTypography.bodySecondary.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (review != null && review!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _pageBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            review!,
                            style: AppTypography.body.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static const _pageBackground = PatientVisitHistoryDetailScreen._pageBackground;
}
