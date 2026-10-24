import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medigo_mobile/services/profile_completion_service.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/date_utils.dart';
import 'package:medigo_mobile/utils/validation_utils.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:medigo_mobile/widgets/app_text_field.dart';
import 'package:medigo_mobile/widgets/field_label.dart';
import 'package:provider/provider.dart';

class CompletePatientProfileScreen extends StatefulWidget {
  const CompletePatientProfileScreen({
    super.key,
    this.isEditing = false,
  });

  /// When true, copy is framed as editing rather than first-time completion.
  final bool isEditing;

  @override
  State<CompletePatientProfileScreen> createState() =>
      _CompletePatientProfileScreenState();
}

class _CompletePatientProfileScreenState
    extends State<CompletePatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _dob = TextEditingController();
  final _medications = TextEditingController();
  final _notes = TextEditingController();
  final _allergyDetails = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _dobFocus = FocusNode();
  final _medicationsFocus = FocusNode();
  final _notesFocus = FocusNode();
  final _allergyFocus = FocusNode();

  String _gender = 'Female';
  String _genderAtBirth = 'Female';
  bool _highBloodPressure = false;
  bool _diabetes = false;
  bool _heartDisease = false;
  bool _asthma = false;
  bool _allergies = false;
  bool _sameGenderPref = false;
  String? _profileImagePath;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  Future<void> _prefill() async {
    final user = context.read<AuthViewModel>().user;
    if (user != null) {
      _firstName.text = user.firstName;
      _lastName.text = user.lastName;
      if (user.phoneNumber != null) {
        _phone.text = user.phoneNumber!;
      }
      if (user.gender != null && user.gender!.isNotEmpty) {
        _gender = user.gender!;
      }
    }

    final dob = await ProfileCompletionService.getDateOfBirth();
    if (dob != null) {
      final parsed = DateTime.tryParse(dob);
      if (parsed != null) {
        _dob.text = UkDateUtils.formatUk(parsed);
      }
    }

    final deferred = await ProfileCompletionService.getDeferredProfile();
    if (deferred != null) {
      final gab = deferred['genderAtBirth'] as String?;
      if (gab != null && gab.isNotEmpty) _genderAtBirth = gab;
      _highBloodPressure = deferred['highBloodPressure'] as bool? ?? false;
      _diabetes = deferred['diabetes'] as bool? ?? false;
      _heartDisease = deferred['heartDisease'] as bool? ?? false;
      _asthma = deferred['asthma'] as bool? ?? false;
      _allergies = deferred['allergies'] as bool? ?? false;
      _sameGenderPref =
          deferred['sameGenderDoctorPreference'] as bool? ?? false;
      final allergyDetails = deferred['allergyDetails'] as String?;
      if (allergyDetails != null) _allergyDetails.text = allergyDetails;
      final meds = deferred['currentMedications'] as String?;
      if (meds != null) _medications.text = meds;
      final notes = deferred['additionalNotes'] as String?;
      if (notes != null) _notes.text = notes;
      final photo = deferred['localProfileImagePath'] as String?;
      if (photo != null && photo.isNotEmpty) _profileImagePath = photo;
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _dob.dispose();
    _medications.dispose();
    _notes.dispose();
    _allergyDetails.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();
    _dobFocus.dispose();
    _medicationsFocus.dispose();
    _notesFocus.dispose();
    _allergyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Edit profile' : 'Finish your profile';
    final subtitle = widget.isEditing
        ? 'Update your details anytime. Photo is optional.'
        : 'These details help your doctor prepare. You can skip the photo.';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(title),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                subtitle,
                style: AppTypography.bodySecondary.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.highlight,
                    child: Icon(
                      _profileImagePath == null
                          ? Icons.camera_alt_outlined
                          : Icons.check_circle_outline,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _profileImagePath == null
                    ? 'Add photo (optional)'
                    : 'Photo selected',
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _firstName,
                focusNode: _firstNameFocus,
                label: 'First name',
                hintText: 'First name',
                icon: Icons.person_outline,
                required: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _lastName,
                focusNode: _lastNameFocus,
                label: 'Last name',
                hintText: 'Last name',
                icon: Icons.person_outline,
                required: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phone,
                focusNode: _phoneFocus,
                label: 'Phone',
                hintText: 'Phone number',
                icon: Icons.phone_outlined,
                required: true,
                keyboardType: TextInputType.phone,
                validator: ValidationUtils.validatePhone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _dob,
                focusNode: _dobFocus,
                label: 'Date of birth',
                hintText: 'DD/MM/YYYY',
                icon: Icons.calendar_today_outlined,
                required: true,
                readOnly: true,
                onTap: _pickDob,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Date of birth is required';
                  }
                  if (UkDateUtils.parseUk(value) == null) {
                    return 'Enter a valid date (DD/MM/YYYY)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                'Gender',
                _gender,
                const ['Female', 'Male', 'Non-binary', 'Prefer not to say'],
                (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                'Gender at birth',
                _genderAtBirth,
                const ['Female', 'Male'],
                (v) => setState(() => _genderAtBirth = v),
              ),
              const SizedBox(height: 24),
              Text(
                'Medical history',
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _toggle(
                'High Blood Pressure',
                _highBloodPressure,
                (v) => setState(() => _highBloodPressure = v),
              ),
              _toggle(
                'Diabetes',
                _diabetes,
                (v) => setState(() => _diabetes = v),
              ),
              _toggle(
                'Heart Disease',
                _heartDisease,
                (v) => setState(() => _heartDisease = v),
              ),
              _toggle('Asthma', _asthma, (v) => setState(() => _asthma = v)),
              _toggle(
                'Allergies',
                _allergies,
                (v) => setState(() => _allergies = v),
              ),
              if (_allergies) ...[
                const SizedBox(height: 8),
                AppTextField(
                  controller: _allergyDetails,
                  focusNode: _allergyFocus,
                  label: 'Allergy details',
                  hintText: 'Describe your allergies',
                  icon: Icons.warning_amber_outlined,
                ),
              ],
              const SizedBox(height: 12),
              AppTextField(
                controller: _medications,
                focusNode: _medicationsFocus,
                label: 'Current medications (optional)',
                hintText: 'List any medications',
                icon: Icons.medication_outlined,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _notes,
                focusNode: _notesFocus,
                label: 'Additional notes (optional)',
                hintText: 'Anything else your doctor should know',
                icon: Icons.notes_outlined,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Prefer same-gender doctor'),
                value: _sameGenderPref,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _sameGenderPref = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surface,
                        ),
                      )
                    : Text(widget.isEditing ? 'Save changes' : 'Save details'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label, required: true),
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

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _profileImagePath = picked.path);
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() => _dob.text = UkDateUtils.formatUk(picked));
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final iso = UkDateUtils.ukDisplayToIso(_dob.text.trim());
    if (iso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid date of birth')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final auth = context.read<AuthViewModel>();
      final user = auth.user;
      if (user == null) return;

      await ProfileCompletionService.saveDateOfBirth(iso);
      await ProfileCompletionService.saveDeferredProfile({
        'genderAtBirth': _genderAtBirth,
        'highBloodPressure': _highBloodPressure,
        'diabetes': _diabetes,
        'heartDisease': _heartDisease,
        'asthma': _asthma,
        'allergies': _allergies,
        'allergyDetails':
            _allergies ? _allergyDetails.text.trim() : null,
        'currentMedications': _medications.text.trim().isEmpty
            ? null
            : _medications.text.trim(),
        'additionalNotes':
            _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        'sameGenderDoctorPreference': _sameGenderPref,
        // Local path only until upload is wired — do not put in profileImageUrl.
        'localProfileImagePath': _profileImagePath,
      });
      await ProfileCompletionService.markMedicalHistorySaved();

      final updated = user.copyWith(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phoneNumber: _phone.text.trim(),
        gender: _gender,
      );
      await auth.updateUser(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? 'Profile updated' : 'Profile saved',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
