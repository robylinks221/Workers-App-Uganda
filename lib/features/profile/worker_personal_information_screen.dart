import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../services/worker_profile_service.dart';
import '../../services/worker_service_management_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class WorkerPersonalInformationScreen extends StatefulWidget {
  const WorkerPersonalInformationScreen({
    super.key,
    required this.user,
    required this.profile,
  });

  final Map<String, dynamic> user;
  final Map<String, dynamic> profile;

  @override
  State<WorkerPersonalInformationScreen> createState() =>
      _WorkerPersonalInformationScreenState();
}

class _WorkerPersonalInformationScreenState
    extends State<WorkerPersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = WorkerProfileService();
  final _serviceManagement = WorkerServiceManagementService();
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _districtController;
  late final TextEditingController _bioController;
  late final TextEditingController _experienceController;
  late final TextEditingController _hourlyRateController;
  late final TextEditingController _monthlyRateController;

  late String _religion;
  late String _gender;
  late String _workType;
  late String _availability;

  XFile? _profilePhoto;
  Uint8List? _profilePhotoBytes;
  XFile? _nationalIdFrontDocument;
  Uint8List? _nationalIdFrontBytes;
  XFile? _nationalIdBackDocument;
  Uint8List? _nationalIdBackBytes;

  final List<XFile?> _galleryImages = List<XFile?>.filled(3, null);
  final List<Uint8List?> _galleryBytes = List<Uint8List?>.filled(3, null);
  late final List<String> _existingGalleryUrls;

  bool _saving = false;

  List<Map<String, dynamic>> _serviceCategories = <Map<String, dynamic>>[];
  Set<int> _selectedServiceIds = <int>{};
  Set<String> _selectedLanguages = <String>{};
  bool _loadingServices = true;
  String? _servicesError;

  static const _religions = [
    'Christian',
    'Muslim',
    'Catholic',
    'Seventh-Day Adventist',
    'Other / Prefer not to say',
  ];

  static const _genders = ['male', 'female', 'other'];
  static const _workTypes = ['full_time', 'part_time'];
  static const _availabilityOptions = ['available', 'busy', 'unavailable'];

  static const _languageOptions = [
    'English',
    'Luganda',
    'Swahili',
    'Runyankole',
    'Rukiga',
    'Lusoga',
    'Runyoro',
    'Rutooro',
    'Acholi',
    'Lango',
    'Ateso',
    'Lugisu',
    'Lumasaba',
    'Lugbara',
    'Alur',
    'Karamojong',
    'French',
    'Arabic',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.user['full_name']?.toString() ?? '',
    );
    _ageController = TextEditingController(
      text: widget.profile['age']?.toString() ?? '',
    );
    _districtController = TextEditingController(
      text: widget.profile['district']?.toString() ?? '',
    );
    _bioController = TextEditingController(
      text: widget.profile['bio']?.toString() ?? '',
    );
    _experienceController = TextEditingController(
      text: widget.profile['experience_years']?.toString() ?? '0',
    );
    _hourlyRateController = TextEditingController(
      text: widget.profile['hourly_rate']?.toString() ?? '',
    );
    _monthlyRateController = TextEditingController(
      text:
          widget.profile['monthly_rate']?.toString() ??
          widget.profile['expected_salary']?.toString() ??
          '',
    );

    _religion = _safeValue(
      widget.profile['religion'],
      _religions,
      _religions.first,
    );
    _gender = _safeValue(widget.profile['gender'], _genders, _genders.first);
    _workType = _safeValue(
      widget.profile['work_type'],
      _workTypes,
      _workTypes.first,
    );
    _availability = _safeValue(
      widget.profile['availability'],
      _availabilityOptions,
      _availabilityOptions.first,
    );

    _existingGalleryUrls = _galleryUrls(widget.profile['gallery_images']);

    final rawLanguages = widget.profile['languages'];

    if (rawLanguages is List) {
      _selectedLanguages =
          rawLanguages
              .map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toSet();
    }

    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _loadingServices = true;
      _servicesError = null;
    });

    final results = await Future.wait([
      _serviceManagement.getCategories(),
      _serviceManagement.getSelectedServices(),
    ]);

    if (!mounted) return;

    final categoriesResult = results[0];
    final selectedResult = results[1];

    if (categoriesResult['success'] != true ||
        selectedResult['success'] != true) {
      setState(() {
        _servicesError =
            categoriesResult['message']?.toString() ??
            selectedResult['message']?.toString() ??
            'Unable to load your services.';
        _loadingServices = false;
      });
      return;
    }

    final categories = <Map<String, dynamic>>[];
    final rawCategories = categoriesResult['service_categories'];

    if (rawCategories is List) {
      for (final item in rawCategories) {
        if (item is Map) {
          categories.add(Map<String, dynamic>.from(item));
        }
      }
    }

    final selectedIds = <int>{};
    final rawSelected = selectedResult['selected_service_ids'];

    if (rawSelected is List) {
      for (final item in rawSelected) {
        final id = int.tryParse(item.toString());
        if (id != null) {
          selectedIds.add(id);
        }
      }
    }

    setState(() {
      _serviceCategories = categories;
      _selectedServiceIds = selectedIds;
      _loadingServices = false;
      _servicesError = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _districtController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    _monthlyRateController.dispose();
    super.dispose();
  }

  Future<ImageSource?> _chooseImageSource(String title) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SourceButton(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          onTap:
                              () => Navigator.pop(
                                sheetContext,
                                ImageSource.camera,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SourceButton(
                          icon: Icons.photo_library_rounded,
                          label: 'Gallery',
                          onTap:
                              () => Navigator.pop(
                                sheetContext,
                                ImageSource.gallery,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _pickProfilePhoto() async {
    final source = await _chooseImageSource('Replace profile photo');
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

  Future<void> _pickNationalIdFront() async {
    final source = await _chooseImageSource('Replace National ID photo');
    if (source == null) return;

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 2000,
    );
    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() {
      _nationalIdFrontDocument = file;
      _nationalIdFrontBytes = bytes;
    });
  }

  Future<void> _pickNationalIdBack() async {
    final source = await _chooseImageSource(
      'Replace back of National ID photo',
    );
    if (source == null) return;

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 2000,
    );
    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() {
      _nationalIdBackDocument = file;
      _nationalIdBackBytes = bytes;
    });
  }

  Future<void> _pickGalleryImage(int index) async {
    final source = await _chooseImageSource(
      'Replace gallery photo ${index + 1}',
    );
    if (source == null) return;

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 84,
      maxWidth: 1800,
    );
    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() {
      _galleryImages[index] = file;
      _galleryBytes[index] = bytes;
    });
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_loadingServices) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while your services load.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one service you offer.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final result = await _service.saveProfile(
      fullName: _nameController.text,
      age: int.parse(_ageController.text),
      religion: _religion,
      gender: _gender,
      district: _districtController.text,
      workType: _workType,
      availability: _availability,
      serviceIds: (_selectedServiceIds.toList()..sort()),
      languages: (_selectedLanguages.toList()..sort()),
      bio: _bioController.text,
      experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
      hourlyRate: double.tryParse(
        _hourlyRateController.text.replaceAll(',', '').trim(),
      ),
      monthlyRate: double.tryParse(
        _monthlyRateController.text.replaceAll(',', '').trim(),
      ),
      profilePhoto: _profilePhoto,
      nationalIdFrontDocument: _nationalIdFrontDocument,
      nationalIdBackDocument: _nationalIdBackDocument,
      galleryImage1: _galleryImages[0],
      galleryImage2: _galleryImages[1],
      galleryImage3: _galleryImages[2],
    );

    if (!mounted) return;
    setState(() => _saving = false);

    final success = result['success'] == true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ??
              (success
                  ? 'Profile updated successfully.'
                  : 'Unable to update profile.'),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? _navy : Colors.red.shade700,
      ),
    );

    if (success) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentProfilePhoto = ApiConfig.storageUrl(
      widget.user['profile_photo']?.toString() ??
          widget.profile['profile_photo']?.toString(),
    );

    final currentIdFrontPhoto = ApiConfig.storageUrl(
      widget.profile['national_id_front_document']?.toString() ??
          widget.profile['national_id_document']?.toString() ??
          widget.profile['national_id_photo']?.toString(),
    );

    final currentIdBackPhoto = ApiConfig.storageUrl(
      widget.profile['national_id_back_document']?.toString(),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _EditHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 125),
                  children: [
                    const _ProfileEditGuide(),
                    const SizedBox(height: 16),
                    _PremiumCard(
                      title: 'Your Profile Photo',
                      icon: Icons.photo_camera_outlined,
                      child: Center(
                        child: GestureDetector(
                          onTap: _pickProfilePhoto,
                          child: Stack(
                            children: [
                              _ProfilePhoto(
                                bytes: _profilePhotoBytes,
                                url: currentProfilePhoto,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: _EditBadge(
                                  icon: Icons.camera_alt_rounded,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PremiumCard(
                      title: 'About You',
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
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              prefixIcon: Icon(Icons.cake_outlined),
                            ),
                            validator: (value) {
                              final age = int.tryParse(value ?? '');
                              if (age == null || age < 18 || age > 70) {
                                return 'Enter an age from 18 to 70.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              prefixIcon: Icon(Icons.wc_rounded),
                            ),
                            items:
                                _genders
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(_label(item)),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _gender = value);
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: _religion,
                            decoration: const InputDecoration(
                              labelText: 'Religion',
                              prefixIcon: Icon(Icons.self_improvement_rounded),
                            ),
                            items:
                                _religions
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(item),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _religion = value);
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _districtController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'District / Location',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            validator:
                                (value) =>
                                    (value ?? '').trim().isEmpty
                                        ? 'Enter your district.'
                                        : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PremiumCard(
                      title: 'Work You Can Do',
                      icon: Icons.cleaning_services_outlined,
                      child:
                          _loadingServices
                              ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: _primary,
                                  ),
                                ),
                              )
                              : _servicesError != null
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _servicesError!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  OutlinedButton.icon(
                                    onPressed: _loadServices,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Try Again'),
                                  ),
                                ],
                              )
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select all the services you can provide. You can change these whenever you edit your profile.',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                      fontSize: 12.5,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 9,
                                    runSpacing: 9,
                                    children:
                                        _serviceCategories.map((category) {
                                          final id =
                                              int.tryParse(
                                                category['id']?.toString() ??
                                                    '',
                                              ) ??
                                              0;
                                          final selected = _selectedServiceIds
                                              .contains(id);

                                          return FilterChip(
                                            selected: selected,
                                            label: Text(
                                              category['name']?.toString() ??
                                                  'Service',
                                            ),
                                            avatar: Icon(
                                              selected
                                                  ? Icons.check_rounded
                                                  : Icons
                                                      .cleaning_services_outlined,
                                              size: 17,
                                              color:
                                                  selected
                                                      ? Colors.white
                                                      : _primary,
                                            ),
                                            selectedColor: _primary,
                                            checkmarkColor: Colors.white,
                                            labelStyle: TextStyle(
                                              color:
                                                  selected
                                                      ? Colors.white
                                                      : Theme.of(
                                                        context,
                                                      ).colorScheme.onSurface,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            side: BorderSide(
                                              color:
                                                  selected
                                                      ? _primary
                                                      : Theme.of(
                                                        context,
                                                      ).dividerColor,
                                            ),
                                            onSelected: (_) {
                                              setState(() {
                                                if (selected) {
                                                  _selectedServiceIds.remove(
                                                    id,
                                                  );
                                                } else {
                                                  _selectedServiceIds.add(id);
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${_selectedServiceIds.length} service${_selectedServiceIds.length == 1 ? '' : 's'} selected',
                                    style: const TextStyle(
                                      color: _primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                    const SizedBox(height: 16),
                    _PremiumCard(
                      title: 'Languages You Speak',
                      icon: Icons.translate_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose all the languages you can speak well enough to use with a homeowner.',
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _languageOptions.map((language) {
                                  final selected = _selectedLanguages.contains(
                                    language,
                                  );

                                  return FilterChip(
                                    selected: selected,
                                    label: Text(language),
                                    selectedColor: _primary,
                                    checkmarkColor: Colors.white,
                                    side: BorderSide.none,
                                    labelStyle: TextStyle(
                                      color:
                                          selected
                                              ? Colors.white
                                              : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    onSelected: (_) {
                                      setState(() {
                                        if (selected) {
                                          _selectedLanguages.remove(language);
                                        } else {
                                          _selectedLanguages.add(language);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PremiumCard(
                      title: 'Your Work Details',
                      icon: Icons.work_outline_rounded,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _workType,
                            decoration: const InputDecoration(
                              labelText: 'How Do You Want to Work?',
                              prefixIcon: Icon(Icons.schedule_rounded),
                            ),
                            items:
                                _workTypes
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(_label(item)),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _workType = value);
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: _availability,
                            decoration: const InputDecoration(
                              labelText: 'Can You Work Now?',
                              prefixIcon: Icon(Icons.event_available_outlined),
                            ),
                            items:
                                _availabilityOptions
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(_label(item)),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _availability = value);
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _experienceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Years of Experience',
                              prefixIcon: Icon(Icons.work_history_outlined),
                            ),
                            validator: (value) {
                              final years = int.tryParse(value ?? '');
                              return years == null || years < 0
                                  ? 'Enter valid experience.'
                                  : null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _hourlyRateController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Hourly Rate (UGX)',
                              prefixIcon: Icon(Icons.payments_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _monthlyRateController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Monthly Rate (UGX)',
                              prefixIcon: Icon(
                                Icons.account_balance_wallet_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _bioController,
                            minLines: 4,
                            maxLines: 6,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'About You',
                              alignLabelWithHint: true,
                              prefixIcon: Icon(Icons.notes_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PremiumCard(
                      title: 'Identity Verification',
                      icon: Icons.verified_user_outlined,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'National ID — Front',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Upload the front of your National ID. Your NIN number is not collected.',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ReplaceableDocument(
                            bytes: _nationalIdFrontBytes,
                            existingUrl: currentIdFrontPhoto,
                            onTap: _pickNationalIdFront,
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'National ID — Back',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Upload the back of your National ID.',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ReplaceableDocument(
                            bytes: _nationalIdBackBytes,
                            existingUrl: currentIdBackPhoto,
                            onTap: _pickNationalIdBack,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PremiumCard(
                      title: 'Work Gallery',
                      icon: Icons.photo_library_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tap any photo to replace it. Existing photos remain unchanged when you do not select replacements.',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: List.generate(3, (index) {
                              final existingUrl =
                                  index < _existingGalleryUrls.length
                                      ? _existingGalleryUrls[index]
                                      : '';

                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: index < 2 ? 10 : 0,
                                  ),
                                  child: _GalleryTile(
                                    index: index,
                                    bytes: _galleryBytes[index],
                                    existingUrl: existingUrl,
                                    onTap: () => _pickGalleryImage(index),
                                  ),
                                ),
                              );
                            }),
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
      bottomNavigationBar: _SaveBar(saving: _saving, onPressed: _save),
    );
  }
}

class _EditHeader extends StatelessWidget {
  const _EditHeader();

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
            blurRadius: 24,
            offset: const Offset(0, 10),
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
            child: const Icon(
              Icons.manage_accounts_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Full Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Update your details, verification and work gallery.',
                  style: TextStyle(
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

class _ProfileEditGuide extends StatelessWidget {
  const _ProfileEditGuide();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(21),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UPDATE YOUR PROFILE',
            style: TextStyle(
              color: _primary,
              fontSize: 9.5,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Keep your information correct',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 5),
          Text(
            'Homeowners use this information to decide whether to contact or hire you. Check each section before saving.',
            style: TextStyle(fontSize: 11.5, height: 1.45),
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
    this.subtitle,
    required this.child,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
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

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.bytes, required this.url});

  final Uint8List? bytes;
  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 55,
        backgroundColor: colors.surfaceContainerHighest,
        backgroundImage:
            bytes != null
                ? MemoryImage(bytes!)
                : url.isNotEmpty
                ? NetworkImage(url)
                : null,
        child:
            bytes == null && url.isEmpty
                ? const Icon(Icons.person_rounded, color: _primary, size: 50)
                : null,
      ),
    );
  }
}

class _EditBadge extends StatelessWidget {
  const _EditBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: _primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, color: Colors.white, size: 17),
    );
  }
}

class _ReplaceableDocument extends StatelessWidget {
  const _ReplaceableDocument({
    required this.bytes,
    required this.existingUrl,
    required this.onTap,
  });

  final Uint8List? bytes;
  final String existingUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasImage = bytes != null || existingUrl.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (bytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(bytes!, fit: BoxFit.cover),
              )
            else if (existingUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  existingUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _DocumentFallback(),
                ),
              )
            else
              const _DocumentFallback(),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _navy.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      hasImage ? 'Replace ID' : 'Upload ID',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentFallback extends StatelessWidget {
  const _DocumentFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.badge_outlined, color: _primary, size: 38),
          SizedBox(height: 7),
          Text(
            'Tap to upload National ID photo',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.index,
    required this.bytes,
    required this.existingUrl,
    required this.onTap,
  });

  final int index;
  final Uint8List? bytes;
  final String existingUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (bytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.memory(bytes!, fit: BoxFit.cover),
              )
            else if (existingUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  existingUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _GalleryFallback(index: index),
                ),
              )
            else
              _GalleryFallback(index: index),
            Positioned(
              right: 7,
              bottom: 7,
              child: Container(
                width: 27,
                height: 27,
                decoration: const BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
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

class _GalleryFallback extends StatelessWidget {
  const _GalleryFallback({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            color: _primary,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            'Photo ${index + 1}',
            style: const TextStyle(
              color: _primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _primary.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: _primary, size: 29),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(
                color: _primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.saving, required this.onPressed});

  final bool saving;
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
              label: Text(saving ? 'Saving Changes...' : 'Save My Profile'),
            ),
          ),
        ),
      ),
    );
  }
}

String _safeValue(dynamic raw, List<String> valid, String fallback) {
  final value = raw?.toString() ?? '';
  return valid.contains(value) ? value : fallback;
}

String _label(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) =>
            word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

List<String> _galleryUrls(dynamic value) {
  if (value is! List) return const [];

  final items = <(int, String)>[];

  for (final raw in value) {
    if (raw is! Map) continue;
    final item = Map<String, dynamic>.from(raw);

    final path =
        item['image_path']?.toString() ??
        item['path']?.toString() ??
        item['image']?.toString() ??
        '';

    final url = ApiConfig.storageUrl(path);
    if (url.isEmpty) continue;

    final position =
        int.tryParse(item['position']?.toString() ?? '') ?? items.length;

    items.add((position, url));
  }

  items.sort((a, b) => a.$1.compareTo(b.$1));
  return items.map((item) => item.$2).toList();
}
