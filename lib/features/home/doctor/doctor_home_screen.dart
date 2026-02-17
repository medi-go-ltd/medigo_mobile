import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_appointments_screen.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_earnings_screen.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_history_screen.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/doctor_bottom_nav_bar.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/doctor_profile_card.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/doctor_sliver_app_bar.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/live_requests_section.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/set_radius_button.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  static const double _appBarExpandedHeight = 92;
  bool _isAppBarCollapsed = false;
  int? _pressedNavIndex;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final collapseThreshold = _appBarExpandedHeight - kToolbarHeight;
    final collapsed = offset > collapseThreshold * 0.3;
    if (collapsed != _isAppBarCollapsed && mounted) {
      setState(() => _isAppBarCollapsed = collapsed);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _currentIndex = 0;
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: _currentIndex == 0
            ? _buildHomeWithSliverAppBar()
            : SafeArea(child: _buildTabContent()),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildHomeWithSliverAppBar() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        DoctorSliverAppBar(
          isAppBarCollapsed: _isAppBarCollapsed,
          expandedHeight: _appBarExpandedHeight,
        ),
        SliverToBoxAdapter(child: _buildHomeContent()),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const DoctorAppointmentsScreen();
      case 2:
        return const DoctorHistoryScreen();
      case 3:
        return const DoctorEarningsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24),
          DoctorProfileCard(),
          SizedBox(height: 32),
          LiveRequestsSection(),
          SizedBox(height: 24),
          SetRadiusButton(),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return DoctorBottomNavBar(
      currentIndex: _currentIndex,
      pressedNavIndex: _pressedNavIndex,
      onIndexChanged: (index) => setState(() => _currentIndex = index),
      onPressedChange: (index) => setState(() => _pressedNavIndex = index),
    );
  }
}
