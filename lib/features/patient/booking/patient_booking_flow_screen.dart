import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/patient_booking_view_model.dart';
import 'package:medigo_mobile/widgets/body_diagram_widget.dart';
import 'package:provider/provider.dart';

class PatientBookingFlowScreen extends StatefulWidget {
  const PatientBookingFlowScreen({
    super.key,
    required this.doctor,
    this.isNearestDoctor = false,
  });

  final Doctor doctor;
  final bool isNearestDoctor;

  @override
  State<PatientBookingFlowScreen> createState() =>
      _PatientBookingFlowScreenState();
}

class _PatientBookingFlowScreenState extends State<PatientBookingFlowScreen> {
  final _pageController = PageController();
  int _step = 0;

  BookingFor _bookingFor = BookingFor.myself;
  final _otherNameController = TextEditingController();
  TriageAnswers _triage = const TriageAnswers();
  final Set<String> _bodyAreas = {};
  final _descriptionController = TextEditingController();
  PaymentMethodType _paymentMethod = PaymentMethodType.debitCard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientBookingViewModel>().startBooking(
        widget.doctor,
        isNearestDoctor: widget.isNearestDoctor,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _otherNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  void _next() {
    _unfocus();
    if (_step < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _step++);
    }
  }

  void _back() {
    _unfocus();
    if (_step > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  String get _appointmentForLabel {
    if (_bookingFor == BookingFor.myself) return 'Myself';
    final name = _otherNameController.text.trim();
    return name.isEmpty ? 'Someone else' : name;
  }

  void _syncDraft() {
    context.read<PatientBookingViewModel>().updateDraft(
      bookingFor: _bookingFor,
      otherPersonName: _bookingFor == BookingFor.someoneElse
          ? _otherNameController.text.trim()
          : null,
      triage: _triage,
      bodyAreas: _bodyAreas.toList(),
      description: _descriptionController.text.trim(),
      paymentMethod: _paymentMethod,
    );
  }

  Future<void> _confirm() async {
    _unfocus();
    _syncDraft();
    final vm = context.read<PatientBookingViewModel>();
    final booking = await vm.confirmBooking(
      patientName: _bookingFor == BookingFor.myself
          ? 'You'
          : _otherNameController.text.trim(),
      patientLocation: 'Your registered address',
    );
    if (!mounted || booking == null) return;
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.patientWaiting,
      arguments: booking.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocus,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: _back,
          ),
          title: Text(
            'Book ${widget.doctor.fullName}',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWhoForStep(),
                  _buildTriageStep(),
                  _buildDescribeStep(),
                  _buildPaymentStep(),
                  _buildConfirmStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    const labels = ['Who', 'Triage', 'Issue', 'Pay', 'Confirm'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i <= _step;
          final current = i == _step;
          return Expanded(
            child: Column(
              children: [
                Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                    color: current
                        ? AppColors.primary
                        : active
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWhoForStep() {
    return _stepScaffold(
      title: 'Who is this appointment for?',
      child: Column(
        children: [
          _selectionCard(
            label: 'Myself',
            selected: _bookingFor == BookingFor.myself,
            onTap: () => setState(() => _bookingFor = BookingFor.myself),
          ),
          const SizedBox(height: 12),
          _selectionCard(
            label: 'Someone else',
            selected: _bookingFor == BookingFor.someoneElse,
            onTap: () => setState(() => _bookingFor = BookingFor.someoneElse),
          ),
          if (_bookingFor == BookingFor.someoneElse) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _otherNameController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Patient name',
                hintText: 'Enter their full name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      onNext: () {
        if (_bookingFor == BookingFor.someoneElse &&
            _otherNameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter the patient name')),
          );
          return;
        }
        _syncDraft();
        _next();
      },
    );
  }

  Widget _buildTriageStep() {
    return _stepScaffold(
      title: 'Screening questions',
      subtitle: 'Help us assess urgency',
      child: Column(
        children: [
          _triageQuestion('Severe chest pain?', _triage.severeChestPain, (v) {
            setState(() => _triage = _triage.copyWith(severeChestPain: v));
          }),
          _triageQuestion('Difficulty breathing?', _triage.difficultyBreathing,
              (v) {
            setState(
              () => _triage = _triage.copyWith(difficultyBreathing: v),
            );
          }),
          _triageQuestion('Pain level severe (8–10)?', _triage.severePain, (v) {
            setState(() => _triage = _triage.copyWith(severePain: v));
          }),
          _triageQuestion(
            'Loss of consciousness or confusion?',
            _triage.lossOfConsciousness,
            (v) {
              setState(
                () => _triage = _triage.copyWith(lossOfConsciousness: v),
              );
            },
          ),
          if (_triage.isUrgent)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningHighlight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Urgent symptoms detected. A doctor will be prioritised.',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      onNext: () {
        _syncDraft();
        _next();
      },
    );
  }

  Widget _buildDescribeStep() {
    return _stepScaffold(
      title: 'Describe your issue',
      subtitle: 'Select one or more areas of concern and describe symptoms',
      child: Column(
        children: [
          BodyDiagramWidget(
            selectedAreas: _bodyAreas,
            onAreaToggled: (area) => setState(() {
              if (_bodyAreas.contains(area)) {
                _bodyAreas.remove(area);
              } else {
                _bodyAreas.add(area);
              }
            }),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Description of issue',
              hintText: 'Describe your symptoms...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
      onNext: () {
        if (_bodyAreas.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least one area of concern'),
            ),
          );
          return;
        }
        if (_descriptionController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please describe your issue')),
          );
          return;
        }
        _syncDraft();
        _next();
      },
    );
  }

  Widget _buildPaymentStep() {
    return _stepScaffold(
      title: 'Payment method',
      subtitle: 'You will confirm payment on the next step',
      child: Column(
        children: PaymentMethodType.values.map((method) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _selectionCard(
              label: _paymentLabel(method),
              selected: _paymentMethod == method,
              onTap: () => setState(() => _paymentMethod = method),
            ),
          );
        }).toList(),
      ),
      onNext: () {
        _syncDraft();
        _next();
      },
    );
  }

  Widget _buildConfirmStep() {
    final fee = widget.doctor.fee;
    return _stepScaffold(
      title: 'Booking summary',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.highlight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryRow('Doctor', widget.doctor.fullName),
            _summaryRow('Specialty', widget.doctor.specialty),
            _summaryRow('For', _appointmentForLabel),
            if (_bodyAreas.isNotEmpty)
              _summaryRow('Areas', BodyDiagramWidget.formatAreas(_bodyAreas)),
            _summaryRow('Payment', _paymentLabel(_paymentMethod)),
            const Divider(height: 28),
            _summaryRow('Total', '£${fee.toInt()}', bold: true),
          ],
        ),
      ),
      nextLabel: 'Confirm appointment',
      onNext: _confirm,
    );
  }

  Widget _stepScaffold({
    required String title,
    String? subtitle,
    required Widget child,
    required VoidCallback onNext,
    String nextLabel = 'Continue',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: AppTypography.pageTitle.copyWith(fontSize: 26),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(subtitle, style: AppTypography.bodySecondary),
                ],
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: AppTypography.button.copyWith(fontSize: 17),
              ),
              child: Text(nextLabel),
            ),
          ),
        ),
      ],
    );
  }

  Widget _selectionCard({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _triageQuestion(
    String question,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _triageAnswerButton(
                  label: 'No',
                  selected: !value,
                  onTap: () => onChanged(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _triageAnswerButton(
                  label: 'Yes',
                  selected: value,
                  isYes: true,
                  onTap: () => onChanged(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _triageAnswerButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool isYes = false,
  }) {
    final Color bg = selected
        ? (isYes
            ? AppColors.warning.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.12))
        : AppColors.surface;
    final Color border = selected
        ? (isYes ? AppColors.warning : AppColors.primary)
        : AppColors.border;
    final Color text = selected
        ? (isYes ? AppColors.warning : AppColors.primary)
        : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: selected ? 1.6 : 1.2),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: AppTypography.bodySecondary),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.body.copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _paymentLabel(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.debitCard:
        return 'Debit card';
      case PaymentMethodType.creditCard:
        return 'Credit card';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.paypal:
        return 'PayPal';
    }
  }
}
