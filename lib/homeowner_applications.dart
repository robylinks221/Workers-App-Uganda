import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'services/homeowner_job_service.dart';

const _primary = Color(0xFFD87C53);
const _navy = Color(0xFF2A3D4E);

class HomeownerApplicationsScreen extends StatefulWidget {
  const HomeownerApplicationsScreen({super.key, required this.jobId});

  final int jobId;

  @override
  State<HomeownerApplicationsScreen> createState() =>
      _HomeownerApplicationsScreenState();
}

class _HomeownerApplicationsScreenState
    extends State<HomeownerApplicationsScreen> {
  final _service = HomeownerJobService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.getApplications(widget.jobId);

    if (!mounted) return;

    final raw = result['applications'];
    setState(() {
      _items =
          result['success'] == true && raw is List
              ? raw
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : [];
      _loading = false;
    });
  }

  Future<void> _change(int id, bool accept) async {
    final result =
        accept
            ? await _service.acceptApplication(id)
            : await _service.declineApplication(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message']?.toString() ?? 'Done.')),
    );

    if (result['success'] == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ApplicantsHeader(
              count: _items.length,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child:
                  _loading
                      ? const Center(
                        child: CircularProgressIndicator(color: _primary),
                      )
                      : _items.isEmpty
                      ? const _ApplicantsEmpty()
                      : RefreshIndicator(
                        color: _primary,
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: _items.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 13),
                          itemBuilder: (_, index) {
                            final item = _items[index];
                            final worker =
                                item['worker'] is Map
                                    ? Map<String, dynamic>.from(item['worker'])
                                    : <String, dynamic>{};

                            final profile =
                                item['profile'] is Map
                                    ? Map<String, dynamic>.from(item['profile'])
                                    : <String, dynamic>{};

                            final status = item['status']?.toString() ?? '';

                            final imageUrl = ApiConfig.storageUrl(
                              worker['profile_photo']?.toString(),
                            );

                            return _ApplicantCard(
                              worker: worker,
                              profile: profile,
                              item: item,
                              imageUrl: imageUrl,
                              status: status,
                              onAccept:
                                  status == 'pending'
                                      ? () => _change(_id(item['id']), true)
                                      : null,
                              onDecline:
                                  status == 'pending'
                                      ? () => _change(_id(item['id']), false)
                                      : null,
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicantsHeader extends StatelessWidget {
  const _ApplicantsHeader({required this.count, required this.onBack});

  final int count;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF123F67), Color(0xFF176B80), Color(0xFF1FB8B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(14),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PEOPLE WHO APPLIED',
                  style: TextStyle(
                    color: Color(0xFFC7E3E7),
                    fontSize: 9.5,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Choose a Worker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Read each worker profile before you accept or decline.',
                  style: TextStyle(color: Colors.white70, fontSize: 10.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({
    required this.worker,
    required this.profile,
    required this.item,
    required this.imageUrl,
    required this.status,
    required this.onAccept,
    required this.onDecline,
  });

  final Map<String, dynamic> worker;
  final Map<String, dynamic> profile;
  final Map<String, dynamic> item;
  final String imageUrl;
  final String status;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final name = worker['full_name']?.toString() ?? 'Worker';

    final experience = profile['experience_years']?.toString() ?? '0';

    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(23),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: _primary.withValues(alpha: 0.10),
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child:
                      imageUrl.isEmpty
                          ? const Icon(
                            Icons.person_outline_rounded,
                            color: _primary,
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF17324D),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$experience years experience',
                        style: const TextStyle(
                          color: Color(0xFF718396),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _ApplicantStatus(status: status),
              ],
            ),
            if ((item['message']?.toString() ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MESSAGE FROM WORKER',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 9,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item['message'].toString(),
                      style: const TextStyle(
                        color: Color(0xFF17324D),
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (status == 'pending') ...[
              const SizedBox(height: 16),
              const Text(
                'Do you want this worker for the job?',
                style: TextStyle(
                  color: Color(0xFF17324D),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: const Color(0xFFE45B63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Not This Worker',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: onAccept,
                      style: FilledButton.styleFrom(
                        backgroundColor: _primary,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Choose Worker',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ApplicantStatus extends StatelessWidget {
  const _ApplicantStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'pending' => 'WAITING',
      'accepted' => 'CHOSEN',
      'declined' => 'NOT CHOSEN',
      _ => status.replaceAll('_', ' ').toUpperCase(),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _primary,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ApplicantsEmpty extends StatelessWidget {
  const _ApplicantsEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded, color: _primary, size: 52),
            SizedBox(height: 13),
            Text(
              'No one has applied yet',
              style: TextStyle(
                color: Color(0xFF17324D),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Workers who apply for this job will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF718396)),
            ),
          ],
        ),
      ),
    );
  }
}

int _id(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
