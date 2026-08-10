import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

const _teal = Color(0xFF1FB8B3),
    _navy = Color(0xFF123F67),
    _bg = Color(0xFFF5F8FA);

class AdminUserDetailsScreen extends StatefulWidget {
  const AdminUserDetailsScreen({super.key, required this.userId});
  final int userId;
  @override
  State<AdminUserDetailsScreen> createState() => _State();
}

class _State extends State<AdminUserDetailsScreen> {
  final _s = AdminService();
  bool _loading = true;
  Map<String, dynamic> _u = {}, _a = {};
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await _s.user(widget.userId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r['success'] == true) {
        _u = Map<String, dynamic>.from(r['user'] ?? {});
        _a = Map<String, dynamic>.from(r['activity'] ?? {});
        _error = null;
      } else
        _error = r['message']?.toString();
    });
  }

  Future<String?> _reason(String title) async {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (x) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: c,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Admin reason',
                hintText: 'Explain clearly why this action is being taken',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(x),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(x, c.text.trim()),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  Future<void> _action(String type) async {
    Map<String, dynamic> r;
    if (type == 'activate') {
      r = await _s.activateUser(widget.userId);
    } else {
      final reason = await _reason(
        type == 'suspend' ? 'Suspend account' : 'Deactivate account',
      );
      if (reason == null) return;
      if (reason.length < 5) {
        _msg('Please enter a clear reason.');
        return;
      }
      r =
          type == 'suspend'
              ? await _s.suspendUser(widget.userId, reason)
              : await _s.deactivateUser(widget.userId, reason);
    }
    if (!mounted) return;
    _msg(r['message']?.toString() ?? 'Updated.');
    if (r['success'] == true) _load();
  }

  void _msg(String s) =>
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(s), behavior: SnackBarBehavior.floating),
        );
  @override
  Widget build(BuildContext context) {
    final status = _u['account_status']?.toString() ?? 'active';
    final role = _u['role']?.toString() ?? '';
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: _teal.withValues(alpha: .12),
                                child: const Icon(Icons.person, color: _teal),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _u['full_name']?.toString() ?? '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      '${role.toUpperCase()} • ${status.toUpperCase()}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 28),
                          _line('Phone', _u['phone']),
                          _line('Email', _u['email'] ?? 'Not provided'),
                          _line(
                            'Verified',
                            _u['is_verified'] == true ? 'Yes' : 'No',
                          ),
                          if ((_u['account_status_reason']?.toString() ?? '')
                              .isNotEmpty)
                            _line(
                              'Account reason',
                              _u['account_status_reason'],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Activity',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _line('Jobs posted', _a['jobs_posted'] ?? 0),
                          _line('Jobs assigned', _a['jobs_assigned'] ?? 0),
                          _line('Applications', _a['applications'] ?? 0),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (role != 'admin' && status == 'active')
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: () => _action('suspend'),
                      icon: const Icon(Icons.pause_circle_outline),
                      label: const Text('Suspend Account'),
                    ),
                  if (role != 'admin' && status == 'active') ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: () => _action('deactivate'),
                      icon: const Icon(Icons.block),
                      label: const Text('Deactivate Account'),
                    ),
                  ],
                  if (role != 'admin' && status != 'active')
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _teal,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: () => _action('activate'),
                      icon: const Icon(Icons.restore),
                      label: const Text('Restore Account'),
                    ),
                  if (role == 'admin')
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Administrator accounts are protected from suspension/deactivation here.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _line(String a, Object? b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 115,
          child: Text(
            a,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Text(b?.toString() ?? '')),
      ],
    ),
  );
}
