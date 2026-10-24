import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/patient/family/family_members_screen.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/family_member.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:medigo_mobile/view_models/family_view_model.dart';
import 'package:medigo_mobile/view_models/patient_booking_view_model.dart';
import 'package:medigo_mobile/view_models/patient_home_view_model.dart';
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
  static const _selfKey = 'self';

  final _pageController = PageController();
  int _page = 0;

  /// Keys of the people being seen: member ids, or [_selfKey].
  final Set<String> _selected = {_selfKey};

  /// Added during this booking without saving to the family.
  final List<FamilyMember> _oneOffMembers = [];

  /// Adults (16+) who have agreed to be booked.
  final Set<String> _consented = {};
  final Map<String, _PatientAnswers> _answers = {};
  PaymentMethodType _paymentMethod = PaymentMethodType.debitCard;

  static const _symptomOptions = [
    'Pain',
    'Fever',
    'Nausea / vomiting',
    'Dizziness',
    'Swelling',
    'Rash',
    'Bleeding',
    'Breathing trouble',
    'Cough',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientBookingViewModel>().startBooking(
        widget.doctor,
        isNearestDoctor: widget.isNearestDoctor,
      );
      final userId = context.read<AuthViewModel>().user?.id;
      if (userId != null) {
        context.read<FamilyViewModel>().loadFor(userId);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final answers in _answers.values) {
      answers.dispose();
    }
    super.dispose();
  }

  /// Everyone who can be picked: saved family first, then one-off additions.
  List<FamilyMember> get _choosableMembers => [
    ...context.read<FamilyViewModel>().members,
    ..._oneOffMembers,
  ];

  /// Selected people in display order; null is the account holder.
  List<FamilyMember?> get _people => [
    if (_selected.contains(_selfKey)) null,
    ..._choosableMembers.where((m) => _selected.contains(m.id)),
  ];

  String _keyOf(FamilyMember? person) => person?.id ?? _selfKey;

  _PatientAnswers _answersFor(FamilyMember? person) =>
      _answers.putIfAbsent(_keyOf(person), _PatientAnswers.new);

  /// Pages: who, then triage + issue per patient, then pay and confirm.
  int get _lastPage => 2 * _people.length + 2;

  /// Index into the step indicator (Who, Triage, Issue, Pay, Confirm).
  int get _stepIndex {
    if (_page == 0) return 0;
    if (_page == _lastPage) return 4;
    if (_page == _lastPage - 1) return 3;
    return (_page - 1).isEven ? 1 : 2;
  }

  void _togglePerson(String key) {
    setState(() {
      if (!_selected.remove(key)) _selected.add(key);
      _consented.remove(key);
    });
  }

  Future<void> _addFamilyMember() async {
    final result = await openFamilyMemberForm(context, showSaveToggle: true);
    if (result == null || result.deleted || !mounted) return;
    setState(() {
      if (!result.saveToFamily) _oneOffMembers.add(result.member);
      _selected.add(result.member.id);
    });
  }

  String _issueDescription(_PatientAnswers answers) {
    final parts = <String>[];
    if (answers.symptoms.isNotEmpty) {
      final ordered = _symptomOptions.where(answers.symptoms.contains);
      parts.add('Symptoms: ${ordered.join(', ')}');
    }
    final details = answers.details.text.trim();
    if (details.isNotEmpty) parts.add(details);
    return parts.join('. ');
  }

  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  void _goTo(int page) {
    _unfocus();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _page = page);
  }

  void _next() {
    if (_page < _lastPage) _goTo(_page + 1);
  }

  void _back() {
    if (_page > 0) {
      _goTo(_page - 1);
    } else {
      _unfocus();
      Navigator.pop(context);
    }
  }

  void _syncPatient(int index, FamilyMember? person) {
    final answers = _answersFor(person);
    context.read<PatientBookingViewModel>().updatePatient(
      index,
      triage: answers.triage,
      bodyAreas: answers.bodyAreas.toList(),
      issueSeverity: answers.severity,
      description: _issueDescription(answers),
    );
  }

  String get _accountHolderName {
    final name = context.read<AuthViewModel>().user?.fullName.trim();
    return name == null || name.isEmpty ? 'Patient' : name;
  }

  Future<void> _confirm() async {
    _unfocus();
    final people = _people;
    for (var i = 0; i < people.length; i++) {
      _syncPatient(i, people[i]);
    }
    context.read<PatientBookingViewModel>().updateDraft(
      paymentMethod: _paymentMethod,
    );
    final homeVm = context.read<PatientHomeViewModel>();
    final location = homeVm.userLocation;
    final patientLocation = location == null
        ? 'Location not shared'
        : location.address?.isNotEmpty == true
        ? location.address!
        : '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';

    final vm = context.read<PatientBookingViewModel>();
    final booking = await vm.confirmBooking(
      accountHolderName: _accountHolderName,
      patientLocation: patientLocation,
      patientLat: location?.latitude,
      patientLng: location?.longitude,
    );
    if (!mounted || booking == null) return;
    Navigator.of(
      context,
    ).pushReplacementNamed(AppRoutes.patientWaiting, arguments: booking.id);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FamilyViewModel>();
    final people = _people;
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
                  for (var i = 0; i < people.length; i++) ...[
                    _buildTriageStep(i, people),
                    _buildDescribeStep(i, people),
                  ],
                  _buildPaymentStep(),
                  _buildConfirmStep(people),
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
    const icons = [
      Icons.person_outline,
      Icons.medical_services_outlined,
      Icons.favorite_border,
      Icons.credit_card_outlined,
      Icons.check,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stepWidth = constraints.maxWidth / labels.length;
          return Column(
            children: [
              SizedBox(
                height: 34,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (var i = 0; i < labels.length - 1; i++)
                      Positioned(
                        left: stepWidth * (i + 0.5),
                        top: 16,
                        width: stepWidth,
                        height: 2,
                        child: i < _stepIndex
                            ? const ColoredBox(color: AppColors.primary)
                            : CustomPaint(
                                painter: _DottedLinePainter(
                                  color: AppColors.border,
                                ),
                              ),
                      ),
                    Row(
                      children: List.generate(labels.length, (i) {
                        return Expanded(
                          child: Center(
                            child: _StepDot(
                              icon: icons[i],
                              active: i <= _stepIndex,
                              current: i == _stepIndex,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(labels.length, (i) {
                  final current = i == _stepIndex;
                  final active = i <= _stepIndex;
                  return Expanded(
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
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
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWhoForStep() {
    final userName = context.watch<AuthViewModel>().user?.fullName.trim();
    final selectedMembers = _people.whereType<FamilyMember>().toList();
    final minors = selectedMembers.where((m) => m.isMinor).toList();
    final adults = selectedMembers.where((m) => !m.isMinor).toList();
    final count = _people.length;
    final fee = widget.doctor.fee.toDouble();

    return _stepScaffold(
      title: 'Who needs to be seen?',
      subtitle: 'Select everyone the doctor should see on this visit',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _selectionCard(
            label: userName?.isNotEmpty == true
                ? 'Myself ($userName)'
                : 'Myself',
            selected: _selected.contains(_selfKey),
            multiSelect: true,
            onTap: () => _togglePerson(_selfKey),
          ),
          for (final member in _choosableMembers) ...[
            const SizedBox(height: 12),
            FamilyMemberTile(
              member: member,
              selected: _selected.contains(member.id),
              onTap: () => _togglePerson(member.id),
              trailing: Icon(
                _selected.contains(member.id)
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: _selected.contains(member.id)
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 24,
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _addFamilyMember,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text('Add family member'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (count > 1) ...[
            const SizedBox(height: 8),
            _InfoBanner(
              icon: Icons.groups_outlined,
              text:
                  '$count people on one visit: £${_money(fee)} for the first, '
                  '£${_money(fee * PatientBooking.additionalPatientRate)} '
                  'for each additional person',
            ),
          ],
          if (minors.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoBanner(
              icon: Icons.child_care_outlined,
              text:
                  'A parent or guardian must be present for '
                  '${_joinNames(minors.map((m) => m.firstName).toList())}.',
            ),
          ],
          for (final adult in adults)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
              value: _consented.contains(adult.id),
              onChanged: (v) => setState(() {
                if (v ?? false) {
                  _consented.add(adult.id);
                } else {
                  _consented.remove(adult.id);
                }
              }),
              title: Text(
                '${adult.firstName} knows about and agrees to this booking',
                style: AppTypography.body.copyWith(fontSize: 14),
              ),
            ),
        ],
      ),
      onNext: () {
        if (_people.isEmpty) {
          _showError('Select at least one person to be seen');
          return;
        }
        final missing = adults.where((a) => !_consented.contains(a.id));
        if (missing.isNotEmpty) {
          _showError(
            'Please confirm ${missing.first.firstName} agrees to this booking',
          );
          return;
        }
        context.read<PatientBookingViewModel>().setPatients(_people);
        _next();
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static String _joinNames(List<String> names) {
    if (names.length <= 1) return names.join();
    return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
  }

  static String _money(double amount) => amount == amount.roundToDouble()
      ? amount.toInt().toString()
      : amount.toStringAsFixed(2);

  /// "Leo (2 of 3)" style banner shown on per-patient steps; null when the
  /// account holder is booking only for themselves.
  Widget? _patientBanner(int index, List<FamilyMember?> people, String verb) {
    final person = people[index];
    if (person == null && people.length == 1) return null;
    final who = person == null ? 'your' : '${person.firstName}\'s';
    final position = people.length > 1
        ? ' (${index + 1} of ${people.length})'
        : '';
    return _InfoBanner(
      icon: Icons.person_outline,
      text: '$verb $who symptoms$position',
    );
  }

  Widget _buildTriageStep(int index, List<FamilyMember?> people) {
    final answers = _answersFor(people[index]);
    final triage = answers.triage;
    void update(TriageAnswers value) => setState(() => answers.triage = value);
    final banner = _patientBanner(index, people, 'Screening');

    return _stepScaffold(
      title: 'Screening questions',
      subtitle: 'Help us assess urgency',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (banner != null) ...[banner, const SizedBox(height: 16)],
          _triageQuestion(
            'Severe chest pain?',
            triage.severeChestPain,
            (v) => update(triage.copyWith(severeChestPain: v)),
          ),
          _triageQuestion(
            'Difficulty breathing?',
            triage.difficultyBreathing,
            (v) => update(triage.copyWith(difficultyBreathing: v)),
          ),
          _triageQuestion(
            'Pain level severe (8–10)?',
            triage.severePain,
            (v) => update(triage.copyWith(severePain: v)),
          ),
          _triageQuestion(
            'Loss of consciousness or confusion?',
            triage.lossOfConsciousness,
            (v) => update(triage.copyWith(lossOfConsciousness: v)),
          ),
          if (triage.isUrgent)
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
        _syncPatient(index, people[index]);
        _next();
      },
    );
  }

  Widget _buildDescribeStep(int index, List<FamilyMember?> people) {
    final person = people[index];
    final answers = _answersFor(person);
    final banner = _patientBanner(index, people, 'Describing');

    return _stepScaffold(
      title: '',
      hideTitle: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (banner != null) ...[banner, const SizedBox(height: 16)],
          BodyDiagramWidget(
            gender:
                person?.sexAtBirth ??
                context.select<AuthViewModel, String?>(
                  (auth) => auth.user?.gender,
                ),
            selectedAreas: answers.bodyAreas,
            onAreaToggled: (area) => setState(() {
              if (!answers.bodyAreas.remove(area)) answers.bodyAreas.add(area);
            }),
          ),
          const SizedBox(height: 28),
          Text(
            'How severe is the issue?',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _IssueSeverityPicker(
            value: answers.severity,
            onChanged: (severity) =>
                setState(() => answers.severity = severity),
          ),
          const SizedBox(height: 28),
          Text(
            person == null
                ? 'What are you experiencing?'
                : 'What is ${person.firstName} experiencing?',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Optional, but it helps the doctor prepare',
            style: AppTypography.bodySecondary.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _symptomOptions.map((symptom) {
              final selected = answers.symptoms.contains(symptom);
              return FilterChip(
                label: Text(symptom),
                selected: selected,
                showCheckmark: false,
                onSelected: (value) => setState(() {
                  if (value) {
                    answers.symptoms.add(symptom);
                  } else {
                    answers.symptoms.remove(symptom);
                  }
                }),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.surface : AppColors.textPrimary,
                ),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary,
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: answers.details,
            minLines: 3,
            maxLines: 5,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText:
                  'Describe what\'s happening, e.g. sharp pain under my right ribs after eating',
              hintMaxLines: 2,
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
        if (answers.bodyAreas.isEmpty) {
          _showError('Please select at least one area of concern');
          return;
        }
        if (answers.severity == null) {
          _showError('Please select issue severity');
          return;
        }
        final onlyGeneral =
            answers.bodyAreas.length == 1 &&
            answers.bodyAreas.contains(BodyDiagramWidget.generalArea);
        if (onlyGeneral && _issueDescription(answers).isEmpty) {
          _showError(
            'Pick a symptom or add a short description so the doctor knows what\'s wrong',
          );
          return;
        }
        _syncPatient(index, person);
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
        context.read<PatientBookingViewModel>().updateDraft(
          paymentMethod: _paymentMethod,
        );
        _next();
      },
    );
  }

  List<_ConfirmDetail> _patientDetails(FamilyMember? person) {
    final answers = _answersFor(person);
    final description = _issueDescription(answers);
    return [
      _ConfirmDetail(
        Icons.person_outline,
        'Patient',
        BookingPatient(member: person).label,
      ),
      if (answers.triage.isUrgent)
        const _ConfirmDetail(
          Icons.warning_amber_rounded,
          'Screening',
          'Urgent symptoms reported',
        ),
      if (answers.bodyAreas.isNotEmpty)
        _ConfirmDetail(
          Icons.accessibility_new_outlined,
          'Issue area',
          BodyDiagramWidget.formatAreas(answers.bodyAreas),
        ),
      if (answers.severity != null)
        _ConfirmDetail(
          Icons.favorite_border,
          'Severity',
          answers.severity!.label,
        ),
      if (description.isNotEmpty)
        _ConfirmDetail(Icons.notes_outlined, 'Details', description),
    ];
  }

  Widget _buildConfirmStep(List<FamilyMember?> people) {
    final baseFee = widget.doctor.fee.toDouble();
    final total = PatientBooking.totalFee(baseFee, people.length);
    final extra = baseFee * PatientBooking.additionalPatientRate;
    final payment = [
      _ConfirmDetail(
        Icons.credit_card_outlined,
        'Payment',
        _paymentLabel(_paymentMethod),
      ),
    ];

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
                  'Review booking',
                  style: AppTypography.pageTitle.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Check the details before you confirm',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: 20),
                _ConfirmDoctorCard(doctor: widget.doctor),
                for (final person in people) ...[
                  const SizedBox(height: 12),
                  _ConfirmDetailsCard(details: _patientDetails(person)),
                ],
                const SizedBox(height: 12),
                _ConfirmDetailsCard(details: payment),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total due',
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (people.length > 1) ...[
                            const SizedBox(height: 2),
                            Text(
                              '£${_money(baseFee)} + ${people.length - 1} × £${_money(extra)}',
                              style: AppTypography.bodySecondary.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '£${_money(total)}',
                      style: AppTypography.pageTitle.copyWith(
                        fontSize: 22,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: AppTypography.button.copyWith(fontSize: 17),
                  ),
                  child: const Text('Confirm booking'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepScaffold({
    required String title,
    String? subtitle,
    bool hideTitle = false,
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
                if (!hideTitle) ...[
                  Text(
                    title,
                    style: AppTypography.pageTitle.copyWith(fontSize: 26),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(subtitle, style: AppTypography.bodySecondary),
                  ],
                  const SizedBox(height: 24),
                ],
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
    bool multiSelect = false,
  }) {
    final IconData icon;
    if (multiSelect) {
      icon = selected ? Icons.check_box : Icons.check_box_outline_blank;
    } else {
      icon = selected ? Icons.radio_button_checked : Icons.radio_button_off;
    }
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
                icon,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                size: multiSelect ? 24 : 22,
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
            style: TextStyle(fontWeight: FontWeight.w600, color: text),
          ),
        ),
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

/// One patient's in-progress answers while the booking flow is open.
class _PatientAnswers {
  TriageAnswers triage = const TriageAnswers();
  final Set<String> bodyAreas = {};
  final Set<String> symptoms = {};
  final details = TextEditingController();
  IssueSeverity? severity;

  void dispose() => details.dispose();
}

class _ConfirmDetail {
  const _ConfirmDetail(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _ConfirmDoctorCard extends StatelessWidget {
  const _ConfirmDoctorCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.highlight,
            child: Text(
              doctor.firstName.isNotEmpty ? doctor.firstName[0] : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.fullName,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(doctor.specialty, style: AppTypography.bodySecondary),
                const SizedBox(height: 6),
                Text(
                  '${doctor.rating.toStringAsFixed(1)} ★ · Fee £${doctor.fee.toInt()}',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (doctor.location.address != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    doctor.location.address!,
                    style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmDetailsCard extends StatelessWidget {
  const _ConfirmDetailsCard({required this.details});

  final List<_ConfirmDetail> details;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < details.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 52),
            _ConfirmDetailRow(detail: details[i]),
          ],
        ],
      ),
    );
  }
}

class _ConfirmDetailRow extends StatelessWidget {
  const _ConfirmDetailRow({required this.detail});

  final _ConfirmDetail detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(detail.icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.label,
                  style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  detail.value,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.icon,
    required this.active,
    required this.current,
  });

  final IconData icon;
  final bool active;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final borderColor = active ? AppColors.primary : AppColors.border;
    final iconColor = active ? AppColors.surface : AppColors.textSecondary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.primary : AppColors.surface,
        border: Border.all(color: borderColor, width: current ? 2 : 1.4),
      ),
      child: Icon(icon, size: 17, color: iconColor),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.highlight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueSeverityPicker extends StatelessWidget {
  const _IssueSeverityPicker({required this.value, required this.onChanged});

  final IssueSeverity? value;
  final ValueChanged<IssueSeverity> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: IssueSeverity.values.map((severity) {
          final selected = value == severity;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(severity),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        severity.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        severity.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.surface
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  _DottedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    var startX = 0.0;
    final y = size.height / 2;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
