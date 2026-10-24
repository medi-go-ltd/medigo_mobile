import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/route_info.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/location_utils.dart';
import 'package:medigo_mobile/widgets/review_card.dart';

class PatientDoctorProfileScreen extends StatelessWidget {
  const PatientDoctorProfileScreen({
    super.key,
    required this.doctor,
    this.routeInfo,
    this.userLocation,
    this.isNearestDoctor = false,
  });

  final Doctor doctor;
  final RouteInfo? routeInfo;
  final Location? userLocation;
  final bool isNearestDoctor;

  String get _distanceLabel {
    if (routeInfo != null) return routeInfo!.distance;
    if (userLocation != null) {
      final km = LocationUtils.distanceToDoctor(userLocation!, doctor);
      final miles = km * 0.621371;
      return '${miles.toStringAsFixed(1)} miles';
    }
    return '—';
  }

  String get _arrivalLabel {
    if (routeInfo != null) return routeInfo!.duration;
    final min = doctor.estimatedTime < 1 ? 1 : doctor.estimatedTime;
    final low = (min - 3).clamp(1, min);
    return '$low–${min + 3} mins';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Doctor profile'),
        titleTextStyle: AppTypography.body.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
              children: [
                _IdentityHeader(doctor: doctor),
                const SizedBox(height: 22),
                _MetricsStrip(
                  arrivalLabel: _arrivalLabel,
                  distanceLabel: _distanceLabel,
                  feeLabel: '£${doctor.fee.toInt()}',
                ),
                const SizedBox(height: 28),
                _Section(
                  title: 'About',
                  child: Text(
                    doctor.bio ??
                        'Experienced clinician available for home visits in your area.',
                    style: AppTypography.body.copyWith(
                      height: 1.55,
                      fontSize: 15,
                      color: AppColors.textPrimary.withValues(alpha: 0.88),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                _Section(
                  title: 'Credentials',
                  child: _CredentialsCard(doctor: doctor),
                ),
                const SizedBox(height: 26),
                _Section(
                  title: 'Visit details',
                  child: _VisitDetailsCard(
                    feeLabel: '£${doctor.fee.toInt()}',
                    feeIncludes: doctor.feeIncludes ??
                        'Includes home visit, clinical assessment, and a visit summary.',
                    clinicAddress: doctor.location.address ??
                        'Exact address shared after booking',
                    arrivalLabel: _arrivalLabel,
                    distanceLabel: _distanceLabel,
                  ),
                ),
                const SizedBox(height: 26),
                _Section(
                  title: 'Reviews',
                  trailing: Text(
                    '${doctor.rating.toStringAsFixed(1)} · ${doctor.reviewCount}',
                    style: AppTypography.bodySecondary.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: doctor.reviews.isEmpty
                      ? Text(
                          'No written reviews yet.',
                          style: AppTypography.bodySecondary.copyWith(
                            height: 1.4,
                          ),
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < doctor.reviews.length; i++) ...[
                              if (i > 0)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Divider(
                                    height: 1,
                                    color: AppColors.border,
                                  ),
                                ),
                              ReviewCard(review: doctor.reviews[i]),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
          _BookBar(
            onBook: () {
              Navigator.of(context).pushNamed(
                AppRoutes.patientBooking,
                arguments: PatientBookingArguments(
                  doctor: doctor,
                  isNearestDoctor: isNearestDoctor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.highlight,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 2,
            ),
            image: doctor.profileImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(doctor.profileImageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: doctor.profileImageUrl == null
              ? const Icon(
                  Icons.medical_services_outlined,
                  color: AppColors.primary,
                  size: 36,
                )
              : null,
        ),
        const SizedBox(height: 14),
        Text(
          doctor.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.highlight.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            doctor.specialty,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, color: AppColors.time, size: 18),
            const SizedBox(width: 4),
            Text(
              doctor.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${doctor.reviewCount} reviews)',
              style: AppTypography.bodySecondary.copyWith(fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricsStrip extends StatelessWidget {
  const _MetricsStrip({
    required this.arrivalLabel,
    required this.distanceLabel,
    required this.feeLabel,
  });

  final String arrivalLabel;
  final String distanceLabel;
  final String feeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricCell(
              label: 'ETA',
              value: arrivalLabel,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          Expanded(
            child: _MetricCell(
              label: 'Distance',
              value: distanceLabel,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          Expanded(
            child: _MetricCell(
              label: 'Fee',
              value: feeLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.bodySecondary.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _CredentialsCard extends StatelessWidget {
  const _CredentialsCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final rows = <({IconData icon, String label, String value})>[
      (
        icon: Icons.badge_outlined,
        label: 'GMC',
        value: doctor.gmcNumber ?? 'Verified',
      ),
      (
        icon: Icons.verified_user_outlined,
        label: 'Checks',
        value: 'GMC · DBS',
      ),
      if (doctor.yearsOfExperience != null)
        (
          icon: Icons.work_outline_rounded,
          label: 'Experience',
          value: '${doctor.yearsOfExperience} years',
        ),
      if (doctor.languages.isNotEmpty)
        (
          icon: Icons.translate_rounded,
          label: 'Languages',
          value: doctor.languages.join(', '),
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Icon(rows[i].icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 92,
                    child: Text(
                      rows[i].label,
                      style: AppTypography.bodySecondary.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rows[i].value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VisitDetailsCard extends StatelessWidget {
  const _VisitDetailsCard({
    required this.feeLabel,
    required this.feeIncludes,
    required this.clinicAddress,
    required this.arrivalLabel,
    required this.distanceLabel,
  });

  final String feeLabel;
  final String feeIncludes;
  final String clinicAddress;
  final String arrivalLabel;
  final String distanceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                feeLabel,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'visit fee',
                style: AppTypography.bodySecondary.copyWith(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            feeIncludes,
            style: AppTypography.bodySecondary.copyWith(
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.border),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clinic / base',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      clinicAddress,
                      style: AppTypography.body.copyWith(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$arrivalLabel · $distanceLabel away',
                      style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookBar extends StatelessWidget {
  const _BookBar({required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Book this doctor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
