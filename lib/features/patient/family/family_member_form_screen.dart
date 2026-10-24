import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/family_member.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/date_utils.dart';
import 'package:medigo_mobile/widgets/app_text_field.dart';
import 'package:medigo_mobile/widgets/field_label.dart';

class FamilyMemberFormResult {
  const FamilyMemberFormResult.saved(this.member, {this.saveToFamily = true})
    : deleted = false;

  const FamilyMemberFormResult.deleted(this.member)
    : saveToFamily = false,
      deleted = true;

  final FamilyMember member;
  final bool saveToFamily;
  final bool deleted;
}

/// Add or edit a family member. Pops with a [FamilyMemberFormResult]; the
/// caller decides whether to persist it.
class FamilyMemberFormScreen extends StatefulWidget {
  const FamilyMemberFormScreen({
    super.key,
    this.member,
    this.defaultLastName,
    this.showSaveToggle = false,
  });

  final FamilyMember? member;
  final String? defaultLastName;

  /// Shown when adding from booking, so a one-off patient needn't be saved.
  final bool showSaveToggle;

  @override
  State<FamilyMemberFormScreen> createState() => _FamilyMemberFormScreenState();
}

class _FamilyMemberFormScreenState extends State<FamilyMemberFormScreen> {
  static const _sexOptions = ['Female', 'Male'];

  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _dob = TextEditingController();
  final _allergies = TextEditingController();
  final _conditions = TextEditingController();
  final _medications = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _dobFocus = FocusNode();
  final _allergiesFocus = FocusNode();
  final _conditionsFocus = FocusNode();
  final _medicationsFocus = FocusNode();

  String? _sexAtBirth;
  FamilyRelationship? _relationship;
  bool _saveToFamily = true;

  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    if (member != null) {
      _firstName.text = member.firstName;
      _lastName.text = member.lastName;
      _dob.text = UkDateUtils.formatUk(member.dateOfBirth);
      _sexAtBirth = member.sexAtBirth;
      _relationship = member.relationship;
      _allergies.text = member.allergies ?? '';
      _conditions.text = member.conditions ?? '';
      _medications.text = member.medications ?? '';
    } else {
      _lastName.text = widget.defaultLastName ?? '';
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _dob,
      _allergies,
      _conditions,
      _medications,
    ]) {
      controller.dispose();
    }
    for (final node in [
      _firstNameFocus,
      _lastNameFocus,
      _dobFocus,
      _allergiesFocus,
      _conditionsFocus,
      _medicationsFocus,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(_isEditing ? 'Edit family member' : 'Add family member'),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Their age and sex help the doctor prepare and show the right body map.',
                  style: AppTypography.bodySecondary.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _firstName,
                  focusNode: _firstNameFocus,
                  label: 'First name',
                  hintText: 'First name',
                  icon: Icons.person_outline,
                  required: true,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'First name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _lastName,
                  focusNode: _lastNameFocus,
                  label: 'Last name',
                  hintText: 'Last name',
                  icon: Icons.person_outline,
                  required: true,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Last name is required'
                      : null,
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
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Date of birth is required';
                    }
                    final parsed = UkDateUtils.parseUk(v);
                    if (parsed == null) return 'Enter a valid date (DD/MM/YYYY)';
                    if (parsed.isAfter(DateTime.now())) {
                      return 'Date of birth cannot be in the future';
                    }
                    final relationship = _relationship;
                    if (relationship != null &&
                        relationship.requiresAdult &&
                        _ageOn(parsed) < FamilyMember.adultAge) {
                      return 'A ${relationship.label.toLowerCase()} must be '
                          '${FamilyMember.adultAge} or over';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _dropdown<FamilyRelationship>(
                  label: 'Relationship to you',
                  value: _relationship,
                  hint: 'Select relationship',
                  items: FamilyRelationship.values,
                  itemLabel: (r) => r.label,
                  onChanged: (v) => setState(() => _relationship = v),
                  errorText: 'Relationship is required',
                ),
                const SizedBox(height: 16),
                _dropdown<String>(
                  label: 'Sex at birth',
                  value: _sexAtBirth,
                  hint: 'Select',
                  items: _sexOptions,
                  itemLabel: (s) => s,
                  onChanged: (v) => setState(() => _sexAtBirth = v),
                  errorText: 'Sex at birth is required',
                ),
                const SizedBox(height: 24),
                Text(
                  'Health details (optional)',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _allergies,
                  focusNode: _allergiesFocus,
                  label: 'Allergies',
                  hintText: 'e.g. penicillin, peanuts',
                  icon: Icons.warning_amber_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _conditions,
                  focusNode: _conditionsFocus,
                  label: 'Medical conditions',
                  hintText: 'e.g. asthma, diabetes',
                  icon: Icons.monitor_heart_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _medications,
                  focusNode: _medicationsFocus,
                  label: 'Current medications',
                  hintText: 'List any medications',
                  icon: Icons.medication_outlined,
                  textInputAction: TextInputAction.done,
                ),
                if (widget.showSaveToggle) ...[
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Save to my family'),
                    subtitle: const Text('Reuse their details next time'),
                    value: _saveToFamily,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _saveToFamily = v),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _isEditing
                        ? 'Save changes'
                        : widget.showSaveToggle
                        ? 'Continue'
                        : 'Add family member',
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _confirmDelete,
                    child: const Text(
                      'Remove from my family',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
    required String errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label, required: true),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          hint: Text(hint),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(itemLabel(i))))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? errorText : null,
        ),
      ],
    );
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final current = UkDateUtils.parseUk(_dob.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 8, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() => _dob.text = UkDateUtils.formatUk(picked));
    }
  }

  int _ageOn(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final member = FamilyMember(
      id:
          widget.member?.id ??
          'family-${DateTime.now().microsecondsSinceEpoch}',
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      dateOfBirth: UkDateUtils.parseUk(_dob.text)!,
      sexAtBirth: _sexAtBirth!,
      relationship: _relationship!,
      allergies: _optional(_allergies),
      conditions: _optional(_conditions),
      medications: _optional(_medications),
    );
    Navigator.of(context).pop(
      FamilyMemberFormResult.saved(
        member,
        saveToFamily: !widget.showSaveToggle || _saveToFamily,
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final member = widget.member!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${member.firstName}?'),
        content: const Text(
          'Their details will be removed from your family. Past visits are not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(FamilyMemberFormResult.deleted(member));
    }
  }
}
