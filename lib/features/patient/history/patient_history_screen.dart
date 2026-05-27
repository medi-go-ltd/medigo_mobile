import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/patient/history/patient_visit_history_detail_screen.dart';
import 'package:medigo_mobile/features/patient/widgets/patient_booking_card.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/patient_booking_view_model.dart';
import 'package:medigo_mobile/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class PatientHistoryScreen extends StatelessWidget {
  const PatientHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final completed = context.watch<PatientBookingViewModel>().completedBookings;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('History', style: AppTypography.pageTitle),
          const SizedBox(height: 8),
          const Text(
            'Past visits and ratings',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: completed.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.history,
                    title: 'No visit history yet',
                    subtitle: 'Completed appointments will appear here.',
                  )
                : ListView.builder(
                    itemCount: completed.length,
                    itemBuilder: (context, index) {
                      final booking = completed[index];
                      return PatientBookingCard(
                        booking: booking,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PatientVisitHistoryDetailScreen(
                                booking: booking,
                              ),
                            ),
                          );
                        },
                        trailing: booking.rating != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${booking.rating}'),
                                ],
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
