import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'services/worker_profile_service.dart';
import 'services/worker_service_management_service.dart';
import 'worker_shell.dart';

const Color _primary = Color(0xFFD87C53);
const Color _heroLight = Color(0xFF4F7089);
const Color _heroDark = Color(0xFF2A3D4E);
const Color _inputFill = Color(0xFFFAEEE6);
const Color _text = Color(0xFF395264);
const Color _subText = Color(0xFF5C7A8C);
const Color _error = Color(0xFFE53E3E);

class WorkerCompleteProfileScreen extends StatefulWidget {
  const WorkerCompleteProfileScreen({super.key, required this.phone});

  final String phone;

  @override
  State<WorkerCompleteProfileScreen> createState() =>
      _WorkerCompleteProfileScreenState();
}

class _WorkerCompleteProfileScreenState
    extends State<WorkerCompleteProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _districtController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController(text: '0');

  final _picker = ImagePicker();
  final _profileService = WorkerProfileService();
  final _serviceManagement = WorkerServiceManagementService();

  String? _religion;
  String? _gender;
  String _workType = 'full_time';
  bool _loading = false;
  bool _loadingServices = true;
  String? _servicesError;
  List<Map<String, dynamic>> _serviceCategories = [];
  final Set<int> _selectedServiceIds = <int>{};

  XFile? _profilePhoto;
  Uint8List? _profilePhotoBytes;
  XFile? _nationalIdFrontDocument;
  Uint8List? _nationalIdFrontBytes;
  XFile? _nationalIdBackDocument;
  Uint8List? _nationalIdBackBytes;
  final List<XFile?> _galleryImages = List<XFile?>.filled(3, null);
  final List<Uint8List?> _galleryImageBytes = List<Uint8List?>.filled(3, null);

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  static const religions = [
    'Christian',
    'Muslim',
    'Catholic',
    'Seventh-Day Adventist',
    'Other / Prefer not to say',
  ];

  static const genders = ['male', 'female', 'other'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
    _loadServiceCategories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _districtController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadServiceCategories() async {
    setState(() {
      _loadingServices = true;
      _servicesError = null;
    });

    final result = await _serviceManagement.getCategories();

    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _loadingServices = false;
        _servicesError =
            result['message']?.toString() ?? 'Unable to load services.';
      });
      return;
    }

    final raw = result['service_categories'];
    final categories = <Map<String, dynamic>>[];

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          categories.add(Map<String, dynamic>.from(item));
        }
      }
    }

    setState(() {
      _serviceCategories = categories;
      _loadingServices = false;
      if (categories.isEmpty) {
        _servicesError = 'No active services are available yet.';
      }
    });
  }

  Future<void> _pickProfilePhoto(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1600,
    );

    if (file == null || !mounted) {
      return;
    }

    final bytes = await file.readAsBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      _profilePhoto = file;
      _profilePhotoBytes = bytes;
    });
  }

  Future<void> _pickNationalIdFront(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 2000,
    );

    if (file == null || !mounted) {
      return;
    }

    final bytes = await file.readAsBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      _nationalIdFrontDocument = file;
      _nationalIdFrontBytes = bytes;
    });
  }

  Future<void> _pickNationalIdBack(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 2000,
    );

    if (file == null || !mounted) {
      return;
    }

    final bytes = await file.readAsBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      _nationalIdBackDocument = file;
      _nationalIdBackBytes = bytes;
    });
  }

  Future<void> _pickGalleryImage(int index, ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1800,
    );

    if (file == null || !mounted) {
      return;
    }

    final bytes = await file.readAsBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      _galleryImages[index] = file;
      _galleryImageBytes[index] = bytes;
    });
  }

  Future<ImageSource?> _chooseImageSource(String title) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _text,
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
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startProfilePhotoPicker() async {
    final source = await _chooseImageSource('Add profile photo');

    if (source != null) {
      await _pickProfilePhoto(source);
    }
  }

  Future<void> _startNationalIdFrontPicker() async {
    final source = await _chooseImageSource('Upload National ID');

    if (source != null) {
      await _pickNationalIdFront(source);
    }
  }

  Future<void> _startNationalIdBackPicker() async {
    final source = await _chooseImageSource('Upload National ID');

    if (source != null) {
      await _pickNationalIdBack(source);
    }
  }

  Future<void> _startGalleryPicker(int index) async {
    final source = await _chooseImageSource('Add gallery photo ${index + 1}');

    if (source != null) {
      await _pickGalleryImage(index, source);
    }
  }

  String? _requiredText(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_religion == null) {
      _showMessage('Please select your religion.', isError: true);
      return;
    }

    if (_gender == null) {
      _showMessage('Please select your gender.', isError: true);
      return;
    }

    if (_loadingServices) {
      _showMessage('Please wait while services load.', isError: true);
      return;
    }

    if (_servicesError != null) {
      _showMessage(_servicesError!, isError: true);
      return;
    }

    if (_selectedServiceIds.isEmpty) {
      _showMessage(
        'Please select at least one service you offer.',
        isError: true,
      );
      return;
    }

    if (_profilePhoto == null) {
      _showMessage('Please add your profile photo.', isError: true);
      return;
    }

    if (_nationalIdFrontDocument == null) {
      _showMessage(
        'Please upload the front of your National ID.',
        isError: true,
      );
      return;
    }

    if (_nationalIdBackDocument == null) {
      _showMessage(
        'Please upload the back of your National ID.',
        isError: true,
      );
      return;
    }

    if (_galleryImages.any((image) => image == null)) {
      _showMessage('Please upload all 3 gallery photos.', isError: true);
      return;
    }

    setState(() => _loading = true);

    final result = await _profileService.saveProfile(
      fullName: _nameController.text,
      age: int.parse(_ageController.text),
      religion: _religion!,
      gender: _gender!,
      district: _districtController.text,
      workType: _workType,
      serviceIds: _selectedServiceIds.toList()..sort(),
      bio: _bioController.text,
      experienceYears: int.tryParse(_experienceController.text) ?? 0,
      profilePhoto: _profilePhoto,
      nationalIdFrontDocument: _nationalIdFrontDocument,
      nationalIdBackDocument: _nationalIdBackDocument,
      galleryImage1: _galleryImages[0],
      galleryImage2: _galleryImages[1],
      galleryImage3: _galleryImages[2],
    );

    if (!mounted) {
      return;
    }

    setState(() => _loading = false);

    if (result['success'] != true) {
      _showMessage(
        result['message']?.toString() ?? 'Unable to save your profile.',
        isError: true,
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WorkerShell()),
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

    return Scaffold(
      backgroundColor: _heroDark,
      body: Column(
        children: [
          _buildHero(),
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 28,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 36),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _SectionTitle('Personal information'),
                        const SizedBox(height: 14),
                        _AppField(
                          controller: _nameController,
                          label: 'Full name',
                          icon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                          validator:
                              (value) => _requiredText(
                                value,
                                'Full name is required.',
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _AppField(
                                controller: _ageController,
                                label: 'Age',
                                icon: Icons.cake_outlined,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                validator: (value) {
                                  final age = int.tryParse(value ?? '');

                                  if (age == null) {
                                    return 'Enter your age.';
                                  }

                                  if (age < 18 || age > 70) {
                                    return 'Use 18–70.';
                                  }

                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AppField(
                                controller: _experienceController,
                                label: 'Experience',
                                icon: Icons.work_history_outlined,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                validator: (value) {
                                  final years = int.tryParse(value ?? '');

                                  if (years == null || years < 0) {
                                    return 'Enter years.';
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _AppDropdown(
                          label: 'Gender',
                          icon: Icons.wc_rounded,
                          value: _gender,
                          items: genders,
                          displayText: (value) {
                            switch (value) {
                              case 'male':
                                return 'Male';
                              case 'female':
                                return 'Female';
                              default:
                                return 'Other';
                            }
                          },
                          onChanged: (value) {
                            setState(() => _gender = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        _AppDropdown(
                          label: 'Religion',
                          icon: Icons.self_improvement_rounded,
                          value: _religion,
                          items: religions,
                          displayText: (value) => value,
                          onChanged: (value) {
                            setState(() => _religion = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        _AppField(
                          controller: _districtController,
                          label: 'District / location',
                          icon: Icons.location_on_outlined,
                          textCapitalization: TextCapitalization.words,
                          validator:
                              (value) => _requiredText(
                                value,
                                'District or location is required.',
                              ),
                        ),
                        const SizedBox(height: 12),
                        _ReadOnlyField(
                          label: widget.phone,
                          icon: Icons.phone_android_rounded,
                        ),
                        const SizedBox(height: 24),
                        const _SectionTitle('Work preference'),
                        const SizedBox(height: 14),
                        _WorkTypeSelector(
                          value: _workType,
                          onChanged: (value) {
                            setState(() => _workType = value);
                          },
                        ),
                        const SizedBox(height: 24),
                        const _SectionTitle('Services you offer'),
                        const SizedBox(height: 8),
                        Text(
                          'Choose one or more services. Homeowners will use these to find you.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_loadingServices)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_servicesError != null)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: _error,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _servicesError!,
                                    style: const TextStyle(
                                      color: _text,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _loadServiceCategories,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _serviceCategories.map((category) {
                                  final id = int.tryParse(
                                    category['id'].toString(),
                                  );
                                  final name =
                                      category['name']?.toString() ?? 'Service';

                                  if (id == null)
                                    return const SizedBox.shrink();

                                  final selected = _selectedServiceIds.contains(
                                    id,
                                  );

                                  return FilterChip(
                                    label: Text(name),
                                    selected: selected,
                                    onSelected: (value) {
                                      setState(() {
                                        if (value) {
                                          _selectedServiceIds.add(id);
                                        } else {
                                          _selectedServiceIds.remove(id);
                                        }
                                      });
                                    },
                                    selectedColor: _primary.withValues(
                                      alpha: 0.16,
                                    ),
                                    checkmarkColor: _primary,
                                    side: BorderSide(
                                      color:
                                          selected
                                              ? _primary
                                              : Colors.grey.shade300,
                                    ),
                                    labelStyle: TextStyle(
                                      color: selected ? _primary : _text,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                }).toList(),
                          ),
                        const SizedBox(height: 24),
                        const _SectionTitle('Identity verification'),
                        const SizedBox(height: 8),
                        Text(
                          'Upload clear photos of the front and back of your National ID. Your NIN number is not collected.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DocumentPicker(
                          title: 'National ID — Front',
                          subtitle:
                              _nationalIdFrontDocument?.name ??
                              'Tap to upload the front of your National ID',
                          bytes: _nationalIdFrontBytes,
                          onTap: _startNationalIdFrontPicker,
                        ),
                        const SizedBox(height: 12),
                        _DocumentPicker(
                          title: 'National ID — Back',
                          subtitle:
                              _nationalIdBackDocument?.name ??
                              'Tap to upload the back of your National ID',
                          bytes: _nationalIdBackBytes,
                          onTap: _startNationalIdBackPicker,
                        ),
                        const SizedBox(height: 24),
                        const _SectionTitle('Work gallery'),
                        const SizedBox(height: 6),
                        Text(
                          'Upload 3 clear photos that show you, your work, or your skills.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: List.generate(3, (index) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index < 2 ? 10 : 0,
                                ),
                                child: _GalleryImagePicker(
                                  index: index + 1,
                                  bytes: _galleryImageBytes[index],
                                  onTap: () => _startGalleryPicker(index),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_galleryImages.where((image) => image != null).length} of 3 photos added',
                          style: TextStyle(
                            color:
                                _galleryImages.every((image) => image != null)
                                    ? _primary
                                    : Colors.grey.shade400,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _SectionTitle('About you'),
                        const SizedBox(height: 12),
                        _AppField(
                          controller: _bioController,
                          label: 'Short bio (optional)',
                          icon: Icons.notes_rounded,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
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
                              disabledBackgroundColor: _primary.withValues(
                                alpha: 0.55,
                              ),
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
                                          'Complete Profile',
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

  Widget _buildHero() {
    return SizedBox(
      height: 225,
      child: Stack(
        children: [
          const Positioned.fill(child: _HeroBackground()),
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Step 2 of 2',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _startProfilePhotoPicker,
                          child: SizedBox(
                            width: 92,
                            height: 92,
                            child: Stack(
                              children: [
                                Container(
                                  width: 92,
                                  height: 92,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.15),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child:
                                        _profilePhotoBytes == null
                                            ? const Icon(
                                              Icons.person_rounded,
                                              color: Colors.white70,
                                              size: 45,
                                            )
                                            : Image.memory(
                                              _profilePhotoBytes!,
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 30,
                                    height: 30,
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
                        ),
                        const SizedBox(width: 17),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Complete Your\nProfile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  height: 1.1,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Build trust and start finding work.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _text,
        fontSize: 15,
        fontWeight: FontWeight.w800,
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
    this.inputFormatters,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      style: const TextStyle(
        color: _text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: _error, width: 1.5),
        ),
      ),
    );
  }
}

class _AppDropdown extends StatelessWidget {
  const _AppDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.displayText,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final String Function(String) displayText;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _subText, fontSize: 13),
        prefixIcon: Icon(icon, color: _subText, size: 20),
        filled: true,
        fillColor: _inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(displayText(item)),
                ),
              )
              .toList(),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
      decoration: BoxDecoration(
        color: _inputFill.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: _subText, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _text,
                fontWeight: FontWeight.w600,
                fontSize: 14,
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
    );
  }
}

class _WorkTypeSelector extends StatelessWidget {
  const _WorkTypeSelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _WorkTypeCard(
            selected: value == 'full_time',
            icon: Icons.access_time_filled_rounded,
            title: 'Full Time',
            subtitle: 'Regular schedule',
            onTap: () => onChanged('full_time'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _WorkTypeCard(
            selected: value == 'part_time',
            icon: Icons.schedule_rounded,
            title: 'Part Time',
            subtitle: 'Flexible hours',
            onTap: () => onChanged('part_time'),
          ),
        ),
      ],
    );
  }
}

class _WorkTypeCard extends StatelessWidget {
  const _WorkTypeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? _primary.withValues(alpha: 0.09) : _inputFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? _primary : _subText),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: _text,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: _subText, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentPicker extends StatelessWidget {
  const _DocumentPicker({
    required this.title,
    required this.subtitle,
    required this.bytes,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Uint8List? bytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _inputFill,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color:
                bytes == null
                    ? Colors.transparent
                    : _primary.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  bytes == null
                      ? const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: _primary,
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(bytes!, fit: BoxFit.cover),
                      ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _text,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _subText, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(
              bytes == null ? Icons.upload_rounded : Icons.check_circle_rounded,
              color: _primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryImagePicker extends StatelessWidget {
  const _GalleryImagePicker({
    required this.index,
    required this.bytes,
    required this.onTap,
  });

  final int index;
  final Uint8List? bytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 112,
        decoration: BoxDecoration(
          color: _inputFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                bytes == null
                    ? Colors.transparent
                    : _primary.withValues(alpha: 0.65),
            width: 1.4,
          ),
        ),
        child:
            bytes == null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: _primary,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Photo $index',
                      style: const TextStyle(
                        color: _subText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
                : Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Image.memory(bytes!, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Container(
                        width: 23,
                        height: 23,
                        decoration: const BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
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
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -45,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primary.withValues(alpha: 0.16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
