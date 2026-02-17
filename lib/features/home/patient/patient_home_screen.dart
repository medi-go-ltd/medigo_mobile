import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/patient_home_view_model.dart';
import 'package:medigo_mobile/widgets/doctor_card.dart';
import 'package:medigo_mobile/widgets/patient_home_header.dart';
import 'package:medigo_mobile/widgets/patient_map_widget.dart';
import 'package:provider/provider.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<PatientHomeViewModel>();
      viewModel.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PatientHomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const PatientHomeHeader(),
            Expanded(
              child: Stack(
                children: [
                  PatientMapWidget(
                    viewModel: viewModel,
                    onMapCreated: (controller) {
                      viewModel.setMapController(controller);
                    },
                    onMapTap: () {
                      viewModel.clearSelection();
                    },
                    bottomPadding: viewModel.selectedDoctor != null ? 280 : 100,
                  ),
                  if (viewModel.selectedDoctor != null)
                    DoctorCard(
                      doctor: viewModel.selectedDoctor!,
                      routeInfo: viewModel.routeInfo,
                      selectedTravelMode: viewModel.selectedTravelMode,
                      onTravelModeChanged: (mode) async {
                        viewModel.setTravelMode(mode);
                        await viewModel.updateRouteForSelectedDoctor();
                      },
                      onDismissed: () {
                        viewModel.clearSelection();
                      },
                      onBookNow: () {
                        // TODO: Handle book now
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
        items: [
          BottomNavigationBarItem(
            icon: _currentIndex == 0
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.home),
                    ],
                  )
                : const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'Payments',
          ),
        ],
      ),
    );
  }
}
