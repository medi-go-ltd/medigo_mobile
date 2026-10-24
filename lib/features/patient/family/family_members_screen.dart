import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/patient/family/family_member_form_screen.dart';
import 'package:medigo_mobile/models/family_member.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:medigo_mobile/view_models/family_view_model.dart';
import 'package:provider/provider.dart';

/// Opens the add/edit form and applies the result to [FamilyViewModel].
/// Returns the result so callers (e.g. booking) can use the member.
Future<FamilyMemberFormResult?> openFamilyMemberForm(
  BuildContext context, {
  FamilyMember? member,
  bool showSaveToggle = false,
}) async {
  final family = context.read<FamilyViewModel>();
  final lastName = context.read<AuthViewModel>().user?.lastName;
  final result = await Navigator.of(context).push<FamilyMemberFormResult>(
    MaterialPageRoute(
      builder: (_) => FamilyMemberFormScreen(
        member: member,
        defaultLastName: lastName,
        showSaveToggle: showSaveToggle,
      ),
    ),
  );
  if (result == null) return null;

  if (result.deleted) {
    await family.remove(result.member.id);
  } else if (result.saveToFamily) {
    if (family.byId(result.member.id) != null) {
      await family.update(result.member);
    } else {
      await family.add(result.member);
    }
  }
  return result;
}

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthViewModel>().user?.id;
    if (userId != null) {
      context.read<FamilyViewModel>().loadFor(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final family = context.watch<FamilyViewModel>();
    final members = family.members;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('My family'),
      ),
      body: family.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                Text(
                  'Save the people you book for, so their details are ready next time.',
                  style: AppTypography.bodySecondary.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 20),
                if (members.isEmpty)
                  const _EmptyFamily()
                else
                  for (final member in members) ...[
                    FamilyMemberTile(
                      member: member,
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () => openFamilyMemberForm(
                        context,
                        member: member,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => openFamilyMemberForm(context),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('Add family member'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyFamily extends StatelessWidget {
  const _EmptyFamily();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.highlight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.family_restroom_outlined,
            size: 44,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No family members yet',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Add children, a partner or parents you book visits for.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySecondary.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Avatar, name and "Child · 4 yrs · Male" line for a family member.
class FamilyMemberTile extends StatelessWidget {
  const FamilyMemberTile({
    super.key,
    required this.member,
    this.onTap,
    this.trailing,
    this.selected = false,
  });

  final FamilyMember member;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final initials = [
      if (member.firstName.isNotEmpty) member.firstName[0],
      if (member.lastName.isNotEmpty) member.lastName[0],
    ].join().toUpperCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.highlight,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.summary,
                      style: AppTypography.bodySecondary.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
