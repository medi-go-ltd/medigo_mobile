import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/doctor_profile.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:medigo_mobile/widgets/app_text_field.dart';
import 'package:medigo_mobile/widgets/file_upload_field.dart';
import 'package:medigo_mobile/widgets/multi_file_upload_field.dart';
import 'package:medigo_mobile/widgets/section_title.dart';
import 'package:provider/provider.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _consultationFeeController;
  late TextEditingController _callOutFeeController;
  late TextEditingController _radiusController;

  List<String> _qualificationsFilePaths = [];
  String? _photoIdFilePath;

  @override
  void initState() {
    super.initState();
    final profile = context.read<DoctorHomeViewModel>().profile;
    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController = TextEditingController(text: profile.lastName);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phoneNumber);
    _addressController = TextEditingController(text: profile.address);
    _consultationFeeController = TextEditingController(text: profile.consultationFee.toStringAsFixed(0));
    _callOutFeeController = TextEditingController(
      text: profile.callOutFee?.toStringAsFixed(0) ?? '',
    );
    _radiusController = TextEditingController(text: profile.radiusKm.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _consultationFeeController.dispose();
    _callOutFeeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DoctorHomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Personal Details'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _firstNameController,
                    focusNode: FocusNode(),
                    label: 'First Name',
                    hintText: 'First name',
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _lastNameController,
                    focusNode: FocusNode(),
                    label: 'Last Name',
                    hintText: 'Last name',
                    icon: Icons.person_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              focusNode: FocusNode(),
              label: 'Email',
              hintText: 'Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              focusNode: FocusNode(),
              label: 'Phone',
              hintText: 'Phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _addressController,
              focusNode: FocusNode(),
              label: 'Address',
              hintText: 'Home address',
              icon: Icons.home_outlined,
            ),
            const SizedBox(height: 32),
            const SectionTitle(title: 'Fees'),
            const SizedBox(height: 16),
            AppTextField(
              controller: _consultationFeeController,
              focusNode: FocusNode(),
              label: 'Consultation Fee (£)',
              hintText: 'e.g. 75',
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _callOutFeeController,
              focusNode: FocusNode(),
              label: 'Call-out Fee (£) - optional',
              hintText: 'e.g. 25',
              icon: Icons.directions_car_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 32),
            const SectionTitle(title: 'Availability'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status', style: AppTypography.bodySecondary),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: viewModel.isOnline ? AppColors.highlight : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              viewModel.isOnline ? Icons.circle : Icons.circle_outlined,
                              size: 12,
                              color: viewModel.isOnline ? Colors.green : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              viewModel.isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: viewModel.isOnline ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Change availability on the home screen',
                        style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _radiusController,
              focusNode: FocusNode(),
              label: 'Radius of operation (km)',
              hintText: 'e.g. 15',
              icon: Icons.place_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 32),
            const SectionTitle(title: 'Documents'),
            const SizedBox(height: 8),
            Text(
              'Update your qualifications or photo ID if needed.',
              style: AppTypography.bodySecondary.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 16),
            MultiFileUploadField(
              label: 'Qualifications & Certificates',
              filePaths: _qualificationsFilePaths,
              onFilesChanged: (paths) => setState(() => _qualificationsFilePaths = paths),
              maxFiles: 10,
            ),
            const SizedBox(height: 16),
            FileUploadField(
              label: 'Photo ID',
              filePath: _photoIdFilePath,
              onFileSelected: (path) => setState(() => _photoIdFilePath = path.isEmpty ? null : path),
              acceptCamera: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveProfile(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: AppTypography.button,
                ),
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _saveProfile(BuildContext context) {
    final consultationFee = double.tryParse(_consultationFeeController.text.trim());
    final callOutFee = _callOutFeeController.text.trim().isEmpty
        ? null
        : double.tryParse(_callOutFeeController.text.trim());
    final radiusKm = double.tryParse(_radiusController.text.trim()) ?? 15;

    final profile = DoctorProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      consultationFee: consultationFee ?? 75,
      callOutFee: callOutFee,
      radiusKm: radiusKm,
    );

    context.read<DoctorHomeViewModel>().updateProfile(profile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
    Navigator.pop(context);
  }
}
