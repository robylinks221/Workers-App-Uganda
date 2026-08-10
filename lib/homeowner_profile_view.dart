// ─────────────────────────────────────────────────────────────────────────────
// homeowner_profile_view.dart
//
// Public profile page — shown to a Worker when they tap a Homeowner's card
// or a job listing posted by that homeowner.
//
// USAGE
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => HomeownerProfileView(homeowner: someHomeownerModel),
//   ));
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Stand-alone preview ───────────────────────────────────────────────────────
void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maid App Uganda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD87C53)),
        useMaterial3: true,
      ),
      home: HomeownerProfileView(homeowner: _mockHomeowner),
    );
  }
}

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFF1FB8B3);
const Color _kDark = Color(0xFF0C2D4B);
const Color _kSlate = Color(0xFF164D7A);
const Color _kSubText = Color(0xFF617889);
const Color _kInputFill = Color(0xFFF2F7F8);
const Color _kHint = Color(0xFF8AA0AE);
const Color _kStar = Color(0xFFFFC107);
const Color _kGreen = Color(0xFF2ECC71);
const Color _kBorder = Color(0xFFE3ECEF);
const Color _kHeroLight = Color(0xFF1B7083);

// ── Homeowner data model ──────────────────────────────────────────────────────
class HomeownerModel {
  const HomeownerModel({
    required this.name,
    required this.location,
    required this.district,
    required this.memberSince,
    required this.totalHires,
    required this.repeatRate,
    required this.isVerified,
    required this.about,
    required this.activeJobs,
    required this.pastJobs,
    required this.avatarColor,
    required this.phone,
  });

  final String name;
  final String location; // street / area
  final String district;
  final String memberSince;
  final int totalHires;
  final int repeatRate; // % repeat hires
  final bool isVerified;
  final String about;
  final List<JobPost> activeJobs;
  final List<JobPost> pastJobs;
  final Color avatarColor;
  final String phone;
}

class JobPost {
  const JobPost({
    required this.title,
    required this.workType,
    required this.location,
    required this.postedAgo,
    required this.isOpen,
  });

  final String title;
  final String workType;
  final String location;
  final String postedAgo;
  final bool isOpen;
}

// ── Mock data ─────────────────────────────────────────────────────────────────
final _mockHomeowner = HomeownerModel(
  name: 'Sarah Namukasa',
  location: 'Ntinda',
  district: 'Kampala',
  memberSince: 'March 2023',
  totalHires: 12,
  repeatRate: 75,
  isVerified: true,
  about:
      'I am a working mother of two based in Ntinda, Kampala. I need a '
      'reliable, honest, and child-friendly maid who can help with cooking, '
      'cleaning, and taking care of my kids. I treat my workers with respect '
      'and pay on time every month.',
  avatarColor: const Color(0xFF6B8FA8),
  phone: '0772 123 456',
  activeJobs: const [
    JobPost(
      title: 'Full-Time Housekeeper Needed',
      workType: 'Full Time',
      location: 'Ntinda, Kampala',
      postedAgo: '2 days ago',
      isOpen: true,
    ),
    JobPost(
      title: 'Part-Time Cook (Mon–Fri)',
      workType: 'Part Time',
      location: 'Ntinda, Kampala',
      postedAgo: '5 days ago',
      isOpen: true,
    ),
  ],
  pastJobs: const [
    JobPost(
      title: 'Live-in Nanny',
      workType: 'Full Time',
      location: 'Ntinda, Kampala',
      postedAgo: '6 months ago',
      isOpen: false,
    ),
    JobPost(
      title: 'Weekend Cleaner',
      workType: 'Part Time',
      location: 'Ntinda, Kampala',
      postedAgo: '8 months ago',
      isOpen: false,
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// Homeowner Profile View
// ─────────────────────────────────────────────────────────────────────────────
class HomeownerProfileView extends StatelessWidget {
  const HomeownerProfileView({super.key, required this.homeowner});
  final HomeownerModel homeowner;

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ContactSheet(homeowner: homeowner),
    );
  }

  void _showApplySheet(BuildContext context, JobPost job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ApplySheet(homeowner: homeowner, job: job),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────────
          CustomScrollView(
            slivers: [
              // ── Hero header ─────────────────────────────────────────────────
              SliverToBoxAdapter(child: _HomeownerHero(homeowner: homeowner)),

              // ── White card body ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Profile overview ─────────────────────────────
                        const _SectionIntro(
                          title: 'Profile Overview',
                          subtitle:
                              'Check this homeowner’s history, trust details and available jobs.',
                        ),
                        const SizedBox(height: 16),

                        // ── Stats row ──────────────────────────────────────
                        _StatsRow(homeowner: homeowner),
                        const SizedBox(height: 24),

                        // ── Trust indicators ───────────────────────────────
                        _TrustBanner(homeowner: homeowner),
                        const SizedBox(height: 24),

                        // ── About ──────────────────────────────────────────
                        const _SectionTitle(title: 'About This Homeowner'),
                        const SizedBox(height: 10),
                        _ExpandableBio(bio: homeowner.about),
                        const SizedBox(height: 26),

                        // ── Active job postings ────────────────────────────
                        if (homeowner.activeJobs.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const _SectionTitle(title: 'Jobs Available Now'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _kGreen.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${homeowner.activeJobs.length} open',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _kGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...homeowner.activeJobs.map(
                            (job) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _JobCard(
                                job: job,
                                onApply: () => _showApplySheet(context, job),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // ── Past jobs ──────────────────────────────────────
                        if (homeowner.pastJobs.isNotEmpty) ...[
                          const _SectionTitle(title: 'Previous Jobs'),
                          const SizedBox(height: 12),
                          ...homeowner.pastJobs.map(
                            (job) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _JobCard(job: job),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // ── Worker tips card ───────────────────────────────
                        _WorkerTipsCard(homeowner: homeowner),

                        // Bottom padding for action bar
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Back + share buttons ────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleIconBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.maybePop(context),
                    ),
                    _CircleIconBtn(icon: Icons.share_rounded, onTap: () {}),
                  ],
                ),
              ),
            ),
          ),

          // ── Fixed bottom action bar ─────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomActionBar(
              homeowner: homeowner,
              onContact: () => _showContactSheet(context),
              onApply:
                  homeowner.activeJobs.isNotEmpty
                      ? () =>
                          _showApplySheet(context, homeowner.activeJobs.first)
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero header  (gradient background + large avatar centred)
// ─────────────────────────────────────────────────────────────────────────────
class _HomeownerHero extends StatelessWidget {
  const _HomeownerHero({required this.homeowner});
  final HomeownerModel homeowner;

  @override
  Widget build(BuildContext context) {
    final initials =
        homeowner.name
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();

    return Container(
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C2D4B), Color(0xFF155A74), Color(0xFF1FB8B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: 64,
            child: Icon(
              Icons.home_work_rounded,
              size: 190,
              color: Colors.white.withOpacity(0.055),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -55,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.045),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 54, 22, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HOMEOWNER PROFILE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9.5,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 18,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: homeowner.avatarColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    homeowner.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      height: 1.05,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                if (homeowner.isVerified) ...[
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.verified_rounded,
                                    color: Color(0xFF74E7D4),
                                    size: 22,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white70,
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${homeowner.location}, ${homeowner.district}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            Wrap(
                              spacing: 7,
                              runSpacing: 7,
                              children: [
                                _HeroTrustPill(
                                  icon: Icons.home_rounded,
                                  label: 'Homeowner',
                                ),
                                if (homeowner.isVerified)
                                  const _HeroTrustPill(
                                    icon: Icons.verified_user_rounded,
                                    label: 'Verified',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroMiniMetric(
                          value: '${homeowner.totalHires}',
                          label: 'Workers Hired',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HeroMiniMetric(
                          value: '${homeowner.repeatRate}%',
                          label: 'Repeat Hire',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HeroMiniMetric(
                          value: '${homeowner.activeJobs.length}',
                          label: 'Open Jobs',
                        ),
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

class _HeroTrustPill extends StatelessWidget {
  const _HeroTrustPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMiniMetric extends StatelessWidget {
  const _HeroMiniMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.homeowner});
  final HomeownerModel homeowner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _kInputFill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _StatCell(
            value: '${homeowner.totalHires}',
            label: 'Total Hires',
            icon: Icons.people_rounded,
            iconColor: _kPrimary,
          ),
          _divider(),
          _StatCell(
            value: '${homeowner.repeatRate}%',
            label: 'Repeat Hire',
            icon: Icons.refresh_rounded,
            iconColor: _kGreen,
          ),
          _divider(),
          _StatCell(
            value: '${homeowner.activeJobs.length}',
            label: 'Open Jobs',
            icon: Icons.work_outline_rounded,
            iconColor: _kSlate,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: _kBorder);
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _kSlate,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: _kSubText)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trust indicators banner
// ─────────────────────────────────────────────────────────────────────────────
class _TrustBanner extends StatelessWidget {
  const _TrustBanner({required this.homeowner});
  final HomeownerModel homeowner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kSlate.withOpacity(0.06), _kPrimary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trust & Safety',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kSlate,
            ),
          ),
          const SizedBox(height: 12),
          _TrustPoint(
            icon: Icons.verified_rounded,
            color: _kGreen,
            label: 'Verified Account',
            subtitle: 'Profile checked by Maids App',
          ),
          const SizedBox(height: 8),
          _TrustPoint(
            icon: Icons.history_rounded,
            color: _kPrimary,
            label: '${homeowner.totalHires} workers hired',
            subtitle: '${homeowner.repeatRate}% hire workers again',
          ),
          const SizedBox(height: 8),
          _TrustPoint(
            icon: Icons.calendar_month_rounded,
            color: _kSlate,
            label: 'Active since ${homeowner.memberSince}',
            subtitle: 'Account has hiring history',
          ),
        ],
      ),
    );
  }
}

class _TrustPoint extends StatelessWidget {
  const _TrustPoint({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kSlate,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11.5, color: _kSubText),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Job card
// ─────────────────────────────────────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, this.onApply});
  final JobPost job;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: job.isOpen ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: job.isOpen ? _kBorder : Colors.grey.shade200),
        boxShadow:
            job.isOpen
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
                : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      job.isOpen
                          ? _kPrimary.withOpacity(0.12)
                          : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.work_outline_rounded,
                  color: job.isOpen ? _kPrimary : Colors.grey,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: job.isOpen ? _kSlate : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _MiniChip(
                          label: job.workType,
                          color: job.isOpen ? _kPrimary : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          job.postedAgo,
                          style: const TextStyle(fontSize: 11, color: _kHint),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!job.isOpen)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Closed',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (job.isOpen && onApply != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: _kHint,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        job.location,
                        style: const TextStyle(fontSize: 12, color: _kSubText),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Worker tips card
// ─────────────────────────────────────────────────────────────────────────────
class _WorkerTipsCard extends StatelessWidget {
  const _WorkerTipsCard({required this.homeowner});
  final HomeownerModel homeowner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kPrimary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPrimary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: _kPrimary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Tips for applying to ${homeowner.name.split(' ').first}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kSlate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'Mention your experience with children or cooking in your message',
            'Include your availability and expected salary',
            'Be polite and professional — first impression matters',
          ].map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 5, right: 8),
                    decoration: const BoxDecoration(
                      color: _kPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: _kSubText,
                        height: 1.5,
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Bottom action bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.homeowner,
    required this.onContact,
    this.onApply,
  });
  final HomeownerModel homeowner;
  final VoidCallback onContact;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Contact / message button
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: onContact,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text(
                  'Message',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kPrimary,
                  side: const BorderSide(color: _kPrimary, width: 1.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
          if (onApply != null) ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'Apply for Job',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ContactSheet extends StatelessWidget {
  const _ContactSheet({required this.homeowner});
  final HomeownerModel homeowner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Contact ${homeowner.name.split(' ').first}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _kSlate,
            ),
          ),
          const SizedBox(height: 20),
          // Phone (masked)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kInputFill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color: _kPrimary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${homeowner.phone.substring(0, 4)}${'*' * (homeowner.phone.length - 4)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kSlate,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Apply first to reveal',
                  style: TextStyle(fontSize: 11, color: _kHint),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Message sent to ${homeowner.name.split(' ').first}!',
                    ),
                    backgroundColor: _kPrimary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_rounded, size: 18),
              label: const Text(
                'Send Message',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Apply bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ApplySheet extends StatefulWidget {
  const _ApplySheet({required this.homeowner, required this.job});
  final HomeownerModel homeowner;
  final JobPost job;

  @override
  State<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends State<_ApplySheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Apply: ${widget.job.title}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _kSlate,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Posted by ${widget.homeowner.name.split(' ').first} · ${widget.job.workType}',
              style: const TextStyle(fontSize: 12, color: _kSubText),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              maxLines: 4,
              minLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText:
                    'Introduce yourself and explain why you\'re a good fit...',
                hintStyle: const TextStyle(color: _kHint, fontSize: 13),
                filled: true,
                fillColor: _kInputFill,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: _kPrimary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Application sent to ${widget.homeowner.name.split(' ').first}!',
                      ),
                      backgroundColor: _kPrimary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text(
                  'Submit Application',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expandable bio
// ─────────────────────────────────────────────────────────────────────────────
class _ExpandableBio extends StatefulWidget {
  const _ExpandableBio({required this.bio});
  final String bio;

  @override
  State<_ExpandableBio> createState() => _ExpandableBioState();
}

class _ExpandableBioState extends State<_ExpandableBio> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.bio,
          maxLines: _expanded ? null : 3,
          overflow: _expanded ? null : TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13.5, color: _kSubText, height: 1.6),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Show less' : 'Read more',
            style: const TextStyle(
              color: _kPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable widgets
// ─────────────────────────────────────────────────────────────────────────────
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 12, color: _kGreen),
          SizedBox(width: 3),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 10,
              color: _kGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: _kPrimary,
            fontSize: 9.5,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: _kSubText,
            fontSize: 12.5,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: _kSlate,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  const _CircleIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero painter
// ─────────────────────────────────────────────────────────────────────────────
class _HeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg =
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF4F7089), Color(0xFF2A3D4E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    canvas.drawCircle(
      Offset(size.width + 20, -20),
      130,
      Paint()..color = Colors.white.withOpacity(0.07),
    );
    canvas.drawCircle(
      Offset(-20, size.height + 10),
      90,
      Paint()..color = Colors.white.withOpacity(0.06),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
