import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../services/profile_section_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class HomeownerPersonalInformationScreen extends StatefulWidget {
  const HomeownerPersonalInformationScreen({
    super.key,
    required this.user,
    required this.profile,
  });

  final Map<String, dynamic> user;
  final Map<String, dynamic> profile;

  @override
  State<HomeownerPersonalInformationScreen> createState() =>
      _HomeownerPersonalInformationScreenState();
}

class _HomeownerPersonalInformationScreenState
    extends State<HomeownerPersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProfileSectionService();
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  XFile? _photo;
  Uint8List? _photoBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.user['full_name']?.toString() ?? '',
    );
    _emailController = TextEditingController(
      text: widget.user['email']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() {
      _photo = file;
      _photoBytes = bytes;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    final result = await _service.updateHomeownerPersonal(
      fullName: _nameController.text,
      email: _emailController.text,
      profilePhoto: _photo,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ?? 'Profile update completed.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (result['success'] == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = ApiConfig.storageUrl(
      widget.user['profile_photo']?.toString() ??
          widget.profile['profile_photo']?.toString(),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _PageHeader(
              title: 'Edit Profile',
              subtitle: 'Keep your personal information accurate and current.',
              icon: Icons.person_outline_rounded,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 120),
                  children: [
                    _PremiumCard(
                      title: 'Profile Photo',
                      icon: Icons.photo_camera_outlined,
                      child: Center(
                        child: GestureDetector(
                          onTap: _pickPhoto,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 54,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  backgroundImage:
                                      _photoBytes != null
                                          ? MemoryImage(_photoBytes!)
                                          : imageUrl.isNotEmpty
                                          ? NetworkImage(imageUrl)
                                          : null,
                                  child:
                                      _photoBytes == null && imageUrl.isEmpty
                                          ? const Icon(
                                            Icons.person_rounded,
                                            size: 50,
                                            color: _primary,
                                          )
                                          : null,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: _primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PremiumCard(
                      title: 'Personal Information',
                      icon: Icons.badge_outlined,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator:
                                (value) =>
                                    (value ?? '').trim().length < 3
                                        ? 'Enter your full name.'
                                        : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              final email = (value ?? '').trim();
                              return !email.contains('@')
                                  ? 'Enter a valid email.'
                                  : null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _SaveBar(
        saving: _saving,
        label: 'Save Profile',
        onPressed: _save,
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      padding: const EdgeInsets.fromLTRB(8, 10, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF177989), _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, color: Colors.white, size: 27),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
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

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.24 : 0.09,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _primary, size: 22),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.saving,
    required this.label,
    required this.onPressed,
  });

  final bool saving;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 16,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: saving ? null : onPressed,
              style: FilledButton.styleFrom(backgroundColor: _primary),
              icon:
                  saving
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.save_rounded),
              label: Text(saving ? 'Saving...' : label),
            ),
          ),
        ),
      ),
    );
  }
}
