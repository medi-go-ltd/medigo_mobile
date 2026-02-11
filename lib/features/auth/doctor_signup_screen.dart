import 'package:flutter/material.dart';
import 'package:medigo_mobile/constants/specialisations.dart';
import 'package:medigo_mobile/models/doctor_registration_request.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/validation_utils.dart';
import 'package:medigo_mobile/view_models/signup_view_model.dart';
import 'package:medigo_mobile/widgets/app_header.dart';
import 'package:medigo_mobile/widgets/app_text_field.dart';
import 'package:medigo_mobile/widgets/file_upload_field.dart';
import 'package:medigo_mobile/widgets/multi_file_upload_field.dart';
import 'package:medigo_mobile/widgets/password_field.dart';
import 'package:provider/provider.dart';

class DoctorSignupScreen extends StatefulWidget {
  const DoctorSignupScreen({super.key});

  @override
  State<DoctorSignupScreen> createState() => _DoctorSignupScreenState();
}

class _DoctorSignupScreenState extends State<DoctorSignupScreen> {
  final _pageController = PageController();
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // Step 1 controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  // Step 2 controllers
  final _gmcController = TextEditingController();
  final _yearsController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _callOutFeeController = TextEditingController();
  final _radiusController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _gmcFocus = FocusNode();
  final _yearsFocus = FocusNode();
  final _consultationFeeFocus = FocusNode();
  final _callOutFeeFocus = FocusNode();
  final _radiusFocus = FocusNode();

  int _currentStep = 0;
  final List<String> _selectedSpecialisations = [];
  List<String> _qualificationsFilePaths = [];
  String? _photoIdFilePath;
  bool _dbsConsentGiven = false;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _gmcController.dispose();
    _yearsController.dispose();
    _consultationFeeController.dispose();
    _callOutFeeController.dispose();
    _radiusController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _addressFocus.dispose();
    _gmcFocus.dispose();
    _yearsFocus.dispose();
    _consultationFeeFocus.dispose();
    _callOutFeeFocus.dispose();
    _radiusFocus.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  bool _validateStep1() {
    return _step1FormKey.currentState?.validate() ?? false;
  }

  bool _validateStep2() {
    if (!(_step2FormKey.currentState?.validate() ?? false)) return false;
    if (_selectedSpecialisations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one specialisation'),
        ),
      );
      return false;
    }
    if (_qualificationsFilePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please upload at least one medical qualification or certificate',
          ),
        ),
      );
      return false;
    }
    if (_photoIdFilePath == null || _photoIdFilePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please upload your photo ID (passport or driving licence)',
          ),
        ),
      );
      return false;
    }
    if (!_dbsConsentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must consent to the Enhanced DBS check'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _handleSubmit() async {
    if (!_validateStep2()) return;

    final request = DoctorRegistrationRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
      homeAddress: _addressController.text.trim(),
      gmcNumber: _gmcController.text.trim().replaceAll(RegExp(r'\s'), ''),
      specialisations: _selectedSpecialisations,
      yearsOfExperience: int.parse(_yearsController.text.trim()),
      consultationFee: double.parse(_consultationFeeController.text.trim()),
      callOutFee: _callOutFeeController.text.trim().isEmpty
          ? null
          : double.tryParse(_callOutFeeController.text.trim()),
      radiusKm: double.parse(_radiusController.text.trim()),
      qualificationsFilePaths: _qualificationsFilePaths,
      photoIdFilePath: _photoIdFilePath,
      dbsConsentGiven: _dbsConsentGiven,
    );

    final viewModel = context.read<SignupViewModel>();
    final success = await viewModel.registerDoctor(request);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.verificationPending,
        (route) => false,
      );
    } else if (viewModel.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              const AppHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  children: [_buildStep1(), _buildStep2()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          _buildStepDot(0, 'Personal'),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep >= 1 ? AppColors.primary : AppColors.border,
            ),
          ),
          _buildStepDot(1, 'Professional'),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? AppColors.primary
                : AppColors.border,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: AppColors.surface, size: 18)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySecondary.copyWith(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _step1FormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text('Personal Details', style: AppTypography.pageTitle),
            const SizedBox(height: 8),
            const Text(
              'Step 1 of 2 – Your basic information',
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _firstNameController,
                    focusNode: _firstNameFocus,
                    label: 'First Name',
                    hintText: 'First Name',
                    icon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_lastNameFocus),
                    validator: ValidationUtils.validateFirstName,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _lastNameController,
                    focusNode: _lastNameFocus,
                    label: 'Last Name',
                    hintText: 'Last Name',
                    icon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_emailFocus),
                    validator: ValidationUtils.validateLastName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              focusNode: _emailFocus,
              label: 'Email',
              hintText: 'Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_phoneFocus),
              validator: ValidationUtils.validateEmail,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              label: 'Phone Number',
              hintText: '+44 7XXX XXXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_passwordFocus),
              validator: ValidationUtils.validatePhone,
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_addressFocus),
              validator: ValidationUtils.validatePassword,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _addressController,
              focusNode: _addressFocus,
              label: 'Home / Base Address',
              hintText: 'Full address',
              icon: Icons.home_outlined,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.done,
              validator: ValidationUtils.validateAddress,
              onFieldSubmitted: (_) {
                FocusScope.of(context).unfocus();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _validateStep1()) _goToStep(1);
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _validateStep1()) _goToStep(1);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: AppTypography.button,
              ),
              child: const Text('Continue'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _step2FormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Professional & Compliance',
              style: AppTypography.pageTitle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Step 2 of 2 – GMC and documents',
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: _gmcController,
              focusNode: _gmcFocus,
              label: 'GMC Number',
              hintText: '7-digit GMC number',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_yearsFocus),
              validator: ValidationUtils.validateGmcNumber,
            ),
            const SizedBox(height: 16),
            MultiFileUploadField(
              label: 'Medical Qualifications & Certificates',
              filePaths: _qualificationsFilePaths,
              onFilesChanged: (paths) =>
                  setState(() => _qualificationsFilePaths = paths),
              maxFiles: 10,
              acceptCamera: true,
            ),
            const SizedBox(height: 16),
            _buildSpecialisationSelector(),
            const SizedBox(height: 16),
            AppTextField(
              controller: _yearsController,
              focusNode: _yearsFocus,
              label: 'Years of Experience',
              hintText: 'e.g. 5',
              icon: Icons.work_outline,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_consultationFeeFocus),
              validator: ValidationUtils.validateYearsOfExperience,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _consultationFeeController,
              focusNode: _consultationFeeFocus,
              label: 'Consultation Fee (£)',
              hintText: 'e.g. 75',
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_callOutFeeFocus),
              validator: ValidationUtils.validateFee,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _callOutFeeController,
              focusNode: _callOutFeeFocus,
              label: 'Call-out Fee (£) – if applicable',
              hintText: 'e.g. 25 (optional)',
              icon: Icons.directions_car_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_radiusFocus),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _radiusController,
              focusNode: _radiusFocus,
              label: 'Radius of Operation (km)',
              hintText: 'e.g. 15',
              icon: Icons.place_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              validator: ValidationUtils.validateRadius,
            ),
            const SizedBox(height: 16),
            FileUploadField(
              label: 'Photo ID (Passport or Driving Licence)',
              filePath: _photoIdFilePath,
              onFileSelected: (path) =>
                  setState(() => _photoIdFilePath = path.isEmpty ? null : path),
              acceptCamera: true,
            ),
            const SizedBox(height: 20),
            _buildDbsNotice(),
            const SizedBox(height: 24),
            Consumer<SignupViewModel>(
              builder: (context, viewModel, _) {
                return ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: AppTypography.button,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.6,
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.surface,
                            ),
                          ),
                        )
                      : const Text('Submit Registration'),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _goToStep(0),
              child: const Text('Back', style: AppTypography.link),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialisationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Specialisation(s)', style: AppTypography.bodySecondary),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kDoctorSpecialisations.map((s) {
            final isSelected = _selectedSpecialisations.contains(s);
            return FilterChip(
              label: Text(s),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSpecialisations.add(s);
                  } else {
                    _selectedSpecialisations.remove(s);
                  }
                });
              },
              selectedColor: AppColors.highlight,
              checkmarkColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDbsNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.highlight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enhanced DBS Check',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'An Enhanced DBS (Disclosure and Barring Service) check will be carried out as part of the verification process. This is required for all healthcare professionals providing direct patient care.',
            style: AppTypography.bodySecondary.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _dbsConsentGiven,
                  onChanged: (v) =>
                      setState(() => _dbsConsentGiven = v ?? false),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _dbsConsentGiven = !_dbsConsentGiven),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'I consent to the Enhanced DBS check being carried out',
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
