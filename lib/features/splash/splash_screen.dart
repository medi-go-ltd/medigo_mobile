import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:medigo_mobile/constants/app_branding.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/utils/patient_navigation.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  final String title;
  final String logoAsset;

  const SplashScreen({
    super.key,
    this.onFinished,
    this.title = kAppDisplayName,
    this.logoAsset = 'assets/images/app-logo.png',
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ring1Controller;
  late final AnimationController _ring2Controller;

  late final Animation<double> _ring1Scale;
  late final Animation<double> _ring2Scale;
  late final Animation<double> _ring1Opacity;
  late final Animation<double> _ring2Opacity;

  Timer? _ring1StartTimer;
  Timer? _ring2StartTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _ring1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _ring2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _ring1Scale = Tween<double>(begin: 0.9, end: 1.25).animate(
      CurvedAnimation(parent: _ring1Controller, curve: Curves.easeInOut),
    );

    _ring1Opacity = Tween<double>(begin: 0.35, end: 0.02).animate(
      CurvedAnimation(parent: _ring1Controller, curve: Curves.easeInOut),
    );

    _ring2Scale = Tween<double>(begin: 1.1, end: 1.25).animate(
      CurvedAnimation(parent: _ring2Controller, curve: Curves.easeInOut),
    );

    _ring2Opacity = Tween<double>(begin: 0.25, end: 0.02).animate(
      CurvedAnimation(parent: _ring2Controller, curve: Curves.easeInOut),
    );

    _ring1StartTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _ring1Controller.repeat(reverse: true);
      }
    });

    _ring2StartTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        _ring2Controller.repeat(reverse: true);
      }
    });

    _navigationTimer = Timer(const Duration(milliseconds: 2000), () async {
      if (!mounted) return;

      final authViewModel = context.read<AuthViewModel>();
      while (authViewModel.isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
      }

      if (mounted) {
        if (authViewModel.isAuthenticated) {
          await navigateAfterAuth(context, authViewModel: authViewModel);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
        }
      }
    });
  }

  @override
  void dispose() {
    _ring1StartTimer?.cancel();
    _ring2StartTimer?.cancel();
    _navigationTimer?.cancel();
    _ring1Controller.dispose();
    _ring2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF2EA5B7);
    const dark = Color(0xFF1E2A32);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_ring1Controller]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _ring1Opacity.value,
                    child: Transform.scale(
                      scale: _ring1Scale.value,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: teal.withValues(alpha: 0.25),
                            width: 10,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: Listenable.merge([_ring2Controller]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _ring2Opacity.value,
                    child: Transform.scale(
                      scale: _ring2Scale.value,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: teal.withValues(alpha: 0.25),
                            width: 10,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF4DA8BC),
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      widget.logoAsset,
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: dark,
                      letterSpacing: 0.5,
                      fontFamily: 'MedigoSans',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
