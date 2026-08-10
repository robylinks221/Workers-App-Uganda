// ─────────────────────────────────────────────────────────────────────────────
// all_reviews.dart
//
// Full reviews screen — shows every review for a worker with:
//   • Overall rating summary + breakdown bars
//   • Filter chips by star (All / 5★ / 4★ / 3★ / 2★ / 1★)
//   • Each review card: avatar, name, star rating, timeAgo, review text
//   • Floating "Write a Review" button
//
// USAGE
//   import 'worker_profile_view.dart' show WorkerModel, ReviewModel;
//
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => AllReviewsScreen(
//       worker:  myWorker,
//       reviews: myReviewsList,
//     ),
//   ));
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'worker_profile_view.dart' show WorkerModel, ReviewModel;
import 'write_review.dart' show WriteReviewScreen;

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
      home: AllReviewsScreen(
        worker: _previewWorker,
        reviews: _previewReviews,
      ),
    );
  }
}

final _previewWorker = WorkerModel(
  name: 'Annet Nakato', age: 27, location: 'Ntinda, Kampala',
  religion: 'Christian', workType: 'Full Time', phone: '0772 345 678',
  bio: 'Experienced house cleaner and nanny.',
  rating: 4.8, reviewCount: 34, jobsDone: 41,
  isVerified: true, isAvailable: true,
  skills: ['Cleaning', 'Cooking', 'Laundry', 'Child Care'],
  galleryColors: [const Color(0xFF6B8FA8), const Color(0xFF8B7355)],
  avatarColor: const Color(0xFF4F7089),
);

final _previewReviews = <ReviewModel>[
  ReviewModel(id: 'r1', reviewerName: 'Joyce Mutebi',      reviewerInitials: 'JM', reviewerColor: const Color(0xFF6C5CE7), rating: 5, text: 'Annet is very hardworking and trustworthy. Highly recommend!',            postedAt: DateTime.now().subtract(const Duration(hours: 2))),
  ReviewModel(id: 'r2', reviewerName: 'Patrick Kizza',     reviewerInitials: 'PK', reviewerColor: const Color(0xFF00B894), rating: 5, text: 'Good worker, always on time. Cooked well and kept the kids entertained.',   postedAt: DateTime.now().subtract(const Duration(days: 3))),
  ReviewModel(id: 'r3', reviewerName: 'Sarah Nakato',      reviewerInitials: 'SN', reviewerColor: const Color(0xFFD87C53), rating: 4, text: 'Very polite and careful with our belongings. Will hire again.',             postedAt: DateTime.now().subtract(const Duration(days: 10))),
  ReviewModel(id: 'r4', reviewerName: 'David Ssemwogerere',reviewerInitials: 'DS', reviewerColor: const Color(0xFF4F7089), rating: 5, text: 'Best house help I have ever had. Professional and very respectful.',         postedAt: DateTime.now().subtract(const Duration(days: 18))),
  ReviewModel(id: 'r5', reviewerName: 'Grace Auma',        reviewerInitials: 'GA', reviewerColor: const Color(0xFFE17055), rating: 4, text: 'She did a great job. Laundry and ironing were done perfectly.',              postedAt: DateTime.now().subtract(const Duration(days: 25))),
  ReviewModel(id: 'r6', reviewerName: 'Robert Mugisha',    reviewerInitials: 'RM', reviewerColor: const Color(0xFF0984E3), rating: 5, text: 'Very thorough cleaner. She reorganised my kitchen beautifully.',             postedAt: DateTime.now().subtract(const Duration(days: 35))),
  ReviewModel(id: 'r7', reviewerName: 'Flavia Nakamya',    reviewerInitials: 'FN', reviewerColor: const Color(0xFF8E44AD), rating: 3, text: 'She was okay. Not very experienced with childcare but a good worker.',       postedAt: DateTime.now().subtract(const Duration(days: 50))),
  ReviewModel(id: 'r8', reviewerName: 'Ivan Tumwine',      reviewerInitials: 'IT', reviewerColor: const Color(0xFF27AE60), rating: 5, text: 'Exceptional. She treated our home like her own. Kids adore her.',           postedAt: DateTime.now().subtract(const Duration(days: 60))),
];

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color _kPrimary  = Color(0xFFD87C53);
const Color _kDark     = Color(0xFF2A3D4E);
const Color _kSlate    = Color(0xFF395264);
const Color _kSubText  = Color(0xFF5C7A8C);
const Color _kHint     = Color(0xFFB0A098);
const Color _kStar     = Color(0xFFFFC107);
const Color _kGreen    = Color(0xFF27AE60);
const Color _kBorder   = Color(0xFFEEE6E0);
const Color _kFill     = Color(0xFFFAEEE6);
const Color _kBg       = Color(0xFFF8F3F0);

// ─────────────────────────────────────────────────────────────────────────────
// AllReviewsScreen
// ─────────────────────────────────────────────────────────────────────────────
class AllReviewsScreen extends StatefulWidget {
  const AllReviewsScreen({
    super.key,
    required this.worker,
    required this.reviews,
  });
  final WorkerModel       worker;
  final List<ReviewModel> reviews;

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  int _filterStar = 0; // 0 = all

  List<ReviewModel> get _filtered => _filterStar == 0
      ? widget.reviews
      : widget.reviews.where((r) => r.rating == _filterStar).toList();

  double get _avgRating {
    if (widget.reviews.isEmpty) return 0;
    return widget.reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        widget.reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Header ────────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _kSlate, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviews',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _kSlate,
                      ),
                    ),
                    Text(
                      widget.worker.name,
                      style: const TextStyle(
                          fontSize: 11, color: _kSubText),
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Divider(
                      height: 1, color: _kBorder.withOpacity(0.6)),
                ),
              ),

              // ── Rating summary ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: _RatingSummaryBig(
                    avgRating: _avgRating,
                    reviews: widget.reviews,
                    onFilterTap: (star) =>
                        setState(() => _filterStar = star),
                    selectedStar: _filterStar,
                  ),
                ),
              ),

              // ── Filter chips ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _FilterChips(
                    selected: _filterStar,
                    reviews: widget.reviews,
                    onSelect: (star) =>
                        setState(() => _filterStar = star),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── Review list ───────────────────────────────────────────────
              _filtered.isEmpty
                  ? SliverToBoxAdapter(
                child: _EmptyState(star: _filterStar),
              )
                  : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReviewCard(review: _filtered[i]),
                    ),
                    childCount: _filtered.length,
                  ),
                ),
              ),
            ],
          ),

          // ── Floating write review button ──────────────────────────────────
          Positioned(
            bottom: 24 + MediaQuery.of(context).padding.bottom,
            left: 24,
            right: 24,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      WriteReviewScreen(worker: widget.worker),
                ),
              ),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: _kPrimary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _kPrimary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rate_review_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Write a Review',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Big rating summary (score + bars + tap-to-filter) ─────────────────────────
class _RatingSummaryBig extends StatelessWidget {
  const _RatingSummaryBig({
    required this.avgRating,
    required this.reviews,
    required this.selectedStar,
    required this.onFilterTap,
  });
  final double            avgRating;
  final List<ReviewModel> reviews;
  final int               selectedStar;
  final ValueChanged<int> onFilterTap;

  @override
  Widget build(BuildContext context) {
    final total = reviews.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Big score
        Column(
          children: [
            Text(
              avgRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.w900,
                color: _kSlate,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(
                5,
                    (i) => Icon(
                  i < avgRating.round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: _kStar,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$total reviews',
              style: const TextStyle(fontSize: 12, color: _kHint),
            ),
          ],
        ),
        const SizedBox(width: 24),
        // Bars (tappable)
        Expanded(
          child: Column(
            children: List.generate(5, (i) {
              final star  = 5 - i;
              final count = reviews.where((r) => r.rating == star).length;
              final frac  = total > 0 ? count / total : 0.0;
              final isSelected = selectedStar == star;
              return GestureDetector(
                onTap: () => onFilterTap(isSelected ? 0 : star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? _kPrimary : _kSubText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.star_rounded,
                          size: 12,
                          color: isSelected ? _kPrimary : _kStar),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: frac,
                            minHeight: 8,
                            backgroundColor: _kBorder,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isSelected
                                  ? _kPrimary
                                  : (star >= 4
                                  ? _kGreen
                                  : star == 3
                                  ? _kStar
                                  : const Color(0xFFE74C3C)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 22,
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? _kPrimary : _kHint,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.reviews,
    required this.onSelect,
  });
  final int               selected;
  final List<ReviewModel> reviews;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final options = [0, 5, 4, 3, 2, 1];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((star) {
          final isAll      = star == 0;
          final isSelected = selected == star;
          final count      = isAll
              ? reviews.length
              : reviews.where((r) => r.rating == star).length;
          final label = isAll ? 'All ($count)' : '$star★ ($count)';

          return GestureDetector(
            onTap: () => onSelect(isSelected && !isAll ? 0 : star),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _kPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? _kPrimary : _kBorder,
                  width: 1.5,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : _kSubText,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Review card ───────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          // ── Reviewer row ────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: review.reviewerColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  review.reviewerInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kSlate,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                              (i) => Icon(
                            i < review.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14,
                            color: _kStar,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4, height: 4,
                          decoration: BoxDecoration(
                            color: _kHint,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
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
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: review.rating >= 4
                      ? _kGreen.withOpacity(0.1)
                      : review.rating == 3
                      ? _kStar.withOpacity(0.1)
                      : const Color(0xFFE74C3C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: review.rating >= 4
                          ? _kGreen
                          : review.rating == 3
                          ? _kStar
                          : const Color(0xFFE74C3C),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${review.rating}.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: review.rating >= 4
                            ? _kGreen
                            : review.rating == 3
                            ? _kStar
                            : const Color(0xFFE74C3C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Review text ──────────────────────────────────────────────────
          Text(
            review.text,
            style: const TextStyle(
              fontSize: 13.5,
              color: _kSubText,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.star});
  final int star;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Icon(Icons.star_outline_rounded,
              size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No $star-star reviews yet',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different filter or be the first to review!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
