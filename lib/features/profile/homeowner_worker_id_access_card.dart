import 'package:flutter/material.dart';

import '../../services/identity_access_service.dart';
import '../hiring/protected_worker_id_screen.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class HomeownerWorkerIdAccessCard extends StatefulWidget {
  const HomeownerWorkerIdAccessCard({
    super.key,
    required this.workerId,
    required this.workerName,
  });

  final int workerId;
  final String workerName;

  @override
  State<HomeownerWorkerIdAccessCard> createState() =>
      _HomeownerWorkerIdAccessCardState();
}

class _HomeownerWorkerIdAccessCardState
    extends State<HomeownerWorkerIdAccessCard> {
  final IdentityAccessService _service = IdentityAccessService();

  bool _loading = true;
  bool _busy = false;
  bool _eligible = false;
  Map<String, dynamic>? _access;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.status(widget.workerId);

    if (!mounted) return;

    setState(() {
      _loading = false;
      _eligible = result['eligible'] == true;
      _access =
          result['access'] is Map
              ? Map<String, dynamic>.from(result['access'])
              : null;
    });
  }

  Future<void> _request() async {
    setState(() => _busy = true);

    final result = await _service.requestAccess(widget.workerId);

    if (!mounted) return;

    setState(() => _busy = false);

    if (result['success'] != true) {
      _message(
        result['message']?.toString() ?? 'Unable to request ID access.',
        error: true,
      );
      return;
    }

    _message('Verified ID access is available for 24 hours.');

    await _load();
  }

  void _message(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? Colors.red.shade700 : _navy,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(color: _primary),
      );
    }

    final active = _access?['active'] == true;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, color: _primary, size: 21),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'IDENTITY VERIFIED',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            active
                ? 'Verified ID Available'
                : 'Want to Confirm This Worker’s Identity?',
            style: const TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            active
                ? 'Your temporary access is active. ID views are recorded for safety.'
                : _eligible
                ? 'You can request temporary access to this admin-verified worker’s National ID before deciding to hire.'
                : 'You can request access to this worker’s verified National ID. If their new front-and-back ID record is incomplete, the app will tell you what is still needed.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child:
                active
                    ? FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => ProtectedWorkerIdScreen(
                                  workerId: widget.workerId,
                                  workerName: widget.workerName,
                                ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(backgroundColor: _primary),
                      icon: const Icon(Icons.badge_outlined),
                      label: const Text(
                        'View Verified ID',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    )
                    : OutlinedButton.icon(
                      onPressed: _busy ? null : _request,
                      icon: const Icon(Icons.visibility_outlined),
                      label: Text(
                        _busy ? 'Requesting...' : 'Request to See ID',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
