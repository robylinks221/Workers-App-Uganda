// ─────────────────────────────────────────────────────────────────────────────
// applicants_list.dart
//
// Applicants List — homeowner reviews workers who applied for a posted job,
// can accept one or decline others.
//
// USAGE
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => ApplicantsListScreen(
//       jobTitle:    'Full-time house cleaner needed',
//       jobCategory: 'Cleaning',
//       jobBudget:   'UGX 80,000/day',
//       applicants:  myApplicantList,
//     ),
//   ));
//
// DEPENDENCIES
//   • worker_profile_view.dart  — WorkerModel (must be in same lib/ folder)
//
// PASTE INTO
//   lib/applicants_list.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'worker_profile_view.dart';

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
    home: ApplicantsListScreen(
      jobTitle:    'Full-time house cleaner needed',
      jobCategory: 'Cleaning',
      jobBudget:   'UGX 80,000/day',
      applicants:  _mockApplicants,
    ),
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
const Color _kStar       = Color(0xFFFFC107);
const Color _kGreen      = Color(0xFF27AE60);
const Color _kGreenBg    = Color(0xFFE8F8EF);
const Color _kRed        = Color(0xFFE74C3C);
const Color _kRedBg      = Color(0xFFFDECEB);

// ── Applicant model ───────────────────────────────────────────────────────────
enum ApplicantStatus { pending, accepted, declined }

class Applicant {
  Applicant({
    required this.worker,
    required this.message,
    required this.appliedAt,
    this.status = ApplicantStatus.pending,
  });
  final WorkerModel worker;
  final String      message;
  final String      appliedAt;
  ApplicantStatus   status;
}

// ── Mock applicants ───────────────────────────────────────────────────────────
final List<Applicant> _mockApplicants = [
  Applicant(
    worker: WorkerModel(
      name: 'Sarah Nakato', age: 28, location: 'Kamwokya, Kampala',
      religion: 'Christian', workType: 'Full Time', phone: '0772 345 678',
      bio: 'Experienced and trustworthy domestic worker. Specialises in deep cleaning, meal preparation, and childcare.',
      rating: 4.9, reviewCount: 42, jobsDone: 51, isVerified: true, isAvailable: true,
      skills: ['Cleaning', 'Cooking', 'Laundry', 'Child Care'],
      galleryColors: [const Color(0xFF6B8FA8), const Color(0xFF8B7355), const Color(0xFF7A9E7E)],
      avatarColor: const Color(0xFFD87C53),
    ),
    message: 'Hi! I have 6 years of experience in house cleaning and I am very reliable. I love working with families and I am great with children. I am available to start on Monday.',
    appliedAt: '15 min ago',
  ),
  Applicant(
    worker: WorkerModel(
      name: 'Harriet Babirye', age: 35, location: 'Bugolobi, Kampala',
      religion: 'Christian', workType: 'Full Time', phone: '0777 890 123',
      bio: '10 years experience with high-income families. Discreet, professional, and highly organised.',
      rating: 5.0, reviewCount: 87, jobsDone: 102, isVerified: true, isAvailable: true,
      skills: ['Cleaning', 'Cooking', 'Laundry', 'Ironing', 'Child Care'],
      galleryColors: [const Color(0xFF27AE60), const Color(0xFF6B8FA8), const Color(0xFFD87C53)],
      avatarColor: const Color(0xFF27AE60),
    ),
    message: 'Good day. I am a professional househelp with 10 years experience. I am honest, hard working, and very organized. I have excellent references from previous employers in Kampala.',
    appliedAt: '1 hr ago',
  ),
  Applicant(
    worker: WorkerModel(
      name: 'Fatuma Nalwoga', age: 22, location: 'Kawempe, Kampala',
      religion: 'Muslim', workType: 'Full Time', phone: '0785 678 901',
      bio: 'Reliable and hardworking cleaner available for full-time positions across Kampala.',
      rating: 4.5, reviewCount: 19, jobsDone: 22, isVerified: false, isAvailable: true,
      skills: ['Cleaning', 'Laundry'],
      galleryColors: [const Color(0xFF4F7089), const Color(0xFFD87C53), const Color(0xFF7A9E7E)],
      avatarColor: const Color(0xFF4F7089),
    ),
    message: 'Hello, I am interested in this position. I am a hardworking and reliable cleaner. I can start this week. Please consider my application.',
    appliedAt: '3 hrs ago',
  ),
  Applicant(
    worker: WorkerModel(
      name: 'Prossy Nansubuga', age: 26, location: 'Kireka, Kampala',
      religion: 'Christian', workType: 'Full Time', phone: '0771 002 345',
      bio: 'Energetic and dedicated househelp. Experienced in cleaning and general household tasks.',
      rating: 4.4, reviewCount: 14, jobsDone: 17, isVerified: true, isAvailable: true,
      skills: ['Cleaning', 'Gardening', 'Elder Care'],
      galleryColors: [const Color(0xFF8E44AD), const Color(0xFF6B8FA8), const Color(0xFF7A9E7E)],
      avatarColor: const Color(0xFF8E44AD),
    ),
    message: 'I saw your posting and I believe I am a good match. I am energetic, thorough, and trustworthy. I have been cleaning homes for 4 years now.',
    appliedAt: '5 hrs ago',
  ),
];

// ── Sort options ──────────────────────────────────────────────────────────────
enum _Sort { recent, topRated, mostExperienced }
extension _SortLabel on _Sort {
  String get label {
    switch (this) {
      case _Sort.recent:         return 'Most Recent';
      case _Sort.topRated:       return 'Top Rated';
      case _Sort.mostExperienced:return 'Most Experienced';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class ApplicantsListScreen extends StatefulWidget {
  const ApplicantsListScreen({
    super.key,
    required this.jobTitle,
    required this.jobCategory,
    required this.jobBudget,
    required this.applicants,
  });
  final String         jobTitle;
  final String         jobCategory;
  final String         jobBudget;
  final List<Applicant> applicants;

  @override
  State<ApplicantsListScreen> createState() => _ApplicantsListScreenState();
}

class _ApplicantsListScreenState extends State<ApplicantsListScreen> {
  late List<Applicant> _applicants;
  _Sort _sort = _Sort.recent;
  bool _oneAccepted = false;

  @override
  void initState() {
    super.initState();
    _applicants = List.from(widget.applicants);
  }

  List<Applicant> get _sorted {
    final list = List<Applicant>.from(_applicants);
    switch (_sort) {
      case _Sort.topRated:
        list.sort((a, b) => b.worker.rating.compareTo(a.worker.rating));
        break;
      case _Sort.mostExperienced:
        list.sort((a, b) => b.worker.jobsDone.compareTo(a.worker.jobsDone));
        break;
      case _Sort.recent:
        break; // already in order
    }
    return list;
  }

  int get _pendingCount =>
      _applicants.where((a) => a.status == ApplicantStatus.pending).length;

  void _accept(Applicant a) {
    setState(() {
      a.status = ApplicantStatus.accepted;
      _oneAccepted = true;
    });
    _showSnack(
        '${a.worker.name.split(' ').first} accepted! They\'ll be notified now.',
        _kGreen);
  }

  void _decline(Applicant a) {
    setState(() => a.status = ApplicantStatus.declined);
    _showSnack(
        '${a.worker.name.split(' ').first} declined.',
        _kMuted);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        current: _sort,
        onSelect: (s) => setState(() => _sort = s),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final sorted = _sorted;

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader()),

          // ── Accepted banner (when one is accepted) ──────────────────────────
          if (_oneAccepted)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kGreenBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kGreen.withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.check_circle_rounded,
                      color: _kGreen, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You\'ve accepted an applicant. They\'ve been notified and the job is filled.',
                      style: TextStyle(
                          fontSize: 13,
                          color: _kGreen,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ),
            ),

          // ── Count + sort ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(children: [
                Container(
                  width: 4, height: 18,
                  decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_pendingCount Pending · ${_applicants.length} Total',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _kSlate),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _showSortSheet,
                  child: Row(children: [
                    const Icon(Icons.sort_rounded,
                        size: 16, color: _kPrimary),
                    const SizedBox(width: 4),
                    Text(_sort.label,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kPrimary)),
                  ]),
                ),
              ]),
            ),
          ),

          // ── Applicant cards ─────────────────────────────────────────────────
          sorted.isEmpty
              ? const SliverFillRemaining(child: _EmptyState())
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (_, i) => _ApplicantCard(
                  applicant: sorted[i],
                  jobAccepted: _oneAccepted,
                  onViewProfile: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkerProfileView(
                          worker: sorted[i].worker),
                    ),
                  ),
                  onAccept: sorted[i].status == ApplicantStatus.pending
                      ? () => _accept(sorted[i])
                      : null,
                  onDecline:
                  sorted[i].status == ApplicantStatus.pending
                      ? () => _decline(sorted[i])
                      : null,
                ),
                childCount: sorted.length,
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
                const Text('Applicants',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.jobTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      _HeaderChip(widget.jobCategory),
                      const SizedBox(width: 8),
                      _HeaderChip(widget.jobBudget),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(label,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600)),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Applicant Card
// ─────────────────────────────────────────────────────────────────────────────
class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({
    required this.applicant,
    required this.jobAccepted,
    required this.onViewProfile,
    required this.onAccept,
    required this.onDecline,
  });
  final Applicant    applicant;
  final bool         jobAccepted;
  final VoidCallback onViewProfile;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final w = applicant.worker;
    final isAccepted = applicant.status == ApplicantStatus.accepted;
    final isDeclined = applicant.status == ApplicantStatus.declined;

    return AnimatedOpacity(
      opacity: isDeclined ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isAccepted
                ? _kGreen.withOpacity(0.4)
                : isDeclined
                ? _kBorder
                : _kBorder,
            width: isAccepted ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: isAccepted
                    ? _kGreen.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
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
                  // ── Worker info row ────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with availability dot
                      GestureDetector(
                        onTap: onViewProfile,
                        child: Stack(children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor:
                            w.avatarColor.withOpacity(0.15),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: w.avatarColor,
                              child: Text(
                                _initials(w.name),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                          if (w.isAvailable)
                            Positioned(
                              bottom: 1, right: 1,
                              child: Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  color: _kGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ]),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + verified + status badge
                            Row(children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: onViewProfile,
                                  child: Text(w.name,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: _kSlate),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              if (w.isVerified)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4, right: 6),
                                  child: Icon(Icons.verified_rounded,
                                      size: 14, color: _kSlateLight),
                                ),
                              // Status badge
                              if (isAccepted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _kGreenBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Accepted',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: _kGreen)),
                                )
                              else if (isDeclined)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _kRedBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Declined',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: _kRed)),
                                ),
                            ]),
                            const SizedBox(height: 3),
                            Row(children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 11, color: _kMuted),
                              const SizedBox(width: 3),
                              Text(w.location,
                                  style: const TextStyle(
                                      fontSize: 12, color: _kSubText)),
                            ]),
                            const SizedBox(height: 5),
                            // Rating + jobs + work type
                            Row(children: [
                              const Icon(Icons.star_rounded,
                                  size: 13, color: _kStar),
                              const SizedBox(width: 3),
                              Text(w.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _kSlate)),
                              const SizedBox(width: 4),
                              Text('(${w.reviewCount})',
                                  style: const TextStyle(
                                      fontSize: 11, color: _kMuted)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _kPrimaryBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(w.workType,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _kPrimary)),
                              ),
                              const Spacer(),
                              Text('${w.jobsDone} jobs done',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _kSubText)),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Skills ──────────────────────────────────────────────────
                  if (w.skills.isNotEmpty)
                    SizedBox(
                      height: 26,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: w.skills.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 6),
                        itemBuilder: (_, i) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: _kBg,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: _kBorder),
                          ),
                          child: Text(w.skills[i],
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: _kSubText)),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ── Application message ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _kBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.format_quote_rounded,
                              size: 14, color: _kPrimary),
                          const SizedBox(width: 4),
                          const Text('Application Message',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _kPrimary)),
                          const Spacer(),
                          Text(applicant.appliedAt,
                              style: const TextStyle(
                                  fontSize: 11, color: _kMuted)),
                        ]),
                        const SizedBox(height: 6),
                        Text(applicant.message,
                            style: const TextStyle(
                                fontSize: 13,
                                color: _kSubText,
                                height: 1.45)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── Action buttons ─────────────────────────────────────────────────
            if (!isAccepted && !isDeclined)
              Container(
                decoration: const BoxDecoration(
                  color: _kBg,
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(18)),
                ),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Row(children: [
                  // View profile
                  GestureDetector(
                    onTap: onViewProfile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kBorder),
                      ),
                      child: const Text('View Profile',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kSlate)),
                    ),
                  ),
                  const Spacer(),
                  // Decline
                  GestureDetector(
                    onTap: jobAccepted ? null : onDecline,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kBorder),
                      ),
                      child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close_rounded,
                                size: 14, color: _kSubText),
                            SizedBox(width: 5),
                            Text('Decline',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _kSubText)),
                          ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Accept
                  GestureDetector(
                    onTap: jobAccepted ? null : onAccept,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: jobAccepted
                            ? _kGreen.withOpacity(0.3)
                            : _kGreen,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: jobAccepted
                            ? []
                            : [
                          BoxShadow(
                              color: _kGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded,
                                size: 14, color: Colors.white),
                            SizedBox(width: 5),
                            Text('Accept',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ]),
                    ),
                  ),
                ]),
              )
            else if (isAccepted)
              Container(
                decoration: const BoxDecoration(
                  color: _kGreenBg,
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(18)),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 16, color: _kGreen),
                    SizedBox(width: 8),
                    Text('Worker accepted — job filled!',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kGreen)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sort Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current, required this.onSelect});
  final _Sort current;
  final ValueChanged<_Sort> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Sort Applicants By',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _kSlate)),
          ),
          const SizedBox(height: 16),
          ..._Sort.values.map((opt) {
            final sel = opt == current;
            return GestureDetector(
              onTap: () {
                onSelect(opt);
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: sel ? _kPrimaryBg : _kBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sel ? _kPrimary : _kBorder,
                      width: sel ? 1.5 : 1),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(opt.label,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: sel
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: sel ? _kPrimary : _kSlate)),
                  ),
                  if (sel)
                    const Icon(Icons.check_rounded,
                        size: 18, color: _kPrimary),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                  color: _kPrimaryBg,
                  borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.people_outline_rounded,
                  size: 40, color: _kPrimary),
            ),
            const SizedBox(height: 20),
            const Text('No applicants yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kSlate)),
            const SizedBox(height: 8),
            const Text(
                'Workers who apply will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _kSubText)),
          ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper
// ─────────────────────────────────────────────────────────────────────────────
String _initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

