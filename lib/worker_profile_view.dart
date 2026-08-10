// ─────────────────────────────────────────────────────────────────────────────
// worker_profile_view.dart
//
// Public profile page — shown to a Homeowner when they tap a Worker's card.
//
// USAGE
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => WorkerProfileView(worker: someWorkerModel),
//   ));
//
// The top section is a full-width auto-sliding image gallery (the 3 photos
// the worker uploaded during onboarding).  Below is all their profile info,
// ratings, contact buttons, etc.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'all_reviews.dart';

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
      home: WorkerProfileView(worker: _mockWorker),
    );
  }
}

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color _kPrimary   = Color(0xFFD87C53);
const Color _kDark      = Color(0xFF2A3D4E);
const Color _kSlate     = Color(0xFF395264);
const Color _kSubText   = Color(0xFF5C7A8C);
const Color _kInputFill = Color(0xFFFAEEE6);
const Color _kHint      = Color(0xFFB0A098);
const Color _kStar      = Color(0xFFFFC107);
const Color _kGreen     = Color(0xFF2ECC71);
const Color _kBorder    = Color(0xFFEEE6E0);

// ── Review model (shared with all_reviews.dart & write_review.dart) ──────────
class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.reviewerName,
    required this.reviewerInitials,
    required this.reviewerColor,
    required this.rating,
    required this.text,
    required this.postedAt,
  });
  final String   id;
  final String   reviewerName;
  final String   reviewerInitials;
  final Color    reviewerColor;
  final int      rating;      // 1–5
  final String   text;
  final DateTime postedAt;

  String get timeAgo {
    final diff = DateTime.now().difference(postedAt);
    if (diff.inMinutes < 60)  return '${diff.inMinutes} min ago';
    if (diff.inHours   < 24)  return '${diff.inHours} hours ago';
    if (diff.inDays    < 7)   return '${diff.inDays} days ago';
    if (diff.inDays    < 30)  return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays    < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }
}

// ── Mock reviews ─────────────────────────────────────────────────────────────
final List<ReviewModel> _mockReviews = [
  ReviewModel(
    id: 'r1',
    reviewerName: 'Joyce Mutebi',
    reviewerInitials: 'JM',
    reviewerColor: const Color(0xFF6C5CE7),
    rating: 5,
    text: 'Annet is very hardworking and trustworthy. My house was spotless after every session. She also handled the kids brilliantly. Highly recommend!',
    postedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  ReviewModel(
    id: 'r2',
    reviewerName: 'Patrick Kizza',
    reviewerInitials: 'PK',
    reviewerColor: const Color(0xFF00B894),
    rating: 5,
    text: 'Good worker, always on time. Cooked well and kept the children entertained. She is reliable and honest.',
    postedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  ReviewModel(
    id: 'r3',
    reviewerName: 'Sarah Nakato',
    reviewerInitials: 'SN',
    reviewerColor: const Color(0xFFD87C53),
    rating: 4,
    text: 'Very polite and careful with our belongings. Will definitely hire again. She cleaned even the areas I usually forget.',
    postedAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  ReviewModel(
    id: 'r4',
    reviewerName: 'David Ssemwogerere',
    reviewerInitials: 'DS',
    reviewerColor: const Color(0xFF4F7089),
    rating: 5,
    text: 'Best house help I have ever had. Professional and very respectful. My family loves her.',
    postedAt: DateTime.now().subtract(const Duration(days: 18)),
  ),
  ReviewModel(
    id: 'r5',
    reviewerName: 'Grace Auma',
    reviewerInitials: 'GA',
    reviewerColor: const Color(0xFFE17055),
    rating: 4,
    text: 'She did a great job overall. Laundry and ironing were done perfectly. Cooking was decent but could improve on seasoning.',
    postedAt: DateTime.now().subtract(const Duration(days: 25)),
  ),
  ReviewModel(
    id: 'r6',
    reviewerName: 'Robert Mugisha',
    reviewerInitials: 'RM',
    reviewerColor: const Color(0xFF0984E3),
    rating: 5,
    text: 'Very thorough cleaner. She reorganised my kitchen and it has never looked better. Highly recommended for any home.',
    postedAt: DateTime.now().subtract(const Duration(days: 35)),
  ),
  ReviewModel(
    id: 'r7',
    reviewerName: 'Flavia Nakamya',
    reviewerInitials: 'FN',
    reviewerColor: const Color(0xFF8E44AD),
    rating: 3,
    text: 'She was okay, came on time and did the cleaning. But she was not very experienced with childcare. Still a good worker overall.',
    postedAt: DateTime.now().subtract(const Duration(days: 50)),
  ),
  ReviewModel(
    id: 'r8',
    reviewerName: 'Ivan Tumwine',
    reviewerInitials: 'IT',
    reviewerColor: const Color(0xFF27AE60),
    rating: 5,
    text: 'Exceptional. She treated our home like it was her own. Every corner was clean, meals were great, and our kids adore her.',
    postedAt: DateTime.now().subtract(const Duration(days: 60)),
  ),
];

// ── Worker data model ─────────────────────────────────────────────────────────
class WorkerModel {
  const WorkerModel({
    required this.name,
    required this.age,
    required this.location,
    required this.religion,
    required this.workType,
    required this.phone,
    required this.bio,
    required this.rating,
    required this.reviewCount,
    required this.jobsDone,
    required this.isVerified,
    required this.isAvailable,
    required this.skills,
    required this.galleryColors, // In real app: List<String> image paths
    required this.avatarColor,
  });

  final String       name;
  final int          age;
  final String       location;
  final String       religion;
  final String       workType;   // 'Full Time' | 'Part Time'
  final String       phone;
  final String       bio;
  final double       rating;
  final int          reviewCount;
  final int          jobsDone;
  final bool         isVerified;
  final bool         isAvailable;
  final List<String> skills;
  final List<Color>  galleryColors; // placeholder colours until real images
  final Color        avatarColor;
}

// ── Mock data for preview ─────────────────────────────────────────────────────
final _mockWorker = WorkerModel(
  name:          'Annet Nakato',
  age:           27,
  location:      'Ntinda, Kampala',
  religion:      'Christian',
  workType:      'Full Time',
  phone:         '0772 345 678',
  bio:           'Experienced house cleaner and nanny with 5+ years working '
      'in Kampala. I am honest, reliable, and love children. '
      'I can cook, clean, and handle laundry.',
  rating:        4.8,
  reviewCount:   34,
  jobsDone:      41,
  isVerified:    true,
  isAvailable:   true,
  skills:        ['Cleaning', 'Cooking', 'Laundry', 'Child Care', 'Ironing'],
  galleryColors: [
    const Color(0xFF6B8FA8),
    const Color(0xFF8B7355),
    const Color(0xFF7A9E7E),
  ],
  avatarColor: const Color(0xFF4F7089),
);

// ─────────────────────────────────────────────────────────────────────────────
// Worker Profile View
// ─────────────────────────────────────────────────────────────────────────────
class WorkerProfileView extends StatefulWidget {
  const WorkerProfileView({super.key, required this.worker});
  final WorkerModel worker;

  @override
  State<WorkerProfileView> createState() => _WorkerProfileViewState();
}

class _WorkerProfileViewState extends State<WorkerProfileView> {
  final PageController _pageCtrl = PageController();
  int  _currentSlide = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentSlide + 1) % widget.worker.galleryColors.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _showHireSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HireSheet(worker: widget.worker),
    );
  }

  void _showMessageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MessageSheet(worker: widget.worker),
    );
  }

  void _showWriteReviewSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _WriteReviewSheet(worker: widget.worker),
    );
  }

  void _openAllReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllReviewsScreen(
          worker:  widget.worker,
          reviews: _mockReviews,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────────
          CustomScrollView(
            slivers: [

              // ── Gallery slider header ───────────────────────────────────────
              SliverToBoxAdapter(
                child: _GalleryHeader(
                  worker:       widget.worker,
                  pageCtrl:     _pageCtrl,
                  currentSlide: _currentSlide,
                  onPageChanged: (i) => setState(() => _currentSlide = i),
                ),
              ),

              // ── Profile card ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Name row + availability badge ───────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(
                                      widget.worker.name,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: _kSlate,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    if (widget.worker.isVerified) ...[
                                      const SizedBox(width: 6),
                                      const _VerifiedBadge(),
                                    ],
                                  ]),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    const Icon(Icons.location_on_rounded,
                                        size: 13, color: _kHint),
                                    const SizedBox(width: 3),
                                    Text(
                                      widget.worker.location,
                                      style: const TextStyle(
                                          fontSize: 13, color: _kSubText),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                            _AvailabilityBadge(
                                available: widget.worker.isAvailable),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Stats row ───────────────────────────────────────
                        _StatsRow(worker: widget.worker),
                        const SizedBox(height: 20),

                        // ── Quick info chips ────────────────────────────────
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoChip(
                              icon: Icons.access_time_rounded,
                              label: widget.worker.workType,
                            ),
                            _InfoChip(
                              icon: Icons.self_improvement_rounded,
                              label: widget.worker.religion,
                            ),
                            _InfoChip(
                              icon: Icons.cake_outlined,
                              label: '${widget.worker.age} yrs',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── About ───────────────────────────────────────────
                        const _SectionTitle(title: 'About'),
                        const SizedBox(height: 10),
                        _ExpandableBio(bio: widget.worker.bio),
                        const SizedBox(height: 24),

                        // ── Skills ──────────────────────────────────────────
                        const _SectionTitle(title: 'Skills & Services'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.worker.skills
                              .map((s) => _SkillChip(label: s))
                              .toList(),
                        ),
                        const SizedBox(height: 24),

                        // ── Contact info ────────────────────────────────────
                        const _SectionTitle(title: 'Contact'),
                        const SizedBox(height: 12),
                        _ContactRow(worker: widget.worker),
                        const SizedBox(height: 24),

                        // ── Reviews section ──────────────────────────────────
                        Row(
                          children: [
                            _SectionTitle(
                              title: 'Reviews (${widget.worker.reviewCount})',
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: _showWriteReviewSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _kPrimary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.rate_review_rounded,
                                        color: Colors.white, size: 13),
                                    SizedBox(width: 5),
                                    Text('Write a Review',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Rating breakdown
                        _RatingSummary(
                          rating: widget.worker.rating,
                          reviews: _mockReviews,
                        ),
                        const SizedBox(height: 16),

                        // First 3 reviews
                        ..._mockReviews.take(3).map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ReviewCard(review: r),
                        )),

                        // See all button
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: _openAllReviews,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _kInputFill,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _kBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'See all ${widget.worker.reviewCount} reviews',
                                  style: const TextStyle(
                                    color: _kPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded,
                                    color: _kPrimary, size: 15),
                              ],
                            ),
                          ),
                        ),

                        // Bottom padding for the fixed action bar
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Back button ─────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleIconBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.maybePop(context),
                    ),
                    _CircleIconBtn(
                      icon: Icons.share_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Fixed bottom action bar ──────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomActionBar(
              onMessage: _showMessageSheet,
              onHire: _showHireSheet,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gallery Header  (auto-sliding image slider)
// ─────────────────────────────────────────────────────────────────────────────
class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({
    required this.worker,
    required this.pageCtrl,
    required this.currentSlide,
    required this.onPageChanged,
  });

  final WorkerModel    worker;
  final PageController pageCtrl;
  final int            currentSlide;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          // ── Slides ──────────────────────────────────────────────────────────
          PageView.builder(
            controller: pageCtrl,
            onPageChanged: onPageChanged,
            itemCount: worker.galleryColors.length,
            itemBuilder: (_, i) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder colour block (replace with Image.network/file)
                  Container(color: worker.galleryColors[i]),
                  // Gradient overlay so avatar + name are readable
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xCC000000),
                        ],
                        stops: [0.45, 1.0],
                      ),
                    ),
                  ),
                  // Photo number watermark
                  Positioned(
                    top: 60,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Photo ${i + 1} / ${worker.galleryColors.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Slide dots ───────────────────────────────────────────────────────
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(worker.galleryColors.length, (i) {
                final active = i == currentSlide;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width:  active ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? _kPrimary
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),

          // ── Avatar + name overlaid at the bottom of the slider ───────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: worker.avatarColor,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        worker.name.split(' ').map((w) => w[0]).take(2).join(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Star rating inline
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [
                          const Icon(Icons.star_rounded,
                              color: _kStar, size: 16),
                          const SizedBox(width: 3),
                          Text(
                            worker.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '  (${worker.reviewCount} reviews)',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 2),
                        Text(
                          '${worker.jobsDone} jobs completed',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
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
// Stats Row  (rating · reviews · jobs)
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.worker});
  final WorkerModel worker;

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
            value: worker.rating.toStringAsFixed(1),
            label: 'Rating',
            icon: Icons.star_rounded,
            iconColor: _kStar,
          ),
          _divider(),
          _StatCell(
            value: '${worker.reviewCount}',
            label: 'Reviews',
            icon: Icons.reviews_rounded,
            iconColor: _kPrimary,
          ),
          _divider(),
          _StatCell(
            value: '${worker.jobsDone}',
            label: 'Jobs Done',
            icon: Icons.work_history_rounded,
            iconColor: _kSlate,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 36,
    color: _kBorder,
  );
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });
  final String   value;
  final String   label;
  final IconData icon;
  final Color    iconColor;

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
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: _kSubText),
          ),
        ],
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
          style: const TextStyle(
            fontSize: 13.5,
            color: _kSubText,
            height: 1.6,
          ),
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
// Contact row  (phone masked + social)
// ─────────────────────────────────────────────────────────────────────────────
class _ContactRow extends StatefulWidget {
  const _ContactRow({required this.worker});
  final WorkerModel worker;

  @override
  State<_ContactRow> createState() => _ContactRowState();
}

class _ContactRowState extends State<_ContactRow> {
  bool _phoneRevealed = false;

  String get _maskedPhone {
    final p = widget.worker.phone;
    if (p.length <= 4) return p;
    return '${p.substring(0, 4)}${'*' * (p.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kInputFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_android_rounded,
                color: _kPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phone Number',
                  style: TextStyle(
                      fontSize: 11, color: _kHint, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  _phoneRevealed ? widget.worker.phone : _maskedPhone,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _kSlate,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _phoneRevealed = !_phoneRevealed),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _phoneRevealed
                    ? _kSlate
                    : _kPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _phoneRevealed ? 'Hide' : 'Reveal',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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
// Bottom action bar  (Message + Hire)
// ─────────────────────────────────────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onMessage,
    required this.onHire,
  });
  final VoidCallback onMessage;
  final VoidCallback onHire;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
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
          // Message button
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: onMessage,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text(
                  'Message',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
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
          const SizedBox(width: 12),
          // Hire button
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onHire,
                icon: const Icon(Icons.handshake_rounded, size: 18),
                label: const Text(
                  'Hire Now',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hire bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _HireSheet extends StatelessWidget {
  const _HireSheet({required this.worker});
  final WorkerModel worker;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Icon(Icons.handshake_rounded, color: _kPrimary, size: 36),
          const SizedBox(height: 12),
          Text(
            'Hire ${worker.name.split(' ').first}?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _kSlate,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a hire request and agree on start date, duties, '
                'and pay directly with the worker.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'Hire request sent to ${worker.name.split(' ').first}!'),
                  backgroundColor: _kPrimary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Send Hire Request',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _kSubText, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _MessageSheet extends StatefulWidget {
  const _MessageSheet({required this.worker});
  final WorkerModel worker;

  @override
  State<_MessageSheet> createState() => _MessageSheetState();
}

class _MessageSheetState extends State<_MessageSheet> {
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
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).padding.bottom + 16),
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
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Message ${widget.worker.name.split(' ').first}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _kSlate,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              maxLines: 4,
              minLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText:
                'Hi ${widget.worker.name.split(' ').first}, I saw your '
                    'profile and I\'m interested in hiring you...',
                hintStyle:
                const TextStyle(color: _kHint, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFFAEEE6),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                  const BorderSide(color: _kPrimary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Message sent to ${widget.worker.name.split(' ').first}!'),
                    backgroundColor: _kPrimary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ));
                },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Send Message',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
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
// Rating Summary  (big score + breakdown bars)
// ─────────────────────────────────────────────────────────────────────────────
class _RatingSummary extends StatelessWidget {
  const _RatingSummary({
    required this.rating,
    required this.reviews,
  });
  final double            rating;
  final List<ReviewModel> reviews;

  @override
  Widget build(BuildContext context) {
    final total = reviews.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kInputFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          // Big score
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: _kSlate,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(
                  5,
                      (i) => Icon(
                    i < rating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 14,
                    color: _kStar,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$total reviews',
                style: const TextStyle(fontSize: 11, color: _kHint),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Breakdown bars
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star  = 5 - i;
                final count = reviews.where((r) => r.rating == star).length;
                final frac  = total > 0 ? count / total : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: const TextStyle(
                            fontSize: 11,
                            color: _kSubText,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded,
                          size: 11, color: _kStar),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: frac,
                            minHeight: 7,
                            backgroundColor: _kBorder,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              star >= 4 ? _kGreen : star == 3
                                  ? _kStar
                                  : const Color(0xFFE74C3C),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 18,
                        child: Text(
                          '$count',
                          style: const TextStyle(
                              fontSize: 11, color: _kHint),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review card
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: review.reviewerColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  review.reviewerInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kSlate,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                              (i) => Icon(
                            i < review.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 13,
                            color: _kStar,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          review.timeAgo,
                          style: const TextStyle(
                              fontSize: 11, color: _kHint),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Rating badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _kStar.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 12, color: _kStar),
                    const SizedBox(width: 2),
                    Text(
                      '${review.rating}.0',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _kSlate,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.text,
            style: const TextStyle(
              fontSize: 13,
              color: _kSubText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Write Review Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet({required this.worker});
  final WorkerModel worker;

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int    _selectedRating = 0;
  final  TextEditingController _ctrl = TextEditingController();

  static const _labels = ['', 'Terrible', 'Poor', 'Okay', 'Good', 'Excellent'];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Review submitted! You gave ${widget.worker.name.split(' ').first} $_selectedRating stars.'),
        backgroundColor: _kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Worker mini card
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: widget.worker.avatarColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.worker.name.split(' ').map((w) => w[0]).take(2).join(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.worker.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _kSlate)),
                    Text(widget.worker.workType,
                        style: const TextStyle(
                            fontSize: 12, color: _kSubText)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Instruction
            const Text(
              'How was your experience?',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _kSlate),
            ),
            const SizedBox(height: 16),

            // Star picker
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = star),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      star <= _selectedRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 44,
                      color: star <= _selectedRating
                          ? _kStar
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _selectedRating > 0 ? _labels[_selectedRating] : 'Tap to rate',
                key: ValueKey(_selectedRating),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _selectedRating > 0 ? _kPrimary : _kHint,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Text field
            TextField(
              controller: _ctrl,
              maxLines: 4,
              minLines: 3,
              maxLength: 300,
              decoration: InputDecoration(
                hintText:
                'Share details about your experience with ${widget.worker.name.split(' ').first}...',
                hintStyle:
                const TextStyle(color: _kHint, fontSize: 13),
                filled: true,
                fillColor: _kInputFill,
                counterStyle:
                const TextStyle(color: _kHint, fontSize: 11),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                  const BorderSide(color: _kPrimary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Submit Review',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
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

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.available});
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: available
            ? const Color(0xFFE6F4EA)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: available ? _kGreen : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            available ? 'Available' : 'Unavailable',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: available ? _kGreen : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _kInputFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _kPrimary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: _kSlate,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _kPrimary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          color: _kPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
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
  final IconData     icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
