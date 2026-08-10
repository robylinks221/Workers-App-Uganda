import 'package:flutter/material.dart';

import '../../job_chat_launcher.dart';
import '../../services/active_job_service.dart';
import 'job_end_reason_sheet.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF123F67);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);
const _bg = Color(0xFFF4F7FA);
const _red = Color(0xFFE45B63);

class WorkerActiveJobLifecycleScreen extends StatefulWidget {
  const WorkerActiveJobLifecycleScreen({super.key, required this.jobId});

  final int jobId;

  @override
  State<WorkerActiveJobLifecycleScreen> createState() => _State();
}

class _State extends State<WorkerActiveJobLifecycleScreen> {
  final ActiveJobService _service = ActiveJobService();

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
    final result = await _service.getWorkerJob(widget.jobId);

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

  Future<void> _act(bool start) async {
    setState(() => _busy = true);

    final result =
        start
            ? await _service.startJob(widget.jobId)
            : await _service.markWorkFinished(widget.jobId);

    if (!mounted) return;

    setState(() => _busy = false);

    if (result['success'] == true) {
      await _showActionSuccess(
        start ? 'Job Started' : 'Work Marked Finished',
        start
            ? 'The app now shows that you have started this job.'
            : 'The homeowner will now be asked to confirm that the work is finished.',
      );

      await _load();
      return;
    }

    _showMessage(
      result['message']?.toString() ?? 'We could not update the job.',
      success: false,
    );
  }

  Future<void> _withdraw() async {
    final result = await showJobEndReasonSheet(
      context: context,
      isWorker: true,
    );

    if (result == null || !mounted) return;

    setState(() => _busy = true);

    final response = await _service.withdrawFromJob(
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

    _showMessage(
      response['message']?.toString() ?? 'We could not update the job.',
      success: false,
    );
  }

  void _showMessage(String message, {required bool success}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? _navy : _red,
        ),
      );
  }

  Future<void> _showActionSuccess(String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.11),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _primary, size: 32),
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
    final status = job['status']?.toString() ?? 'accepted';

    final homeowner =
        job['homeowner'] is Map
            ? Map<String, dynamic>.from(job['homeowner'])
            : <String, dynamic>{};

    final homeownerName = homeowner['full_name']?.toString() ?? 'Homeowner';

    final canWithdraw = [
      'accepted',
      'in_progress',
      'awaiting_confirmation',
    ].contains(status);

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _JobWorkHeader(
              title: job['title']?.toString() ?? 'Job',
              homeowner: homeownerName,
              district: job['district']?.toString() ?? '',
              status: status,
              onBack: () => Navigator.of(context).maybePop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 125),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _NextStepCard(
                  status: status,
                  busy: _busy,
                  onStart: () => _act(true),
                  onFinished: () => _act(false),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  eyebrow: 'YOUR JOB',
                  title: 'What Happens Next?',
                  subtitle: 'Follow these steps so you always know what to do.',
                  child: _SimpleTimeline(job: job),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  eyebrow: 'NEED TO TALK?',
                  title: 'Message the Homeowner',
                  subtitle:
                      'Use chat if you need directions or want to ask about the work.',
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
                        'Message Homeowner',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
                if (canWithdraw) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    eyebrow: 'PROBLEM WITH THE JOB?',
                    title:
                        status == 'in_progress'
                            ? 'I Cannot Finish This Job'
                            : 'I Cannot Take This Job',
                    subtitle:
                        'Only use this if you really need to leave the job.',
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: _busy ? null : _withdraw,
                        style: TextButton.styleFrom(
                          foregroundColor: _red,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        icon: const Icon(Icons.exit_to_app_rounded),
                        label: Text(
                          status == 'in_progress'
                              ? 'End Job Early'
                              : 'Leave This Job',
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

class _JobWorkHeader extends StatelessWidget {
  const _JobWorkHeader({
    required this.title,
    required this.homeowner,
    required this.district,
    required this.status,
    required this.onBack,
  });

  final String title;
  final String homeowner;
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
        25,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C2D4B), Color(0xFF155A74), _primary],
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
                color: Colors.white.withValues(alpha: 0.12),
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
                      'MY WORK',
                      style: TextStyle(
                        color: Color(0xFFC7E3E7),
                        fontSize: 9.5,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Job I Am Doing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _SimpleStatus(status: status),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            homeowner,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (district.isNotEmpty) ...[
            const SizedBox(height: 7),
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

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({
    required this.status,
    required this.busy,
    required this.onStart,
    required this.onFinished,
  });

  final String status;
  final bool busy;
  final VoidCallback onStart;
  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context) {
    if (status == 'accepted') {
      return _ActionCard(
        icon: Icons.play_arrow_rounded,
        eyebrow: 'NEXT STEP',
        title: 'Ready to start work?',
        message: 'Tap the button when you arrive and begin the job.',
        buttonText: busy ? 'Starting...' : 'Start This Job',
        onPressed: busy ? null : onStart,
      );
    }

    if (status == 'in_progress') {
      return _ActionCard(
        icon: Icons.task_alt_rounded,
        eyebrow: 'WORK IN PROGRESS',
        title: 'Are you finished?',
        message: 'Only tap finished when you have completed the work.',
        buttonText: busy ? 'Updating...' : 'I Finished the Work',
        onPressed: busy ? null : onFinished,
      );
    }

    if (status == 'awaiting_confirmation') {
      return const _InfoActionCard(
        icon: Icons.hourglass_top_rounded,
        title: 'Waiting for the homeowner',
        message:
            'You said the work is finished. The homeowner now needs to confirm it.',
      );
    }

    if (status == 'completed') {
      return const _InfoActionCard(
        icon: Icons.verified_rounded,
        title: 'Job Completed',
        message: 'The homeowner confirmed that this job is finished.',
      );
    }

    return _InfoActionCard(
      icon: Icons.info_outline_rounded,
      title: _statusText(status),
      message: 'Open this page to see the latest job status.',
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String message;
  final String buttonText;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: _primary, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 9.5,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        color: _slate,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: _muted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 16),
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
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoActionCard extends StatelessWidget {
  const _InfoActionCard({
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
          Icon(icon, color: _primary, size: 28),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String eyebrow;
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
            blurRadius: 17,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: _primary,
              fontSize: 9.5,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
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

class _SimpleTimeline extends StatelessWidget {
  const _SimpleTimeline({required this.job});

  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    final status = job['status']?.toString() ?? '';

    return Column(
      children: [
        _TimelineRow(
          title: 'You accepted the job',
          subtitle: 'The job is now yours.',
          done: true,
        ),
        _TimelineRow(
          title: 'Start the work',
          subtitle: 'Tap Start This Job when you begin.',
          done: [
            'in_progress',
            'awaiting_confirmation',
            'completed',
          ].contains(status),
        ),
        _TimelineRow(
          title: 'Finish the work',
          subtitle: 'Tell the app when the work is done.',
          done: ['awaiting_confirmation', 'completed'].contains(status),
        ),
        _TimelineRow(
          title: 'Homeowner confirms',
          subtitle: 'The homeowner confirms the job is complete.',
          done: status == 'completed',
          last: true,
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.subtitle,
    required this.done,
    this.last = false,
  });

  final String title;
  final String subtitle;
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
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: done ? _primary : const Color(0xFFE5ECEF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                done ? Icons.check_rounded : Icons.circle_outlined,
                color: done ? Colors.white : _muted,
                size: 16,
              ),
            ),
            if (!last)
              Container(
                width: 2,
                height: 40,
                color:
                    done
                        ? _primary.withValues(alpha: 0.30)
                        : const Color(0xFFE5ECEF),
              ),
          ],
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: done ? _slate : _muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SimpleStatus extends StatelessWidget {
  const _SimpleStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
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
      return 'Ready to Start';
    case 'in_progress':
      return 'Work Started';
    case 'awaiting_confirmation':
      return 'Waiting for Homeowner';
    case 'completed':
      return 'Completed';
    default:
      return status.replaceAll('_', ' ').trim();
  }
}
