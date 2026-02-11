import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/home/doctor_patient_chat_screen.dart';
import 'package:medigo_mobile/features/home/doctor_profile_screen.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/map_launcher.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:medigo_mobile/widgets/booking_card.dart';
import 'package:medigo_mobile/widgets/booking_request_card.dart';
import 'package:provider/provider.dart';

class DoctorBookingsScreen extends StatefulWidget {
  const DoctorBookingsScreen({super.key});

  @override
  State<DoctorBookingsScreen> createState() => _DoctorBookingsScreenState();
}

class _DoctorBookingsScreenState extends State<DoctorBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 24,
        title: const Text(
          'Bookings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoctorProfileScreen()),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Live'),
                Tab(text: 'Active'),
                Tab(text: 'Past'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLiveTab(),
                  _buildActiveTab(),
                  _buildPastTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTab() {
    final viewModel = context.watch<DoctorHomeViewModel>();
    final requests = viewModel.liveRequests;

    if (requests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        title: 'No live requests',
        subtitle: 'New requests will appear here when you\'re online.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final r = requests[i];
        return BookingRequestCard(
          request: r,
          onAccept: () => viewModel.acceptBooking(r.id),
          onDecline: () => viewModel.declineBooking(r.id),
        );
      },
    );
  }

  Widget _buildActiveTab() {
    final viewModel = context.watch<DoctorHomeViewModel>();
    final bookings = viewModel.activeBookings;

    if (bookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_busy_outlined,
        title: 'No active visits',
        subtitle: 'Accepted bookings will show here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: bookings.length,
      itemBuilder: (_, i) {
        final b = bookings[i];
        return BookingCard(
          booking: b,
          showCompleteButton: true,
          onComplete: () => viewModel.completeBooking(b.id),
          onNavigate: () => launchMapNavigation(b.patientLocation),
          onMessage: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorPatientChatScreen(
                patientName: b.patientName,
                bookingId: b.id,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPastTab() {
    final viewModel = context.watch<DoctorHomeViewModel>();
    final bookings = viewModel.pastBookings;

    if (bookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No past bookings',
        subtitle: 'Completed visits will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: bookings.length,
      itemBuilder: (_, i) {
        final b = bookings[i];
        return BookingCard(booking: b);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.bodySecondary.copyWith(fontSize: 16)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: AppTypography.bodySecondary.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
