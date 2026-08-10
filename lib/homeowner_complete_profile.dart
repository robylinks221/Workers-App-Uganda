import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'homeowner_shell.dart';
import 'services/homeowner_profile_service.dart';

const Color _primary = Color(0xFFD87C53);
const Color _heroLight = Color(0xFF4F7089);
const Color _heroDark = Color(0xFF2A3D4E);
const Color _inputFill = Color(0xFFFAEEE6);
const Color _text = Color(0xFF395264);
const Color _subText = Color(0xFF5C7A8C);
const Color _error = Color(0xFFE53E3E);

const List<String> _districts = [
  'Kampala',
  'Wakiso',
  'Mukono',
  'Entebbe',
  'Jinja',
  'Mbale',
  'Gulu',
  'Lira',
  'Mbarara',
  'Fort Portal',
  'Masaka',
  'Soroti',
  'Arua',
  'Kabale',
  'Hoima',
  'Tororo',
  'Iganga',
  'Mityana',
  'Kasese',
  'Bushenyi',
  'Rukungiri',
  'Moroto',
  'Other',
];

class HomeownerCompleteProfileScreen extends StatefulWidget {
  const HomeownerCompleteProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    this.email = '',
  });

  final String name;
  final String phone;
  final String email;

  @override
  State<HomeownerCompleteProfileScreen> createState() =>
      _HomeownerCompleteProfileScreenState();
}

class _HomeownerCompleteProfileScreenState
    extends State<HomeownerCompleteProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final HomeownerProfileService _service = HomeownerProfileService();

  XFile? _profilePhoto;
  Uint8List? _profilePhotoBytes;
  String? _district;
  String _preferredContact = 'phone';
  bool _loading = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.name;
    _emailController.text = widget.email;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<ImageSource?> _chooseImageSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Add Profile Photo',
                  style: TextStyle(
                    color: _text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _SourceButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: () => Navigator.pop(context, ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _SourceButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap:
                            () => Navigator.pop(context, ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickProfilePhoto() async {
    final source = await _chooseImageSource();

    if (source == null) return;

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();

    if (!mounted) return;

    setState(() {
      _profilePhoto = file;
      _profilePhotoBytes = bytes;
    });
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_district == null) {
      _showMessage('Please select your district.', isError: true);
      return;
    }

    setState(() => _loading = true);

    final result = await _service.saveProfile(
      fullName: _nameController.text,
      email: _emailController.text,
      address: _addressController.text,
      city: _cityController.text,
      district: _district!,
      country: 'Uganda',
      preferredContact: _preferredContact,
      profilePhoto: _profilePhoto,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (result['success'] != true) {
      _showMessage(
        result['message']?.toString() ?? 'Unable to save homeowner profile.',
        isError: true,
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeownerShell()),
      (route) => false,
    );
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isError ? _error : _primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final firstName =
        _nameController.text.trim().isEmpty
            ? 'Homeowner'
            : _nameController.text.trim().split(RegExp(r'\s+')).first;

    return Scaffold(
      backgroundColor: _heroDark,
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                const Positioned.fill(child: _HeroBackground()),
                SafeArea(
                  bottom: false,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Step 2 of 2',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _pickProfilePhoto,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.18,
                                  ),
                                  backgroundImage:
                                      _profilePhotoBytes == null
                                          ? null
                                          : MemoryImage(_profilePhotoBytes!),
                                  child:
                                      _profilePhotoBytes == null
                                          ? const Icon(
                                            Icons.person_rounded,
                                            color: Colors.white70,
                                            size: 48,
                                          )
                                          : null,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 31,
                                    height: 31,
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
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _nameController.text.trim().isEmpty
                                ? widget.name
                                : _nameController.text.trim(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '🏠 Homeowner',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Almost done, $firstName 🏠',
                          style: const TextStyle(
                            color: _text,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Add a few details so workers know where you are.',
                          style: TextStyle(color: _subText, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        _AppField(
                          controller: _nameController,
                          label: 'Full name',
                          icon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            if ((value ?? '').trim().length < 3) {
                              return 'Enter your full name.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _AppField(
                          controller: _emailController,
                          label: 'Email address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final email = (value ?? '').trim();

                            if (email.isEmpty || !email.contains('@')) {
                              return 'Enter a valid email address.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _district,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() => _district = value);
                          },
                          decoration: _inputDecoration(
                            'District',
                            Icons.location_city_rounded,
                          ),
                          items:
                              _districts
                                  .map(
                                    (district) => DropdownMenuItem(
                                      value: district,
                                      child: Text(district),
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 12),
                        _AppField(
                          controller: _cityController,
                          label: 'City / town',
                          icon: Icons.apartment_rounded,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        _AppField(
                          controller: _addressController,
                          label: 'Street / area',
                          icon: Icons.signpost_outlined,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Enter your street or area.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 17,
                          ),
                          decoration: BoxDecoration(
                            color: _inputFill.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.phone_android_rounded,
                                color: _subText,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.phone,
                                  style: const TextStyle(
                                    color: _text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Text(
                                'From sign-up',
                                style: TextStyle(
                                  color: _primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Preferred contact',
                          style: TextStyle(
                            color: _text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'phone',
                              icon: Icon(Icons.phone_rounded),
                              label: Text('Phone'),
                            ),
                            ButtonSegment(
                              value: 'whatsapp',
                              icon: Icon(Icons.chat_rounded),
                              label: Text('WhatsApp'),
                            ),
                            ButtonSegment(
                              value: 'email',
                              icon: Icon(Icons.email_rounded),
                              label: Text('Email'),
                            ),
                          ],
                          selected: {_preferredContact},
                          onSelectionChanged: (selection) {
                            setState(() {
                              _preferredContact = selection.first;
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child:
                                _loading
                                    ? const SizedBox(
                                      width: 23,
                                      height: 23,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                    : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Start Finding Workers',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded),
                                      ],
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppField extends StatelessWidget {
  const _AppField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
      decoration: _inputDecoration(label, icon),
    );
  }
}

InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: _subText, fontSize: 13),
    prefixIcon: Icon(icon, color: _subText, size: 20),
    filled: true,
    fillColor: _inputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: _primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: _error),
    ),
  );
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _inputFill,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: _primary, size: 30),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(color: _text, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_heroLight, _heroDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
