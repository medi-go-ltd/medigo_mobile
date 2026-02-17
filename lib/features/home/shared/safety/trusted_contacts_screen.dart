import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/services/safety_preferences_service.dart';

/// Uber-style: store trusted contacts to share visit details with.
class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  State<TrustedContactsScreen> createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends State<TrustedContactsScreen> {
  List<TrustedContact> _contacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await SafetyPreferencesService.getTrustedContacts();
    if (mounted) {
      setState(() {
        _contacts = list;
        _loading = false;
      });
    }
  }

  Future<void> _addContact() async {
    final result = await Navigator.push<TrustedContact>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTrustedContactScreen(),
      ),
    );
    if (result != null && mounted) await _load();
  }

  Future<void> _removeContact(TrustedContact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove contact'),
        content: Text(
          'Remove ${contact.name} from trusted contacts? They will no longer receive visit updates.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await SafetyPreferencesService.removeTrustedContact(contact.phone);
      if (mounted) await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'Trusted Contacts',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Text(
                    'These contacts can receive your visit details and location when you start a visit. Add people you trust in an emergency.',
                    style: AppTypography.bodySecondary.copyWith(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                Expanded(
                  child: _contacts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No trusted contacts yet',
                                  style: AppTypography.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add contacts to share your visit details and location with when you\'re on a home visit.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodySecondary.copyWith(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _contacts.length,
                          itemBuilder: (context, index) {
                            final c = _contacts[index];
                            return _ContactTile(
                              contact: c,
                              onRemove: () => _removeContact(c),
                              onShareVisit: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Share visit with ${c.name} (implement when visit is active)',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addContact,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add contact',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.onRemove,
    required this.onShareVisit,
  });

  final TrustedContact contact;
  final VoidCallback onRemove;
  final VoidCallback onShareVisit;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            contact.name.isNotEmpty
                ? contact.name.substring(0, 1).toUpperCase()
                : '?',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          contact.name,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          contact.phone,
          style: AppTypography.bodySecondary.copyWith(fontSize: 13),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          onSelected: (value) {
            if (value == 'share') onShareVisit();
            if (value == 'remove') onRemove();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share_outlined, size: 22),
                title: Text('Share current visit'),
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: ListTile(
                leading: Icon(Icons.person_remove_outlined, size: 22),
                title: Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTrustedContactScreen extends StatefulWidget {
  const AddTrustedContactScreen({super.key});

  @override
  State<AddTrustedContactScreen> createState() => _AddTrustedContactScreenState();
}

class _AddTrustedContactScreenState extends State<AddTrustedContactScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    await SafetyPreferencesService.addTrustedContact(
      TrustedContact(name: name, phone: phone),
    );
    if (mounted) Navigator.pop(context, TrustedContact(name: name, phone: phone));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'Add trusted contact',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: AppTypography.link),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'This person will be able to receive your visit details and location when you enable "Share visit with trusted contacts" in Safety Preferences.',
                style: AppTypography.bodySecondary.copyWith(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter a name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  hintText: 'e.g. +1 234 567 8900',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter a phone number';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
