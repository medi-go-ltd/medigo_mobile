import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medigo_mobile/features/home/doctor_bookings_screen.dart';
import 'package:medigo_mobile/features/home/doctor_history_screen.dart';
import 'package:medigo_mobile/features/home/doctor_payments_screen.dart';
import 'package:medigo_mobile/features/home/doctor_profile_screen.dart';
import 'package:medigo_mobile/features/home/set_radius_screen.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:medigo_mobile/widgets/booking_request_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentIndex == 0) _buildHeader(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTabContent() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const DoctorBookingsScreen();
      case 2:
        return const DoctorHistoryScreen();
      case 3:
        return const DoctorPaymentsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildDoctorProfileCard(),
          const SizedBox(height: 32),
          _buildLiveRequestsSection(),
          const SizedBox(height: 24),
          _buildSetRadiusButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final user = context.watch<AuthViewModel>().user;
    final firstName = user?.firstName ?? '';
    final greeting = firstName.isNotEmpty ? 'Welcome back, $firstName' : 'Welcome back';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: user?.profileImageUrl != null
                ? Image.network(
                    user!.profileImageUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildHeaderAvatar(),
                  )
                : _buildHeaderAvatar(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Ready to see patients?',
                  style: AppTypography.bodySecondary.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Open notifications
            },
            icon: const Icon(
              Icons.notifications_outlined,
              size: 26,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () => _showProfileMenu(context),
            icon: const Icon(
              Icons.settings_outlined,
              size: 26,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAvatar() {
    return Image.asset(
      'assets/images/doctor.png',
      width: 44,
      height: 44,
      fit: BoxFit.cover,
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DoctorProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () async {
                Navigator.pop(ctx);
                final authViewModel = context.read<AuthViewModel>();
                await authViewModel.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorProfileCard() {
    final user = context.watch<AuthViewModel>().user;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: user?.profileImageUrl != null
                    ? Image.network(
                        user!.profileImageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                      )
                    : _buildDefaultAvatar(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null
                          ? 'Dr. ${user.firstName} ${user.lastName}'
                          : 'Loading...',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (user?.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user!.email,
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildRatingRow(),
                    const SizedBox(height: 8),
                    _buildSpecialties(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAvailabilityStatus(),
          const SizedBox(height: 16),
          _buildReviewsSummary(),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Image.asset(
      'assets/images/doctor.png',
      width: 80,
      height: 80,
      fit: BoxFit.cover,
    );
  }

  static const double _mockRating = 4.9;
  static const int _mockReviewCount = 127;
  static const List<Map<String, String>> _mockReviews = [
    {'name': 'Sarah M.', 'text': 'Very professional and thorough. Highly recommend!'},
    {'name': 'John K.', 'text': 'Great bedside manner, explained everything clearly.'},
    {'name': 'Emma L.', 'text': 'Arrived promptly and was very knowledgeable. Felt at ease throughout the visit.'},
    {'name': 'David P.', 'text': 'Excellent doctor. Took time to listen and address all my concerns.'},
  ];

  Widget _buildRatingRow() {
    return Row(
      children: [
        const Text(
          '$_mockRating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          if (index < 4) {
            return const Icon(Icons.star, size: 16, color: Colors.amber);
          }
          return const Icon(Icons.star_half, size: 16, color: Colors.amber);
        }),
        const SizedBox(width: 8),
        Text(
          '($_mockReviewCount reviews)',
          style: AppTypography.bodySecondary.copyWith(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildReviewsSummary() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 140),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.highlight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.rate_review_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Recent reviews',
                  style: AppTypography.bodySecondary.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._mockReviews.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.bodySecondary.copyWith(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: '${r['name']} ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: r['text']),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialties() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildSpecialtyChip('General Medicine'),
        _buildSpecialtyChip('Dermatology'),
      ],
    );
  }

  Widget _buildSpecialtyChip(String specialty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.highlight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        specialty,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildAvailabilityStatus() {
    final viewModel = context.watch<DoctorHomeViewModel>();
    final isOnline = viewModel.isOnline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: AppTypography.bodySecondary.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 1.4),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSegment(
                  label: 'Online',
                  isSelected: isOnline,
                  isFirst: true,
                  onTap: () => viewModel.setOnline(true),
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.border),
              Expanded(
                child: _buildSegment(
                  label: 'Offline',
                  isSelected: !isOnline,
                  isFirst: false,
                  onTap: () => viewModel.setOnline(false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegment({
    required String label,
    required bool isSelected,
    required bool isFirst,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: isFirst
              ? const BorderRadius.horizontal(left: Radius.circular(8))
              : const BorderRadius.horizontal(right: Radius.circular(8)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.surface : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLiveRequestsSection() {
    final viewModel = context.watch<DoctorHomeViewModel>();
    final requests = viewModel.liveRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Live Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (requests.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${requests.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Status will auto-switch to 'On a visit' after accepting.",
          style: AppTypography.bodySecondary.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 16),
        if (requests.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.highlight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.inbox_outlined, size: 32, color: AppColors.textSecondary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No live requests right now. New requests will appear when you\'re online.',
                    style: AppTypography.bodySecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...requests.map(
            (r) => BookingRequestCard(
              request: r,
              onAccept: () => viewModel.acceptBooking(r.id),
              onDecline: () => viewModel.declineBooking(r.id),
            ),
          ),
        const SizedBox(height: 20),
        _buildMetricsRow(),
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'Earnings Today',
            value: '£125',
            icon: Icons.attach_money,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            label: 'Online Time',
            value: '4 h 12 m',
            icon: Icons.access_time,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            label: 'Avg. Response',
            value: '7 min',
            icon: Icons.timer_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.highlight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySecondary.copyWith(fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSetRadiusButton() {
    final viewModel = context.watch<DoctorHomeViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (viewModel.radiusKm > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Current radius: ${viewModel.radiusKm.round()} km',
              style: AppTypography.bodySecondary.copyWith(fontSize: 13),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SetRadiusScreen(
                    initialRadius: viewModel.radiusKm,
                    initialIsAvailable: viewModel.isOnline,
                    onSave: (radius, setAvailable) {
                      viewModel.setRadius(radius);
                      if (setAvailable) viewModel.setOnline(true);
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Set Radius',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            activeIcon: Icon(Icons.check_box),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Payments',
          ),
        ],
      ),
    );
  }
}
