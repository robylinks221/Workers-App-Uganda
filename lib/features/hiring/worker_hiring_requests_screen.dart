import 'package:flutter/material.dart';

import '../../services/hiring_service.dart';
import '../../services/worker_job_service.dart';
import 'worker_hiring_request_details_screen.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class WorkerHiringRequestsScreen extends StatefulWidget {
  const WorkerHiringRequestsScreen({super.key});

  @override
  State<WorkerHiringRequestsScreen> createState() =>
      _WorkerHiringRequestsScreenState();
}

class _WorkerHiringRequestsScreenState
    extends State<WorkerHiringRequestsScreen> {
  final HiringService _hiringService = HiringService();
  final WorkerJobService _jobService = WorkerJobService();

  bool _loading = true;
  String? _error;
  int _selectedTab = 0;
  final Set<int> _workingApplications = <int>{};
  List<Map<String, dynamic>> _applications = const [];
  List<Map<String, dynamic>> _offers = const [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final results = await Future.wait<Map<String, dynamic>>([
      _jobService.getApplications(),
      _hiringService.getWorkerHiringRequests(),
    ]);

    if (!mounted) return;

    final applicationsResult = results[0];
    final offersResult = results[1];

    if (applicationsResult['success'] != true &&
        offersResult['success'] != true) {
      setState(() {
        _error =
            applicationsResult['message']?.toString() ??
            offersResult['message']?.toString() ??
            'Unable to load requests.';
        _loading = false;
      });
      return;
    }

    setState(() {
      _applications = _listOfMaps(applicationsResult['applications'])
          .where((item) => item['invited_by_homeowner'] != true)
          .toList();
      _offers = _listOfMaps(offersResult['hiring_requests']);
      _loading = false;
    });
  }

  Future<void> _openOffer(Map<String, dynamic> offer) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WorkerHiringRequestDetailsScreen(request: offer),
      ),
    );

    if (changed == true) {
      await _loadAll();
    }
  }

  Future<void> _withdrawApplication(Map<String, dynamic> application) async {
    final id = _asInt(application['id']);
    if (id <= 0 || _workingApplications.contains(id)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: const Text(
          'This application will be marked as withdrawn. If the job is still open, it can appear in available jobs again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _workingApplications.add(id));
    final result = await _jobService.withdrawApplication(id);

    if (!mounted) return;

    setState(() => _workingApplications.remove(id));
    _showMessage(
      result['message']?.toString() ?? 'Request completed.',
      success: result['success'] == true,
    );

    if (result['success'] == true) {
      await _loadAll();
    }
  }

  void _showMessage(String message, {required bool success}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? _navy : Colors.red.shade700,
        ),
      );
  }

  int get _pendingApplications => _applications
      .where((item) => item['status']?.toString() == 'pending')
      .length;

  int get _pendingOffers =>
      _offers.where((item) => item['status']?.toString() == 'pending').length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _RequestsHeader(
              pendingApplications: _pendingApplications,
              pendingOffers: _pendingOffers,
              onRefresh: _loadAll,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _RequestTabs(
                selectedIndex: _selectedTab,
                applications: _applications.length,
                offers: _offers.length,
                onChanged: (value) => setState(() => _selectedTab = value),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _primary),
                    )
                  : _error != null
                  ? _EmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Unable to load requests',
                      message: _error!,
                      buttonLabel: 'Try Again',
                      onPressed: _loadAll,
                    )
                  : _selectedTab == 0
                  ? _buildApplications()
                  : _buildOffers(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplications() {
    if (_applications.isEmpty) {
      return const _EmptyState(
        icon: Icons.description_outlined,
        title: 'No applications yet',
        message: 'Jobs you apply for will appear here with their status.',
      );
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _loadAll,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
        itemCount: _applications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final application = _applications[index];
          final status = application['status']?.toString() ?? 'pending';
          final job = _map(application['job']);
          final homeowner = _map(job['homeowner']);
          final id = _asInt(application['id']);

          return _ApplicationCard(
            title: job['title']?.toString() ?? 'Job application',
            district: job['district']?.toString() ?? '',
            homeowner: homeowner['full_name']?.toString() ?? '',
            status: status,
            expectedSalary: application['expected_salary']?.toString(),
            message: application['message']?.toString(),
            busy: _workingApplications.contains(id),
            onWithdraw: status == 'pending'
                ? () => _withdrawApplication(application)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildOffers() {
    if (_offers.isEmpty) {
      return const _EmptyState(
        icon: Icons.mark_email_unread_outlined,
        title: 'No direct job offers',
        message: 'Direct hiring requests from homeowners will appear here.',
      );
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _loadAll,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
        itemCount: _offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final offer = _offers[index];
          final job = _map(offer['job']);
          final homeowner = _map(offer['homeowner']);
          final status = offer['status']?.toString() ?? 'pending';

          return _OfferCard(
            title: job['title']?.toString() ?? 'Direct job offer',
            district: job['district']?.toString() ?? '',
            homeowner: homeowner['full_name']?.toString() ?? 'Homeowner',
            amount: offer['offered_amount']?.toString(),
            status: status,
            onTap: () => _openOffer(offer),
          );
        },
      ),
    );
  }
}

class _RequestsHeader extends StatelessWidget {
  const _RequestsHeader({
    required this.pendingApplications,
    required this.pendingOffers,
    required this.onRefresh,
  });

  final int pendingApplications;
  final int pendingOffers;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.paddingOf(context).top + 18,
        12,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, Color(0xFF177989), _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.assignment_turned_in_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$pendingApplications pending applications • $pendingOffers pending offers',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _RequestTabs extends StatelessWidget {
  const _RequestTabs({
    required this.selectedIndex,
    required this.applications,
    required this.offers,
    required this.onChanged,
  });

  final int selectedIndex;
  final int applications;
  final int offers;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              selected: selectedIndex == 0,
              label: 'My Applications',
              count: applications,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _TabButton(
              selected: selectedIndex == 1,
              label: 'Job Offers',
              count: offers,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.selected,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.surface : null,
          borderRadius: BorderRadius.circular(13),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected ? _navy : Theme.of(context).hintColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? _primary.withValues(alpha: 0.13)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.title,
    required this.district,
    required this.homeowner,
    required this.status,
    required this.expectedSalary,
    required this.message,
    required this.busy,
    required this.onWithdraw,
  });

  final String title;
  final String district;
  final String homeowner;
  final String status;
  final String? expectedSalary;
  final String? message;
  final bool busy;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              _StatusPill(status: status),
            ],
          ),
          if (district.isNotEmpty || homeowner.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              [homeowner, district].where((value) => value.isNotEmpty).join(' • '),
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ],
          if (expectedSalary != null && expectedSalary!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Expected salary: UGX ${_money(expectedSalary!)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          if (message != null && message!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(message!, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          if (onWithdraw != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: busy ? null : onWithdraw,
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.undo_rounded),
                label: const Text('Withdraw'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.title,
    required this.district,
    required this.homeowner,
    required this.amount,
    required this.status,
    required this.onTap,
  });

  final String title;
  final String district;
  final String homeowner;
  final String? amount;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              _StatusPill(status: status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            [homeowner, district].where((value) => value.isNotEmpty).join(' • '),
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          if (amount != null && amount!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Offer: UGX ${_money(amount!)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                status == 'pending' ? 'Tap to respond' : 'Tap to view details',
                style: const TextStyle(color: _primary, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: _primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  const _BaseCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.45),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'accepted' || 'in_progress' || 'completed' => Colors.green.shade700,
      'declined' || 'cancelled' => Colors.red.shade700,
      'withdrawn' => Colors.grey.shade700,
      _ => Colors.orange.shade800,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).hintColor),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor, height: 1.4),
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onPressed, child: Text(buttonLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> _listOfMaps(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _statusLabel(String status) {
  return switch (status) {
    'in_progress' => 'IN PROGRESS',
    'accepted' => 'ACCEPTED',
    'declined' => 'DECLINED',
    'withdrawn' => 'WITHDRAWN',
    'cancelled' => 'CANCELLED',
    'completed' => 'COMPLETED',
    _ => 'PENDING',
  };
}

String _money(String value) {
  final number = double.tryParse(value);
  if (number == null) return value;
  final digits = number.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
  }
  return buffer.toString();
}
