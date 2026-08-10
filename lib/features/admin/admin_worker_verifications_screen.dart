import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../services/admin_service.dart';
import 'admin_worker_verification_details_screen.dart';

const _primary = Color(0xFF1FB8B3);
const _slate = Color(0xFF17324D);

class AdminWorkerVerificationsScreen extends StatefulWidget {
  const AdminWorkerVerificationsScreen({super.key});

  @override
  State<AdminWorkerVerificationsScreen> createState() => _AdminWorkerVerificationsScreenState();
}

class _AdminWorkerVerificationsScreenState extends State<AdminWorkerVerificationsScreen> {
  final AdminService _service = AdminService();
  String _status = 'pending';
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _workers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await _service.verifications(status: _status);
    if (!mounted) return;
    final raw = result['workers'];
    setState(() {
      _loading = false;
      if (result['success'] == true && raw is List) {
        _workers = raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        _error = result['message']?.toString() ?? 'Unable to load workers.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(title: const Text('Worker Verifications')),
      body: Column(children: [
        _filters(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(_error!)))])
                    : _workers.isEmpty
                        ? ListView(children: const [SizedBox(height: 100), Icon(Icons.verified_user_outlined, size: 52, color: _primary), SizedBox(height: 12), Center(child: Text('No workers in this verification status.'))])
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                            itemCount: _workers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, index) => _WorkerTile(
                              worker: _workers[index],
                              onTap: () async {
                                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminWorkerVerificationDetailsScreen(profileId: _workers[index]['id'] as int)));
                                _load();
                              },
                            ),
                          ),
          ),
        ),
      ]),
    );
  }

  Widget _filters() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Row(
          children: [
            for (final item in const [('pending', 'Pending'), ('approved', 'Approved'), ('rejected', 'Rejected'), ('all', 'All')]) ...[
              ChoiceChip(
                label: Text(item.$2),
                selected: _status == item.$1,
                onSelected: (_) { setState(() => _status = item.$1); _load(); },
                selectedColor: _primary.withValues(alpha: 0.15),
                labelStyle: TextStyle(color: _status == item.$1 ? _primary : _slate, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
            ]
          ],
        ),
      );
}

class _WorkerTile extends StatelessWidget {
  const _WorkerTile({required this.worker, required this.onTap});
  final Map<String, dynamic> worker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = worker['full_name']?.toString() ?? 'Worker';
    final photo = ApiConfig.storageUrl(worker['profile_photo']?.toString());
    final services = (worker['services'] as List?)?.map((e) => e.toString()).join(' • ') ?? '';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: _primary.withValues(alpha: 0.12),
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty ? Text(_initials(name), style: const TextStyle(color: _primary, fontWeight: FontWeight.w900)) : null,
            ),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _slate, fontSize: 15, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(worker['district']?.toString() ?? 'District not provided', style: const TextStyle(color: Color(0xFF6D8092), fontSize: 12)),
              if (services.isNotEmpty) ...[const SizedBox(height: 4), Text(services, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.w700))],
            ])),
            _StatusPill(worker['verification_status']?.toString() ?? 'pending'),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AACB8)),
          ]),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);
  final String status;
  @override
  Widget build(BuildContext context) {
    final approved = status == 'approved';
    final rejected = status == 'rejected';
    final color = approved ? Colors.green : rejected ? Colors.redAccent : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  return parts.isEmpty ? 'W' : parts.take(2).map((e) => e[0].toUpperCase()).join();
}
