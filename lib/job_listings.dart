// ─────────────────────────────────────────────────────────────────────────────
// job_listings.dart
//
// Job Listings screen — workers browse open job posts from homeowners
// and apply with a short message.
//
// USAGE
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => const JobListingsScreen(),
//   ));
//
// PASTE INTO
//   lib/job_listings.dart   (standalone — no imports from other screens)
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD87C53)),
      useMaterial3: true,
      fontFamily: 'Roboto',
    ),
    home: const JobListingsScreen(),
  );
}

// ── Tokens ────────────────────────────────────────────────────────────────────
const Color _kPrimary    = Color(0xFFD87C53);
const Color _kPrimaryBg  = Color(0xFFFAEEE6);
const Color _kSlate      = Color(0xFF395264);
const Color _kSlateLight = Color(0xFF4F7089);
const Color _kSubText    = Color(0xFF5C7A8C);
const Color _kBorder     = Color(0xFFEAE0D8);
const Color _kMuted      = Color(0xFFB0A098);
const Color _kBg         = Color(0xFFF8F5F3);
const Color _kInputFill  = Color(0xFFFAEEE6);
const Color _kGreen      = Color(0xFF27AE60);
const Color _kGreenBg    = Color(0xFFE8F8EF);
const Color _kAmber      = Color(0xFFF39C12);
const Color _kAmberBg    = Color(0xFFFFF8EC);

// ── JobPost model ─────────────────────────────────────────────────────────────
class JobPost {
  const JobPost({
    required this.id,
    required this.homeownerName,
    required this.homeownerInitials,
    required this.homeownerColor,
    required this.homeownerDistrict,
    required this.isVerifiedHomeowner,
    required this.category,
    required this.categoryIcon,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.duration,
    required this.budget,
    required this.applicantCount,
    required this.postedAt,
    this.isUrgent = false,
  });
  final String   id;
  final String   homeownerName;
  final String   homeownerInitials;
  final Color    homeownerColor;
  final String   homeownerDistrict;
  final bool     isVerifiedHomeowner;
  final String   category;
  final IconData categoryIcon;
  final String   title;
  final String   description;
  final String   location;
  final String   startDate;
  final String   duration;
  final String   budget;
  final int      applicantCount;
  final String   postedAt;
  final bool     isUrgent;
}

// ── Mock listings ─────────────────────────────────────────────────────────────
final List<JobPost> _kJobs = [
  const JobPost(
    id: 'j1',
    homeownerName: 'Brian Mukasa',
    homeownerInitials: 'BM',
    homeownerColor: Color(0xFF4F7089),
    homeownerDistrict: 'Ntinda, Kampala',
    isVerifiedHomeowner: true,
    category: 'Cleaning',
    categoryIcon: Icons.cleaning_services_rounded,
    title: 'Full-time house cleaner needed',
    description: 'Looking for a reliable cleaner for our 4-bedroom home in Ntinda. Weekly deep cleaning plus daily tidying. Must be experienced with babies.',
    location: 'Ntinda, Kampala',
    startDate: 'Mon, 4 Aug 2025',
    duration: 'Full day (8 hrs)',
    budget: 'UGX 80,000/day',
    applicantCount: 3,
    postedAt: '20 min ago',
    isUrgent: true,
  ),
  const JobPost(
    id: 'j2',
    homeownerName: 'Joyce Namusoke',
    homeownerInitials: 'JN',
    homeownerColor: Color(0xFF8E44AD),
    homeownerDistrict: 'Muyenga, Kampala',
    isVerifiedHomeowner: false,
    category: 'Babysitting',
    categoryIcon: Icons.child_care_rounded,
    title: 'Babysitter for 2 children — weekday mornings',
    description: 'Need a caring and patient babysitter for my 3-year-old and 6-year-old every Monday to Friday from 7am to 12pm.',
    location: 'Muyenga, Kampala',
    startDate: 'Wed, 6 Aug 2025',
    duration: 'Half day (4 hrs)',
    budget: 'UGX 40,000/day',
    applicantCount: 7,
    postedAt: '3 hrs ago',
  ),
  const JobPost(
    id: 'j3',
    homeownerName: 'Patrick Kizza',
    homeownerInitials: 'PK',
    homeownerColor: Color(0xFF00B894),
    homeownerDistrict: 'Bugolobi, Kampala',
    isVerifiedHomeowner: true,
    category: 'Cooking',
    categoryIcon: Icons.restaurant_rounded,
    title: 'Daily cook for family of 5',
    description: 'Need someone to cook breakfast and dinner daily. Must know Ugandan cuisine well — matoke, groundnut stew, posho, etc. Long-term position.',
    location: 'Bugolobi, Kampala',
    startDate: 'Thu, 7 Aug 2025',
    duration: '2 hrs/day',
    budget: 'UGX 350,000/mo',
    applicantCount: 12,
    postedAt: '7 hrs ago',
  ),
  const JobPost(
    id: 'j4',
    homeownerName: 'Flavia Nakamya',
    homeownerInitials: 'FN',
    homeownerColor: Color(0xFFE17055),
    homeownerDistrict: 'Kira, Wakiso',
    isVerifiedHomeowner: true,
    category: 'Laundry',
    categoryIcon: Icons.local_laundry_service,
    title: 'Laundry + ironing twice a week',
    description: 'Looking for someone to handle all laundry and ironing for a family of 4 twice per week. Saturdays and Tuesdays preferred.',
    location: 'Kira, Wakiso',
    startDate: 'Flexible',
    duration: 'Half day (4 hrs)',
    budget: 'UGX 35,000/session',
    applicantCount: 2,
    postedAt: '1 day ago',
  ),
  const JobPost(
    id: 'j5',
    homeownerName: 'Ivan Tumwine',
    homeownerInitials: 'IT',
    homeownerColor: Color(0xFF27AE60),
    homeownerDistrict: 'Entebbe',
    isVerifiedHomeowner: true,
    category: 'Elder Care',
    categoryIcon: Icons.elderly_rounded,
    title: 'Carer for elderly parent — live-in',
    description: 'Seeking a compassionate and patient carer for my 78-year-old mother. Full-time live-in preferred. Must be gentle, experienced, and honest.',
    location: 'Entebbe',
    startDate: 'ASAP',
    duration: 'Live-in / Full Time',
    budget: 'UGX 500,000/mo',
    applicantCount: 5,
    postedAt: '2 days ago',
    isUrgent: true,
  ),
  const JobPost(
    id: 'j6',
    homeownerName: 'Sarah Ssali',
    homeownerInitials: 'SS',
    homeownerColor: Color(0xFFD87C53),
    homeownerDistrict: 'Kololo, Kampala',
    isVerifiedHomeowner: true,
    category: 'General Help',
    categoryIcon: Icons.home_repair_service_rounded,
    title: 'General housemaid — full time',
    description: 'Looking for a hardworking, trustworthy housemaid to handle cooking, cleaning, and childcare. Room and board provided.',
    location: 'Kololo, Kampala',
    startDate: 'Mon, 11 Aug 2025',
    duration: 'Full Time / Ongoing',
    budget: 'UGX 420,000/mo',
    applicantCount: 9,
    postedAt: '3 days ago',
  ),
];

// ── Categories ────────────────────────────────────────────────────────────────
const List<Map<String, dynamic>> _kCats = [
  {'icon': Icons.apps_rounded,               'label': 'All'},
  {'icon': Icons.cleaning_services_rounded,  'label': 'Cleaning'},
  {'icon': Icons.restaurant_rounded,         'label': 'Cooking'},
  {'icon': Icons.local_laundry_service,      'label': 'Laundry'},
  {'icon': Icons.child_care_rounded,         'label': 'Babysitting'},
  {'icon': Icons.elderly_rounded,            'label': 'Elder Care'},
  {'icon': Icons.home_repair_service_rounded,'label': 'General Help'},
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class JobListingsScreen extends StatefulWidget {
  const JobListingsScreen({super.key});
  @override
  State<JobListingsScreen> createState() => _JobListingsScreenState();
}

class _JobListingsScreenState extends State<JobListingsScreen> {
  int _catIndex = 0;
  bool _urgentOnly = false;
  final _searchCtrl = TextEditingController();
  String _query = '';
  final Set<String> _applied = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<JobPost> get _filtered {
    final q = _query.toLowerCase();
    return _kJobs.where((j) {
      final matchCat = _catIndex == 0 ||
          j.category == (_kCats[_catIndex]['label'] as String);
      final matchSearch = q.isEmpty ||
          j.title.toLowerCase().contains(q) ||
          j.location.toLowerCase().contains(q) ||
          j.category.toLowerCase().contains(q);
      final matchUrgent = !_urgentOnly || j.isUrgent;
      return matchCat && matchSearch && matchUrgent;
    }).toList();
  }

  void _openApply(JobPost job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ApplySheet(
        job: job,
        onApply: (msg) {
          setState(() => _applied.add(job.id));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Application sent! 🎉',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            backgroundColor: _kGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            duration: const Duration(seconds: 2),
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final filtered = _filtered;

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader()),

          // ── Category strip ──────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildCategoryStrip()),

          // ── Filter row ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(children: [
                Text('${filtered.length} Open Job${filtered.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kSlate)),
                const Spacer(),
                // Urgent toggle
                GestureDetector(
                  onTap: () => setState(() => _urgentOnly = !_urgentOnly),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _urgentOnly ? _kAmberBg : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _urgentOnly ? _kAmber : _kBorder),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.bolt_rounded,
                          size: 14,
                          color: _urgentOnly ? _kAmber : _kMuted),
                      const SizedBox(width: 4),
                      Text('Urgent',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _urgentOnly ? _kAmber : _kMuted)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),

          // ── Job list ────────────────────────────────────────────────────────
          filtered.isEmpty
              ? const SliverFillRemaining(child: _EmptyState())
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (_, i) => _JobCard(
                  job: filtered[i],
                  hasApplied: _applied.contains(filtered[i].id),
                  onApply: () => _openApply(filtered[i]),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F7089), Color(0xFF2A3D4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const Expanded(
                  child: Text('Browse Jobs',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${_kJobs.length} live',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 12),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search_rounded,
                        color: _kMuted, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                            fontSize: 14, color: _kSlate),
                        decoration: const InputDecoration(
                          hintText: 'Search by title, skill, location…',
                          hintStyle:
                          TextStyle(color: _kMuted, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.close_rounded,
                              size: 16, color: _kMuted),
                        ),
                      )
                    else
                      const SizedBox(width: 12),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category strip ───────────────────────────────────────────────────────────
  Widget _buildCategoryStrip() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        scrollDirection: Axis.horizontal,
        itemCount: _kCats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = _catIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _catIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? _kPrimary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: sel ? _kPrimary : _kBorder),
                boxShadow: sel
                    ? [
                  BoxShadow(
                      color: _kPrimary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]
                    : [],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_kCats[i]['icon'] as IconData,
                    size: 14,
                    color: sel ? Colors.white : _kSubText),
                const SizedBox(width: 5),
                Text(_kCats[i]['label'] as String,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : _kSubText)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Job Card
// ─────────────────────────────────────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.hasApplied,
    required this.onApply,
  });
  final JobPost  job;
  final bool     hasApplied;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: job.isUrgent
                ? _kAmber.withOpacity(0.4)
                : _kBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row ─────────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category icon
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: _kPrimaryBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(job.categoryIcon,
                          size: 20, color: _kPrimary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(job.title,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _kSlate),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            if (job.isUrgent) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _kAmberBg,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt_rounded,
                                          size: 11, color: _kAmber),
                                      SizedBox(width: 2),
                                      Text('Urgent',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: _kAmber)),
                                    ]),
                              ),
                            ],
                          ]),
                          const SizedBox(height: 4),
                          // Homeowner
                          Row(children: [
                            CircleAvatar(
                              radius: 9,
                              backgroundColor: job.homeownerColor,
                              child: Text(
                                job.homeownerInitials[0],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(job.homeownerName,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _kSubText)),
                            if (job.isVerifiedHomeowner) ...[
                              const SizedBox(width: 3),
                              const Icon(Icons.verified_rounded,
                                  size: 11, color: _kSlateLight),
                            ],
                            const Spacer(),
                            Text(job.postedAt,
                                style: const TextStyle(
                                    fontSize: 11, color: _kMuted)),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Description ──────────────────────────────────────────────
                Text(job.description,
                    style: const TextStyle(
                        fontSize: 13,
                        color: _kSubText,
                        height: 1.45),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),

                const SizedBox(height: 12),

                // ── Detail chips ─────────────────────────────────────────────
                Wrap(spacing: 8, runSpacing: 6, children: [
                  _Chip(
                      icon: Icons.location_on_rounded,
                      label: job.location),
                  _Chip(
                      icon: Icons.schedule_rounded,
                      label: job.duration),
                  _Chip(
                      icon: Icons.payments_rounded,
                      label: job.budget,
                      color: _kGreen,
                      bg: _kGreenBg),
                ]),

                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── Footer ──────────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: _kBg,
              borderRadius:
              BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(children: [
              // Applicants count
              Row(children: [
                const Icon(Icons.people_outline_rounded,
                    size: 14, color: _kMuted),
                const SizedBox(width: 4),
                Text(
                  '${job.applicantCount} applied',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kMuted),
                ),
              ]),
              const Spacer(),
              // Apply button
              GestureDetector(
                onTap: hasApplied ? null : onApply,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: hasApplied ? _kGreenBg : _kPrimary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: hasApplied
                        ? []
                        : [
                      BoxShadow(
                          color: _kPrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      hasApplied
                          ? Icons.check_rounded
                          : Icons.send_rounded,
                      size: 14,
                      color: hasApplied ? _kGreen : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasApplied ? 'Applied' : 'Apply Now',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: hasApplied ? _kGreen : Colors.white),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Apply Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ApplySheet extends StatefulWidget {
  const _ApplySheet({required this.job, required this.onApply});
  final JobPost          job;
  final ValueChanged<String> onApply;
  @override
  State<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends State<_ApplySheet> {
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  void _submit() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    widget.onApply(_msgCtrl.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: _kBorder,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Apply for this Job',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _kSlate)),
            const SizedBox(height: 4),
            Text(widget.job.title,
                style: const TextStyle(
                    fontSize: 13, color: _kSubText)),
            const SizedBox(height: 16),
            // Job summary pill row
            Wrap(spacing: 8, runSpacing: 6, children: [
              _Chip(
                  icon: Icons.payments_rounded,
                  label: widget.job.budget,
                  color: _kGreen,
                  bg: _kGreenBg),
              _Chip(
                  icon: Icons.schedule_rounded,
                  label: widget.job.duration),
            ]),
            const SizedBox(height: 18),
            const Text('Message to Homeowner',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kSlate)),
            const SizedBox(height: 8),
            TextField(
              controller: _msgCtrl,
              maxLines: 4,
              maxLength: 300,
              style: const TextStyle(fontSize: 14, color: _kSlate),
              decoration: InputDecoration(
                hintText:
                'Introduce yourself and explain why you\'re a great fit for this job…',
                hintStyle: const TextStyle(color: _kMuted, fontSize: 13),
                filled: true,
                fillColor: _kInputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _kPrimary.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _sending
                    ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Text('Send Application',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip helper + Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, this.color, this.bg});
  final IconData icon;
  final String   label;
  final Color?   color;
  final Color?   bg;

  @override
  Widget build(BuildContext context) {
    final col = color ?? _kSubText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg ?? _kBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: col),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: col)),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
                color: _kPrimaryBg,
                borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.work_off_rounded,
                size: 40, color: _kPrimary),
          ),
          const SizedBox(height: 20),
          const Text('No jobs found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kSlate)),
          const SizedBox(height: 8),
          const Text('Try adjusting your filters or search.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _kSubText)),
        ]),
      ),
    );
  }
}
