import 'package:flutter/material.dart';

import '../../services/hiring_service.dart';
import 'confirm_hiring_request_screen.dart';
import 'direct_hire_offer_screen.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF17324D);
const _muted = Color(0xFF6D8092);
const _line = Color(0xFFE5EDF2);

class ChooseHiringJobScreen extends StatefulWidget {
  const ChooseHiringJobScreen({
    super.key,
    required this.workerId,
    required this.workerName,
  });

  final int workerId;
  final String workerName;

  @override
  State<ChooseHiringJobScreen> createState() => _ChooseHiringJobScreenState();
}

class _ChooseHiringJobScreenState extends State<ChooseHiringJobScreen> {
  final HiringService _service = HiringService();

  bool _loading = true;
  bool _sendingQuick = false;
  String? _error;
  List<Map<String, dynamic>> _jobs = const [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getAvailableJobs();

    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _error =
            result['message']?.toString() ?? 'Unable to load your open jobs.';
        _loading = false;
      });
      return;
    }

    final jobs = <Map<String, dynamic>>[];
    final raw = result['jobs'];

    if (raw is List) {
      for (final value in raw) {
        if (value is Map) {
          jobs.add(Map<String, dynamic>.from(value));
        }
      }
    }

    setState(() {
      _jobs = jobs;
      _loading = false;
    });
  }

  Future<void> _hireNow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Send quick hiring request?'),
          content: Text(
            'Send ${widget.workerName} a direct hiring request now? '
            'You can discuss salary, start date and other job details in chat afterwards.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: _primary),
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _sendingQuick = true);

    final result = await _service.sendQuickHiringRequest(
      workerId: widget.workerId,
    );

    if (!mounted) return;

    setState(() => _sendingQuick = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                'Quick hiring request sent successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ?? 'Unable to send hiring request.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _customOffer() async {
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => DirectHireOfferScreen(
              workerId: widget.workerId,
              workerName: widget.workerName,
            ),
      ),
    );

    if (sent == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _selectJob(Map<String, dynamic> job) async {
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => ConfirmHiringRequestScreen(
              workerId: widget.workerId,
              workerName: widget.workerName,
              job: job,
            ),
      ),
    );

    if (sent == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hire ${widget.workerName}')),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: _loadJobs,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
          children: [
            const Text(
              'Choose how you want to hire',
              style: TextStyle(
                color: _navy,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'You have three ways to send ${widget.workerName} a hiring request.',
              style: const TextStyle(color: _muted, height: 1.4),
            ),
            const SizedBox(height: 20),

            _ChoiceCard(
              icon: Icons.flash_on_rounded,
              title: 'Hire Now',
              subtitle:
                  'Send a quick request immediately. No salary, date or job form required.',
              badge: 'FASTEST',
              emphasized: true,
              loading: _sendingQuick,
              onTap: _sendingQuick ? null : _hireNow,
            ),
            const SizedBox(height: 12),

            _ChoiceCard(
              icon: Icons.tune_rounded,
              title: 'Create Custom Job Offer',
              subtitle:
                  'Choose services, salary, location, work type, start date and a message.',
              badge: 'CUSTOM',
              onTap: _customOffer,
            ),
            const SizedBox(height: 20),

            const Row(
              children: [
                Expanded(child: Divider(color: _line)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR USE AN EXISTING JOB',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _muted,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: _line)),
              ],
            ),
            const SizedBox(height: 14),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: _primary),
                ),
              )
            else if (_error != null)
              _InfoCard(text: _error!, button: 'Try Again', onTap: _loadJobs)
            else if (_jobs.isEmpty)
              const _NoJobsCard()
            else
              ..._jobs.map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: _ExistingJobCard(
                    job: job,
                    onTap: () => _selectJob(job),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.badge,
    this.emphasized = false,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String badge;
  final bool emphasized;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: emphasized ? _navy : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: _primary.withValues(alpha: 0.15),
                child: Icon(icon, color: _primary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: emphasized ? Colors.white : _navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: _primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: emphasized ? const Color(0xFFD6E3EC) : _muted,
                        height: 1.35,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _primary,
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: emphasized ? Colors.white : _primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoJobsCard extends StatelessWidget {
  const _NoJobsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You have no open posted jobs right now. You can still use Hire Now or create a custom direct offer above.',
              style: TextStyle(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.text,
    required this.button,
    required this.onTap,
  });

  final String text;
  final String button;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.4),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onTap, child: Text(button)),
        ],
      ),
    );
  }
}

class _ExistingJobCard extends StatelessWidget {
  const _ExistingJobCard({required this.job, required this.onTap});

  final Map<String, dynamic> job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.work_outline_rounded, color: _primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title']?.toString() ?? 'Job',
                      style: const TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job['district']?.toString() ?? '',
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _primary),
            ],
          ),
        ),
      ),
    );
  }
}
