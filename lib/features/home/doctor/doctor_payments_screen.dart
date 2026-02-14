import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/earnings_by_type_section.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/earnings_chart_section.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/payment_history_section.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/projected_earnings_card.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/total_earnings_card.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/upcoming_earnings_card.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:medigo_mobile/widgets/doctor_screen_app_bar.dart';
import 'package:provider/provider.dart';

class DoctorPaymentsScreen extends StatefulWidget {
  const DoctorPaymentsScreen({super.key});

  @override
  State<DoctorPaymentsScreen> createState() => _DoctorPaymentsScreenState();
}

class _DoctorPaymentsScreenState extends State<DoctorPaymentsScreen>
    with TickerProviderStateMixin {
  int _chartDays = 7;
  PaymentHistoryPeriod _historyFilter = PaymentHistoryPeriod.all;

  bool _animationsInitialized = false;

  AnimationController? _entryController;
  Animation<double>? _totalEarningsAnim;
  Animation<double>? _chartAnim;
  Animation<double>? _cardsAnim;
  Animation<double>? _pieAnim;
  Animation<double>? _historyHeaderAnim;

  void _ensureAnimationsInitialized() {
    if (_animationsInitialized || !mounted) return;
    _animationsInitialized = true;

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _totalEarningsAnim = CurvedAnimation(
      parent: _entryController!,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );
    _chartAnim = CurvedAnimation(
      parent: _entryController!,
      curve: const Interval(0.1, 0.35, curve: Curves.easeOut),
    );
    _cardsAnim = CurvedAnimation(
      parent: _entryController!,
      curve: const Interval(0.2, 0.45, curve: Curves.easeOut),
    );
    _pieAnim = CurvedAnimation(
      parent: _entryController!,
      curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
    );
    _historyHeaderAnim = CurvedAnimation(
      parent: _entryController!,
      curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entryController?.forward();
    });
  }

  @override
  void initState() {
    super.initState();
    _ensureAnimationsInitialized();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureAnimationsInitialized();
  }

  @override
  void dispose() {
    _entryController?.dispose();
    super.dispose();
  }

  Widget _buildAnimatedSection({
    required Animation<double>? animation,
    required Widget child,
  }) {
    if (animation == null) return child;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureAnimationsInitialized();
    final viewModel = context.watch<DoctorHomeViewModel>();
    final totalEarnings = viewModel.totalEarnings;
    final history = viewModel.paymentHistoryFiltered(_historyFilter);
    final totalInPeriod = viewModel.totalEarningsInFiltered(_historyFilter);
    final upcoming = viewModel.upcomingEarnings;
    final byDescription = viewModel.earningsByDescription;
    final now = DateTime.now();
    final chartEnd = DateTime(now.year, now.month, now.day);
    final chartStart = chartEnd.subtract(Duration(days: _chartDays));
    final chartData = viewModel.earningsByDay(chartStart, chartEnd);
    final avgDaily = viewModel.averageDailyEarningsLastNDays(7);
    final projectedWeek = viewModel.projectedEarningsThisWeek;
    final hasEnoughHistory = viewModel.paymentHistory.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const DoctorScreenAppBar(title: 'Payments'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedSection(
                animation: _totalEarningsAnim,
                child: TotalEarningsCard(total: totalEarnings),
              ),
              const SizedBox(height: 24),
              _buildAnimatedSection(
                animation: _chartAnim,
                child: EarningsChartSection(
                  chartData: chartData,
                  chartDays: _chartDays,
                  onChartDaysChanged: (days) =>
                      setState(() => _chartDays = days),
                ),
              ),
              const SizedBox(height: 24),
              if (upcoming > 0) ...[
                _buildAnimatedSection(
                  animation: _cardsAnim,
                  child: UpcomingEarningsCard(
                    amount: upcoming,
                    bookingCount: viewModel.activeBookings.length,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (hasEnoughHistory && projectedWeek > 0) ...[
                _buildAnimatedSection(
                  animation: _cardsAnim,
                  child: ProjectedEarningsCard(
                    projected: projectedWeek,
                    avgDaily: avgDaily,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (byDescription.isNotEmpty) ...[
                _buildAnimatedSection(
                  animation: _pieAnim,
                  child: EarningsByTypeSection(byDescription: byDescription),
                ),
                const SizedBox(height: 24),
              ],
              _buildAnimatedSection(
                animation: _historyHeaderAnim,
                child: PaymentHistorySection(
                  history: history,
                  totalInPeriod: totalInPeriod,
                  filter: _historyFilter,
                  onFilterChanged: (v) => setState(() => _historyFilter = v),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
