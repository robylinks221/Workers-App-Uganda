// ─────────────────────────────────────────────────────────────────────────────
// saved_workers.dart
//
// Saved Workers screen — homeowner's bookmarked maids.
// Tap a card to open WorkerProfileView. Swipe left or tap the bookmark
// icon to remove a worker from the saved list.
//
// USAGE
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => SavedWorkersScreen(savedWorkers: myList),
//   ));
//
// DEPENDENCIES
//   • worker_profile_view.dart  — WorkerModel (must be in same lib/ folder)
//
// PASTE INTO
//   lib/saved_workers.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'worker_profile_view.dart';

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
        fontFamily: 'Roboto',
      ),
      home: SavedWorkersScreen(savedWorkers: _mockSaved),
    );
  }
}

// ── Design tokens ─────────────────────────────────────────────────────────────
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
const Color _kRedBg      = Color(0xFFFDECEB);
const Color _kRed        = Color(0xFFE74C3C);

// ── Mock saved workers ────────────────────────────────────────────────────────
final List<WorkerModel> _mockSaved = [
  WorkerModel(
    name: 'Sarah Nakato', age: 28, location: 'Kamwokya, Kampala',
    religion: 'Christian', workType: 'Full Time', phone: '0772 345 678',
    bio: 'Experienced and trustworthy domestic worker. Specialises in deep cleaning, meal preparation, and childcare.',
    rating: 4.9, reviewCount: 42, jobsDone: 51, isVerified: true, isAvailable: true,
    skills: ['Cleaning', 'Cooking', 'Laundry', 'Child Care'],
    galleryColors: [const Color(0xFF6B8FA8), const Color(0xFF8B7355), const Color(0xFF7A9E7E)],
    avatarColor: const Color(0xFFD87C53),
  ),
  WorkerModel(
    name: 'Harriet Babirye', age: 35, location: 'Bugolobi, Kampala',
    religion: 'Christian', workType: 'Full Time', phone: '0777 890 123',
    bio: '10 years experience with high-income families. Discreet, professional, and highly organised.',
    rating: 5.0, reviewCount: 87, jobsDone: 102, isVerified: true, isAvailable: true,
    skills: ['Cleaning', 'Cooking', 'Laundry', 'Ironing', 'Child Care'],
    galleryColors: [const Color(0xFF27AE60), const Color(0xFF6B8FA8), const Color(0xFFD87C53)],
    avatarColor: const Color(0xFF27AE60),
  ),
  WorkerModel(
    name: 'Grace Apio', age: 24, location: 'Nansana, Wakiso',
    religion: 'Christian', workType: 'Full Time', phone: '0756 789 012',
    bio: 'Caring and patient with children. 4 years experience with families in Wakiso and Kampala.',
    rating: 4.7, reviewCount: 28, jobsDone: 33, isVerified: true, isAvailable: false,
    skills: ['Babysitting', 'Cooking', 'Cleaning'],
    galleryColors: [const Color(0xFF395264), const Color(0xFF4F8070), const Color(0xFF8B6355)],
    avatarColor: const Color(0xFF395264),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Saved Workers Screen
// ─────────────────────────────────────────────────────────────────────────────
class SavedWorkersScreen extends StatefulWidget {
  const SavedWorkersScreen({super.key, required this.savedWorkers});
  final List<WorkerModel> savedWorkers;

  @override
  State<SavedWorkersScreen> createState() => _SavedWorkersScreenState();
}

class _SavedWorkersScreenState extends State<SavedWorkersScreen> {
  late List<WorkerModel> _saved;

  @override
  void initState() {
    super.initState();
    _saved = List.from(widget.savedWorkers);
  }

  void _remove(WorkerModel w) {
    setState(() => _saved.removeWhere((s) => s.name == w.name));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${w.name.split(' ').first} removed from saved',
          style: const TextStyle(color: Colors.white)),
      backgroundColor: _kSlate,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Undo',
        textColor: _kPrimary,
        onPressed: () => setState(() => _saved.add(w)),
      ),
    ));
  }

  void _openProfile(WorkerModel w) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => WorkerProfileView(worker: w)));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader()),

          // ── Count row ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(children: [
                Container(
                  width: 4, height: 18,
                  decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_saved.length} Saved Worker${_saved.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kSlate),
                ),
                const Spacer(),
                if (_saved.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() => _saved.clear());
                    },
                    child: const Text('Clear All',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _kRed)),
                  ),
              ]),
            ),
          ),

          // ── List or empty state ─────────────────────────────────────────────
          _saved.isEmpty
              ? const SliverFillRemaining(child: _EmptyState())
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (_, i) => Dismissible(
                  key: ValueKey(_saved[i].name),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: _kRedBg,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.bookmark_remove_rounded,
                        color: _kRed, size: 24),
                  ),
                  onDismissed: (_) => _remove(_saved[i]),
                  child: _SavedWorkerCard(
                    worker: _saved[i],
                    onTap: () => _openProfile(_saved[i]),
                    onRemove: () => _remove(_saved[i]),
                  ),
                ),
                childCount: _saved.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          padding: const EdgeInsets.fromLTRB(4, 4, 20, 20),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.maybePop(context),
            ),
            const Text('Saved Workers',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            if (_saved.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_saved.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Saved Worker Card
// ─────────────────────────────────────────────────────────────────────────────
class _SavedWorkerCard extends StatelessWidget {
  const _SavedWorkerCard({
    required this.worker,
    required this.onTap,
    required this.onRemove,
  });
  final WorkerModel worker;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            // ── Top section ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with availability dot
                  Stack(children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: worker.avatarColor.withOpacity(0.15),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: worker.avatarColor,
                        child: Text(
                          _initials(worker.name),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18),
                        ),
                      ),
                    ),
                    if (worker.isAvailable)
                      Positioned(
                        bottom: 2, right: 2,
                        child: Container(
                          width: 13, height: 13,
                          decoration: BoxDecoration(
                            color: _kGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ]),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(worker.name,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _kSlate),
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (worker.isVerified)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.verified_rounded,
                                  size: 15, color: _kSlateLight),
                            ),
                        ]),
                        const SizedBox(height: 3),
                        Row(children: [
                          const Icon(Icons.location_on_rounded,
                              size: 12, color: _kMuted),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(worker.location,
                                style: const TextStyle(
                                    fontSize: 12, color: _kSubText),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: _kStar),
                          const SizedBox(width: 3),
                          Text(worker.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _kSlate)),
                          const SizedBox(width: 4),
                          Text('(${worker.reviewCount})',
                              style: const TextStyle(
                                  fontSize: 11, color: _kMuted)),
                          const Spacer(),
                          Text('${worker.jobsDone} jobs',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _kSubText)),
                        ]),
                      ],
                    ),
                  ),

                  // Remove bookmark
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onRemove,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.bookmark_rounded,
                          size: 22, color: _kPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // ── Skills row ──────────────────────────────────────────────────
            if (worker.skills.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: SizedBox(
                  height: 28,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: worker.skills.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Text(worker.skills[i],
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _kSubText)),
                    ),
                  ),
                ),
              ),

            // ── Availability + CTA ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(children: [
                // Availability pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: worker.isAvailable ? _kGreenBg : _kPrimaryBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          worker.isAvailable
                              ? Icons.check_circle_outline_rounded
                              : Icons.schedule_rounded,
                          size: 12,
                          color: worker.isAvailable
                              ? _kGreen
                              : _kPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          worker.isAvailable
                              ? 'Available Now'
                              : 'Not Available',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: worker.isAvailable
                                  ? _kGreen
                                  : _kPrimary),
                        ),
                      ]),
                ),
                const Spacer(),
                // Work type chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kPrimaryBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(worker.workType,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _kPrimary)),
                ),
                const SizedBox(width: 8),
                // View profile
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: _kPrimary.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: const Text('View Profile',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ]),
            ),
          ],
        ),
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
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: _kPrimaryBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.bookmark_border_rounded,
                  size: 40, color: _kPrimary),
            ),
            const SizedBox(height: 20),
            const Text('No saved workers yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kSlate)),
            const SizedBox(height: 8),
            const Text(
              'Tap the bookmark icon on any worker\'s card to save them here.',
              textAlign: TextAlign.center,
              style:
              TextStyle(fontSize: 14, color: _kSubText, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper
// ─────────────────────────────────────────────────────────────────────────────
String _initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}
