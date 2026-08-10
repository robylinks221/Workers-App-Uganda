import 'package:flutter/material.dart';

import '../../homeowner_review.dart';
import '../../job_chat_launcher.dart';
import '../../services/homeowner_job_service.dart';
import 'job_end_reason_sheet.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF123F67);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);
const _bg = Color(0xFFF4F7FA);
const _red = Color(0xFFE45B63);

class HomeownerJobLifecycleScreen extends StatefulWidget {
  const HomeownerJobLifecycleScreen({super.key, required this.jobId});

  final int jobId;

  @override
  State<HomeownerJobLifecycleScreen> createState() => _State();
}

class _State extends State<HomeownerJobLifecycleScreen> {
  final HomeownerJobService _service = HomeownerJobService();

  Map<String, dynamic>? _job;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.getJob(widget.jobId);

    if (!mounted) return;

    setState(() {
      _loading = false;

      if (result['success'] == true) {
        _job = Map<String, dynamic>.from(result['job'] as Map);
        _error = null;
      } else {
        _error = result['message']?.toString();
      }
    });
  }

  Future<void> _confirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Is the work finished?'),
          content: const Text(
            'Only confirm if you are satisfied that the agreed work has been completed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Not Yet'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: _primary),
              child: const Text('Yes, Work Is Finished'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);

    final result = await _service.confirmCompletion(widget.jobId);

    if (!mounted) return;

    setState(() => _busy = false);

    if (result['success'] == true) {
      await _showDone(
        'Job Completed',
        'You confirmed that the worker finished the job.',
      );
      await _load();
      return;
    }

    _message(result['message']?.toString() ?? 'We could not confirm the job.');
  }

  Future<void> _cancel() async {
    final result = await showJobEndReasonSheet(
      context: context,
      isWorker: false,
    );

    if (result == null || !mounted) return;

    setState(() => _busy = true);

    final response = await _service.cancelActiveJob(
      jobId: widget.jobId,
      reason: result.reason,
      note: result.note,
    );

    if (!mounted) return;

    setState(() => _busy = false);

    if (response['success'] == true) {
      Navigator.pop(context, true);
      return;
    }

    _message(
      response['message']?.toString() ?? 'We could not update this job.',
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _red,
        ),
      );
  }

  Future<void> _showDone(String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _primary, size: 34),
          ),
          title: Text(title, textAlign: TextAlign.center),
          content: Text(message, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(backgroundColor: _primary),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _primary)),
      );
    }

    if (_job == null) {
      return Scaffold(
        backgroundColor: _bg,
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
    final status = job['status']?.toString() ?? '';

    final worker =
        job['worker'] is Map
            ? Map<String, dynamic>.from(job['worker'])
            : <String, dynamic>{};

    final workerName = worker['full_name']?.toString() ?? 'Worker';

    final canCancel = [
      'accepted',
      'in_progress',
      'awaiting_confirmation',
    ].contains(status);

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ActiveJobHeader(
              title: job['title']?.toString() ?? 'Job',
              worker: workerName,
              district: job['district']?.toString() ?? '',
              status: status,
              onBack: () => Navigator.of(context).maybePop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _NextStep(
                  status: status,
                  busy: _busy,
                  onConfirm: _confirm,
                  onReview: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => HomeownerReviewScreen(
                              jobId: widget.jobId,
                              jobTitle: job['title']?.toString() ?? 'Job',
                            ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _GuideCard(
                  title: 'What Happens Next?',
                  subtitle:
                      'The app will guide you and the worker through each step.',
                  child: _Timeline(status: status),
                ),
                const SizedBox(height: 14),
                _GuideCard(
                  title: 'Need to Talk?',
                  subtitle:
                      'Message the worker if you need to explain the work or give directions.',
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          () => JobChatLauncher.open(
                            context: context,
                            jobId: widget.jobId,
                          ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        minimumSize: const Size.fromHeight(50),
                        side: const BorderSide(color: _primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: const Text(
                        'Message Worker',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
                if (canCancel) ...[
                  const SizedBox(height: 14),
                  _GuideCard(
                    title: 'Problem With This Job?',
                    subtitle: 'Only end the job if you really cannot continue.',
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: _busy ? null : _cancel,
                        style: TextButton.styleFrom(
                          foregroundColor: _red,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text(
                          status == 'in_progress'
                              ? 'End Job Early'
                              : 'Cancel This Job',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveJobHeader extends StatelessWidget {
  const _ActiveJobHeader({
    required this.title,
    required this.worker,
    required this.district,
    required this.status,
    required this.onBack,
  });

  final String title;
  final String worker;
  final String district;
  final String status;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 12,
        16,
        24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF123F67), Color(0xFF176B80), _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(14),
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE JOB',
                      style: TextStyle(
                        color: Color(0xFFC7E3E7),
                        fontSize: 9.5,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Work in Your Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _Status(status),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            worker,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (district.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white70,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  district,
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  const _NextStep({
    required this.status,
    required this.busy,
    required this.onConfirm,
    required this.onReview,
  });

  final String status;
  final bool busy;
  final VoidCallback onConfirm;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    if (status == 'accepted') {
      return const _InfoBox(
        icon: Icons.schedule_rounded,
        title: 'Waiting for the worker to start',
        message:
            'The worker accepted your job. They will tap Start This Job when the work begins.',
      );
    }

    if (status == 'in_progress') {
      return const _InfoBox(
        icon: Icons.home_repair_service_rounded,
        title: 'The worker has started',
        message:
            'Work is now in progress. You can message the worker if you need to explain anything.',
      );
    }

    if (status == 'awaiting_confirmation') {
      return _ActionBox(
        icon: Icons.task_alt_rounded,
        title: 'Is the work finished?',
        message:
            'The worker says the job is complete. Check the work before you confirm.',
        button: busy ? 'Confirming...' : 'Yes, Work Is Finished',
        onPressed: busy ? null : onConfirm,
      );
    }

    if (status == 'completed') {
      return _ActionBox(
        icon: Icons.star_rounded,
        title: 'How was the worker?',
        message:
            'The job is complete. Leave a rating and short review to help other homeowners.',
        button: 'Rate the Worker',
        onPressed: onReview,
      );
    }

    return _InfoBox(
      icon: Icons.info_outline_rounded,
      title: _statusText(status),
      message: 'This is the latest status of your job.',
    );
  }
}

class _ActionBox extends StatelessWidget {
  const _ActionBox({
    required this.icon,
    required this.title,
    required this.message,
    required this.button,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String button;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: _primary, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _slate,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                button,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primary, size: 29),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _slate,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.45,
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

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _slate,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: _muted, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Step(title: 'Worker accepted', done: true),
        _Step(
          title: 'Worker started work',
          done: [
            'in_progress',
            'awaiting_confirmation',
            'completed',
          ].contains(status),
        ),
        _Step(
          title: 'Worker says work is finished',
          done: ['awaiting_confirmation', 'completed'].contains(status),
        ),
        _Step(
          title: 'You confirmed the work',
          done: status == 'completed',
          last: true,
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.title, required this.done, this.last = false});

  final String title;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                color: done ? _primary : const Color(0xFFE5ECEF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                done ? Icons.check_rounded : Icons.circle_outlined,
                color: done ? Colors.white : _muted,
                size: 15,
              ),
            ),
            if (!last)
              Container(
                width: 2,
                height: 31,
                color:
                    done
                        ? _primary.withValues(alpha: 0.30)
                        : const Color(0xFFE5ECEF),
              ),
          ],
        ),
        const SizedBox(width: 11),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            title,
            style: TextStyle(
              color: done ? _slate : _muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _Status extends StatelessWidget {
  const _Status(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        _statusText(status).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _statusText(String status) {
  switch (status) {
    case 'accepted':
      return 'Waiting to Start';
    case 'in_progress':
      return 'Work Started';
    case 'awaiting_confirmation':
      return 'Check the Work';
    case 'completed':
      return 'Completed';
    default:
      return status.replaceAll('_', ' ');
  }
}
