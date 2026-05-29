import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/patient/appointments/patient_appointments_screen.dart';
import 'package:medigo_mobile/features/patient/history/patient_history_screen.dart';
import 'package:medigo_mobile/features/patient/payments/patient_payments_screen.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
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
      context.read<PatientHomeViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(child: _buildBody()),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildMapHome();
      case 1:
        return const PatientAppointmentsScreen();
      case 2:
        return const PatientHistoryScreen();
      case 3:
        return const PatientPaymentsScreen();
      default:
        return _buildMapHome();
    }
  }

  Widget _buildMapHome() {
    final viewModel = context.watch<PatientHomeViewModel>();

    return Column(
      children: [
        const PatientHomeHeader(),
        Expanded(
          child: Stack(
            children: [
              PatientMapWidget(
                viewModel: viewModel,
                onMapCreated: viewModel.setMapController,
                onMapTap: viewModel.clearSelection,
                bottomPadding: viewModel.selectedDoctor != null ? 340 : 100,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: _buildFindNearestButton(viewModel),
                    ),
                    if (viewModel.selectedDoctor != null)
                      DoctorCard(
                        doctor: viewModel.selectedDoctor!,
                        routeInfo: viewModel.routeInfo,
                        userLocation: viewModel.userLocation,
                        onDismissed: viewModel.clearSelection,
                        onBookNow: () => _startBooking(
                          viewModel.selectedDoctor!,
                          isNearestDoctor: false,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFindNearestButton(PatientHomeViewModel viewModel) {
    return ElevatedButton.icon(
      onPressed: viewModel.nearestAvailableDoctor == null
          ? null
          : () => _startBooking(
              viewModel.nearestAvailableDoctor!,
              isNearestDoctor: true,
            ),
      icon: const Icon(Icons.near_me),
      label: const Text('Find Nearest Available Doctor'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _startBooking(Doctor doctor, {required bool isNearestDoctor}) {
    Navigator.of(context).pushNamed(
      AppRoutes.patientBooking,
      arguments: PatientBookingArguments(
        doctor: doctor,
        isNearestDoctor: isNearestDoctor,
      ),
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
        onTap: (index) => setState(() => _currentIndex = index),
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
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'Payments',
          ),
        ],
      ),
    );
  }
}
