import 'dart:async';
import 'package:flutter/material.dart';

enum TipAudience { homeowner, worker }

const _navy = Color(0xFF164D7A);
const _teal = Color(0xFF1FB8B3);

class SmartTip {
  const SmartTip(this.category, this.title, this.message, this.icon);
  final String category;
  final String title;
  final String message;
  final IconData icon;
}

const homeownerTips = <SmartTip>[
  SmartTip(
    'Hiring Safety',
    'Verify before hiring',
    'Review the worker profile, verification status and National ID information before confirming a request.',
    Icons.verified_user_outlined,
  ),
  SmartTip(
    'Work Agreement',
    'Agree on duties early',
    'Discuss salary, duties, working hours, meals, accommodation, days off and the start date before work begins.',
    Icons.assignment_turned_in_outlined,
  ),
  SmartTip(
    'Communication',
    'Keep agreements in the app',
    'Use in-app messages for important discussions so both parties can refer back to them later.',
    Icons.forum_outlined,
  ),
  SmartTip(
    'Payments',
    'Avoid risky advance payments',
    'Do not send money before confirming the worker, the job details and the reason for the payment.',
    Icons.payments_outlined,
  ),
  SmartTip(
    'Respect',
    'Create a respectful workplace',
    'Use respectful language, provide reasonable rest and maintain a safe working environment.',
    Icons.volunteer_activism_outlined,
  ),
  SmartTip(
    'Privacy',
    'Protect private information',
    'Never request passwords, verification codes or access to another user’s private account.',
    Icons.privacy_tip_outlined,
  ),
];

const workerTips = <SmartTip>[
  SmartTip(
    'Scam Prevention',
    'Never pay to receive a job',
    'Do not pay anyone who promises guaranteed employment, profile approval or special access to homeowners.',
    Icons.gpp_bad_outlined,
  ),
  SmartTip(
    'Work Agreement',
    'Confirm every important detail',
    'Confirm the location, duties, salary, working hours, meals, accommodation and days off before accepting.',
    Icons.fact_check_outlined,
  ),
  SmartTip(
    'Personal Safety',
    'Tell someone where you are going',
    'Share the workplace location and homeowner details with someone you trust before travelling.',
    Icons.health_and_safety_outlined,
  ),
  SmartTip(
    'Profile',
    'Keep your profile updated',
    'Update your availability, services, bio, location and gallery so homeowners see correct information.',
    Icons.manage_accounts_outlined,
  ),
  SmartTip(
    'Account Security',
    'Protect your password and codes',
    'Never share your password, PIN or verification code with anyone.',
    Icons.lock_outline_rounded,
  ),
  SmartTip(
    'Professionalism',
    'Communicate clearly',
    'Respond politely, arrive as agreed and explain early when your availability changes.',
    Icons.record_voice_over_outlined,
  ),
];

class DashboardSmartTipsCard extends StatefulWidget {
  const DashboardSmartTipsCard({
    super.key,
    required this.audience,
    this.margin = const EdgeInsets.fromLTRB(18, 18, 18, 0),
  });

  final TipAudience audience;
  final EdgeInsetsGeometry margin;

  @override
  State<DashboardSmartTipsCard> createState() => _DashboardSmartTipsCardState();
}

class _DashboardSmartTipsCardState extends State<DashboardSmartTipsCard> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  List<SmartTip> get tips =>
      widget.audience == TipAudience.homeowner ? homeownerTips : workerTips;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.animateToPage(
        (_index + 1) % tips.length,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.34 : 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_navy, Color(0xFF177989), _teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -45,
              right: -35,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.tips_and_updates_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Smart Tips for You',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              widget.audience == TipAudience.homeowner
                                  ? 'Safer hiring and a better home'
                                  : 'Safer work and better opportunities',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'TIP OF THE DAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 124,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: tips.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (_, i) => _TipSlide(tip: tips[i]),
                    ),
                  ),
                  Row(
                    children: [
                      ...List.generate(
                        tips.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: i == _index ? 20 : 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color:
                                i == _index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.38),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => TipsAndSafetyScreen(
                                    audience: widget.audience,
                                  ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.13),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                        label: const Text('View All Tips'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipSlide extends StatelessWidget {
  const _TipSlide({required this.tip});
  final SmartTip tip;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(tip.icon, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tip.category.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFD7FFFB),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tip.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tip.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11.8,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TipsAndSafetyScreen extends StatelessWidget {
  const TipsAndSafetyScreen({super.key, required this.audience});

  final TipAudience audience;

  @override
  Widget build(BuildContext context) {
    final tips = audience == TipAudience.homeowner ? homeownerTips : workerTips;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              padding: const EdgeInsets.fromLTRB(8, 10, 18, 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_navy, Color(0xFF177989), _teal],
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
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.health_and_safety_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tips & Safety',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          audience == TipAudience.homeowner
                              ? 'Helpful guidance for safe and respectful hiring.'
                              : 'Helpful guidance for safe and professional work.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 100),
                itemCount: tips.length,
                separatorBuilder: (_, __) => const SizedBox(height: 13),
                itemBuilder: (_, i) => _TipCard(tip: tips[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});
  final SmartTip tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.25 : 0.09,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF177989), _teal],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(tip.icon, color: Colors.white),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.category.toUpperCase(),
                  style: const TextStyle(
                    color: _teal,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  tip.message,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12.5,
                    height: 1.5,
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
