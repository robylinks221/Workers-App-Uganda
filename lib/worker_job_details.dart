import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'homeowner_public_profile.dart';

import 'services/worker_job_service.dart';
import 'widgets/premium_buttons.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class WorkerJobDetailsScreen extends StatefulWidget {
  const WorkerJobDetailsScreen({super.key, required this.jobId});

  final int jobId;

  @override
  State<WorkerJobDetailsScreen> createState() => _WorkerJobDetailsScreenState();
}

class _WorkerJobDetailsScreenState extends State<WorkerJobDetailsScreen> {
  final WorkerJobService _service = WorkerJobService();

  Map<String, dynamic>? _job;
  bool _loading = true;
  bool _hasApplied = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.getJob(widget.jobId);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _job = Map<String, dynamic>.from(result['job'] as Map);
        _hasApplied = result['has_applied'] == true;
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['message']?.toString();
        _loading = false;
      });
    }
  }

  Future<void> _apply() async {
    final application = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _WorkerApplicationSheet(
            initialSalary:
                _job?['budget_amount']?.toString().split('.').first ?? '',
          ),
    );

    if (!mounted || application == null) return;

    final message = application['message']?.toString().trim() ?? '';
    final expectedSalary = application['expected_salary'];

    if (message.isEmpty || expectedSalary is! double) return;

    final result = await _service.apply(
      jobId: widget.jobId,
      message: message,
      expectedSalary: expectedSalary,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() => _hasApplied = true);

      await _showApplicationSent();
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                'We could not send your application.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ),
      );
  }

  Future<void> _showApplicationSent() async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE5EA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.11),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: _primary,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Application Sent',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF17324D),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'The homeowner has received your application. We will tell you when they reply.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF718396),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).maybePop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.search_rounded),
                    label: const Text(
                      'Find More Jobs',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Stay on This Job'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FA),
        body: const Center(child: CircularProgressIndicator(color: _primary)),
      );
    }

    if (_error != null || _job == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FA),
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error ?? 'Unable to load job.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final job = _job!;
    final homeowner = _map(job['homeowner']);
    final services =
        job['service_categories'] is List
            ? job['service_categories'] as List
            : const [];

    final homeownerName =
        homeowner['full_name']?.toString().trim().isNotEmpty == true
            ? homeowner['full_name'].toString()
            : 'Homeowner';

    final homeownerPhoto = ApiConfig.storageUrl(
      homeowner['profile_photo']?.toString(),
    );

    final isUrgent = job['is_urgent'] == true;
    final title = job['title']?.toString() ?? 'Job';
    final district = job['district']?.toString() ?? 'Location not provided';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 325,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF0E3858),
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(7),
              child: Material(
                color: Colors.black.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0B2B47),
                      Color(0xFF135875),
                      Color(0xFF1FB8B3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: 40,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 70, 20, 25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.13),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Text(
                                    'OPEN JOB',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      letterSpacing: 1.1,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                if (isUrgent) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFFC15A,
                                      ).withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.bolt_rounded,
                                          color: Color(0xFFFFD37A),
                                          size: 14,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'URGENT',
                                          style: TextStyle(
                                            color: Color(0xFFFFD37A),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                height: 1.12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white70,
                                  size: 17,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    district,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.5,
                                    ),
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
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 125),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ModernBudgetCard(job: job),
                const SizedBox(height: 14),

                _ModernJobSection(
                  icon: Icons.description_outlined,
                  title: 'What Work Is Needed',
                  subtitle: 'Read what the homeowner wants you to do.',
                  child: Text(
                    job['description']?.toString() ??
                        'No description provided.',
                    style: const TextStyle(
                      color: Color(0xFF65788A),
                      fontSize: 13.5,
                      height: 1.6,
                    ),
                  ),
                ),

                if (services.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _ModernJobSection(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Work Skills Needed',
                    subtitle:
                        'Make sure you can do this work before you apply.',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          services
                              .whereType<Map>()
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _primary.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    item['name']?.toString() ?? 'Service',
                                    style: const TextStyle(
                                      color: _primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                _ModernJobSection(
                  icon: Icons.event_note_outlined,
                  title: 'When & Where',
                  subtitle: 'Check where the job is and when the work starts.',
                  child: Column(
                    children: [
                      _ModernDetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'District',
                        value: job['district']?.toString() ?? 'Not provided',
                      ),
                      _ModernDetailRow(
                        icon: Icons.home_outlined,
                        label: 'Address',
                        value: job['address']?.toString() ?? 'Not provided',
                      ),
                      _ModernDetailRow(
                        icon: Icons.schedule_rounded,
                        label: 'Work arrangement',
                        value: _label(
                          job['work_arrangement'] ?? job['duration'],
                        ),
                      ),
                      _ModernDetailRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Start date',
                        value: _prettyDate(job['start_date']),
                      ),
                      _ModernDetailRow(
                        icon: Icons.timelapse_rounded,
                        label: 'Contract duration',
                        value: _label(
                          job['contract_duration'] ?? job['duration'],
                        ),
                        last: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                _ModernJobSection(
                  icon: Icons.person_outline_rounded,
                  title: 'Homeowner',
                  subtitle: 'See who posted this job.',
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => HomeownerPublicProfileScreen(
                                homeowner: homeowner,
                                jobId: widget.jobId,
                                fallbackDistrict: district,
                              ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F9FA),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: _primary.withValues(alpha: 0.10),
                            backgroundImage:
                                homeownerPhoto.isNotEmpty
                                    ? NetworkImage(homeownerPhoto)
                                    : null,
                            child:
                                homeownerPhoto.isEmpty
                                    ? Text(
                                      _initials(homeownerName),
                                      style: const TextStyle(
                                        color: _primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        homeownerName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF17324D),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    if (homeowner['is_verified'] == true) ...[
                                      const SizedBox(width: 5),
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: _primary,
                                        size: 17,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'View homeowner profile',
                                  style: TextStyle(
                                    color: Color(0xFF718396),
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: _primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        color: Colors.white,
        elevation: 20,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: FilledButton.icon(
              onPressed: _hasApplied ? null : _apply,
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFB7C7CE),
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              icon: Icon(
                _hasApplied
                    ? Icons.check_circle_outline_rounded
                    : Icons.send_rounded,
              ),
              label: Text(
                _hasApplied ? 'Application Sent' : 'Apply for This Job',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernBudgetCard extends StatelessWidget {
  const _ModernBudgetCard({required this.job});

  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    final amount = job['budget_amount'];
    final budgetType = _label(job['budget_type']);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF9F8), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 51,
            height: 51,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: _primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Offered Budget',
                  style: TextStyle(
                    color: Color(0xFF718396),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatBudget(amount),
                  style: const TextStyle(
                    color: Color(0xFF17324D),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (budgetType.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                budgetType,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _formatBudget(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '');

    if (amount == null || amount <= 0) {
      return 'Negotiable';
    }

    final whole = amount.round().toString();
    final formatted = whole.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );

    return 'UGX $formatted';
  }
}

class _ModernJobSection extends StatelessWidget {
  const _ModernJobSection({
    required this.icon,
    required this.title,
    this.subtitle = '',
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: _primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF17324D),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF718396),
                          fontSize: 10.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ModernDetailRow extends StatelessWidget {
  const _ModernDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: _primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF718396),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value.trim().isEmpty ? 'Not provided' : value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF17324D),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!last) const Divider(height: 1, color: Color(0xFFEAF0F3)),
      ],
    );
  }
}

class _WorkerApplicationSheet extends StatefulWidget {
  const _WorkerApplicationSheet({required this.initialSalary});

  final String initialSalary;

  @override
  State<_WorkerApplicationSheet> createState() =>
      _WorkerApplicationSheetState();
}

class _WorkerApplicationSheetState extends State<_WorkerApplicationSheet> {
  late final TextEditingController _messageController;
  late final TextEditingController _salaryController;
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _salaryController = TextEditingController(text: widget.initialSalary);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _submit() {
    final message = _messageController.text.trim();
    final expectedSalary = double.tryParse(
      _salaryController.text.replaceAll(',', '').trim(),
    );

    if (message.isEmpty || expectedSalary == null || expectedSalary < 0) {
      setState(() => _showValidation = true);
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.of(context).pop(<String, dynamic>{
      'message': message,
      'expected_salary': expectedSalary,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Apply for This Job',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Introduce yourself and confirm your expected salary.',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  minLines: 4,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: 'Application message',
                    alignLabelWithHint: true,
                    errorText:
                        _showValidation &&
                                _messageController.text.trim().isEmpty
                            ? 'Please enter an application message.'
                            : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _salaryController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Expected salary (UGX)',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    errorText:
                        _showValidation &&
                                double.tryParse(
                                      _salaryController.text
                                          .replaceAll(',', '')
                                          .trim(),
                                    ) ==
                                    null
                            ? 'Enter a valid salary amount.'
                            : null,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: PremiumGradientButton(
                    label: 'Submit Application',
                    icon: Icons.send_rounded,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JobHeader extends StatelessWidget {
  const _JobHeader({required this.job, required this.onBack});

  final Map<String, dynamic> job;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.paddingOf(context).top + 10,
        18,
        24,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF177989), _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              if (job['is_urgent'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title']?.toString() ?? 'When & Where',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${job['district'] ?? 'Location not provided'} • ${_label(job['duration'])}',
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
        ],
      ),
    );
  }
}

class _SalaryCard extends StatelessWidget {
  const _SalaryCard({required this.job});

  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF177989), _primary]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, color: Colors.white, size: 34),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UGX ${_money(job['budget_amount'])}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _label(job['budget_type']),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.24 : 0.09,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _primary, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: _primary, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String _money(dynamic value) {
  final amount = double.tryParse(value?.toString() ?? '') ?? 0;
  return amount.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}

String _label(dynamic value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return 'Not provided';

  return raw
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) =>
            word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

String _prettyDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return 'Not specified';

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

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
