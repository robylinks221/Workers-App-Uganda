import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config/api_config.dart';
import 'job_chat_launcher.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);
const _deepNavy = Color(0xFF0C2D4B);
const _muted = Color(0xFF617889);
const _page = Color(0xFFF4F7FA);
const _border = Color(0xFFE4ECEF);
const _green = Color(0xFF1F9D68);

class HomeownerPublicProfileScreen extends StatelessWidget {
  const HomeownerPublicProfileScreen({
    super.key,
    required this.homeowner,
    required this.jobId,
    required this.fallbackDistrict,
  });

  final Map<String, dynamic> homeowner;
  final int jobId;
  final String fallbackDistrict;

  @override
  Widget build(BuildContext context) {
    final name = _text(
      homeowner['full_name'],
      'Homeowner',
    );

    final district = _text(
      homeowner['district'] ??
          homeowner['location'],
      fallbackDistrict,
    );

    final photoUrl = ApiConfig.storageUrl(
      homeowner['profile_photo']?.toString(),
    );

    final phone = _text(
      homeowner['phone'],
    );

    final verified =
        homeowner['is_verified'] == true ||
        homeowner['verified'] == true;

    final createdAt = _text(
      homeowner['created_at'],
    );

    final memberSince =
        _memberSince(createdAt);

    return Scaffold(
      backgroundColor: _page,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _PremiumHomeownerHero(
                  name: name,
                  district: district,
                  photoUrl: photoUrl,
                  verified: verified,
                  memberSince: memberSince,
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      130,
                    ),
                    child: Column(
                      children: [
                        _QuickTrustCard(
                          verified: verified,
                          district: district,
                          memberSince: memberSince,
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          eyebrow: 'ABOUT',
                          title: 'About This Homeowner',
                          subtitle:
                              'Know who posted the job before you apply or start a conversation.',
                          child: Text(
                            _aboutText(
                              homeowner,
                              name,
                              district,
                            ),
                            style: const TextStyle(
                              color: _muted,
                              height: 1.55,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          eyebrow: 'JOB SAFETY',
                          title: 'Before You Accept Work',
                          subtitle:
                              'Use the app to confirm the job details clearly.',
                          child: const Column(
                            children: [
                              _SafetyPoint(
                                icon:
                                    Icons.location_on_outlined,
                                text:
                                    'Confirm the exact work location.',
                              ),
                              SizedBox(height: 11),
                              _SafetyPoint(
                                icon:
                                    Icons.payments_outlined,
                                text:
                                    'Agree on salary or payment before starting.',
                              ),
                              SizedBox(height: 11),
                              _SafetyPoint(
                                icon:
                                    Icons.schedule_outlined,
                                text:
                                    'Confirm work days, hours and duties.',
                              ),
                              SizedBox(height: 11),
                              _SafetyPoint(
                                icon:
                                    Icons.chat_bubble_outline_rounded,
                                text:
                                    'Keep important job discussions in the app.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: _primary.withValues(
                              alpha: 0.07,
                            ),
                            borderRadius:
                                BorderRadius.circular(22),
                          ),
                          child: const Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: _primary,
                                size: 22,
                              ),
                              SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stay Safe',
                                      style: TextStyle(
                                        color: _navy,
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Do not send money to secure a job. Meet in a safe place and report anything suspicious.',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 11.5,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  8,
                  14,
                  0,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    _GlassAction(
                      icon:
                          Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onTap: () =>
                          Navigator.of(context).maybePop(),
                    ),
                    const _ProfileLabel(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          _HomeownerProfileActions(
        onMessage: () =>
            JobChatLauncher.open(
          context: context,
          jobId: jobId,
        ),
        onCall:
            phone.isEmpty
                ? () =>
                    _phoneUnavailable(context)
                : () =>
                    _call(context, phone),
        phoneAvailable: phone.isNotEmpty,
      ),
    );
  }

  Future<void> _call(
    BuildContext context,
    String phone,
  ) async {
    final uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (!await launchUrl(uri)) {
      if (context.mounted) {
        _phoneUnavailable(context);
      }
    }
  }

  void _phoneUnavailable(
    BuildContext context,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'The homeowner phone number is not available yet.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }
}

class _PremiumHomeownerHero
    extends StatelessWidget {
  const _PremiumHomeownerHero({
    required this.name,
    required this.district,
    required this.photoUrl,
    required this.verified,
    required this.memberSince,
  });

  final String name;
  final String district;
  final String photoUrl;
  final bool verified;
  final String memberSince;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 355,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _deepNavy,
            Color(0xFF155A74),
            _primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: 70,
            child: Icon(
              Icons.home_work_rounded,
              size: 210,
              color: Colors.white.withValues(
                alpha: 0.05,
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -70,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.04,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                22,
                72,
                22,
                50,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 104,
                    height: 104,
                    padding:
                        const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withValues(
                            alpha: 0.20,
                          ),
                          blurRadius: 24,
                          offset:
                              const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child:
                          photoUrl.isNotEmpty
                              ? Image.network(
                                photoUrl,
                                fit:
                                    BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        _InitialAvatar(
                                  name: name,
                                ),
                              )
                              : _InitialAvatar(
                                name: name,
                              ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 2,
                          textAlign:
                              TextAlign.center,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            height: 1.05,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                      if (verified) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          color:
                              Color(0xFF7BE5D6),
                          size: 22,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          district.isEmpty
                              ? 'Uganda'
                              : district,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white
                                .withValues(
                              alpha: 0.84,
                            ),
                            fontSize: 12.5,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Wrap(
                    alignment:
                        WrapAlignment.center,
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      const _HeroPill(
                        icon:
                            Icons.home_rounded,
                        label: 'Homeowner',
                      ),
                      if (verified)
                        const _HeroPill(
                          icon: Icons
                              .verified_user_rounded,
                          label:
                              'Verified Account',
                        ),
                      if (memberSince.isNotEmpty)
                        _HeroPill(
                          icon: Icons
                              .calendar_month_outlined,
                          label: memberSince,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialAvatar
    extends StatelessWidget {
  const _InitialAvatar({
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _primary.withValues(
        alpha: 0.16,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: const TextStyle(
          color: _navy,
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.13,
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTrustCard
    extends StatelessWidget {
  const _QuickTrustCard({
    required this.verified,
    required this.district,
    required this.memberSince,
  });

  final bool verified;
  final String district;
  final String memberSince;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'PROFILE OVERVIEW',
            style: TextStyle(
              color: _primary,
              fontSize: 9.5,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Know who posted the job',
            style: TextStyle(
              color: _navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Check the homeowner’s trust details before you apply or discuss work.',
            style: TextStyle(
              color: _muted,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TrustMetric(
                  icon:
                      verified
                          ? Icons
                              .verified_user_rounded
                          : Icons
                              .person_outline_rounded,
                  value:
                      verified
                          ? 'Verified'
                          : 'Profile',
                  label:
                      verified
                          ? 'Account Check'
                          : 'Homeowner',
                  accent:
                      verified
                          ? _green
                          : _navy,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TrustMetric(
                  icon: Icons
                      .location_on_outlined,
                  value:
                      district.isEmpty
                          ? 'Uganda'
                          : district,
                  label: 'Location',
                  accent: _primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustMetric
    extends StatelessWidget {
  const _TrustMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: accent,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _navy,
              fontSize: 12,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard
    extends StatelessWidget {
  const _SectionCard({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: _primary,
              fontSize: 9,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: _muted,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}

class _SafetyPoint
    extends StatelessWidget {
  const _SafetyPoint({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _primary.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: _primary,
            size: 17,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
              top: 7,
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.4,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeownerProfileActions
    extends StatelessWidget {
  const _HomeownerProfileActions({
    required this.onMessage,
    required this.onCall,
    required this.phoneAvailable,
  });

  final VoidCallback onMessage;
  final VoidCallback onCall;
  final bool phoneAvailable;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 18,
      shadowColor:
          Colors.black.withValues(
        alpha: 0.15,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            14,
            10,
            14,
            11,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor: _navy,
                    minimumSize:
                        const Size.fromHeight(
                      50,
                    ),
                    side: BorderSide(
                      color:
                          phoneAvailable
                              ? _border
                              : _border,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        17,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons.call_outlined,
                    size: 19,
                  ),
                  label: const Text(
                    'Call',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: onMessage,
                  style:
                      FilledButton.styleFrom(
                    backgroundColor:
                        _primary,
                    minimumSize:
                        const Size.fromHeight(
                      50,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        17,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons
                        .chat_bubble_outline_rounded,
                    size: 19,
                  ),
                  label: const Text(
                    'Message Homeowner',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassAction
    extends StatelessWidget {
  const _GlassAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color:
            Colors.black.withValues(
          alpha: 0.26,
        ),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileLabel
    extends StatelessWidget {
  const _ProfileLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
            Colors.black.withValues(
          alpha: 0.24,
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: const Text(
        'HOMEOWNER',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8.5,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _aboutText(
  Map<String, dynamic> homeowner,
  String name,
  String district,
) {
  final about = _text(
    homeowner['about'] ??
        homeowner['bio'] ??
        homeowner['description'],
  );

  if (about.isNotEmpty) {
    return about;
  }

  final firstName =
      name.trim().split(RegExp(r'\s+')).first;

  if (district.isNotEmpty) {
    return '$firstName is a homeowner in $district. This profile is connected to the job you are viewing. Use the in-app message feature to discuss the work before making any agreement.';
  }

  return '$firstName posted the job you are viewing. Use the in-app message feature to discuss the work before making any agreement.';
}

String _memberSince(String raw) {
  final date = DateTime.tryParse(raw)?.toLocal();

  if (date == null) {
    return '';
  }

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

  return 'Since ${months[date.month - 1]} ${date.year}';
}

String _text(
  dynamic value, [
  String fallback = '',
]) {
  final text =
      value?.toString().trim() ?? '';

  return text.isEmpty
      ? fallback
      : text;
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where(
        (part) => part.isNotEmpty,
      )
      .toList();

  if (parts.isEmpty) {
    return 'H';
  }

  return parts
      .take(2)
      .map(
        (part) =>
            part[0].toUpperCase(),
      )
      .join();
}
