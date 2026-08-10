import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import 'worker_public_profile_screen.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({
    super.key,
    required this.role,
    required this.user,
    required this.profile,
  });

  final String role;
  final Map<String, dynamic> user;
  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    if (role == 'worker') {
      final workerId = int.tryParse(user['id']?.toString() ?? '') ?? 0;

      return WorkerPublicProfileScreen(workerId: workerId, previewMode: true);
    }

    return _HomeownerPreview(user: user, profile: profile);
  }
}

class _HomeownerPreview extends StatelessWidget {
  const _HomeownerPreview({required this.user, required this.profile});

  final Map<String, dynamic> user;
  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final name = user['full_name']?.toString() ?? 'Homeowner';
    final imageUrl = ApiConfig.storageUrl(
      user['profile_photo']?.toString() ?? profile['profile_photo']?.toString(),
    );
    final district =
        profile['district']?.toString() ??
        user['location']?.toString() ??
        'Not provided';
    final verified =
        user['is_verified'] == true || profile['identity_verified'] == true;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HomeownerHero(
                name: name,
                imageUrl: imageUrl,
                district: district,
                verified: verified,
                joinedAt: user['created_at'],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 115),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _PreviewNotice(),
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Contact Information',
                    icon: Icons.contact_phone_outlined,
                    items: [
                      _InfoItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user['email'],
                      ),
                      _InfoItem(
                        icon: Icons.phone_android_rounded,
                        label: 'Phone',
                        value: user['phone'],
                      ),
                      _InfoItem(
                        icon: Icons.chat_outlined,
                        label: 'Preferred Contact',
                        value: profile['preferred_contact'],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Location',
                    icon: Icons.location_on_outlined,
                    items: [
                      _InfoItem(
                        icon: Icons.location_city_outlined,
                        label: 'District',
                        value: profile['district'],
                      ),
                      _InfoItem(
                        icon: Icons.apartment_outlined,
                        label: 'City / Town',
                        value: profile['city'],
                      ),
                      _InfoItem(
                        icon: Icons.signpost_outlined,
                        label: 'Address',
                        value: profile['address'],
                      ),
                      _InfoItem(
                        icon: Icons.public_rounded,
                        label: 'Country',
                        value: profile['country'] ?? 'Uganda',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _AccountStatusCard(
                    verified: verified,
                    profileComplete:
                        user['profile_completed'] == true || profile.isNotEmpty,
                    joinedAt: user['created_at'],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeownerHero extends StatelessWidget {
  const _HomeownerHero({
    required this.name,
    required this.imageUrl,
    required this.district,
    required this.verified,
    required this.joinedAt,
  });

  final String name;
  final String imageUrl;
  final String district;
  final bool verified;
  final dynamic joinedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      padding: const EdgeInsets.fromLTRB(8, 10, 18, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF177989), _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -45,
            right: -45,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Profile Preview',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white24,
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child:
                      imageUrl.isEmpty
                          ? Text(
                            _initials(name),
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 13),
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
                  if (verified) ...[
                    const SizedBox(width: 7),
                    const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  const _HeroPill(icon: Icons.home_outlined, text: 'Homeowner'),
                  _HeroPill(icon: Icons.location_on_outlined, text: district),
                  if (_joined(joinedAt).isNotEmpty)
                    _HeroPill(
                      icon: Icons.schedule_rounded,
                      text: _joined(joinedAt),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.visibility_outlined, color: _primary),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'This is how workers see your homeowner profile.',
              style: TextStyle(color: _primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.24 : 0.09,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _primary),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(items.length, (index) {
            return _InfoRow(
              item: items[index],
              last: index == items.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final dynamic value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.item, required this.last});

  final _InfoItem item;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final value = item.value?.toString().trim() ?? '';

    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(item.icon, color: _primary, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not provided' : _label(value),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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

class _AccountStatusCard extends StatelessWidget {
  const _AccountStatusCard({
    required this.verified,
    required this.profileComplete,
    required this.joinedAt,
  });

  final bool verified;
  final bool profileComplete;
  final dynamic joinedAt;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Account Status',
      icon: Icons.verified_user_outlined,
      items: [
        _InfoItem(
          icon: verified ? Icons.verified_rounded : Icons.info_outline_rounded,
          label: 'Verification',
          value: verified ? 'Verified' : 'Pending Verification',
        ),
        _InfoItem(
          icon:
              profileComplete
                  ? Icons.check_circle_outline_rounded
                  : Icons.pending_outlined,
          label: 'Profile Completion',
          value: profileComplete ? 'Complete' : 'Incomplete',
        ),
        _InfoItem(
          icon: Icons.calendar_month_outlined,
          label: 'Member Since',
          value: _joinedDate(joinedAt),
        ),
      ],
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

String _label(String value) {
  if (value.trim().isEmpty) return 'Not provided';

  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) =>
            word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

String _joined(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return '';

  final days = DateTime.now().difference(date).inDays;

  if (days < 1) return 'Joined today';
  if (days == 1) return 'Joined yesterday';
  if (days < 30) return 'Joined $days days ago';
  if (days < 365) return 'Joined ${days ~/ 30} months ago';
  return 'Joined ${days ~/ 365} years ago';
}

String _joinedDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return 'Not available';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
