import 'package:flutter/material.dart';

import '../../chat_screen.dart';
import '../../config/api_config.dart';
import '../../services/chat_service.dart';
import '../../services/worker_public_profile_service.dart';
import 'homeowner_worker_id_access_card.dart';
import '../../widgets/premium_buttons.dart';
import '../hiring/choose_hiring_job_screen.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);
const _gold = Color(0xFFFFB300);

class WorkerPublicProfileScreen extends StatefulWidget {
  const WorkerPublicProfileScreen({
    super.key,
    required this.workerId,
    this.previewMode = false,
  });

  final int workerId;
  final bool previewMode;

  @override
  State<WorkerPublicProfileScreen> createState() =>
      _WorkerPublicProfileScreenState();
}

class _WorkerPublicProfileScreenState extends State<WorkerPublicProfileScreen> {
  final WorkerPublicProfileService _service = WorkerPublicProfileService();
  final ChatService _chatService = ChatService();

  Map<String, dynamic>? _worker;
  Map<String, dynamic>? _profile;
  List<dynamic> _reviews = const [];

  bool _loading = true;
  bool _savingWorker = false;
  bool _startingChat = false;
  bool _isSaved = false;
  bool _isOwnProfile = false;
  String _viewerRole = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getWorkerProfile(widget.workerId);

    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _error =
            result['message']?.toString() ?? 'Unable to load worker profile.';
        _loading = false;
      });
      return;
    }

    final viewer = _map(result['viewer']);

    setState(() {
      _worker = _map(result['worker']);
      _profile = _map(result['profile']);
      _reviews =
          result['reviews'] is List ? result['reviews'] as List : const [];
      _viewerRole = viewer['role']?.toString() ?? '';
      _isSaved = viewer['is_saved'] == true;
      _isOwnProfile = viewer['is_own_profile'] == true;
      _loading = false;
    });
  }

  Future<void> _toggleSaved() async {
    if (_savingWorker) return;

    setState(() => _savingWorker = true);

    final result =
        _isSaved
            ? await _service.removeSavedWorker(widget.workerId)
            : await _service.saveWorker(widget.workerId);

    if (!mounted) return;

    setState(() => _savingWorker = false);

    final success = result['success'] == true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ?? 'Saved worker request completed.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? _navy : Colors.red.shade700,
      ),
    );

    if (success) {
      setState(() {
        _isSaved = result['is_saved'] == true;
      });
    }
  }

  Future<void> _chat() async {
    if (_startingChat) return;

    setState(() => _startingChat = true);

    try {
      final conversation = await _chatService.createDirectConversation(
        widget.workerId,
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(conversation: conversation),
        ),
      );
    } on ChatServiceException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _startingChat = false);
      }
    }
  }

  Future<void> _hire() async {
    final worker = _worker ?? const <String, dynamic>{};
    final workerName = worker['full_name']?.toString() ?? 'Worker';

    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => ChooseHiringJobScreen(
              workerId: widget.workerId,
              workerName: workerName,
            ),
      ),
    );

    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hiring request sent successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final showHomeownerActions =
        !widget.previewMode && _viewerRole == 'homeowner' && !_isOwnProfile;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: null,
      body:
          _loading
              ? const _LoadingState()
              : _error != null
              ? _ErrorState(message: _error!, onRetry: _loadProfile)
              : RefreshIndicator(
                color: _primary,
                onRefresh: _loadProfile,
                child: _ProfileBody(
                  worker: _worker ?? const {},
                  profile: _profile ?? const {},
                  reviews: _reviews,
                  previewMode: widget.previewMode,
                  isSaved: _isSaved,
                  saving: _savingWorker,
                  showSave: showHomeownerActions,
                  onSave: _toggleSaved,
                  workerId: widget.workerId,
                  showIdentityAccess: showHomeownerActions,
                ),
              ),
      bottomNavigationBar:
          showHomeownerActions
              ? _BottomActionBar(
                isSaved: _isSaved,
                saving: _savingWorker,
                startingChat: _startingChat,
                onSave: _toggleSaved,
                onChat: _chat,
                onHire: _hire,
              )
              : null,
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.worker,
    required this.profile,
    required this.reviews,
    required this.previewMode,
    required this.isSaved,
    required this.saving,
    required this.showSave,
    required this.onSave,
    required this.workerId,
    required this.showIdentityAccess,
  });

  final Map<String, dynamic> worker;
  final Map<String, dynamic> profile;
  final List<dynamic> reviews;
  final bool previewMode;
  final bool isSaved;
  final bool saving;
  final bool showSave;
  final VoidCallback onSave;
  final int workerId;
  final bool showIdentityAccess;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final name = worker['full_name']?.toString() ?? 'Worker';
    final district =
        profile['district']?.toString() ?? worker['location']?.toString() ?? '';

    final imageUrl = ApiConfig.storageUrl(
      worker['profile_photo']?.toString() ??
          profile['profile_photo']?.toString(),
    );

    final coverUrl = ApiConfig.storageUrl(
      profile['cover_photo']?.toString() ?? profile['cover_image']?.toString(),
    );

    final rating = profile['rating']?.toString() ?? '0.00';
    final totalReviews = profile['total_reviews']?.toString() ?? '0';
    final jobsCompleted = profile['jobs_completed']?.toString() ?? '0';
    final experience = profile['experience_years']?.toString() ?? '0';
    final gallery = _gallery(profile['gallery_images']);
    final services = _services(profile['services']);
    final languages = _stringList(profile['languages']);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 140),
      children: [
        _GalleryHeroSlider(
          gallery: gallery,
          fallbackImageUrl: coverUrl.isNotEmpty ? coverUrl : imageUrl,
          isSaved: isSaved,
          saving: saving,
          showSave: showSave,
          onSave: onSave,
          previewMode: previewMode,
        ),
        Transform.translate(
          offset: const Offset(0, -30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _WorkerIdentitySummary(
              name: name,
              district: district,
              imageUrl: imageUrl,
              rating: rating,
              reviews: totalReviews,
              availability:
                  profile['availability']?.toString() ?? 'unavailable',
              featured: profile['featured'] == true,
              verified:
                  worker['is_verified'] == true ||
                  profile['identity_verified'] == true,
              joinedLabel: _joinedLabel(worker['created_at']),
              serviceTitle: _primaryService(services),
            ),
          ),
        ),
        const SizedBox(height: 0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: _StatisticsGrid(
            items: [
              _StatisticData(
                icon: Icons.work_history_outlined,
                value: jobsCompleted,
                label: 'Jobs Completed',
              ),
              _StatisticData(
                icon: Icons.star_outline_rounded,
                value: rating,
                label: 'Homeowner Rating',
              ),
              _StatisticData(
                icon: Icons.workspace_premium_outlined,
                value: '$experience yrs',
                label: 'Experience',
              ),
              _StatisticData(
                icon: Icons.reviews_outlined,
                value: totalReviews,
                label: 'What Homeowners Say',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: _VerificationSection(profile: profile, worker: worker),
        ),
        if (showIdentityAccess && profile['identity_verified'] == true) ...[
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: HomeownerWorkerIdAccessCard(
              workerId: workerId,
              workerName: name,
            ),
          ),
        ],
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: _SectionCard(
            title: 'About Me',
            icon: Icons.person_outline_rounded,
            child: Text(
              _textOrFallback(
                profile['bio'],
                'This worker has not added a biography yet.',
              ),
              style: TextStyle(
                color: colors.onSurfaceVariant,
                height: 1.55,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: _SectionCard(
            title: 'What This Worker Can Do',
            icon: Icons.cleaning_services_outlined,
            child:
                services.isEmpty
                    ? Text(
                      'This worker has not listed any services yet.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    )
                    : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          services
                              .map((service) => _ServiceChip(label: service))
                              .toList(),
                    ),
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: _SectionCard(
            title: 'About This Worker',
            icon: Icons.badge_outlined,
            child: _DetailsGrid(
              items: [
                _DetailData(
                  'Experience',
                  '$experience years',
                  Icons.history_rounded,
                ),
                _DetailData(
                  'Work Type',
                  _label(profile['work_type']),
                  Icons.schedule_rounded,
                ),
                _DetailData(
                  'Religion',
                  _label(profile['religion']),
                  Icons.self_improvement_rounded,
                ),
                _DetailData(
                  'Gender',
                  _label(profile['gender']),
                  Icons.wc_rounded,
                ),
                if (languages.isNotEmpty)
                  _DetailData(
                    'Languages Spoken',
                    languages.join(', '),
                    Icons.language_rounded,
                  ),
                if (profile['expected_salary'] != null)
                  _DetailData(
                    'Expected Salary',
                    'UGX ${_money(profile['expected_salary'])}',
                    Icons.payments_outlined,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: _SectionCard(
            title: 'What Homeowners Say',
            icon: Icons.star_outline_rounded,
            child:
                reviews.isEmpty
                    ? Text(
                      'No homeowner reviews yet.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    )
                    : Column(
                      children:
                          reviews
                              .take(5)
                              .map(
                                (review) => _ReviewCard(review: _map(review)),
                              )
                              .toList(),
                    ),
          ),
        ),
        if (previewMode) ...[
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.visibility_outlined, color: _primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is how homeowners see your profile.',
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GalleryHeroSlider extends StatefulWidget {
  const _GalleryHeroSlider({
    required this.gallery,
    required this.fallbackImageUrl,
    required this.isSaved,
    required this.saving,
    required this.showSave,
    required this.onSave,
    required this.previewMode,
  });

  final List<String> gallery;
  final String fallbackImageUrl;
  final bool isSaved;
  final bool saving;
  final bool showSave;
  final VoidCallback onSave;
  final bool previewMode;

  @override
  State<_GalleryHeroSlider> createState() => _GalleryHeroSliderState();
}

class _GalleryHeroSliderState extends State<_GalleryHeroSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<String> get _images {
    if (widget.gallery.isNotEmpty) {
      return widget.gallery.take(3).toList();
    }

    if (widget.fallbackImageUrl.isNotEmpty) {
      return [widget.fallbackImageUrl];
    }

    return const <String>[];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    final topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 410,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE9EFF3),
              child:
                  images.isEmpty
                      ? const _GalleryEmptyHero()
                      : PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          return _GalleryHeroImage(imageUrl: images[index]);
                        },
                      ),
            ),
          ),

          // Premium dark fade to keep controls clear over every photo.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.36),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.20),
                    ],
                    stops: const [0, 0.26, 0.74, 1],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: topInset + 12,
            left: 16,
            child: _HeroGlassButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),

          if (widget.showSave)
            Positioned(
              top: topInset + 12,
              right: 16,
              child: _HeroGlassButton(
                icon:
                    widget.isSaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                tooltip: widget.isSaved ? 'Remove saved worker' : 'Save worker',
                active: widget.isSaved,
                loading: widget.saving,
                onTap: widget.saving ? null : widget.onSave,
              ),
            ),

          if (widget.previewMode)
            Positioned(
              top: topInset + 18,
              right: 76,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PROFILE PREVIEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

          if (images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: index == _currentPage ? 24 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color:
                          index == _currentPage
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.52),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),

          if (images.length > 1)
            Positioned(
              right: 16,
              bottom: 46,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.44),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1}/${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryHeroImage extends StatelessWidget {
  const _GalleryHeroImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'worker-gallery-$imageUrl',
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const _GalleryEmptyHero(),
      ),
    );
  }
}

class _GalleryEmptyHero extends StatelessWidget {
  const _GalleryEmptyHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF173B5B), Color(0xFF1B7381), Color(0xFF1FB8B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.photo_library_outlined,
          color: Colors.white54,
          size: 62,
        ),
      ),
    );
  }
}

class _HeroGlassButton extends StatelessWidget {
  const _HeroGlassButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
    this.loading = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool active;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color:
            active
                ? const Color(0xFFE94877).withValues(alpha: 0.92)
                : Colors.black.withValues(alpha: 0.48),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onTap,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Center(
              child:
                  loading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkerIdentitySummary extends StatelessWidget {
  const _WorkerIdentitySummary({
    required this.name,
    required this.district,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.availability,
    required this.featured,
    required this.verified,
    required this.joinedLabel,
    required this.serviceTitle,
  });

  final String name;
  final String district;
  final String imageUrl;
  final String rating;
  final String reviews;
  final String availability;
  final bool featured;
  final bool verified;
  final String joinedLabel;
  final String serviceTitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final available = availability.trim().toLowerCase() == 'available';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 82,
                height: 82,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      imageUrl.isEmpty
                          ? Container(
                            color: _primary.withValues(alpha: 0.12),
                            child: Center(
                              child: Text(
                                _initials(name),
                                style: const TextStyle(
                                  color: _primary,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          )
                          : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  color: _primary.withValues(alpha: 0.12),
                                  child: Center(
                                    child: Text(
                                      _initials(name),
                                      style: const TextStyle(
                                        color: _primary,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 22,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (verified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: _primary,
                            size: 21,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      serviceTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (district.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: colors.onSurfaceVariant,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              district,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _WorkerSummaryPill(
                icon:
                    available
                        ? Icons.check_circle_rounded
                        : Icons.schedule_rounded,
                label: available ? 'Available Now' : _label(availability),
                accent:
                    available
                        ? const Color(0xFF1F9D68)
                        : colors.onSurfaceVariant,
              ),
              _WorkerSummaryPill(
                icon: Icons.star_rounded,
                label: '$rating ($reviews)',
                accent: _gold,
              ),
              if (verified)
                const _WorkerSummaryPill(
                  icon: Icons.verified_user_rounded,
                  label: 'Identity Verified',
                  accent: _primary,
                ),
              if (featured)
                const _WorkerSummaryPill(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Recommended',
                  accent: _gold,
                ),
            ],
          ),
          if (joinedLabel.trim().isNotEmpty) ...[
            const SizedBox(height: 13),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 14,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Text(
                  joinedLabel,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkerSummaryPill extends StatelessWidget {
  const _WorkerSummaryPill({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.name,
    required this.district,
    required this.imageUrl,
    required this.coverUrl,
    required this.rating,
    required this.reviews,
    required this.availability,
    required this.featured,
    required this.verified,
    required this.joinedLabel,
    required this.serviceTitle,
    required this.isSaved,
    required this.saving,
    required this.showSave,
    required this.onSave,
    required this.previewMode,
  });

  final String name;
  final String district;
  final String imageUrl;
  final String coverUrl;
  final String rating;
  final String reviews;
  final String availability;
  final bool featured;
  final bool verified;
  final String joinedLabel;
  final String serviceTitle;
  final bool isSaved;
  final bool saving;
  final bool showSave;
  final VoidCallback onSave;
  final bool previewMode;

  @override
  Widget build(BuildContext context) {
    final isAvailable = availability == 'available';
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF08253F), Color(0xFF124E6D), Color(0xFF1FB8B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Stack(
        children: [
          if (coverUrl.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                child: Opacity(
                  opacity: 0.08,
                  child: Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          Positioned(
            right: -52,
            top: -55,
            child: _HeroGlow(size: 185, opacity: 0.055),
          ),
          Positioned(
            left: -70,
            bottom: -85,
            child: _HeroGlow(size: 175, opacity: 0.04),
          ),
          Column(
            children: [
              Row(
                children: [
                  _HeroTopAction(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  if (previewMode)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            color: Colors.white,
                            size: 15,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'PROFILE PREVIEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (showSave)
                    _HeroTopAction(
                      icon:
                          isSaved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                      tooltip:
                          isSaved ? 'Remove saved worker' : 'Save for later',
                      loading: saving,
                      active: isSaved,
                      onTap: saving ? null : onSave,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 116,
                          height: 116,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.70),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.12,
                            ),
                            backgroundImage:
                                imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : null,
                            child:
                                imageUrl.isEmpty
                                    ? Text(
                                      _initials(name),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                        if (verified)
                          Positioned(
                            right: 2,
                            bottom: 5,
                            child: Container(
                              width: 31,
                              height: 31,
                              decoration: BoxDecoration(
                                color: const Color(0xFF79E2C0),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF124E6D),
                                  width: 2.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF08253F),
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      serviceTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFCFE5EA),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (district.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white70,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              district,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _PremiumHeroMetric(
                            icon: Icons.star_rounded,
                            value: rating,
                            label: '$reviews reviews',
                            accent: _gold,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _PremiumHeroMetric(
                            icon:
                                isAvailable
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.schedule_rounded,
                            value: _label(availability),
                            label: 'Availability',
                            accent:
                                isAvailable
                                    ? const Color(0xFF8CF0CE)
                                    : Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _PremiumHeroMetric(
                            icon: Icons.verified_user_outlined,
                            value: verified ? 'Verified' : 'Pending',
                            label: 'Identity',
                            accent: const Color(0xFF8CF0CE),
                          ),
                        ),
                      ],
                    ),
                    if (featured || joinedLabel.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (featured)
                            const _HeroStatusPill(
                              label: 'Recommended Worker',
                              icon: Icons.workspace_premium_rounded,
                              accent: Color(0xFFFFD66B),
                            ),
                          if (joinedLabel.isNotEmpty)
                            _HeroStatusPill(
                              label: joinedLabel,
                              icon: Icons.schedule_rounded,
                              accent: Colors.white70,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (showSave) ...[
                const SizedBox(height: 13),
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color:
                        isSaved
                            ? const Color(0xFFE94877).withValues(alpha: 0.85)
                            : Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(18),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: saving ? null : onSave,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (saving)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              Icon(
                                isSaved
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              isSaved ? 'Saved for Later' : 'Save Worker',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumHeroMetric extends StatelessWidget {
  const _PremiumHeroMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 8.5),
          ),
        ],
      ),
    );
  }
}

class _HeroTopAction extends StatelessWidget {
  const _HeroTopAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.loading = false,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool loading;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color:
            active
                ? const Color(0xFFE94877).withValues(alpha: 0.82)
                : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Center(
              child:
                  loading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Icon(icon, color: Colors.white, size: 21),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroInfoPill extends StatelessWidget {
  const _HeroInfoPill({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 210),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? Colors.white, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatusPill extends StatelessWidget {
  const _HeroStatusPill({
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroGlow extends StatelessWidget {
  const _HeroGlow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PremiumCoverFallback extends StatelessWidget {
  const _PremiumCoverFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF164D7A), Color(0xFF177989), Color(0xFF1FB8B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.home_work_outlined, color: Colors.white30, size: 84),
      ),
    );
  }
}

class _MiniMeta extends StatelessWidget {
  const _MiniMeta({required this.icon, required this.label, this.iconColor});

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor ?? muted, size: 17),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  const _StatisticsGrid({required this.items});

  final List<_StatisticData> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.65,
      ),
      itemBuilder: (_, index) => _StatisticCard(data: items[index]),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({required this.data});

  final _StatisticData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.24 : 0.09,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(data.icon, color: _primary, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
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

class _VerificationSection extends StatelessWidget {
  const _VerificationSection({required this.profile, required this.worker});

  final Map<String, dynamic> profile;
  final Map<String, dynamic> worker;

  @override
  Widget build(BuildContext context) {
    final badges = [
      _VerificationData(
        'National ID',
        profile['identity_verified'] == true,
        Icons.badge_outlined,
      ),
      _VerificationData(
        'Phone',
        worker['phone_verified'] == true || worker['phone_verified_at'] != null,
        Icons.phone_android_rounded,
      ),
      _VerificationData(
        'Background',
        profile['background_checked'] == true,
        Icons.security_rounded,
      ),
      _VerificationData(
        'Police',
        profile['police_clearance'] == true,
        Icons.local_police_outlined,
      ),
    ];

    return _SectionCard(
      title: 'Trust & Verification',
      icon: Icons.verified_user_outlined,
      child: Wrap(
        spacing: 9,
        runSpacing: 9,
        children:
            badges.map((badge) {
              final color =
                  badge.verified
                      ? const Color(0xFF16A957)
                      : Theme.of(context).colorScheme.onSurfaceVariant;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      badge.verified ? Icons.check_circle_rounded : badge.icon,
                      color: color,
                      size: 17,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badge.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.24 : 0.09,
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: _primary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.items});

  final List<_DetailData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];

        return Padding(
          padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 13),
          child: _DetailRow(data: item),
        );
      }),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.data});

  final _DetailData data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(data.icon, color: _primary, size: 19),
        const SizedBox(width: 10),
        SizedBox(
          width: 105,
          child: Text(
            data.label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            data.value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (_, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            images[index],
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
          ),
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reviewer = _map(review['homeowner']);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123F67).withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) {
                  final reviewerPhoto = ApiConfig.storageUrl(
                    reviewer['profile_photo']?.toString(),
                  );

                  return CircleAvatar(
                    radius: 21,
                    backgroundColor: _primary.withValues(alpha: 0.14),
                    backgroundImage:
                        reviewerPhoto.isNotEmpty
                            ? NetworkImage(reviewerPhoto)
                            : null,
                    child:
                        reviewerPhoto.isEmpty
                            ? Text(
                              _initials(
                                reviewer['full_name']?.toString() ??
                                    'Homeowner',
                              ),
                              style: const TextStyle(
                                color: _primary,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                            : null,
                  );
                },
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewer['full_name']?.toString() ?? 'Homeowner',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _reviewMeta(review),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: _gold, size: 18),
                  const SizedBox(width: 3),
                  Text(
                    review['rating']?.toString() ?? '0',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _textOrFallback(review['comment'], 'No comment provided.'),
            style: TextStyle(
              color: colors.onSurfaceVariant,
              height: 1.45,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.isSaved,
    required this.saving,
    required this.startingChat,
    required this.onSave,
    required this.onChat,
    required this.onHire,
  });

  final bool isSaved;
  final bool saving;
  final bool startingChat;
  final VoidCallback onSave;
  final VoidCallback onChat;
  final VoidCallback onHire;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      elevation: 18,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
          child: Row(
            children: [
              PremiumActionIconButton(
                tooltip: isSaved ? 'Remove saved worker' : 'Save for later',
                icon:
                    isSaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                active: isSaved,
                loading: saving,
                onPressed: onSave,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: PremiumOutlineButton(
                  label: 'Chat',
                  icon: Icons.chat_bubble_outline_rounded,
                  loading: startingChat,
                  onPressed: onChat,
                  size: PremiumButtonSize.regular,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                flex: 2,
                child: PremiumGradientButton(
                  label: 'Offer Job',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: onHire,
                  size: PremiumButtonSize.regular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: colors.primary, size: 58),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 17),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticData {
  const _StatisticData({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

class _DetailData {
  const _DetailData(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _VerificationData {
  const _VerificationData(this.label, this.verified, this.icon);

  final String label;
  final bool verified;
  final IconData icon;
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<String> _gallery(dynamic value) {
  if (value is! List) return const [];

  final items = <(int, String)>[];

  for (final raw in value) {
    final item = _map(raw);
    final path =
        item['image_path']?.toString() ??
        item['path']?.toString() ??
        item['image']?.toString() ??
        '';

    final url = ApiConfig.storageUrl(path);
    final position =
        int.tryParse(item['position']?.toString() ?? '') ?? items.length;

    if (url.isNotEmpty) {
      items.add((position, url));
    }
  }

  items.sort((a, b) => a.$1.compareTo(b.$1));
  return items.map((item) => item.$2).toList();
}

List<String> _services(dynamic value) {
  if (value is! List) return const [];

  return value
      .map((raw) {
        final item = _map(raw);
        return item['name']?.toString() ?? '';
      })
      .where((name) => name.trim().isNotEmpty)
      .map(_label)
      .toList();
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) {
          if (item is Map) {
            return item['name']?.toString() ?? '';
          }
          return item?.toString() ?? '';
        })
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }

  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return const [];

  return raw
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

String _primaryService(List<String> services) {
  if (services.isEmpty) return 'Domestic Worker';
  return services.first;
}

String _label(dynamic value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return 'Not provided';

  return text
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

String _textOrFallback(dynamic value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String _joinedLabel(dynamic value) {
  final raw = value?.toString().trim() ?? '';
  final date = DateTime.tryParse(raw)?.toLocal();
  if (date == null) return '';

  var difference = DateTime.now().difference(date);
  if (difference.isNegative) difference = Duration.zero;

  if (difference.inMinutes < 1) return 'Joined just now';
  if (difference.inHours < 1) {
    return 'Joined ${difference.inMinutes} min ago';
  }
  if (difference.inDays < 1) {
    return 'Joined ${difference.inHours} hr ago';
  }
  if (difference.inDays == 1) return 'Joined yesterday';
  if (difference.inDays < 7) {
    return 'Joined ${difference.inDays} days ago';
  }
  if (difference.inDays < 14) return 'Joined last week';
  if (difference.inDays < 30) {
    return 'Joined ${(difference.inDays / 7).floor()} weeks ago';
  }
  if (difference.inDays < 60) return 'Joined last month';
  if (difference.inDays < 365) {
    return 'Joined ${(difference.inDays / 30).floor()} months ago';
  }
  if (difference.inDays < 730) return 'Joined last year';
  return 'Joined ${(difference.inDays / 365).floor()} years ago';
}

String _reviewMeta(Map<String, dynamic> review) {
  final job = _map(review['job']);
  final title = job['title']?.toString().trim() ?? '';
  final created = review['created_at']?.toString();

  String date = '';
  if (created != null && created.isNotEmpty) {
    final parsed = DateTime.tryParse(created)?.toLocal();
    if (parsed != null) {
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
      date = '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
    }
  }

  if (title.isNotEmpty && date.isNotEmpty) {
    return '$title  •  $date';
  }

  if (title.isNotEmpty) return title;
  if (date.isNotEmpty) return date;
  return 'Homeowner review';
}

String _money(dynamic value) {
  final amount = double.tryParse(value?.toString() ?? '') ?? 0;
  return amount.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

class _PremiumPreviewHeader extends StatelessWidget {
  const _PremiumPreviewHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        padding: const EdgeInsets.fromLTRB(8, 10, 18, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF164D7A), Color(0xFF177989), Color(0xFF1FB8B3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.visibility_outlined,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'This is how homeowners see your public profile.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.35,
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
