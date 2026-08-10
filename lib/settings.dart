// ─────────────────────────────────────────────────────────────────────────────
// settings.dart
//
// Settings / Account screen — works for both Worker and Homeowner roles.
// Covers: edit profile, notification toggles, change password, logout,
// privacy, help, and danger zone (delete account).
//
// USAGE
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => SettingsScreen(
//       userName:    'Annet Nakato',
//       userRole:    UserRole.worker,       // or UserRole.homeowner
//       avatarColor: Color(0xFF4F7089),
//       userPhone:   '0772 345 678',
//     ),
//   ));
//
// PASTE INTO
//   lib/settings.dart   (standalone — no imports from other screens)
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Stand-alone preview ───────────────────────────────────────────────────────
void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maid App Uganda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD87C53)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: SettingsScreen(
        userName: 'Annet Nakato',
        userRole: UserRole.worker,
        avatarColor: const Color(0xFF4F7089),
        userPhone: '0772 345 678',
        userLocation: 'Ntinda, Kampala',
      ),
    );
  }
}

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color _kPrimary    = Color(0xFFD87C53);
const Color _kPrimaryBg  = Color(0xFFFAEEE6);
const Color _kDark       = Color(0xFF2A3D4E);
const Color _kSlate      = Color(0xFF395264);
const Color _kSlateLight = Color(0xFF4F7089);
const Color _kSubText    = Color(0xFF5C7A8C);
const Color _kBorder     = Color(0xFFEAE0D8);
const Color _kMuted      = Color(0xFFB0A098);
const Color _kBg         = Color(0xFFF8F5F3);
const Color _kGreen      = Color(0xFF27AE60);
const Color _kRed        = Color(0xFFE74C3C);
const Color _kRedBg      = Color(0xFFFDECEB);

// ── Role enum ─────────────────────────────────────────────────────────────────
enum UserRole { worker, homeowner }

// ─────────────────────────────────────────────────────────────────────────────
// Settings Screen
// ─────────────────────────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.userName,
    required this.userRole,
    required this.avatarColor,
    required this.userPhone,
    required this.userLocation,
  });
  final String   userName;
  final UserRole userRole;
  final Color    avatarColor;
  final String   userPhone;
  final String   userLocation;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification toggles
  bool _notifyJobRequests  = true;
  bool _notifyMessages     = true;
  bool _notifyReviews      = true;
  bool _notifyPayments     = true;
  bool _notifyPromotions   = false;

  // Privacy toggles
  bool _showPhone          = false;
  bool _showOnlineStatus   = true;

  String get _initials {
    final parts = widget.userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?';
  }

  String get _roleLabel =>
      widget.userRole == UserRole.worker ? 'Worker' : 'Homeowner';

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: _kSlate,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      duration: const Duration(seconds: 2),
    ));
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text('Log Out',
            style:
            TextStyle(fontWeight: FontWeight.w700, color: _kSlate)),
        content: const Text(
            'Are you sure you want to log out of your account?',
            style: TextStyle(color: _kSubText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _kMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Logged out successfully');
            },
            child: const Text('Log Out',
                style: TextStyle(
                    color: _kRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Account',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: _kRed)),
        content: const Text(
            'This will permanently delete your account and all your data. This cannot be undone.',
            style: TextStyle(color: _kSubText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _kMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Account deletion requested');
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: _kRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EditProfileSheet(
        name: widget.userName,
        phone: widget.userPhone,
        location: widget.userLocation,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader()),

          // ── Profile card ───────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildProfileCard()),

          // ── Account ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(child: _SectionLabel(label: 'Account')),
          SliverToBoxAdapter(
            child: _SettingsGroup(items: [
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profile',
                onTap: _showEditProfileSheet,
              ),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                onTap: _showChangePasswordSheet,
              ),
              _SettingsTile(
                icon: Icons.phone_outlined,
                label: 'Phone Number',
                trailing: Text(widget.userPhone,
                    style: const TextStyle(
                        fontSize: 13, color: _kMuted)),
                onTap: () => _showSnack('Update your phone number'),
              ),
              _SettingsTile(
                icon: Icons.verified_outlined,
                label: 'ID Verification',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Verified',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _kGreen)),
                ),
                onTap: () => _showSnack('ID already verified'),
              ),
            ]),
          ),

          // ── Notifications ──────────────────────────────────────────────────
          const SliverToBoxAdapter(
              child: _SectionLabel(label: 'Notifications')),
          SliverToBoxAdapter(
            child: _SettingsGroup(items: [
              _ToggleTile(
                icon: Icons.work_outline_rounded,
                label: 'Job Requests',
                subtitle: 'When a homeowner sends a request',
                value: _notifyJobRequests,
                onChanged: (v) => setState(() => _notifyJobRequests = v),
              ),
              _ToggleTile(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                subtitle: 'New chat messages',
                value: _notifyMessages,
                onChanged: (v) => setState(() => _notifyMessages = v),
              ),
              _ToggleTile(
                icon: Icons.star_outline_rounded,
                label: 'Reviews',
                subtitle: 'When someone leaves a review',
                value: _notifyReviews,
                onChanged: (v) => setState(() => _notifyReviews = v),
              ),
              _ToggleTile(
                icon: Icons.payments_outlined,
                label: 'Payments',
                subtitle: 'Payment received or sent',
                value: _notifyPayments,
                onChanged: (v) => setState(() => _notifyPayments = v),
              ),
              _ToggleTile(
                icon: Icons.campaign_outlined,
                label: 'Promotions',
                subtitle: 'Tips, offers and app updates',
                value: _notifyPromotions,
                onChanged: (v) => setState(() => _notifyPromotions = v),
              ),
            ]),
          ),

          // ── Privacy ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(child: _SectionLabel(label: 'Privacy')),
          SliverToBoxAdapter(
            child: _SettingsGroup(items: [
              _ToggleTile(
                icon: Icons.visibility_outlined,
                label: 'Show Phone to Others',
                subtitle: 'Allow others to see your number',
                value: _showPhone,
                onChanged: (v) => setState(() => _showPhone = v),
              ),
              _ToggleTile(
                icon: Icons.circle_outlined,
                label: 'Show Online Status',
                subtitle: 'Let others see when you\'re active',
                value: _showOnlineStatus,
                onChanged: (v) => setState(() => _showOnlineStatus = v),
              ),
            ]),
          ),

          // ── Support ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(child: _SectionLabel(label: 'Support')),
          SliverToBoxAdapter(
            child: _SettingsGroup(items: [
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                label: 'Help & FAQ',
                onTap: () => _showSnack('Opening Help Centre…'),
              ),
              _SettingsTile(
                icon: Icons.report_outlined,
                label: 'Report a Problem',
                onTap: () => _showSnack('Opening report form…'),
              ),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                label: 'About Maid App Uganda',
                trailing: const Text('v1.0.0',
                    style: TextStyle(fontSize: 13, color: _kMuted)),
                onTap: () {},
              ),
            ]),
          ),

          // ── Logout ─────────────────────────────────────────────────────────
          const SliverToBoxAdapter(child: _SectionLabel(label: '')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                _ActionButton(
                  label: 'Log Out',
                  icon: Icons.logout_rounded,
                  color: _kRed,
                  bg: _kRedBg,
                  onTap: _confirmLogout,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _confirmDeleteAccount,
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(
                        fontSize: 13,
                        color: _kMuted,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
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
          padding: const EdgeInsets.fromLTRB(4, 4, 20, 20),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.maybePop(context),
            ),
            const Text('Settings & Account',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  // ── Profile card ───────────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return GestureDetector(
      onTap: _showEditProfileSheet,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(children: [
          Stack(children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: widget.avatarColor,
              child: Text(_initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20)),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: _kPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit_rounded,
                    size: 12, color: Colors.white),
              ),
            ),
          ]),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kSlate)),
                const SizedBox(height: 3),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kPrimaryBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_roleLabel,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _kPrimary)),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.userPhone,
                      style: const TextStyle(
                          fontSize: 12, color: _kSubText)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on_rounded,
                      size: 12, color: _kMuted),
                  const SizedBox(width: 3),
                  Text(widget.userLocation,
                      style: const TextStyle(
                          fontSize: 12, color: _kSubText)),
                ]),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: _kMuted),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(label.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: _kMuted)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings group (white card)
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final isLast = i == items.length - 1;
          return Column(children: [
            items[i],
            if (!isLast)
              const Divider(
                  indent: 52, endIndent: 0,
                  height: 1, color: _kBorder),
          ]);
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile types
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor,
  });
  final IconData icon;
  final String   label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color?  iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? _kSlateLight).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18,
                color: iconColor ?? _kSlateLight),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _kSlate)),
          ),
          if (trailing != null) trailing!,
          if (trailing == null)
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: _kMuted),
        ]),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String   label;
  final String   subtitle;
  final bool     value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: _kSlateLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: _kSlateLight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _kSlate)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: _kSubText)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: _kPrimary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action button (logout etc.)
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Profile Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.name,
    required this.phone,
    required this.location,
  });
  final String name;
  final String phone;
  final String location;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  final _bioCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl     = TextEditingController(text: widget.name);
    _phoneCtrl    = TextEditingController(text: widget.phone);
    _locationCtrl = TextEditingController(text: widget.location);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Edit Profile',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _kSlate)),
            ),
            const SizedBox(height: 16),
            _FormField(label: 'Full Name',      ctrl: _nameCtrl,
                hint: 'Your full name'),
            const SizedBox(height: 12),
            _FormField(label: 'Phone Number',   ctrl: _phoneCtrl,
                hint: '07XX XXX XXX',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _FormField(label: 'Location',       ctrl: _locationCtrl,
                hint: 'e.g. Ntinda, Kampala'),
            const SizedBox(height: 12),
            _FormField(label: 'Bio (optional)', ctrl: _bioCtrl,
                hint: 'Tell people about yourself…',
                maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Profile updated!',
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: _kGreen,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Save Changes',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Change Password Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  String? _error;

  void _submit() {
    setState(() => _error = null);
    if (_currentCtrl.text.isEmpty) {
      setState(() => _error = 'Enter your current password');
      return;
    }
    if (_newCtrl.text.length < 8) {
      setState(() => _error = 'New password must be at least 8 characters');
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Password changed successfully!',
          style: TextStyle(color: Colors.white)),
      backgroundColor: _kGreen,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Change Password',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _kSlate)),
            ),
            const SizedBox(height: 16),
            _PasswordField(
              label: 'Current Password',
              ctrl: _currentCtrl,
              obscure: _obscureCurrent,
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 12),
            _PasswordField(
              label: 'New Password',
              ctrl: _newCtrl,
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 12),
            _PasswordField(
              label: 'Confirm New Password',
              ctrl: _confirmCtrl,
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.error_outline_rounded,
                    size: 14, color: _kRed),
                const SizedBox(width: 6),
                Text(_error!,
                    style: const TextStyle(
                        fontSize: 13, color: _kRed)),
              ]),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Update Password',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable form widgets
// ─────────────────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });
  final String                label;
  final TextEditingController ctrl;
  final String                hint;
  final int                   maxLines;
  final TextInputType?        keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kSlate)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: _kSlate),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _kMuted),
            filled: true,
            fillColor: const Color(0xFFFAEEE6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.ctrl,
    required this.obscure,
    required this.onToggle,
  });
  final String                label;
  final TextEditingController ctrl;
  final bool                  obscure;
  final VoidCallback          onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kSlate)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14, color: _kSlate),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: _kMuted),
            filled: true,
            fillColor: const Color(0xFFFAEEE6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18, color: _kMuted,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
