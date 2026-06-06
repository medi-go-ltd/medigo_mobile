import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/patient_registration_request.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/date_utils.dart';
import 'package:medigo_mobile/utils/validation_utils.dart';
import 'package:medigo_mobile/view_models/signup_view_model.dart';
import 'package:medigo_mobile/widgets/app_header.dart';
import 'package:medigo_mobile/widgets/app_text_field.dart';
import 'package:medigo_mobile/widgets/field_label.dart';
import 'package:medigo_mobile/widgets/file_upload_field.dart';
import 'package:medigo_mobile/widgets/password_field.dart';
import 'package:provider/provider.dart';

class PatientSignupScreen extends StatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  State<PatientSignupScreen> createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends State<PatientSignupScreen> {
  final _pageController = PageController();
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step1ScrollController = ScrollController();
  final _step2ScrollController = ScrollController();
  final _step3ScrollController = ScrollController();
  final _profileUploadKey = GlobalKey();
  final _proofUploadKey = GlobalKey();
  final _photoIdUploadKey = GlobalKey();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _dob = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _houseNo = TextEditingController();
  final _street = TextEditingController();
  final _postcode = TextEditingController();
  final _password = TextEditingController();
  final _medications = TextEditingController();
  final _notes = TextEditingController();
  final _allergyDetails = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _dobFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _houseNoFocus = FocusNode();
  final _streetFocus = FocusNode();
  final _postcodeFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _medicationsFocus = FocusNode();
  final _notesFocus = FocusNode();
  final _allergyFocus = FocusNode();

  String _gender = 'Female';
  String _genderAtBirth = 'Female';
  String? _profileImagePath;
  String? _proofOfAddressPath;
  String? _photoIdPath;
  bool _highBloodPressure = false;
  bool _diabetes = false;
  bool _heartDisease = false;
  bool _asthma = false;
  bool _allergies = false;
  bool _sameGenderPref = false;
  bool _locationEnabled = true;
  int _currentStep = 0;
  bool _step1Attempted = false;
  List<String> _step1IssueMessages = [];
  String? _profileImageError;
  String? _proofOfAddressError;
  String? _photoIdError;

  @override
  void dispose() {
    _pageController.dispose();
    _step1ScrollController.dispose();
    _step2ScrollController.dispose();
    _step3ScrollController.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _dob.dispose();
    _email.dispose();
    _phone.dispose();
    _houseNo.dispose();
    _street.dispose();
    _postcode.dispose();
    _password.dispose();
    _medications.dispose();
    _notes.dispose();
    _allergyDetails.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _dobFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _houseNoFocus.dispose();
    _streetFocus.dispose();
    _postcodeFocus.dispose();
    _passwordFocus.dispose();
    _medicationsFocus.dispose();
    _notesFocus.dispose();
    _allergyFocus.dispose();
    super.dispose();
  }

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  void _goToStep(int step) {
    _dismissKeyboard();
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  Future<void> _pickDate() async {
    _dismissKeyboard();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      locale: UkDateUtils.ukLocale,
      initialDate: DateTime(now.year - 30),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Select date of birth',
      fieldLabelText: 'Date of birth',
    );
    if (picked != null) {
      _dob.text = UkDateUtils.formatUk(picked);
    }
  }

  bool _hasUpload(String? path) => path != null && path.isNotEmpty;

  bool _validateStep1({bool markAttempted = true}) {
    final profileMissing = !_hasUpload(_profileImagePath);
    final proofMissing = !_hasUpload(_proofOfAddressPath);
    final photoIdMissing = !_hasUpload(_photoIdPath);
    final showUploadErrors = markAttempted || _step1Attempted;
    final issues = _collectStep1Issues();

    setState(() {
      if (markAttempted) _step1Attempted = true;
      _step1IssueMessages = issues;
      if (showUploadErrors) {
        _profileImageError =
            profileMissing ? 'Please upload a profile picture' : null;
        _proofOfAddressError =
            proofMissing ? 'Please upload proof of address' : null;
        _photoIdError = photoIdMissing ? 'Please upload photo ID' : null;
      }
    });

    _step1Key.currentState?.validate();
    return issues.isEmpty;
  }

  List<String> _collectStep1Issues() {
    final issues = <String>[];

    void add(String? message) {
      if (message != null && message.isNotEmpty) {
        issues.add(message);
      }
    }

    add(ValidationUtils.validateFirstName(_firstName.text));
    add(ValidationUtils.validateLastName(_lastName.text));
    add(_dob.text.trim().isEmpty ? 'Date of birth is required' : null);
    if (!_hasUpload(_profileImagePath)) {
      add('Please upload a profile picture');
    }
    add(ValidationUtils.validateEmail(_email.text));
    add(ValidationUtils.validatePhone(_phone.text));
    add(_houseNo.text.trim().isEmpty ? 'House number is required' : null);
    add(_street.text.trim().isEmpty ? 'Street is required' : null);
    add(ValidationUtils.validateUkPostcode(_postcode.text));
    if (!_hasUpload(_proofOfAddressPath)) {
      add('Please upload proof of address');
    }
    if (!_hasUpload(_photoIdPath)) {
      add('Please upload photo ID');
    }
    add(ValidationUtils.validatePassword(_password.text));

    return issues;
  }

  void _scrollToStep1Issue() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      bool scrollToFirstInvalid({
        required String? Function() validate,
        required VoidCallback scrollTo,
      }) {
        if (validate() != null) {
          scrollTo();
          return true;
        }
        return false;
      }

      if (scrollToFirstInvalid(
        validate: () => ValidationUtils.validateFirstName(_firstName.text),
        scrollTo: () => _scrollToFocus(_firstNameFocus),
      )) {
        return;
      }
      if (scrollToFirstInvalid(
        validate: () => ValidationUtils.validateLastName(_lastName.text),
        scrollTo: () => _scrollToFocus(_lastNameFocus),
      )) {
        return;
      }
      if (scrollToFirstInvalid(
        validate: () => _dob.text.trim().isEmpty ? 'Required' : null,
        scrollTo: () => _scrollToFocus(_dobFocus, requestFocus: false),
      )) {
        return;
      }
      if (!_hasUpload(_profileImagePath)) {
        _scrollToKey(_profileUploadKey);
        return;
      }
      if (scrollToFirstInvalid(
        validate: () => ValidationUtils.validateEmail(_email.text),
        scrollTo: () => _scrollToFocus(_emailFocus),
      )) {
        return;
      }
      if (scrollToFirstInvalid(
        validate: () => ValidationUtils.validatePhone(_phone.text),
        scrollTo: () => _scrollToFocus(_phoneFocus),
      )) {
        return;
      }
      if (scrollToFirstInvalid(
        validate: () => _houseNo.text.trim().isEmpty ? 'Required' : null,
        scrollTo: () => _scrollToFocus(_houseNoFocus),
      )) {
        return;
      }
      if (scrollToFirstInvalid(
        validate: () => _street.text.trim().isEmpty ? 'Required' : null,
        scrollTo: () => _scrollToFocus(_streetFocus),
      )) {
        return;
      }
      if (scrollToFirstInvalid(
        validate: () => ValidationUtils.validateUkPostcode(_postcode.text),
        scrollTo: () => _scrollToFocus(_postcodeFocus),
      )) {
        return;
      }
      if (!_hasUpload(_proofOfAddressPath)) {
        _scrollToKey(_proofUploadKey);
        return;
      }
      if (!_hasUpload(_photoIdPath)) {
        _scrollToKey(_photoIdUploadKey);
        return;
      }
      if (scrollToFirstInvalid(
        validate: () => ValidationUtils.validatePassword(_password.text),
        scrollTo: () => _scrollToFocus(_passwordFocus),
      )) {
        return;
      }
    });
  }

  void _scrollToFocus(FocusNode node, {bool requestFocus = true}) {
    final targetContext = node.context;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      alignment: 0.25,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (requestFocus) {
      node.requestFocus();
    }
  }

  void _scrollToKey(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      alignment: 0.25,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleStep1ValidationFailure() {
    final issues = _step1IssueMessages;
    final message = issues.isEmpty
        ? 'Please review the highlighted fields below'
        : issues.length == 1
            ? issues.first
            : '${issues.length} items need attention: ${issues.first}';
    _showError(message);
    _dismissKeyboard();

    if (_currentStep == 0) {
      _scrollToStep1Issue();
      return;
    }

    _pageController
        .animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
      if (!mounted) return;
      setState(() => _currentStep = 0);
      _scrollToStep1Issue();
    });
  }

  Future<void> _submit() async {
    _dismissKeyboard();

    if (!_validateStep1()) {
      _handleStep1ValidationFailure();
      return;
    }

    final dobIso = UkDateUtils.ukDisplayToIso(_dob.text.trim());
    if (dobIso == null) {
      _showError('Please enter a valid date of birth (DD/MM/YYYY)');
      return;
    }

    final request = PatientRegistrationRequest(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      dateOfBirth: dobIso,
      gender: _gender,
      genderAtBirth: _genderAtBirth,
      profileImagePath: _profileImagePath,
      email: _email.text.trim(),
      phoneNumber: _phone.text.trim(),
      houseNumber: _houseNo.text.trim(),
      street: _street.text.trim(),
      postcode: _postcode.text.trim(),
      proofOfAddressPath: _proofOfAddressPath,
      photoIdPath: _photoIdPath,
      password: _password.text,
      highBloodPressure: _highBloodPressure,
      diabetes: _diabetes,
      heartDisease: _heartDisease,
      asthma: _asthma,
      allergies: _allergies,
      allergyDetails: _allergies ? _allergyDetails.text.trim() : null,
      currentMedications: _medications.text.trim().isEmpty
          ? null
          : _medications.text.trim(),
      additionalNotes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      sameGenderDoctorPreference: _sameGenderPref,
      locationServicesEnabled: _locationEnabled,
    );

    final vm = context.read<SignupViewModel>();
    final success = await vm.registerPatient(request);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.patientRegistrationSuccess,
        (route) => false,
      );
    } else if (vm.hasError) {
      _showError(vm.errorMessage ?? 'Registration failed');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignupViewModel>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: _dismissKeyboard,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              const AppHeader(),
              _buildProgress(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [_buildStep1(), _buildStep2(), _buildStep3()],
                ),
              ),
              if (vm.isLoading)
                const LinearProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    const labels = ['Personal', 'Medical', 'Preferences'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final step = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: _currentStep > step
                    ? AppColors.primary
                    : AppColors.border,
              ),
            );
          }
          final step = i ~/ 2;
          final active = _currentStep == step;
          final done = _currentStep > step;
          return Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done || active ? AppColors.primary : AppColors.border,
                ),
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              Text(
                labels[step],
                style: TextStyle(
                  fontSize: 10,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      controller: _step1ScrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Personal Information', style: AppTypography.pageTitle),
            const SizedBox(height: 8),
            const Text(
              'Tell us about yourself',
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: 20),
            if (_step1IssueMessages.isNotEmpty) ...[
              _buildStep1IssueSummary(),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _firstName,
                    focusNode: _firstNameFocus,
                    label: 'First Name',
                    hintText: 'First Name',
                    icon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_lastNameFocus),
                    validator: ValidationUtils.validateFirstName,
                    required: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _lastName,
                    focusNode: _lastNameFocus,
                    label: 'Last Name',
                    hintText: 'Last Name',
                    icon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    onFieldSubmitted: (_) => _pickDate(),
                    validator: ValidationUtils.validateLastName,
                    required: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _dob,
              focusNode: _dobFocus,
              label: 'Date of Birth',
              hintText: 'DD/MM/YYYY',
              icon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: _pickDate,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_emailFocus),
              validator: ValidationUtils.validateUkDateOfBirth,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildDropdown('Gender', _gender, [
              'Female',
              'Male',
              'Non-binary',
              'Prefer not to say',
            ], (v) => setState(() => _gender = v), required: true),
            const SizedBox(height: 16),
            _buildDropdown(
              'Gender at Birth',
              _genderAtBirth,
              [
                'Female',
                'Male',
              ],
              (v) => setState(() => _genderAtBirth = v),
              required: true,
            ),
            const SizedBox(height: 16),
            KeyedSubtree(
              key: _profileUploadKey,
              child: FileUploadField(
                label: 'Profile Picture',
                filePath: _profileImagePath,
                previewSize: 72,
                required: true,
                errorText: _profileImageError,
                onFileSelected: (path) => setState(() {
                  _profileImagePath = path.isEmpty ? null : path;
                  if (_hasUpload(_profileImagePath)) {
                    _profileImageError = null;
                  }
                }),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _email,
              focusNode: _emailFocus,
              label: 'Email',
              hintText: 'Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_phoneFocus),
              validator: ValidationUtils.validateEmail,
              required: true,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phone,
              focusNode: _phoneFocus,
              label: 'Phone',
              hintText: 'Phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_houseNoFocus),
              validator: ValidationUtils.validatePhone,
              required: true,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _houseNo,
              focusNode: _houseNoFocus,
              label: 'House No.',
              hintText: 'House number',
              icon: Icons.home_outlined,
              keyboardType: TextInputType.text,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_streetFocus),
              validator: (v) =>
                  v == null || v.isEmpty ? 'House number is required' : null,
              required: true,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _street,
              focusNode: _streetFocus,
              label: 'Street',
              hintText: 'Street name',
              icon: Icons.signpost_outlined,
              keyboardType: TextInputType.streetAddress,
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_postcodeFocus),
              validator: (v) => v == null || v.isEmpty ? 'Street is required' : null,
              required: true,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _postcode,
              focusNode: _postcodeFocus,
              label: 'Postcode',
              hintText: 'Postcode',
              icon: Icons.location_on_outlined,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_passwordFocus),
              validator: ValidationUtils.validateUkPostcode,
              required: true,
            ),
            const SizedBox(height: 16),
            KeyedSubtree(
              key: _proofUploadKey,
              child: FileUploadField(
                label: 'Proof of Address',
                filePath: _proofOfAddressPath,
                required: true,
                errorText: _proofOfAddressError,
                onFileSelected: (path) => setState(() {
                  _proofOfAddressPath = path.isEmpty ? null : path;
                  if (_hasUpload(_proofOfAddressPath)) {
                    _proofOfAddressError = null;
                  }
                }),
              ),
            ),
            const SizedBox(height: 16),
            KeyedSubtree(
              key: _photoIdUploadKey,
              child: FileUploadField(
                label: 'Photo ID',
                filePath: _photoIdPath,
                required: true,
                errorText: _photoIdError,
                onFileSelected: (path) => setState(() {
                  _photoIdPath = path.isEmpty ? null : path;
                  if (_hasUpload(_photoIdPath)) {
                    _photoIdError = null;
                  }
                }),
              ),
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _password,
              focusNode: _passwordFocus,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _dismissKeyboard(),
              validator: ValidationUtils.validatePassword,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _dismissKeyboard();
                if (_validateStep1()) {
                  _goToStep(1);
                } else {
                  _scrollToStep1Issue();
                }
              },
              style: _primaryButtonStyle(),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      controller: _step2ScrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Medical Information', style: AppTypography.pageTitle),
            const SizedBox(height: 8),
            const Text(
              'Help us understand your health history',
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: 20),
            _buildConditionToggle('High Blood Pressure', _highBloodPressure,
                (v) => setState(() => _highBloodPressure = v)),
            _buildConditionToggle(
                'Diabetes', _diabetes, (v) => setState(() => _diabetes = v)),
            _buildConditionToggle('Heart Disease', _heartDisease,
                (v) => setState(() => _heartDisease = v)),
            _buildConditionToggle(
                'Asthma', _asthma, (v) => setState(() => _asthma = v)),
            _buildConditionToggle(
                'Allergies', _allergies, (v) => setState(() => _allergies = v)),
            if (_allergies) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _allergyDetails,
                focusNode: _allergyFocus,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: 'Allergy Details',
                  hintText: 'Describe your allergies',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _medications,
              focusNode: _medicationsFocus,
              maxLines: 2,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                labelText: 'Current Medications (Optional)',
                hintText: 'List any medications',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              focusNode: _notesFocus,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _dismissKeyboard(),
              decoration: InputDecoration(
                labelText: 'Additional Medical Notes (Optional)',
                hintText: 'Any other relevant information',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _goToStep(0),
                    style: _outlineButtonStyle(),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _goToStep(2),
                    style: _primaryButtonStyle(),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      controller: _step3ScrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Preferences', style: AppTypography.pageTitle),
          const SizedBox(height: 8),
          const Text(
            'Customise your experience',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Same Gender Doctor Preference'),
            subtitle: const Text(
              'Prefer to be seen by a doctor of the same gender',
            ),
            value: _sameGenderPref,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _sameGenderPref = v),
          ),
          SwitchListTile(
            title: const Text('Enable Location Services'),
            subtitle: const Text(
              'Required to find nearby doctors and track visits',
            ),
            value: _locationEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _locationEnabled = v),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _goToStep(1),
                  style: _outlineButtonStyle(),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: _primaryButtonStyle(),
                  child: const Text('Create Account'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1IssueSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _step1IssueMessages.length == 1
                ? 'Please fix this before continuing:'
                : 'Please fix these ${_step1IssueMessages.length} items before continuing:',
            style: AppTypography.body.copyWith(
              color: Colors.red.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ..._step1IssueMessages.map(
            (issue) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: AppTypography.body.copyWith(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      issue,
                      style: AppTypography.body.copyWith(
                        color: Colors.red.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged, {
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label, required: required),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }

  Widget _buildConditionToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.body)),
          const Text('No', style: AppTypography.bodySecondary),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
          const Text('Yes', style: AppTypography.bodySecondary),
        ],
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.surface,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );

  ButtonStyle _outlineButtonStyle() => OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
    side: const BorderSide(color: AppColors.border),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );
}
