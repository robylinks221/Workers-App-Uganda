import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'admin_user_details_screen.dart';

const _teal = Color(0xFF1FB8B3),
    _navy = Color(0xFF123F67),
    _bg = Color(0xFFF5F8FA);

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _service = AdminService();
  final _search = TextEditingController();
  Timer? _timer;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _users = [];
  String _role = '';
  String _status = '';
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await _service.users(
      role: _role,
      status: _status,
      search: _search.text,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = r['success'] == true ? null : r['message']?.toString();
      _users =
          (r['users'] is List)
              ? (r['users'] as List)
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : [];
    });
  }

  void _changed(String _) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 450), _load);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(
      title: const Text(
        'User Management',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      backgroundColor: _navy,
      foregroundColor: Colors.white,
    ),
    body: RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _search,
            onChanged: _changed,
            decoration: InputDecoration(
              hintText: 'Search name, phone or email',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _drop(
                  'Role',
                  _role,
                  {
                    '': 'All roles',
                    'worker': 'Workers',
                    'homeowner': 'Homeowners',
                    'admin': 'Admins',
                  },
                  (v) {
                    setState(() => _role = v!);
                    _load();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _drop(
                  'Status',
                  _status,
                  {
                    '': 'All status',
                    'active': 'Active',
                    'suspended': 'Suspended',
                    'deactivated': 'Deactivated',
                  },
                  (v) {
                    setState(() => _status = v!);
                    _load();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _message(_error!)
          else if (_users.isEmpty)
            _message('No users found.')
          else
            ..._users.map(_card),
        ],
      ),
    ),
  );
  Widget _drop(
    String label,
    String value,
    Map<String, String> items,
    ValueChanged<String?> onChanged,
  ) => DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    items:
        items.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
    onChanged: onChanged,
  );
  Widget _message(String s) => Padding(
    padding: const EdgeInsets.all(30),
    child: Center(child: Text(s, textAlign: TextAlign.center)),
  );
  Widget _card(Map<String, dynamic> u) {
    final status = u['account_status']?.toString() ?? 'active',
        role = u['role']?.toString() ?? '';
    final p = role == 'worker' ? u['worker_profile'] : u['homeowner_profile'];
    final district = p is Map ? p['district']?.toString() : null;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: _teal.withValues(alpha: .12),
          child: Icon(
            role == 'worker'
                ? Icons.badge_outlined
                : role == 'homeowner'
                ? Icons.home_outlined
                : Icons.admin_panel_settings_outlined,
            color: _teal,
          ),
        ),
        title: Text(
          u['full_name']?.toString() ?? 'User',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${role.toUpperCase()} • ${u['phone'] ?? ''}${district == null ? '' : ' • $district'}\n${status.toUpperCase()}',
          style: TextStyle(
            color: status == 'active' ? Colors.black54 : Colors.redAccent,
          ),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AdminUserDetailsScreen(
                    userId: int.parse(u['id'].toString()),
                  ),
            ),
          );
          _load();
        },
      ),
    );
  }
}
