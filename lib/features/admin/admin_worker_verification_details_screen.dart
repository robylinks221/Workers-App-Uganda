import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../storage/token_storage.dart';
import '../../services/admin_service.dart';

const _primary = Color(0xFF1FB8B3);
const _slate = Color(0xFF17324D);
const _sub = Color(0xFF6D8092);

class AdminWorkerVerificationDetailsScreen extends StatefulWidget {
  const AdminWorkerVerificationDetailsScreen({
    super.key,
    required this.profileId,
  });
  final int profileId;

  @override
  State<AdminWorkerVerificationDetailsScreen> createState() =>
      _AdminWorkerVerificationDetailsScreenState();
}

class _AdminWorkerVerificationDetailsScreenState
    extends State<AdminWorkerVerificationDetailsScreen> {
  final AdminService _service = AdminService();
  bool _loading = true;
  bool _saving = false;
  String? _error;
  Map<String, dynamic>? _worker;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.verification(widget.profileId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success'] == true && result['worker'] is Map) {
        _worker = Map<String, dynamic>.from(result['worker']);
      } else {
        _error = result['message']?.toString() ?? 'Unable to load worker.';
      }
    });
  }

  Future<void> _approve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Approve worker?'),
            content: const Text(
              'This will activate the verified badge for this worker.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Approve'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    setState(() => _saving = true);
    final result = await _service.approve(widget.profileId);
    if (!mounted) return;
    setState(() => _saving = false);
    _toast(result['message']?.toString() ?? 'Done');
    if (result['success'] == true) Navigator.of(context).pop(true);
  }

  Future<void> _reject() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Reject verification'),
            content: TextField(
              controller: controller,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Reason for worker',
                hintText: 'Explain what must be corrected...',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton.tonal(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.length >= 5) Navigator.pop(context, text);
                },
                child: const Text('Reject'),
              ),
            ],
          ),
    );
    controller.dispose();
    if (reason == null) return;
    setState(() => _saving = true);
    final result = await _service.reject(widget.profileId, reason);
    if (!mounted) return;
    setState(() => _saving = false);
    _toast(result['message']?.toString() ?? 'Done');
    if (result['success'] == true) Navigator.of(context).pop(true);
  }

  void _toast(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _worker == null)
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Worker not found.')),
      );
    final w = _worker!;
    final name = w['full_name']?.toString() ?? 'Worker';
    final photo = ApiConfig.storageUrl(w['profile_photo']?.toString());
    final status = w['verification_status']?.toString() ?? 'pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(title: const Text('Worker Verification')),
      bottomNavigationBar:
          status == 'approved'
              ? null
              : SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _reject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _approve,
                        style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: Text(_saving ? 'Saving...' : 'Approve Worker'),
                      ),
                    ),
                  ],
                ),
              ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          _hero(name, photo, status),
          const SizedBox(height: 14),
          _section('Personal Information', [
            _row('Phone', w['phone']),
            _row('Email', w['email']),
            _row('Age', w['age']),
            _row('Gender', w['gender']),
            _row('Religion', w['religion']),
            _row('District', w['district']),
            _row('Work type', w['work_type']),
            _row('Experience', '${w['experience_years'] ?? 0} years'),
          ]),
          const SizedBox(height: 14),
          _services(w['services']),
          const SizedBox(height: 14),
          _idCard(w),
          const SizedBox(height: 14),
          _gallery(w['gallery']),
          if ((w['rejection_reason']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            _section('Previous Rejection Reason', [
              Text(
                w['rejection_reason'].toString(),
                style: const TextStyle(color: Colors.redAccent, height: 1.4),
              ),
            ]),
          ],
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _hero(String name, String photo, String status) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 37,
          backgroundColor: _primary.withValues(alpha: 0.12),
          backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
          child:
              photo.isEmpty
                  ? const Icon(Icons.person, color: _primary, size: 36)
                  : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: _slate,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                wrapStatus(status),
                style: const TextStyle(color: _sub, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _section(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _slate,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 13),
        ...children,
      ],
    ),
  );

  Widget _row(String label, dynamic value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(label, style: const TextStyle(color: _sub, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            (value == null || value.toString().trim().isEmpty)
                ? 'Not provided'
                : value.toString(),
            style: const TextStyle(
              color: _slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _services(dynamic raw) {
    final services =
        raw is List
            ? raw
                .whereType<Map>()
                .map((e) => e['name']?.toString())
                .whereType<String>()
                .toList()
            : <String>[];
    return _section('Services', [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            services.isEmpty
                ? [const Text('No services selected.')]
                : services
                    .map(
                      (name) => Chip(
                        label: Text(name),
                        backgroundColor: _primary.withValues(alpha: 0.10),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
      ),
    ]);
  }

  Widget _idCard(Map<String, dynamic> w) {
    final profileId = int.tryParse(w['id']?.toString() ?? '') ?? 0;

    return _section('National ID', [
      _AdminProtectedIdImage(
        title: 'Front of National ID',
        url: ApiConfig.adminWorkerIdentityDocument(profileId, 'front'),
      ),
      const SizedBox(height: 14),
      _AdminProtectedIdImage(
        title: 'Back of National ID',
        url: ApiConfig.adminWorkerIdentityDocument(profileId, 'back'),
      ),
    ]);
  }

  Widget _gallery(dynamic raw) {
    final items = raw is List ? raw.whereType<Map>().toList() : <Map>[];
    return _section('Gallery', [
      if (items.isEmpty)
        const Text('No gallery images uploaded.')
      else
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (_, i) {
              final url = ApiConfig.storageUrl(items[i]['path']?.toString());
              return ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 105,
                  child: Image.network(url, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
    ]);
  }
}

class _AdminProtectedIdImage extends StatelessWidget {
  const _AdminProtectedIdImage({required this.title, required this.url});

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenStorage.getToken(),
      builder: (context, snapshot) {
        final token = snapshot.data;

        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator(color: _primary)),
          );
        }

        if (token == null || token.isEmpty) {
          return const Text('Please sign in again.');
        }

        final headers = {'Authorization': 'Bearer $token', 'Accept': 'image/*'};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _slate,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            GestureDetector(
              onTap:
                  () => showDialog(
                    context: context,
                    builder:
                        (_) => Dialog(
                          child: InteractiveViewer(
                            child: Image.network(
                              url,
                              headers: headers,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                  ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1.6,
                  child: Image.network(
                    url,
                    headers: headers,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => const Center(
                          child: Text(
                            'ID image not uploaded or could not be displayed.',
                          ),
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap the document to enlarge',
              style: TextStyle(color: _sub, fontSize: 11),
            ),
          ],
        );
      },
    );
  }
}

String wrapStatus(String status) {
  switch (status) {
    case 'approved':
      return 'Verified worker';
    case 'rejected':
      return 'Verification rejected';
    default:
      return 'Awaiting verification review';
  }
}
