import 'package:flutter/material.dart';

import '../../services/admin_service.dart';

const _teal = Color(0xFF20B9B4);
const _navy = Color(0xFF123F67);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);
const _red = Color(0xFFE45B63);
const _surface = Color(0xFFF4F7FA);

class AdminAccountAppealsScreen extends StatefulWidget {
  const AdminAccountAppealsScreen({super.key});

  @override
  State<AdminAccountAppealsScreen> createState() =>
      _AdminAccountAppealsScreenState();
}

class _AdminAccountAppealsScreenState extends State<AdminAccountAppealsScreen> {
  final AdminService _service = AdminService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _appeals = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.accountAppeals();

    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _loading = false;
        _appeals = <Map<String, dynamic>>[];
        _error =
            result['message']?.toString() ??
            'Unable to load suspension appeals.';
      });
      return;
    }

    final raw = result['appeals'];

    setState(() {
      _loading = false;
      _appeals =
          raw is List
              ? raw
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList()
              : <Map<String, dynamic>>[];
    });
  }

  Future<String?> _responseDialog(String title, {bool required = true}) async {
    return showDialog<String>(
      context: context,
      builder: (_) => _AdminResponseDialog(title: title, required: required),
    );
  }

  Future<void> _approve(int id) async {
    final response = await _responseDialog('Restore account', required: false);

    if (response == null || !mounted) return;

    final result = await _service.approveAppeal(id, response: response);

    if (!mounted) return;

    _message(
      result['message']?.toString() ?? 'Appeal updated.',
      success: result['success'] == true,
    );

    if (result['success'] == true) {
      await _load();
    }
  }

  Future<void> _reject(int id) async {
    final response = await _responseDialog('Reject appeal');

    if (response == null || !mounted) return;

    final result = await _service.rejectAppeal(id, response);

    if (!mounted) return;

    _message(
      result['message']?.toString() ?? 'Appeal updated.',
      success: result['success'] == true,
    );

    if (result['success'] == true) {
      await _load();
    }
  }

  void _message(String message, {required bool success}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? _navy : _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suspension Appeals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            Text(
              'Review requests from suspended users',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: _teal,
        child:
            _loading
                ? const Center(child: CircularProgressIndicator(color: _teal))
                : _error != null
                ? _errorView()
                : _appeals.isEmpty
                ? _emptyView()
                : _appealsList(),
      ),
    );
  }

  Widget _appealsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _appeals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 13),
      itemBuilder: (context, index) {
        final appeal = _appeals[index];

        final user =
            appeal['user'] is Map
                ? Map<String, dynamic>.from(appeal['user'])
                : <String, dynamic>{};

        final name = user['full_name']?.toString() ?? 'User';

        final role = user['role']?.toString() ?? '';

        final phone = user['phone']?.toString() ?? '';

        final reason = user['account_status_reason']?.toString().trim() ?? '';

        final message = appeal['message']?.toString().trim() ?? '';

        final id = int.tryParse(appeal['id']?.toString() ?? '') ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: const Color(0xFFE7EDF2)),
            boxShadow: [
              BoxShadow(
                color: _navy.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _navy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: _slate,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_roleLabel(role)}${phone.isNotEmpty ? '  •  $phone' : ''}',
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PENDING',
                        style: TextStyle(
                          color: _red,
                          fontSize: 9.5,
                          letterSpacing: 0.7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoBlock(
                  title: 'Suspension reason',
                  icon: Icons.pause_circle_outline,
                  text: reason.isEmpty ? 'No reason provided.' : reason,
                  accent: _red,
                ),
                const SizedBox(height: 10),
                _InfoBlock(
                  title: 'User appeal',
                  icon: Icons.rate_review_outlined,
                  text:
                      message.isEmpty ? 'No appeal message provided.' : message,
                  accent: _teal,
                ),
                const SizedBox(height: 17),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: id <= 0 ? null : () => _reject(id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _red,
                          minimumSize: const Size.fromHeight(48),
                          side: const BorderSide(color: _red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text(
                          'Reject Appeal',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: id <= 0 ? null : () => _approve(id),
                        style: FilledButton.styleFrom(
                          backgroundColor: _teal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(Icons.restore_rounded, size: 18),
                        label: const Text(
                          'Restore Account',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 110),
        Container(
          width: 82,
          height: 82,
          margin: const EdgeInsets.symmetric(horizontal: 100),
          decoration: BoxDecoration(
            color: _teal.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: _teal,
            size: 38,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'No pending appeals',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _slate,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'When a suspended user submits an appeal, it will appear here for administrator review.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 12.5, height: 1.45),
        ),
      ],
    );
  }

  Widget _errorView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
        const Icon(Icons.cloud_off_outlined, color: _red, size: 46),
        const SizedBox(height: 15),
        const Text(
          'Could not load appeals',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _slate,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, height: 1.45),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: _load,
            style: FilledButton.styleFrom(backgroundColor: _teal),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ),
      ],
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'worker':
        return 'Worker';
      case 'homeowner':
        return 'Homeowner';
      case 'admin':
        return 'Administrator';
      default:
        return 'User';
    }
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.title,
    required this.icon,
    required this.text,
    required this.accent,
  });

  final String title;
  final IconData icon;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.13)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: _slate,
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
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

class _AdminResponseDialog extends StatefulWidget {
  const _AdminResponseDialog({required this.title, required this.required});

  final String title;
  final bool required;

  @override
  State<_AdminResponseDialog> createState() => _AdminResponseDialogState();
}

class _AdminResponseDialogState extends State<_AdminResponseDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          minLines: 4,
          maxLines: 7,
          maxLength: 1500,
          decoration: const InputDecoration(
            hintText: 'Write a short response for the user...',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (!widget.required) {
              return null;
            }

            if ((value?.trim().length ?? 0) < 5) {
              return 'Please write at least 5 characters.';
            }

            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }

            Navigator.of(context).pop(_controller.text.trim());
          },
          style: FilledButton.styleFrom(backgroundColor: _teal),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
