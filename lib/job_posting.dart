// ─────────────────────────────────────────────────────────────────────────────
// job_posting.dart
//
// Job Posting screen — homeowner creates a job listing in 3 steps:
//   Step 1: Job category + title
//   Step 2: Description, location, schedule
//   Step 3: Budget + review & post
//
// USAGE
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => const JobPostingScreen(),
//   ));
//
// PASTE INTO
//   lib/job_posting.dart   (standalone — no imports from other screens)
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
    home: const JobPostingScreen(),
  );
}

// ── Tokens ────────────────────────────────────────────────────────────────────
const Color _kPrimary    = Color(0xFFD87C53);
const Color _kPrimaryBg  = Color(0xFFFAEEE6);
const Color _kDark       = Color(0xFF2A3D4E);
const Color _kSlate      = Color(0xFF395264);
const Color _kSlateLight = Color(0xFF4F7089);
const Color _kSubText    = Color(0xFF5C7A8C);
const Color _kBorder     = Color(0xFFEAE0D8);
const Color _kMuted      = Color(0xFFB0A098);
const Color _kBg         = Color(0xFFF8F5F3);
const Color _kInputFill  = Color(0xFFFAEEE6);
const Color _kGreen      = Color(0xFF27AE60);
const Color _kGreenBg    = Color(0xFFE8F8EF);

// ── Categories ────────────────────────────────────────────────────────────────
const List<Map<String, dynamic>> _kCategories = [
  {'icon': Icons.cleaning_services_rounded, 'label': 'Cleaning'},
  {'icon': Icons.restaurant_rounded,        'label': 'Cooking'},
  {'icon': Icons.local_laundry_service,     'label': 'Laundry'},
  {'icon': Icons.child_care_rounded,        'label': 'Babysitting'},
  {'icon': Icons.iron_rounded,              'label': 'Ironing'},
  {'icon': Icons.elderly_rounded,           'label': 'Elder Care'},
  {'icon': Icons.yard_rounded,              'label': 'Gardening'},
  {'icon': Icons.home_repair_service_rounded,'label': 'General Help'},
];

// ── Duration options ──────────────────────────────────────────────────────────
const List<String> _kDurations = [
  'A few hours', 'Half day (4 hrs)', 'Full day (8 hrs)',
  'Weekly', 'Monthly', 'Ongoing',
];

// ── Budget types ──────────────────────────────────────────────────────────────
const List<Map<String, dynamic>> _kBudgetTypes = [
  {'label': 'Per Day',   'icon': Icons.today_rounded},
  {'label': 'Per Month', 'icon': Icons.calendar_month_rounded},
  {'label': 'Fixed',     'icon': Icons.attach_money_rounded},
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class JobPostingScreen extends StatefulWidget {
  const JobPostingScreen({super.key});
  @override
  State<JobPostingScreen> createState() => _JobPostingScreenState();
}

class _JobPostingScreenState extends State<JobPostingScreen>
    with SingleTickerProviderStateMixin {
  // Step controller
  final _pageCtrl = PageController();
  int _step = 0; // 0, 1, 2

  // Step 1
  int?   _categoryIndex;
  final  _titleCtrl = TextEditingController();

  // Step 2
  final  _descCtrl     = TextEditingController();
  final  _locationCtrl = TextEditingController();
  final  _dateCtrl     = TextEditingController();
  int    _durationIndex = 0;

  // Step 3
  int    _budgetTypeIndex = 0;
  final  _budgetCtrl = TextEditingController();

  // Validation
  String? _stepError;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _dateCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────────
  void _next() {
    setState(() => _stepError = null);

    if (_step == 0) {
      if (_categoryIndex == null) {
        setState(() => _stepError = 'Please select a job category');
        return;
      }
      if (_titleCtrl.text.trim().isEmpty) {
        setState(() => _stepError = 'Please enter a job title');
        return;
      }
    }
    if (_step == 1) {
      if (_descCtrl.text.trim().isEmpty) {
        setState(() => _stepError = 'Please describe the job');
        return;
      }
      if (_locationCtrl.text.trim().isEmpty) {
        setState(() => _stepError = 'Please enter a location');
        return;
      }
    }
    if (_step == 2) {
      if (_budgetCtrl.text.trim().isEmpty) {
        setState(() => _stepError = 'Please enter your budget');
        return;
      }
      _showSuccess();
      return;
    }

    setState(() => _step++);
    _pageCtrl.animateToPage(_step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
  }

  void _back() {
    if (_step == 0) {
      Navigator.maybePop(context);
      return;
    }
    setState(() {
      _step--;
      _stepError = null;
    });
    _pageCtrl.animateToPage(_step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
  }

  void _showSuccess() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => _SuccessScreen(
              category:   _kCategories[_categoryIndex!]['label'] as String,
              title:      _titleCtrl.text.trim(),
              location:   _locationCtrl.text.trim(),
              budget:     'UGX ${_budgetCtrl.text.trim()} ${_kBudgetTypes[_budgetTypeIndex]['label']}',
              duration:   _kDurations[_durationIndex],
            )));
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    const stepTitles  = ['Job Category', 'Job Details', 'Budget & Review'];
    const stepSubtitles = [
      'What kind of help do you need?',
      'Describe the job and location',
      'Set your budget and post',
    ];

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
              // Back + title
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: _back,
                ),
                const Text('Post a Job',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stepTitles[_step],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(stepSubtitles[_step],
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13)),
                    const SizedBox(height: 16),
                    // Step dots
                    Row(children: List.generate(3, (i) {
                      final done = i < _step;
                      final active = i == _step;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                          height: 4,
                          decoration: BoxDecoration(
                            color: done
                                ? Colors.white
                                : active
                                ? Colors.white.withOpacity(0.7)
                                : Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    })),
                    const SizedBox(height: 6),
                    Text('Step ${_step + 1} of 3',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_stepError != null) ...[
            Row(children: [
              const Icon(Icons.error_outline_rounded,
                  size: 14, color: Colors.red),
              const SizedBox(width: 6),
              Text(_stepError!,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.red)),
            ]),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                _step == 2 ? 'Post Job Now' : 'Continue',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1 — Category + Title ───────────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('Select Category'),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: _kCategories.length,
            itemBuilder: (_, i) {
              final sel = _categoryIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _categoryIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: sel ? _kPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: sel ? _kPrimary : _kBorder,
                        width: sel ? 1.5 : 1),
                    boxShadow: sel
                        ? [
                      BoxShadow(
                          color: _kPrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _kCategories[i]['icon'] as IconData,
                        size: 22,
                        color: sel ? Colors.white : _kSlateLight,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _kCategories[i]['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : _kSubText),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const _Label('Job Title'),
          const SizedBox(height: 8),
          _InputField(
            ctrl: _titleCtrl,
            hint: 'e.g. Full-time house cleaner needed',
          ),
          const SizedBox(height: 8),
          const Text(
            'Be specific — a clear title attracts the right workers.',
            style: TextStyle(fontSize: 12, color: _kMuted),
          ),
        ],
      ),
    );
  }

  // ── Step 2 — Details ────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('Job Description'),
          const SizedBox(height: 8),
          _InputField(
            ctrl: _descCtrl,
            hint:
            'Describe the job in detail — number of rooms, special requirements, etc.',
            maxLines: 5,
          ),
          const SizedBox(height: 20),

          const _Label('Location'),
          const SizedBox(height: 8),
          _InputField(
            ctrl: _locationCtrl,
            hint: 'e.g. Ntinda, Kampala',
            prefix: const Icon(Icons.location_on_rounded,
                size: 18, color: _kMuted),
          ),
          const SizedBox(height: 20),

          const _Label('Start Date'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                        primary: _kPrimary),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                _dateCtrl.text =
                '${picked.day}/${picked.month}/${picked.year}';
              }
            },
            child: AbsorbPointer(
              child: _InputField(
                ctrl: _dateCtrl,
                hint: 'Select start date',
                prefix: const Icon(Icons.calendar_today_rounded,
                    size: 18, color: _kMuted),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const _Label('Duration / Schedule'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_kDurations.length, (i) {
              final sel = _durationIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _durationIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _kPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: sel ? _kPrimary : _kBorder),
                  ),
                  child: Text(
                    _kDurations[i],
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : _kSubText),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Step 3 — Budget + review ─────────────────────────────────────────────────
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('Budget Type'),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_kBudgetTypes.length, (i) {
              final sel = _budgetTypeIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _budgetTypeIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? _kPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel ? _kPrimary : _kBorder),
                    ),
                    child: Column(children: [
                      Icon(
                        _kBudgetTypes[i]['icon'] as IconData,
                        size: 20,
                        color: sel ? Colors.white : _kSlateLight,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _kBudgetTypes[i]['label'] as String,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : _kSubText),
                      ),
                    ]),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          const _Label('Amount (UGX)'),
          const SizedBox(height: 8),
          _InputField(
            ctrl: _budgetCtrl,
            hint: 'e.g. 350,000',
            keyboardType: TextInputType.number,
            prefix: const Text('UGX ',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _kMuted,
                    fontSize: 14)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tip: Workers are more likely to apply when the pay is fair and clearly stated.',
            style: TextStyle(fontSize: 12, color: _kMuted, height: 1.5),
          ),
          const SizedBox(height: 28),

          // ── Review summary ─────────────────────────────────────────────────
          const _Label('Review Your Listing'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_categoryIndex != null)
                  _ReviewRow(
                    icon: _kCategories[_categoryIndex!]['icon'] as IconData,
                    label: 'Category',
                    value: _kCategories[_categoryIndex!]['label'] as String,
                  ),
                _ReviewRow(
                  icon: Icons.title_rounded,
                  label: 'Title',
                  value: _titleCtrl.text.trim().isEmpty
                      ? '—'
                      : _titleCtrl.text.trim(),
                ),
                _ReviewRow(
                  icon: Icons.location_on_rounded,
                  label: 'Location',
                  value: _locationCtrl.text.trim().isEmpty
                      ? '—'
                      : _locationCtrl.text.trim(),
                ),
                _ReviewRow(
                  icon: Icons.schedule_rounded,
                  label: 'Duration',
                  value: _kDurations[_durationIndex],
                ),
                _ReviewRow(
                  icon: Icons.payments_rounded,
                  label: 'Budget',
                  value: _budgetCtrl.text.trim().isEmpty
                      ? '—'
                      : 'UGX ${_budgetCtrl.text.trim()} ${_kBudgetTypes[_budgetTypeIndex]['label']}',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });
  final IconData icon;
  final String   label;
  final String   value;
  final bool     isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Icon(icon, size: 16, color: _kSlateLight),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: _kMuted)),
            const Spacer(),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kSlate)),
            ),
          ]),
        ),
        if (!isLast)
          const Divider(height: 1, color: _kBorder),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success screen
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen({
    required this.category,
    required this.title,
    required this.location,
    required this.budget,
    required this.duration,
  });
  final String category, title, location, budget, duration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success icon
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: _kGreenBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: _kGreen.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    size: 52, color: _kGreen),
              ),
              const SizedBox(height: 28),
              const Text('Job Posted!',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _kSlate)),
              const SizedBox(height: 10),
              const Text(
                'Your job listing is now live.\nWorkers can see it and apply.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, color: _kSubText, height: 1.5),
              ),
              const SizedBox(height: 28),

              // Summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kBorder),
                ),
                child: Column(children: [
                  _SummaryTile(label: 'Category', value: category),
                  const Divider(height: 1, color: _kBorder),
                  _SummaryTile(label: 'Title', value: title),
                  const Divider(height: 1, color: _kBorder),
                  _SummaryTile(label: 'Location', value: location),
                  const Divider(height: 1, color: _kBorder),
                  _SummaryTile(label: 'Duration', value: duration),
                  const Divider(height: 1, color: _kBorder),
                  _SummaryTile(label: 'Budget', value: budget),
                ]),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Back to Home',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('View Applicants',
                    style: TextStyle(
                        color: _kSlateLight,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: _kMuted)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kSlate)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _kSlate));
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.ctrl,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.prefix,
  });
  final TextEditingController ctrl;
  final String                hint;
  final int                   maxLines;
  final TextInputType?        keyboardType;
  final Widget?               prefix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: _kSlate),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kMuted, fontSize: 14),
        prefixIcon: prefix != null
            ? Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: prefix)
            : null,
        prefixIconConstraints:
        const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: _kInputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 13),
      ),
    );
  }
}
