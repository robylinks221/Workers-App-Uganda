import 'package:flutter/material.dart';

import '../../services/hiring_service.dart';

const _primary = Color(0xFF1FB8B3);

class ConfirmHiringRequestScreen extends StatefulWidget {
  const ConfirmHiringRequestScreen({
    super.key,
    required this.workerId,
    required this.workerName,
    required this.job,
  });

  final int workerId;
  final String workerName;
  final Map<String, dynamic> job;

  @override
  State<ConfirmHiringRequestScreen> createState() =>
      _ConfirmHiringRequestScreenState();
}

class _ConfirmHiringRequestScreenState
    extends State<ConfirmHiringRequestScreen> {
  final HiringService _service = HiringService();
  final TextEditingController _messageController = TextEditingController();
  late final TextEditingController _amountController;

  DateTime? _startDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    final budget = _asDouble(widget.job['budget_amount']);
    _amountController = TextEditingController(
      text: budget > 0 ? budget.toStringAsFixed(0) : '',
    );

    _messageController.text =
        'Hello ${widget.workerName}, I would like to hire you for '
        '${widget.job['title'] ?? 'this job'}.';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      initialDate: _startDate ?? now,
    );

    if (selected != null && mounted) {
      setState(() => _startDate = selected);
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', ''),
    );

    if (amount == null || amount <= 0) {
      _showMessage('Enter a valid offer amount.', error: true);
      return;
    }

    setState(() => _submitting = true);

    final result = await _service.sendHiringRequest(
      jobId: _asInt(widget.job['id']),
      workerId: widget.workerId,
      offeredAmount: amount,
      message: _messageController.text,
      startDate: _startDate == null ? null : _dateValue(_startDate!),
    );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (result['success'] != true) {
      _showMessage(
        result['message']?.toString() ?? 'Unable to send hiring request.',
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
              size: 58,
            ),
            title: const Text('Hiring Request Sent'),
            content: Text(
              '${widget.workerName} has received your request. '
              'You will be notified after the worker responds.',
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

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Confirm Hiring Request')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        children: [
          _SummaryCard(workerName: widget.workerName, job: widget.job),
          const SizedBox(height: 18),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Offer Amount',
              prefixText: 'UGX ',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, color: _primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _startDate == null
                          ? 'Select a start date (optional)'
                          : _displayDate(_startDate!),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            minLines: 4,
            maxLines: 7,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: 'Message',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        color: colors.surface,
        elevation: 14,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submit,
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
                      : const Icon(Icons.send_rounded),
              label: Text(
                _submitting ? 'Sending Request...' : 'Send Hiring Request',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.workerName, required this.job});

  final String workerName;
  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF164D7A), Color(0xFF177989), Color(0xFF1FB8B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('You are hiring', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Text(
            workerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _Line(
            icon: Icons.work_outline_rounded,
            text: job['title']?.toString() ?? 'Job',
          ),
          const SizedBox(height: 9),
          _Line(
            icon: Icons.location_on_outlined,
            text: job['district']?.toString() ?? 'Location not provided',
          ),
          const SizedBox(height: 9),
          _Line(
            icon: Icons.payments_outlined,
            text: 'UGX ${_money(job['budget_amount'])}',
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _money(dynamic value) {
  final amount = _asDouble(value);
  return amount.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}

String _dateValue(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _displayDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
