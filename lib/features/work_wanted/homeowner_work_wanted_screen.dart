import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../services/work_wanted_service.dart';
import '../profile/worker_public_profile_screen.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF17324D);

class HomeownerWorkWantedScreen extends StatefulWidget {
  const HomeownerWorkWantedScreen({super.key});
  @override
  State<HomeownerWorkWantedScreen> createState() =>
      _HomeownerWorkWantedScreenState();
}

class _HomeownerWorkWantedScreenState extends State<HomeownerWorkWantedScreen> {
  final _service = WorkWantedService();
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;
  String? _error;
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
    final r = await _service.browse();
    if (!mounted) return;
    final raw = r['posts'];
    setState(() {
      _posts =
          raw is List
              ? raw
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : [];
      _error = r['success'] == true ? null : r['message']?.toString();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Workers Looking for Work')),
    body: RefreshIndicator(
      onRefresh: _load,
      color: _primary,
      child:
          _loading
              ? const Center(child: CircularProgressIndicator(color: _primary))
              : _error != null
              ? ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                ],
              )
              : _posts.isEmpty
              ? ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'No active Looking for Work posts yet.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _card(_posts[i]),
              ),
    ),
  );
  Widget _card(Map<String, dynamic> p) {
    final w =
        p['worker'] is Map
            ? Map<String, dynamic>.from(p['worker'])
            : <String, dynamic>{};
    final name = w['full_name']?.toString() ?? 'Worker';
    final photo = ApiConfig.storageUrl(w['profile_photo']?.toString());
    final services = (p['services'] is List ? p['services'] as List : const [])
        .whereType<Map>()
        .map((e) => e['name']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .join(' • ');
    return InkWell(
      onTap: () => _open(w),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 16,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: const Color(0xFFE6F8F7),
                  backgroundImage: photo.isEmpty ? null : NetworkImage(photo),
                  child:
                      photo.isEmpty
                          ? Text(
                            name.isEmpty ? 'W' : name[0].toUpperCase(),
                            style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _navy,
                              ),
                            ),
                          ),
                          if (w['is_verified'] == true) ...const [
                            SizedBox(width: 4),
                            Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: _primary,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        p['district']?.toString() ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'AVAILABLE',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              p['title']?.toString() ?? 'Looking for Work',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              services,
              style: const TextStyle(
                color: _primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              p['description']?.toString() ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.4),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _open(w),
                icon: const Icon(Icons.person_outline),
                label: const Text('View Worker & Send Offer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(Map<String, dynamic> w) {
    final id = (w['id'] as num?)?.toInt();
    if (id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkerPublicProfileScreen(workerId: id),
      ),
    );
  }
}
