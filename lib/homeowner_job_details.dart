import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/homeowner_job_service.dart';
import 'widgets/premium_buttons.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);
const _text = Color(0xFF17324D);
const _muted = Color(0xFF6D8092);
const _background = Color(0xFFF5F8FB);
const _border = Color(0xFFE4ECF2);

class HomeownerJobDetailsScreen extends StatefulWidget {
  const HomeownerJobDetailsScreen({super.key, required this.jobId});

  final int jobId;

  @override
  State<HomeownerJobDetailsScreen> createState() =>
      _HomeownerJobDetailsScreenState();
}

class _HomeownerJobDetailsScreenState extends State<HomeownerJobDetailsScreen> {
  final HomeownerJobService _service = HomeownerJobService();

  Map<String, dynamic>? _job;
  List<Map<String, dynamic>> _categories = [];

  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _district = TextEditingController();
  final _budget = TextEditingController();
  final _otherBenefits = TextEditingController();

  final Set<int> _selectedServices = {};

  String _workArrangement = 'full_time';
  String _contractDuration = 'permanent';
  String _budgetType = 'monthly';
  DateTime? _startDate;
  TimeOfDay? _startTime;

  bool _accommodation = false;
  bool _meals = false;
  bool _transport = false;
  bool _medical = false;
  bool _uniform = false;
  bool _urgent = false;

  static const _workOptions = {
    'full_time': 'Full-time',
    'part_time': 'Part-time',
    'one_time': 'One-time',
    'temporary': 'Temporary',
    'live_in': 'Live-in',
    'weekend': 'Weekend',
  };

  static const _durationOptions = {
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
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _address.dispose();
    _district.dispose();
    _budget.dispose();
    _otherBenefits.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final results = await Future.wait([
      _service.getJob(widget.jobId),
      _service.getServiceCategories(),
    ]);

    if (!mounted) return;

    final jobResult = results[0];
    final categoryResult = results[1];

    if (jobResult['success'] != true) {
      setState(() {
        _error = jobResult['message']?.toString() ?? 'Unable to load job.';
        _loading = false;
      });
      return;
    }

    final job = Map<String, dynamic>.from(jobResult['job'] as Map);

    final rawCategories = categoryResult['service_categories'];

    final categories =
        rawCategories is List
            ? rawCategories
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
            : <Map<String, dynamic>>[];

    _fillForm(job);

    setState(() {
      _job = job;
      _categories = categories;
      _loading = false;
    });
  }

  void _fillForm(Map<String, dynamic> job) {
    _title.text = job['title']?.toString() ?? '';
    _description.text = job['description']?.toString() ?? '';
    _address.text = job['address']?.toString() ?? '';
    _district.text = job['district']?.toString() ?? '';
    _budget.text = job['budget_amount']?.toString() ?? '';
    _otherBenefits.text = job['other_benefits']?.toString() ?? '';

    _workArrangement = _normaliseWorkArrangement(
      job['work_arrangement'] ?? job['duration'],
    );

    _contractDuration = _normaliseContractDuration(job['contract_duration']);

    _budgetType = _normaliseBudgetType(job['budget_type']);

    _accommodation = job['accommodation_provided'] == true;
    _meals = job['meals_provided'] == true;
    _transport = job['transport_allowance'] == true;
    _medical = job['medical_support'] == true;
    _uniform = job['uniform_provided'] == true;
    _urgent = job['is_urgent'] == true;

    _startDate = DateTime.tryParse(job['start_date']?.toString() ?? '');

    final timeText = job['start_time']?.toString() ?? '';

    if (timeText.isNotEmpty) {
      final parts = timeText.split(':');
      if (parts.length >= 2) {
        _startTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    _selectedServices.clear();
    final services = job['service_categories'];

    if (services is List) {
      for (final raw in services) {
        final item = Map<String, dynamic>.from(raw as Map);
        final id = int.tryParse(item['id']?.toString() ?? '');
        if (id != null) _selectedServices.add(id);
      }
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedServices.isEmpty) {
      _show('Select at least one service.', false);
      return;
    }

    if (_startDate == null) {
      _show('Select the start date.', false);
      return;
    }

    final amount = double.tryParse(_budget.text.replaceAll(',', '').trim());

    if (amount == null || amount < 1000) {
      _show('Enter a valid budget.', false);
      return;
    }

    setState(() => _saving = true);

    final result = await _service.updateJob(
      jobId: widget.jobId,
      title: _title.text,
      serviceCategoryIds: _selectedServices.toList(),
      description: _description.text,
      address: _address.text,
      district: _district.text,
      startDate: _dateValue(_startDate!),
      startTime: _startTime == null ? '' : _timeValue(_startTime!),
      workArrangement: _workArrangement,
      contractDuration: _contractDuration,
      budgetType: _budgetType,
      budgetAmount: amount,
      accommodationProvided: _accommodation,
      mealsProvided: _meals,
      transportAllowance: _transport,
      medicalSupport: _medical,
      uniformProvided: _uniform,
      otherBenefits: _otherBenefits.text,
      isUrgent: _urgent,
    );

    if (!mounted) return;

    setState(() => _saving = false);

    _show(
      result['message']?.toString() ?? 'Request completed.',
      result['success'] == true,
    );

    if (result['success'] == true) {
      setState(() {
        _editing = false;
        _job = Map<String, dynamic>.from(result['job'] as Map);
      });
      _fillForm(_job!);
    }
  }

  void _show(String message, bool success) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body:
          _loading
              ? const Center(child: CircularProgressIndicator(color: _primary))
              : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : _editing
              ? Column(
                children: [
                  _EditHeroHeader(
                    onBack: () {
                      setState(() {
                        _editing = false;
                        if (_job != null) _fillForm(_job!);
                      });
                    },
                  ),
                  Expanded(child: _buildEditForm()),
                ],
              )
              : _buildDetails(),
      bottomNavigationBar:
          _editing
              ? SafeArea(
                top: false,
                child: Material(
                  color: theme.colorScheme.surface,
                  elevation: 16,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                    child: PremiumGradientButton(
                      label: _saving ? 'Saving...' : 'Save Changes',
                      icon: Icons.save_rounded,
                      loading: _saving,
                      onPressed: _saving ? null : _save,
                      size: PremiumButtonSize.large,
                    ),
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildDetails() {
    final job = _job!;
    final colors = Theme.of(context).colorScheme;
    final services =
        job['service_categories'] is List
            ? job['service_categories'] as List
            : const [];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _JobHeroHeader(
            job: job,
            onBack: () => Navigator.of(context).pop(true),
            onEdit: () => setState(() => _editing = true),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _JobSummaryCard(job: job),
              const SizedBox(height: 16),
              _PremiumSectionCard(
                icon: Icons.description_outlined,
                title: 'What Work Is Needed',
                child: Text(
                  (job['description']?.toString().trim() ?? '').isEmpty
                      ? 'No description was provided.'
                      : job['description'].toString(),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _PremiumSectionCard(
                icon: Icons.category_outlined,
                title: 'Services Required',
                child:
                    services.isEmpty
                        ? Text(
                          'No services selected.',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        )
                        : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              services.whereType<Map>().map((raw) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    raw['name']?.toString() ?? 'Service',
                                    style: const TextStyle(
                                      color: _primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
              ),
              const SizedBox(height: 16),
              _PremiumSectionCard(
                icon: Icons.info_outline_rounded,
                title: 'When & Where',
                child: Column(
                  children: [
                    _PremiumInfoRow(
                      icon: Icons.location_city_outlined,
                      label: 'District',
                      value: job['district']?.toString() ?? 'Not provided',
                    ),
                    _PremiumInfoRow(
                      icon: Icons.home_outlined,
                      label: 'Address',
                      value: job['address']?.toString() ?? 'Not provided',
                    ),
                    _PremiumInfoRow(
                      icon: Icons.schedule_rounded,
                      label: 'Work Arrangement',
                      value: _label(job['work_arrangement']),
                    ),
                    _PremiumInfoRow(
                      icon: Icons.timelapse_rounded,
                      label: 'Contract Duration',
                      value: _label(job['contract_duration']),
                    ),
                    _PremiumInfoRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Work Starts',
                      value: _prettyDate(job['start_date']),
                    ),
                    _PremiumInfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Start Time',
                      value: _prettyTime(job['start_time']),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _PremiumSectionCard(
                icon: Icons.card_giftcard_outlined,
                title: 'Benefits',
                child: Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    _PremiumBenefit(
                      icon: Icons.bed_outlined,
                      label: 'Accommodation',
                      enabled: job['accommodation_provided'] == true,
                    ),
                    _PremiumBenefit(
                      icon: Icons.restaurant_outlined,
                      label: 'Meals',
                      enabled: job['meals_provided'] == true,
                    ),
                    _PremiumBenefit(
                      icon: Icons.directions_bus_outlined,
                      label: 'Transport',
                      enabled: job['transport_allowance'] == true,
                    ),
                    _PremiumBenefit(
                      icon: Icons.medical_services_outlined,
                      label: 'Medical',
                      enabled: job['medical_support'] == true,
                    ),
                    _PremiumBenefit(
                      icon: Icons.checkroom_outlined,
                      label: 'Uniform',
                      enabled: job['uniform_provided'] == true,
                    ),
                  ],
                ),
              ),
              if ((job['other_benefits']?.toString().trim() ?? '')
                  .isNotEmpty) ...[
                const SizedBox(height: 16),
                _PremiumSectionCard(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Other Benefits',
                  child: Text(
                    job['other_benefits'].toString(),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        children: [
          _EditSection(
            title: 'Basic Information',
            children: [
              _field(controller: _title, label: 'Job title'),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _categories.map((item) {
                      final id = int.tryParse(item['id']?.toString() ?? '');
                      if (id == null) {
                        return const SizedBox.shrink();
                      }

                      final selected = _selectedServices.contains(id);

                      return FilterChip(
                        selected: selected,
                        label: Text(item['name']?.toString() ?? 'Service'),
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedServices.add(id);
                            } else {
                              _selectedServices.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _description,
                label: 'Description',
                minLines: 4,
                maxLines: 7,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _EditSection(
            title: 'Location and Schedule',
            children: [
              _field(controller: _district, label: 'District'),
              const SizedBox(height: 14),
              _field(controller: _address, label: 'Address'),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _workArrangement,
                decoration: _input('Work arrangement'),
                items:
                    _workOptions.entries
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
                decoration: _input('Contract duration'),
                items:
                    _durationOptions.entries
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
          _EditSection(
            title: 'Payment and Benefits',
            children: [
              DropdownButtonFormField<String>(
                value: _budgetType,
                decoration: _input('Payment type'),
                items: const [
                  DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _budgetType = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              _field(
                controller: _budget,
                label: 'Budget amount',
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              _switch(
                'Accommodation provided',
                _accommodation,
                (value) => setState(() => _accommodation = value),
              ),
              _switch(
                'Meals provided',
                _meals,
                (value) => setState(() => _meals = value),
              ),
              _switch(
                'Transport allowance',
                _transport,
                (value) => setState(() => _transport = value),
              ),
              _switch(
                'Medical support',
                _medical,
                (value) => setState(() => _medical = value),
              ),
              _switch(
                'Uniform provided',
                _uniform,
                (value) => setState(() => _uniform = value),
              ),
              _switch(
                'Urgent Help Needed',
                _urgent,
                (value) => setState(() => _urgent = value),
              ),
              _field(
                controller: _otherBenefits,
                label: 'Other benefits',
                minLines: 3,
                maxLines: 5,
                required: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    int minLines = 1,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator:
          required
              ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required.';
                }
                return null;
              }
              : null,
      decoration: _input(label),
    );
  }

  Widget _switch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      activeColor: _primary,
      onChanged: onChanged,
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.24 : 0.09,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class _EditSection extends StatelessWidget {
  const _EditSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.24 : 0.09,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

InputDecoration _input(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: _background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _border),
    ),
  );
}

Widget _row(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 135,
          child: Text(
            label,
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value?.toString() ?? 'Not provided',
            style: const TextStyle(color: _text, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

Widget _benefit(String label, bool enabled) {
  return Chip(
    avatar: Icon(
      enabled ? Icons.check_circle_rounded : Icons.cancel_outlined,
      color: enabled ? Colors.green : Colors.grey,
      size: 17,
    ),
    label: Text(label),
  );
}

String _label(dynamic value) {
  final text = value?.toString() ?? '';
  return text
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (part) =>
            part.isEmpty
                ? part
                : '${part[0].toUpperCase()}'
                    '${part.substring(1)}',
      )
      .join(' ');
}

String _money(dynamic value) {
  final amount = double.tryParse(value?.toString() ?? '') ?? 0;

  return amount.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}

String _postedDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();

  if (date == null) return 'recently';

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

  return '${date.day} ${months[date.month - 1]} '
      '${date.year}';
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

class _JobHeroHeader extends StatelessWidget {
  const _JobHeroHeader({
    required this.job,
    required this.onBack,
    required this.onEdit,
  });

  final Map<String, dynamic> job;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final status = job['status']?.toString() ?? 'open';

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_navy, Color(0xFF177989), _primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -42,
              right: -34,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  MediaQuery.paddingOf(context).top + 10,
                  18,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CircleHeaderButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: onBack,
                        ),
                        const Spacer(),
                        _CircleHeaderButton(
                          icon: Icons.edit_outlined,
                          onTap: onEdit,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.17),
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: const Icon(
                            Icons.work_history_outlined,
                            color: Colors.white,
                            size: 29,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job['title']?.toString() ?? 'Your Job',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  height: 1.12,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _HeroStatusChip(status: status),
                                  if (job['is_urgent'] == true)
                                    const _HeroSmallPill(
                                      icon: Icons.priority_high_rounded,
                                      label: 'Urgent',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Posted ${_postedDate(job['created_at'])}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.5,
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
          ],
        ),
      ),
    );
  }
}

class _EditHeroHeader extends StatelessWidget {
  const _EditHeroHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, Color(0xFF177989), _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            10,
            MediaQuery.paddingOf(context).top + 8,
            18,
            22,
          ),
          child: Row(
            children: [
              _CircleHeaderButton(icon: Icons.close_rounded, onTap: onBack),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Job Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Change the information workers see about this job.',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_note_rounded,
                color: Colors.white,
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleHeaderButton extends StatelessWidget {
  const _CircleHeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _JobSummaryCard extends StatelessWidget {
  const _JobSummaryCard({required this.job});

  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.28 : 0.12,
            ),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: job['district']?.toString() ?? 'Not provided',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.payments_outlined,
                  label: 'Budget',
                  value: 'UGX ${_money(job['budget_amount'])}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.schedule_rounded,
                  label: 'Work Type',
                  value: _label(job['work_arrangement']),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'Work Starts',
                  value: _prettyDate(job['start_date']),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primary, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10.5),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumSectionCard extends StatelessWidget {
  const _PremiumSectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: _primary, size: 21),
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
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}

class _PremiumInfoRow extends StatelessWidget {
  const _PremiumInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: _primary, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _PremiumBenefit extends StatelessWidget {
  const _PremiumBenefit({
    required this.icon,
    required this.label,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? const Color(0xFF16A957) : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check_circle_rounded : icon,
            color: color,
            size: 17,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatusChip extends StatelessWidget {
  const _HeroStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return _HeroSmallPill(
      icon:
          status == 'open'
              ? Icons.check_circle_outline_rounded
              : Icons.info_outline_rounded,
      label: _label(status),
    );
  }
}

class _HeroSmallPill extends StatelessWidget {
  const _HeroSmallPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: colors.primary, size: 58),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

String _normaliseToken(dynamic value) {
  return value
          ?.toString()
          .trim()
          .toLowerCase()
          .replaceAll('-', '_')
          .replaceAll(RegExp(r'\s+'), '_') ??
      '';
}

String _normaliseWorkArrangement(dynamic value) {
  final token = _normaliseToken(value);

  const aliases = <String, String>{
    'fulltime': 'full_time',
    'full_time': 'full_time',
    'parttime': 'part_time',
    'part_time': 'part_time',
    'onetime': 'one_time',
    'one_time': 'one_time',
    'temporary': 'temporary',
    'livein': 'live_in',
    'live_in': 'live_in',
    'weekend': 'weekend',
  };

  final normalised = aliases[token] ?? token;

  return _HomeownerJobDetailsScreenState._workOptions.containsKey(normalised)
      ? normalised
      : 'full_time';
}

String _normaliseContractDuration(dynamic value) {
  final token = _normaliseToken(value);

  const aliases = <String, String>{
    '1_day': 'one_day',
    'one_day': 'one_day',
    '1_week': 'one_week',
    'one_week': 'one_week',
    '1_month': 'one_month',
    'one_month': 'one_month',
    '3_months': 'three_months',
    'three_months': 'three_months',
    '6_months': 'six_months',
    'six_months': 'six_months',
    '1_year': 'one_year',
    'one_year': 'one_year',
    'permanent': 'permanent',
  };

  final normalised = aliases[token] ?? token;

  return _HomeownerJobDetailsScreenState._durationOptions.containsKey(
        normalised,
      )
      ? normalised
      : 'permanent';
}

String _normaliseBudgetType(dynamic value) {
  final token = _normaliseToken(value);

  return const {'fixed', 'daily', 'monthly'}.contains(token)
      ? token
      : 'monthly';
}

String _prettyDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return 'Not specified';

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

String _prettyTime(dynamic value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return 'Not specified';

  final parts = raw.split(':');
  if (parts.length < 2) return raw;

  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

  return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
}
