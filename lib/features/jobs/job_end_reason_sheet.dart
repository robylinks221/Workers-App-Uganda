import 'package:flutter/material.dart';

class JobEndReasonResult {
  const JobEndReasonResult({required this.reason, required this.note});
  final String reason;
  final String note;
}

Future<JobEndReasonResult?> showJobEndReasonSheet({
  required BuildContext context,
  required bool isWorker,
}) {
  return showModalBottomSheet<JobEndReasonResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _JobEndReasonSheet(isWorker: isWorker),
  );
}

class _JobEndReasonSheet extends StatefulWidget {
  const _JobEndReasonSheet({required this.isWorker});
  final bool isWorker;

  @override
  State<_JobEndReasonSheet> createState() => _JobEndReasonSheetState();
}

class _JobEndReasonSheetState extends State<_JobEndReasonSheet> {
  final _note = TextEditingController();
  String? _reason;

  List<String> get _reasons =>
      widget.isWorker
          ? const [
            'Schedule conflict',
            'Personal reasons',
            'Salary or payment disagreement',
            'Job duties changed',
            'Transport or location problem',
            'Safety concern',
            'Other',
          ]
          : const [
            'Worker no longer needed',
            'Schedule changed',
            'Budget changed',
            'Worker did not meet requirements',
            'Job requirements changed',
            'Safety concern',
            'Other',
          ];

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isWorker ? 'Withdraw from this job?' : 'Cancel this job?',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isWorker
                  ? 'Choose a reason. The homeowner will be able to see that the engagement ended.'
                  : 'Choose a reason. The cancellation will be kept in the job history.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _reason,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              items:
                  _reasons
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
              onChanged: (v) => setState(() => _reason = v),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _note,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Additional explanation (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    _reason == null
                        ? null
                        : () => Navigator.pop(
                          context,
                          JobEndReasonResult(
                            reason: _reason!,
                            note: _note.text.trim(),
                          ),
                        ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(
                  widget.isWorker
                      ? 'Confirm Withdrawal'
                      : 'Confirm Cancellation',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
