import 'package:flutter/material.dart';

import 'services/homeowner_job_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF123F67);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);
const _background = Color(0xFFF4F7FA);

class HomeownerReviewScreen extends StatefulWidget {
  const HomeownerReviewScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
    this.existingReview,
  });

  final int jobId;
  final String jobTitle;
  final Map<String, dynamic>? existingReview;

  @override
  State<HomeownerReviewScreen> createState() => _HomeownerReviewScreenState();
}

class _HomeownerReviewScreenState extends State<HomeownerReviewScreen> {
  final HomeownerJobService _service = HomeownerJobService();

  final TextEditingController _commentController = TextEditingController();

  int _rating = 5;
  bool _submitting = false;

  bool get _isEditing => widget.existingReview != null;

  @override
  void initState() {
    super.initState();

    final review = widget.existingReview;

    if (review != null) {
      _rating = _asInt(review['rating']).clamp(1, 5);

      _commentController.text = review['comment']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _commentController.text.trim();

    if (comment.isEmpty) {
      _showMessage('Please tell us a little about the worker.', success: false);
      return;
    }

    setState(() => _submitting = true);

    final result =
        _isEditing
            ? await _service.updateReview(
              jobId: widget.jobId,
              rating: _rating,
              comment: comment,
            )
            : await _service.createReview(
              jobId: widget.jobId,
              rating: _rating,
              comment: comment,
            );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (result['success'] == true) {
      await _showSaved();

      if (mounted) {
        Navigator.of(context).pop(true);
      }

      return;
    }

    _showMessage(
      result['message']?.toString() ?? 'We could not save your review.',
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
          backgroundColor: success ? _navy : Colors.red.shade700,
        ),
      );
  }

  Future<void> _showSaved() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
          title: Text(
            _isEditing ? 'Review Updated' : 'Thank You',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            _isEditing
                ? 'Your changes have been saved.'
                : 'Your review has been saved. It can help other homeowners understand this worker better.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(backgroundColor: _primary),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF123F67), Color(0xFF176B80), _primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Material(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR FEEDBACK',
                          style: TextStyle(
                            color: Color(0xFFC7E3E7),
                            fontSize: 9.5,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          _isEditing
                              ? 'Change Your Review'
                              : 'How Was the Worker?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Your review helps other homeowners.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.jobTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _slate,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'How many stars would you give this worker?',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final value = index + 1;

                            return IconButton(
                              onPressed: () {
                                setState(() {
                                  _rating = value;
                                });
                              },
                              iconSize: 38,
                              icon: Icon(
                                value <= _rating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: const Color(0xFFFFB300),
                              ),
                            );
                          }),
                        ),
                        Text(
                          _ratingText(_rating),
                          style: const TextStyle(
                            color: _slate,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tell Other Homeowners',
                          style: TextStyle(
                            color: _slate,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Write a short and simple comment about your experience.',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentController,
                          minLines: 5,
                          maxLines: 8,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText:
                                'Example: She arrived on time and did the work well.',
                            filled: true,
                            fillColor: const Color(0xFFF5F8FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(17),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: _primary,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      icon:
                          _submitting
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.check_rounded),
                      label: Text(
                        _submitting
                            ? 'Saving...'
                            : _isEditing
                            ? 'Save Changes'
                            : 'Save My Review',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _ratingText(int rating) {
  switch (rating) {
    case 1:
      return 'Poor';
    case 2:
      return 'Not Good';
    case 3:
      return 'Okay';
    case 4:
      return 'Good';
    case 5:
      return 'Excellent';
    default:
      return '$rating stars';
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
