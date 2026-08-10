import 'package:flutter/material.dart';

import '../../services/hiring_service.dart';
import '../../services/work_wanted_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF17324D);

class DirectHireOfferScreen extends StatefulWidget {
  const DirectHireOfferScreen({
    super.key,
    required this.workerId,
    required this.workerName,
  });

  final int workerId;
  final String workerName;

  @override
  State<DirectHireOfferScreen> createState() => _DirectHireOfferScreenState();
}

class _DirectHireOfferScreenState extends State<DirectHireOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hiring = HiringService();
  final _workWanted = WorkWantedService();

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _district = TextEditingController();
  final _duration = TextEditingController(text: 'Ongoing');
  final _amount = TextEditingController();
  final _message = TextEditingController();

  List<Map<String, dynamic>> _categories = const [];
  final Set<int> _selectedServices = <int>{};
  DateTime? _startDate;
  String _budgetType = 'monthly';
  String _workArrangement = 'full_time';
  bool _loadingCategories = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _message.text =
        'Hello ${widget.workerName}, I would like to offer you this job.';
    _loadCategories();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _address.dispose();
    _district.dispose();
    _duration.dispose();
    _amount.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final result = await _workWanted.categories();
    if (!mounted) return;
    final raw = result['service_categories'];
    final items = <Map<String, dynamic>>[];
    if (raw is List) {
      for (final value in raw) {
        if (value is Map) items.add(Map<String, dynamic>.from(value));
      }
    }
    setState(() {
      _categories = items;
      _loadingCategories = false;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      initialDate: _startDate ?? now,
    );
    if (value != null && mounted) setState(() => _startDate = value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServices.isEmpty) {
      _snack('Please choose at least one type of work.', error: true);
      return;
    }
    if (_startDate == null) {
      _snack('Choose a start date.', error: true);
      return;
    }
    final amount = double.tryParse(_amount.text.replaceAll(',', '').trim());
    if (amount == null || amount <= 0) {
      _snack('Please enter how much you will pay.', error: true);
      return;
    }

    setState(() => _submitting = true);
    final result = await _hiring.sendDirectOffer(
      workerId: widget.workerId,
      title: _title.text,
      description: _description.text,
      address: _address.text,
      district: _district.text,
      startDate: _dateValue(_startDate!),
      duration: _duration.text,
      budgetType: _budgetType,
      offeredAmount: amount,
      serviceIds: _selectedServices.toList(),
      workArrangement: _workArrangement,
      message: _message.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result['success'] != true) {
      _snack(
        result['message']?.toString() ?? 'Unable to send offer.',
        error: true,
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            icon: const Icon(
              Icons.check_circle_rounded,
              color: _primary,
              size: 56,
            ),
            title: const Text('Job Offer Sent'),
            content: Text(
              '${widget.workerName} will see this under Requests → Job Offers. The job is private and will not appear in public New Jobs.',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Done'),
              ),
            ],
          ),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? Colors.red.shade700 : _navy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offer This Worker a Job')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'JOB OFFER',
                    style: TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hire ${widget.workerName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Only this worker will receive this offer. They can accept or decline it.',
                    style: TextStyle(color: Color(0xFFD4E1EA), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _field(_title, 'Job title', hint: 'e.g. Full-time Housekeeper'),
            _field(
              _description,
              'Job description',
              hint: 'Describe the work and responsibilities',
              maxLines: 4,
            ),
            _field(_address, 'Work address', hint: 'e.g. Ntinda, Kampala'),
            _field(_district, 'Where Is the Job?', hint: 'e.g. Kampala'),
            const SizedBox(height: 8),
            const Text(
              'What Work Do You Need?',
              style: TextStyle(color: _navy, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 9),
            if (_loadingCategories)
              const LinearProgressIndicator(color: _primary)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _categories.map((category) {
                      final id =
                          int.tryParse(category['id']?.toString() ?? '') ?? 0;
                      final selected = _selectedServices.contains(id);
                      return FilterChip(
                        selected: selected,
                        label: Text(
                          category['name']?.toString() ?? 'Skill / Service',
                        ),
                        onSelected:
                            (_) => setState(() {
                              selected
                                  ? _selectedServices.remove(id)
                                  : _selectedServices.add(id);
                            }),
                        selectedColor: _primary.withValues(alpha: .16),
                        checkmarkColor: _primary,
                      );
                    }).toList(),
              ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _workArrangement,
              decoration: _decoration('Work type'),
              items: const [
                DropdownMenuItem(value: 'full_time', child: Text('Full-time')),
                DropdownMenuItem(value: 'part_time', child: Text('Part-time')),
                DropdownMenuItem(value: 'live_in', child: Text('Live-in')),
                DropdownMenuItem(value: 'live_out', child: Text('Live-out')),
              ],
              onChanged:
                  (value) =>
                      setState(() => _workArrangement = value ?? 'full_time'),
            ),
            const SizedBox(height: 14),
            _field(_duration, 'Duration', hint: 'e.g. Ongoing, 6 months'),
            DropdownButtonFormField<String>(
              value: _budgetType,
              decoration: _decoration('Payment type'),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'fixed', child: Text('Fixed amount')),
              ],
              onChanged:
                  (value) => setState(() => _budgetType = value ?? 'monthly'),
            ),
            const SizedBox(height: 14),
            _field(
              _amount,
              'How Much Will You Pay? (UGX)',
              hint: 'e.g. 500000',
              keyboardType: TextInputType.number,
            ),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: _decoration('Start date'),
                child: Text(
                  _startDate == null
                      ? 'Choose date'
                      : _displayDate(_startDate!),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _field(_message, 'Tell the Worker About the Job', maxLines: 3),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                minimumSize: const Size.fromHeight(54),
              ),
              icon:
                  _submitting
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.send_rounded),
              label: Text(_submitting ? 'Sending...' : 'Send Job Offer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: _decoration(label, hint: hint),
        validator:
            (value) =>
                value == null || value.trim().isEmpty
                    ? '$label is required.'
                    : null,
      ),
    );
  }

  InputDecoration _decoration(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: Theme.of(context).colorScheme.surface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _primary, width: 1.5),
    ),
  );
}

String _dateValue(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
String _displayDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
