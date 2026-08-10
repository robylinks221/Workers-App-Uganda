// ─────────────────────────────────────────────────────────────────────────────
// write_review.dart
//
// Full-screen review composer screen.
// Features:
//   • Slate-gradient header with worker avatar + name
//   • Animated star picker (tap to select 1-5, with label)
//   • Multi-line review text field (300 char limit)
//   • Anonymous toggle
//   • Submit button → success snackbar → pops back
//
// USAGE
//   import 'worker_profile_view.dart' show WorkerModel;
//
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => WriteReviewScreen(worker: myWorker),
//   ));
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'worker_profile_view.dart' show WorkerModel;

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
      home: WriteReviewScreen(worker: _previewWorker),
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

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color _kPrimary   = Color(0xFFD87C53);
const Color _kDark      = Color(0xFF2A3D4E);
const Color _kSlate     = Color(0xFF395264);
const Color _kSubText   = Color(0xFF5C7A8C);
const Color _kHint      = Color(0xFFB0A098);
const Color _kInputFill = Color(0xFFFAEEE6);
const Color _kStar      = Color(0xFFFFC107);
const Color _kGreen     = Color(0xFF27AE60);
const Color _kBorder    = Color(0xFFEEE6E0);

// ─────────────────────────────────────────────────────────────────────────────
// WriteReviewScreen
// ─────────────────────────────────────────────────────────────────────────────
class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key, required this.worker});
  final WorkerModel worker;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen>
    with TickerProviderStateMixin {
  int    _selectedRating = 0;
  bool   _anonymous      = false;
  final  TextEditingController _ctrl = TextEditingController();
  late   List<AnimationController> _starCtrl;
  late   List<Animation<double>>   _starScale;

  static const _ratingLabels = [
    '', 'Terrible 😞', 'Poor 😕', 'Okay 🙂', 'Good 😊', 'Excellent 🤩'
  ];

  static const _ratingColors = [
    Colors.transparent,
    Color(0xFFE74C3C),
    Color(0xFFE67E22),
    Color(0xFFF39C12),
    Color(0xFF27AE60),
    Color(0xFF2ECC71),
  ];

  @override
  void initState() {
    super.initState();
    _starCtrl = List.generate(
      5,
          (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
    _starScale = _starCtrl
        .map((c) => Tween(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: c, curve: Curves.elasticOut),
    ))
        .toList();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    for (final c in _starCtrl) c.dispose();
    super.dispose();
  }

  void _selectStar(int star) {
    setState(() => _selectedRating = star);
    // Animate all stars up to selected
    for (int i = 0; i < 5; i++) {
      if (i < star) {
        _starCtrl[i].forward().then((_) => _starCtrl[i].reverse());
      }
    }
    HapticFeedback.lightImpact();
  }

  void _submit() {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please tap the stars to rate first'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_ctrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please write at least a short review'),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            'Review submitted! $_selectedRating-star rating sent.',
          ),
        ]),
        backgroundColor: _kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Gradient header ───────────────────────────────────────────────
          _ReviewHeader(worker: widget.worker),

          // ── Scrollable form ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  const Text(
                    'Your Rating',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _kSlate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap the stars to rate your experience',
                    style: TextStyle(fontSize: 12, color: _kHint),
                  ),
                  const SizedBox(height: 20),

                  // ── Star picker ───────────────────────────────────────────
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (i) {
                        final star     = i + 1;
                        final isActive = star <= _selectedRating;
                        return GestureDetector(
                          onTap: () => _selectStar(star),
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 6),
                            child: ScaleTransition(
                              scale: _starScale[i],
                              child: Icon(
                                isActive
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 52,
                                color: isActive
                                    ? _kStar
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Rating label
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                      child: _selectedRating > 0
                          ? Container(
                        key: ValueKey(_selectedRating),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: _ratingColors[_selectedRating]
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _ratingColors[_selectedRating]
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _ratingLabels[_selectedRating],
                          key: ValueKey(_selectedRating),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _ratingColors[_selectedRating],
                          ),
                        ),
                      )
                          : Text(
                        'No rating selected',
                        key: const ValueKey(0),
                        style: const TextStyle(
                            fontSize: 13, color: _kHint),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Review text ───────────────────────────────────────────
                  const Text(
                    'Your Review',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _kSlate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tell others about ${widget.worker.name.split(' ').first}\'s work',
                    style: const TextStyle(fontSize: 12, color: _kHint),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _ctrl,
                    maxLines: 6,
                    minLines: 5,
                    maxLength: 300,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                      'e.g. "She was very professional and cleaned every corner. I will definitely hire her again..."',
                      hintStyle: const TextStyle(
                          color: _kHint, fontSize: 13, height: 1.5),
                      filled: true,
                      fillColor: _kInputFill,
                      counterStyle: TextStyle(
                        fontSize: 11,
                        color: _ctrl.text.length >= 270
                            ? Colors.red.shade400
                            : _kHint,
                      ),
                      contentPadding: const EdgeInsets.all(18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                            color: _kPrimary, width: 1.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Anonymous toggle ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _kInputFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Row(children: [
                      const Icon(Icons.person_outline_rounded,
                          color: _kSubText, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Post Anonymously',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _kSlate)),
                            Text('Your name will be hidden',
                                style: TextStyle(
                                    fontSize: 11, color: _kHint)),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _anonymous,
                        onChanged: (v) =>
                            setState(() => _anonymous = v),
                        activeColor: _kPrimary,
                      ),
                    ]),
                  ),

                  const SizedBox(height: 28),

                  // ── Submit button ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRating > 0
                            ? _kPrimary
                            : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        elevation: _selectedRating > 0 ? 0 : 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedRating > 0
                                ? Icons.check_circle_rounded
                                : Icons.star_outline_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedRating > 0
                                ? 'Submit $_selectedRating-Star Review'
                                : 'Select Stars to Continue',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Review header (gradient + worker card) ────────────────────────────────────
class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.worker});
  final WorkerModel worker;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F7089), Color(0xFF2A3D4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back row
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const Spacer(),
              ]),

              // Worker card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(children: [
                  // Avatar
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: worker.avatarColor,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      worker.name.split(' ').map((w) => w[0]).take(2).join(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review ${worker.name.split(' ').first}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(children: [
                          const Icon(Icons.location_on_rounded,
                              size: 12,
                              color: Colors.white60),
                          const SizedBox(width: 3),
                          Text(
                            worker.location,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: Color(0xFFFFC107)),
                          const SizedBox(width: 3),
                          Text(
                            '${worker.rating.toStringAsFixed(1)}  ·  ${worker.reviewCount} reviews  ·  ${worker.jobsDone} jobs',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
