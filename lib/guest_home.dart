import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/api_config.dart';
import 'features/auth/screens/login_screen.dart';
import 'signup.dart';
import 'features/guest/guest_worker_profile_screen.dart';
import 'services/guest_marketplace_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF123F67);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);
const _bg = Color(0xFFF4F7FA);
const _border = Color(0xFFE7EDF2);

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  final GuestMarketplaceService _marketplace = GuestMarketplaceService();
  final TextEditingController _search = TextEditingController();
  Timer? _timer;

  List<Map<String, dynamic>> _workers = const [];
  List<Map<String, dynamic>> _categories = const [];
  bool _loading = true;
  String? _error;
  String _selectedService = '';

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
    setState(() {
      _loading = true;
      _error = null;
    });

    final results = await Future.wait([
      _marketplace.getCategories(),
      _marketplace.getWorkers(
        search: _search.text,
        service: _selectedService,
        perPage: 30,
      ),
    ]);

    if (!mounted) return;

    final cats = results[0];
    final workers = results[1];

    if (workers['success'] != true) {
      setState(() {
        _loading = false;
        _error = workers['message']?.toString() ?? 'Unable to load workers.';
      });
      return;
    }

    setState(() {
      _categories =
          cats['service_categories'] is List
              ? (cats['service_categories'] as List)
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : const [];
      _workers =
          workers['workers'] is List
              ? (workers['workers'] as List)
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : const [];
      _loading = false;
    });
  }

  void _searchChanged(String value) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 400), _load);
    setState(() {});
  }

  Future<void> _selectService(String slug) async {
    setState(() => _selectedService = _selectedService == slug ? '' : slug);
    await _load();
  }

  void _openWorker(Map<String, dynamic> worker) {
    final id = int.tryParse(worker['id']?.toString() ?? '');
    if (id == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GuestWorkerProfileScreen(workerId: id)),
    );
  }

  void _login() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));

  void _signup() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: RefreshIndicator(
          onRefresh: _load,
          color: _primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _hero()),
              SliverToBoxAdapter(child: _serviceBrowser()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 25, 18, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'APPROVED WORKERS',
                              style: TextStyle(
                                color: _primary,
                                fontSize: 10,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Explore trusted workers',
                              style: TextStyle(
                                color: _slate,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_workers.length} shown',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 70),
                    child: Center(
                      child: CircularProgressIndicator(color: _primary),
                    ),
                  ),
                )
              else if (_error != null)
                SliverToBoxAdapter(child: _errorState())
              else if (_workers.isEmpty)
                const SliverToBoxAdapter(child: _EmptyGuestWorkers())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 110),
                  sliver: SliverList.separated(
                    itemCount: _workers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 13),
                    itemBuilder:
                        (_, index) => _GuestWorkerCard(
                          worker: _workers[index],
                          onTap: () => _openWorker(_workers[index]),
                        ),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _login,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primary,
                      minimumSize: const Size.fromHeight(49),
                      side: const BorderSide(color: _primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _signup,
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(49),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: const Text(
                      'Create Account',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(18, top + 14, 18, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C2E4C), Color(0xFF155C76), _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WORKLINK AFRICA',
                      style: TextStyle(
                        color: Color(0xFFC7DFE8),
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Browse as Guest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _login,
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Find trusted help\nfor your home.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 31,
              height: 1.07,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Browse real approved workers before creating your account.',
            style: TextStyle(
              color: Color(0xFFD8E8EE),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.white,
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            child: TextField(
              controller: _search,
              onChanged: _searchChanged,
              decoration: InputDecoration(
                hintText: 'Search name, district or service',
                prefixIcon: const Icon(Icons.search_rounded, color: _primary),
                suffixIcon:
                    _search.text.isEmpty
                        ? null
                        : IconButton(
                          onPressed: () {
                            _search.clear();
                            _load();
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceBrowser() {
    if (_categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'What Help Do You Need?',
              style: TextStyle(
                color: _slate,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final c = _categories[index];
                final slug = c['slug']?.toString() ?? '';
                final selected = slug == _selectedService;
                return Material(
                  color: selected ? _primary : Colors.white,
                  elevation: selected ? 7 : 3,
                  shadowColor: _navy.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(19),
                  child: InkWell(
                    onTap: () => _selectService(slug),
                    borderRadius: BorderRadius.circular(19),
                    child: SizedBox(
                      width: 105,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 11,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _serviceIcon(c['icon']?.toString()),
                              color: selected ? Colors.white : _primary,
                              size: 25,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              c['name']?.toString() ?? 'Service',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selected ? Colors.white : _slate,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 65, 24, 130),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: _primary, size: 42),
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _GuestWorkerCard extends StatelessWidget {
  const _GuestWorkerCard({required this.worker, required this.onTap});
  final Map<String, dynamic> worker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photo = ApiConfig.storageUrl(worker['profile_photo']?.toString());
    final name = worker['full_name']?.toString() ?? 'Worker';
    final district = worker['district']?.toString() ?? '';
    final services =
        worker['services'] is List ? worker['services'] as List : const [];
    final rating = worker['rating']?.toString() ?? '0';

    return Material(
      color: Colors.white,
      elevation: 5,
      shadowColor: _navy.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              CircleAvatar(
                radius: 31,
                backgroundColor: _primary.withValues(alpha: 0.12),
                backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                child:
                    photo.isEmpty
                        ? Text(
                          _initials(name),
                          style: const TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _slate,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.verified_rounded,
                          color: _primary,
                          size: 17,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      district,
                      style: const TextStyle(color: _muted, fontSize: 11.5),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children:
                          services.take(2).map((raw) {
                            final s =
                                raw is Map
                                    ? raw['name']?.toString()
                                    : raw.toString();
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F8F8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                s ?? 'Service',
                                style: const TextStyle(
                                  color: _primary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB21A),
                        size: 15,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: const TextStyle(
                          color: _slate,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Icon(Icons.arrow_forward_rounded, color: _primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGuestWorkers extends StatelessWidget {
  const _EmptyGuestWorkers();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(24, 70, 24, 130),
    child: Column(
      children: [
        Icon(Icons.person_search_outlined, color: _primary, size: 46),
        SizedBox(height: 12),
        Text(
          'No approved workers found.',
          style: TextStyle(color: _slate, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return 'W';
  return parts.take(2).map((e) => e[0].toUpperCase()).join();
}

IconData _serviceIcon(String? icon) {
  switch (icon) {
    case 'cleaning_services':
      return Icons.cleaning_services_outlined;
    case 'local_laundry_service':
      return Icons.local_laundry_service_outlined;
    case 'child_care':
      return Icons.child_care_outlined;
    case 'restaurant':
      return Icons.restaurant_outlined;
    case 'home':
      return Icons.home_outlined;
    case 'elderly':
      return Icons.elderly_outlined;
    case 'yard':
      return Icons.yard_outlined;
    case 'security':
      return Icons.security_outlined;
    case 'directions_car':
      return Icons.directions_car_outlined;
    case 'pets':
      return Icons.pets_outlined;
    default:
      return Icons.work_outline_rounded;
  }
}
