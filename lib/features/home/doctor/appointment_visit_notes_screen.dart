import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medigo_mobile/models/appointment.dart';
import 'package:medigo_mobile/models/appointment_flag.dart';
import 'package:medigo_mobile/models/visit_notes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:medigo_mobile/widgets/doctor_screen_app_bar.dart';
import 'package:provider/provider.dart';

class AppointmentVisitNotesScreen extends StatefulWidget {
  const AppointmentVisitNotesScreen({
    super.key,
    required this.appointment,
  });

  final Appointment appointment;

  @override
  State<AppointmentVisitNotesScreen> createState() =>
      _AppointmentVisitNotesScreenState();
}

class _AppointmentVisitNotesScreenState extends State<AppointmentVisitNotesScreen> {
  late TextEditingController _manualNotesController;
  late TextEditingController _flagDescriptionController;
  FlagReason _selectedFlagReason = FlagReason.other;
  bool _flagAddress = false;

  @override
  void initState() {
    super.initState();
    _manualNotesController = TextEditingController();
    _flagDescriptionController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DoctorHomeViewModel>();
      final notes = vm.getVisitNotes(widget.appointment.id);
      _manualNotesController.text = notes.manualNotes;
    });
  }

  @override
  void dispose() {
    _manualNotesController.dispose();
    _flagDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (xFile == null || !mounted) return;
    final vm = context.read<DoctorHomeViewModel>();
    final path = await vm.addScreenshotToNotes(widget.appointment.id, xFile.path);
    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo added to notes')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add photo')),
      );
    }
  }

  void _requestAiNotes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI notes'),
        content: const Text(
          'AI-generated notes will be available in a future update. '
          'You can type your notes manually or add photos for now.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _saveNotes() {
    final vm = context.read<DoctorHomeViewModel>();
    vm.updateManualNotes(widget.appointment.id, _manualNotesController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes saved')),
      );
      Navigator.pop(context);
    }
  }

  void _submitFlag() {
    final description = _flagDescriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
      );
      return;
    }
    final vm = context.read<DoctorHomeViewModel>();
    vm.addFlag(
      widget.appointment.id,
      AppointmentFlag(
        reason: _selectedFlagReason,
        description: description,
        flaggedAt: DateTime.now(),
        isAddressFlag: _flagAddress,
      ),
    );
    _flagDescriptionController.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted. Our team will review it.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: DoctorScreenAppBar(
        title: 'Visit notes – ${widget.appointment.patientName}',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        showSettings: false,
      ),
      body: Consumer<DoctorHomeViewModel>(
        builder: (context, vm, _) {
          final notes = vm.getVisitNotes(widget.appointment.id);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppointmentSummary(),
                const SizedBox(height: 24),
                _buildNotesSection(notes, vm),
                const SizedBox(height: 24),
                _buildFlagSection(notes),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentSummary() {
    final a = widget.appointment;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.highlight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(a.patientName, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(a.patientLocation, style: AppTypography.bodySecondary),
          const SizedBox(height: 4),
          Text(a.reasonForVisit, style: AppTypography.bodySecondary),
        ],
      ),
    );
  }

  Widget _buildNotesSection(VisitNotes notes, DoctorHomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes during visit',
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _manualNotesController,
          onChanged: (v) => vm.updateManualNotes(widget.appointment.id, v),
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Type notes here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined, size: 20),
              label: const Text('Take photo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 20),
              label: const Text('Gallery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: _requestAiNotes,
              icon: const Icon(Icons.auto_awesome_outlined, size: 20),
              label: const Text('AI notes'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ),
        if (notes.screenshotPaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: notes.screenshotPaths.map((path) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => vm.removeScreenshot(widget.appointment.id, path),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.warning,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
        if (notes.aiNotes != null && notes.aiNotes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoHighlight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.info),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 18, color: AppColors.info),
                    const SizedBox(width: 6),
                    Text('AI notes', style: AppTypography.bodySecondary.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(notes.aiNotes!, style: AppTypography.bodySecondary),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveNotes,
            icon: const Icon(Icons.check, size: 20),
            label: const Text('Save notes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlagSection(VisitNotes notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flag_outlined, size: 20, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(
              'Report an issue',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Flag this visit or address if you encountered abuse, safety concerns, or location issues.',
          style: AppTypography.bodySecondary.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Flag address / location (not just this visit)'),
          value: _flagAddress,
          onChanged: (v) => setState(() => _flagAddress = v),
          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          activeThumbColor: AppColors.primary,
        ),
        DropdownButtonFormField<FlagReason>(
          initialValue: _selectedFlagReason,
          decoration: InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: FlagReason.values
              .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
              .toList(),
          onChanged: (v) => setState(() => _selectedFlagReason = v ?? FlagReason.other),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _flagDescriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Describe the issue',
            hintText: 'Provide details for our team to review...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _submitFlag,
            icon: const Icon(Icons.flag, size: 20),
            label: const Text('Submit report'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: const BorderSide(color: AppColors.warning),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (notes.flags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Submitted reports', style: AppTypography.bodySecondary.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...notes.flags.map((AppointmentFlag f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningHighlight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.reason.label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                      if (f.isAddressFlag)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text('Address/location flagged', style: AppTypography.bodySecondary.copyWith(fontSize: 12)),
                        ),
                      const SizedBox(height: 4),
                      Text(f.description, style: AppTypography.bodySecondary),
                    ],
                  ),
                ),
              )),
        ],
      ],
    );
  }
}
