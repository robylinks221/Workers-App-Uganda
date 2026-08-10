import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../services/guest_marketplace_service.dart';
import '../auth/screens/login_screen.dart';
import '../../signup.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF123F67);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);
const _bg = Color(0xFFF4F7FA);

class GuestWorkerProfileScreen extends StatefulWidget {
  const GuestWorkerProfileScreen({super.key, required this.workerId});

  final int workerId;

  @override
  State<GuestWorkerProfileScreen> createState() =>
      _GuestWorkerProfileScreenState();
}

class _GuestWorkerProfileScreenState extends State<GuestWorkerProfileScreen> {
  final GuestMarketplaceService _service = GuestMarketplaceService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _worker = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.getWorker(widget.workerId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success'] == true) {
        _worker = Map<String, dynamic>.from(result['worker'] ?? {});
      } else {
        _error = result['message']?.toString() ?? 'Unable to load worker.';
      }
    });
  }

  void _authPrompt() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E9EE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.lock_person_outlined,
                    color: _primary,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unlock the full worker profile',
                    style: TextStyle(
                      color: _slate,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Create an account or sign in to see full profile information, reviews, gallery, contact options and hiring actions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: _primary,
                          ),
                          child: const Text('Create Account'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _primary)),
      );
    }

    if (_error != null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(_error!)));
    }

    final name = _worker['full_name']?.toString() ?? 'Worker';
    final district = _worker['district']?.toString() ?? '';
    final photo = ApiConfig.storageUrl(_worker['profile_photo']?.toString());
    final services =
        _worker['services'] is List ? _worker['services'] as List : const [];
    final bio = _worker['bio_preview']?.toString() ?? '';

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 285,
            pinned: true,
            backgroundColor: _navy,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0C2E4C),
                          Color(0xFF176477),
                          _primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 65, 20, 22),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 47,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.16,
                            ),
                            backgroundImage:
                                photo.isNotEmpty ? NetworkImage(photo) : null,
                            child:
                                photo.isEmpty
                                    ? Text(
                                      _initials(name),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 31,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    )
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF8AF0DA),
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            district,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: _stat(
                        Icons.star_rounded,
                        '${_worker['rating'] ?? 0}',
                        'Rating',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _stat(
                        Icons.work_history_outlined,
                        '${_worker['experience_years'] ?? 0} yrs',
                        'Experience',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _section(
                  'Services Offered',
                  Icons.cleaning_services_outlined,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        services.map((raw) {
                          final map = raw is Map ? raw : const {};
                          return Chip(
                            label: Text(map['name']?.toString() ?? 'Service'),
                            side: BorderSide.none,
                            backgroundColor: const Color(0xFFEAF9F8),
                            labelStyle: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w800,
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                _section(
                  'About',
                  Icons.person_outline_rounded,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bio,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _authPrompt,
                        icon: const Icon(Icons.lock_outline_rounded),
                        label: const Text('Sign in to read full profile'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _lockedSection(
                  title: 'Reviews & Work History',
                  subtitle:
                      'Sign in to read homeowner reviews and completed-job history.',
                  icon: Icons.reviews_outlined,
                ),
                const SizedBox(height: 14),
                _lockedSection(
                  title: 'Gallery & Verification Details',
                  subtitle:
                      'Create an account to view more profile details and worker gallery.',
                  icon: Icons.photo_library_outlined,
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
          child: FilledButton.icon(
            onPressed: _authPrompt,
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: const Icon(Icons.lock_open_rounded),
            label: const Text(
              'Sign In or Create Account to Continue',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(icon, color: _primary),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: _slate,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(label, style: const TextStyle(color: _muted, fontSize: 10.5)),
          ],
        ),
      ],
    ),
  );

  Widget _section(String title, IconData icon, Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _primary),
            const SizedBox(width: 9),
            Text(
              title,
              style: const TextStyle(
                color: _slate,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        child,
      ],
    ),
  );

  Widget _lockedSection({
    required String title,
    required String subtitle,
    required IconData icon,
  }) => InkWell(
    onTap: _authPrompt,
    borderRadius: BorderRadius.circular(22),
    child: Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _slate,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline_rounded, color: _muted),
        ],
      ),
    ),
  );
}

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return 'W';
  return parts.take(2).map((e) => e[0].toUpperCase()).join();
}
