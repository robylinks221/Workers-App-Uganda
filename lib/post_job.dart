import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/homeowner_job_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final HomeownerJobService _service = HomeownerJobService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _budgetController = TextEditingController();
  final _otherBenefitsController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  final Set<int> _selectedCategoryIds = {};

  String _workArrangement = 'full_time';
  String _contractDuration = 'permanent';
  String _budgetType = 'monthly';
  DateTime? _startDate;
  TimeOfDay? _startTime;

  bool _accommodationProvided = false;
  bool _mealsProvided = false;
  bool _transportAllowance = false;
  bool _medicalSupport = false;
  bool _uniformProvided = false;
  bool _isUrgent = false;

  bool _loadingCategories = true;
  bool _submitting = false;
  String? _categoryError;

  static const _workArrangements = {
    'full_time': 'Full-time',
    'part_time': 'Part-time',
    'one_time': 'One-time',
    'temporary': 'Temporary',
    'live_in': 'Live-in',
    'weekend': 'Weekend',
  };

  static const _contractDurations = {
    'one_day': '1 day',
    'one_week': '1 week',
    'one_month': '1 month',
    'three_months': '3 months',
    'six_months': '6 months',
    'one_year': '1 year',
    'permanent': 'Permanent',
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _budgetController.dispose();
    _otherBenefitsController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final result = await _service.getServiceCategories();
    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _categoryError =
            result['message']?.toString() ?? 'Unable to load services.';
        _loadingCategories = false;
      });
      return;
    }

    final raw = result['service_categories'];
    setState(() {
      _categories =
          raw is List
              ? raw
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList()
              : <Map<String, dynamic>>[];
      _loadingCategories = false;
      _categoryError = null;
    });
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate ?? today,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 3),
    );

    if (selected != null && mounted) {
      setState(() => _startDate = selected);
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (selected != null && mounted) {
      setState(() => _startTime = selected);
    }
  }

  Future<void> _publish() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedCategoryIds.isEmpty) {
      _showMessage('Select at least one required service.', false);
      return;
    }

    if (_startDate == null) {
      _showMessage('Please select the job start date.', false);
      return;
    }

    final budget = double.tryParse(
      _budgetController.text.replaceAll(',', '').trim(),
    );

    if (budget == null || budget < 1000) {
      _showMessage('Enter a valid budget of at least UGX 1,000.', false);
      return;
    }

    if (_submitting) return;
    setState(() => _submitting = true);

    final result = await _service.createJob(
      title: _titleController.text,
      serviceCategoryIds: _selectedCategoryIds.toList(),
      description: _descriptionController.text,
      address: _addressController.text,
      district: _districtController.text,
      startDate: _dateValue(_startDate!),
      startTime: _startTime == null ? '' : _timeValue(_startTime!),
      workArrangement: _workArrangement,
      contractDuration: _contractDuration,
      budgetType: _budgetType,
      budgetAmount: budget,
      accommodationProvided: _accommodationProvided,
      mealsProvided: _mealsProvided,
      transportAllowance: _transportAllowance,
      medicalSupport: _medicalSupport,
      uniformProvided: _uniformProvided,
      otherBenefits: _otherBenefitsController.text,
      isUrgent: _isUrgent,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result['success'] == true) {
      await _showJobPosted();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    _showMessage(
      result['message']?.toString() ?? 'Unable to post the job.',
      false,
    );
  }

  void _showMessage(String message, bool success) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? _navy : Colors.red.shade700,
        ),
      );
  }

  Future<void> _showJobPosted() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _primary, size: 36),
          ),
          title: const Text(
            'Job Posted',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Workers can now see your job and apply. We will tell you when someone applies.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(backgroundColor: _primary),
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _PostJobHeader(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  children: [
                    const _ProgressBanner(),
                    const SizedBox(height: 16),
                    _PremiumFormSection(
                      number: 1,
                      title: 'What Help Do You Need?',
                      icon: Icons.description_outlined,
                      children: [
                        _Field(
                          controller: _titleController,
                          label: 'Give This Job a Name',
                          hint: 'Example: House Cleaning in Kampala',
                          validator: _required,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'What work should the worker do?',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildServices(),
                        const SizedBox(height: 15),
                        _Field(
                          controller: _descriptionController,
                          label: 'Tell the Worker What to Do',
                          hint:
                              'Write simple instructions about the work you need.',
                          minLines: 4,
                          maxLines: 8,
                          validator: _required,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _PremiumFormSection(
                      number: 2,
                      title: 'How Will the Worker Work?',
                      icon: Icons.work_outline_rounded,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _workArrangement,
                          decoration: const InputDecoration(
                            labelText: 'Type of Work',
                            prefixIcon: Icon(Icons.schedule_rounded),
                          ),
                          items:
                              _workArrangements.entries
                                  .map(
                                    (entry) => DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _workArrangement = value);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: _contractDuration,
                          decoration: const InputDecoration(
                            labelText: 'How Long Do You Need Help?',
                            prefixIcon: Icon(Icons.timelapse_rounded),
                          ),
                          items:
                              _contractDurations.entries
                                  .map(
                                    (entry) => DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _contractDuration = value);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _PremiumFormSection(
                      number: 3,
                      title: 'Where & When?',
                      icon: Icons.location_on_outlined,
                      children: [
                        _Field(
                          controller: _districtController,
                          label: 'District',
                          hint: 'Example: Kampala',
                          validator: _required,
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          controller: _addressController,
                          label: 'Where is the work?',
                          hint: 'Village, street, area or nearby landmark',
                          validator: _required,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _PickerButton(
                                label: 'Work Start Date',
                                value:
                                    _startDate == null
                                        ? 'Select date'
                                        : _displayDate(_startDate!),
                                icon: Icons.calendar_today_outlined,
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PickerButton(
                                label: 'What Time?',
                                value:
                                    _startTime == null
                                        ? 'Optional'
                                        : _startTime!.format(context),
                                icon: Icons.schedule_outlined,
                                onTap: _pickTime,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _PremiumFormSection(
                      number: 4,
                      title: 'How Much Will You Pay?',
                      icon: Icons.payments_outlined,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _budgetType,
                          decoration: const InputDecoration(
                            labelText: 'Payment type',
                            prefixIcon: Icon(
                              Icons.account_balance_wallet_outlined,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'fixed',
                              child: Text('Fixed amount'),
                            ),
                            DropdownMenuItem(
                              value: 'daily',
                              child: Text('Daily rate'),
                            ),
                            DropdownMenuItem(
                              value: 'monthly',
                              child: Text('Monthly salary'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _budgetType = value);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          controller: _budgetController,
                          label: 'Amount (UGX)',
                          hint: 'Example: 350000',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            final amount = double.tryParse(value?.trim() ?? '');
                            if (amount == null || amount < 1000) {
                              return 'Enter at least UGX 1,000.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _PremiumFormSection(
                      number: 5,
                      title: 'Benefits & Visibility',
                      icon: Icons.volunteer_activism_outlined,
                      children: [
                        _BenefitSwitch(
                          title: 'Accommodation provided',
                          value: _accommodationProvided,
                          onChanged: (value) {
                            setState(() => _accommodationProvided = value);
                          },
                        ),
                        _BenefitSwitch(
                          title: 'Meals provided',
                          value: _mealsProvided,
                          onChanged: (value) {
                            setState(() => _mealsProvided = value);
                          },
                        ),
                        _BenefitSwitch(
                          title: 'Transport allowance',
                          value: _transportAllowance,
                          onChanged: (value) {
                            setState(() => _transportAllowance = value);
                          },
                        ),
                        _BenefitSwitch(
                          title: 'Medical support',
                          value: _medicalSupport,
                          onChanged: (value) {
                            setState(() => _medicalSupport = value);
                          },
                        ),
                        _BenefitSwitch(
                          title: 'Uniform provided',
                          value: _uniformProvided,
                          onChanged: (value) {
                            setState(() => _uniformProvided = value);
                          },
                        ),
                        _BenefitSwitch(
                          title: 'Mark as urgent',
                          value: _isUrgent,
                          onChanged: (value) {
                            setState(() => _isUrgent = value);
                          },
                        ),
                        const SizedBox(height: 10),
                        _Field(
                          controller: _otherBenefitsController,
                          label: 'Other benefits or conditions',
                          hint:
                              'Example: One rest day weekly and lunch provided.',
                          minLines: 3,
                          maxLines: 6,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Material(
        color: theme.colorScheme.surface,
        elevation: 16,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 13),
            child: SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _publish,
                style: FilledButton.styleFrom(backgroundColor: _primary),
                icon:
                    _submitting
                        ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.add_task_rounded),
                label: Text(_submitting ? 'Publishing...' : 'Post This Job'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServices() {
    if (_loadingCategories) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }

    if (_categoryError != null) {
      return Text(_categoryError!);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          _categories.map((category) {
            final id = int.tryParse(category['id']?.toString() ?? '');
            if (id == null) return const SizedBox.shrink();

            final selected = _selectedCategoryIds.contains(id);

            return FilterChip(
              selected: selected,
              selectedColor: _primary.withValues(alpha: 0.14),
              checkmarkColor: _primary,
              label: Text(category['name']?.toString() ?? 'Service'),
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _selectedCategoryIds.add(id);
                  } else {
                    _selectedCategoryIds.remove(id);
                  }
                });
              },
            );
          }).toList(),
    );
  }
}

class _PostJobHeader extends StatelessWidget {
  const _PostJobHeader({required this.onBack});

  final VoidCallback onBack;

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
            onPressed: onBack,
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
              Icons.add_task_rounded,
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
                  'Post a Job',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tell workers what help you need at home.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: _primary),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Simple and clear information helps workers understand the job before they apply.',
              style: TextStyle(
                color: _primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFormSection extends StatelessWidget {
  const _PremiumFormSection({
    required this.number,
    required this.title,
    required this.icon,
    required this.children,
  });

  final int number;
  final String title;
  final IconData icon;
  final List<Widget> children;

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
                child: Center(
                  child: Text(
                    number.toString(),
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, color: _primary),
              const SizedBox(width: 8),
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
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 86),
          padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.70),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 10.5,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Icon(icon, color: _primary, size: 19),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitSwitch extends StatelessWidget {
  const _BenefitSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: value,
      activeColor: _primary,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      onChanged: onChanged,
    );
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required.';
  }
  return null;
}

String _dateValue(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _timeValue(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _displayDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
