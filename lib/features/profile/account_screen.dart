import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../services/logout_helper.dart';
import '../../services/account_appeal_service.dart';
import '../../services/worker_profile_service.dart';
import '../../theme/theme_controller.dart';
import 'homeowner_personal_information_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_view_screen.dart';
import 'security_screen.dart';
import 'account_control_screen.dart';
import 'worker_personal_information_screen.dart';
import 'worker_services_screen.dart';

const _primary = Color(0xFF1FB8B3);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);

const _blue = Color(0xFF164D7A);
const _blueDark = Color(0xFF0F355B);
const _teal = Color(0xFF1FB8B3);
const _danger = Color(0xFFD63031);

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.role,
    required this.user,
    required this.profile,
    this.onBack,
  });
  final VoidCallback? onBack;
  final String role;
  final Map<String, dynamic> user;
  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final name = user['full_name']?.toString() ?? 'Account';

    final imageUrl = ApiConfig.storageUrl(
      user['profile_photo']?.toString() ?? profile['profile_photo']?.toString(),
    );

    final district =
        profile['district']?.toString() ?? user['location']?.toString() ?? '';

    final verified =
        user['is_verified'] == true || profile['identity_verified'] == true;

    return Scaffold(
      backgroundColor: _pageBackground(context),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.mode,
        builder: (context, mode, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  name: name,
                  role: role,
                  district: district,
                  imageUrl: imageUrl,
                  verified: verified,
                  onBack: onBack,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 150),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if ((user['account_status']?.toString() ?? 'active') ==
                        'suspended') ...[
                      _SuspendedAccountCard(user: user),
                      const SizedBox(height: 18),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: _AccountGuideCard(),
                      ),
                      const SizedBox(height: 18),
                    ],
                    Transform.translate(
                      offset: Offset(
                        0,
                        (user['account_status']?.toString() ?? 'active') ==
                                'suspended'
                            ? 14
                            : role == 'worker' &&
                                (profile['verification_status']?.toString() ??
                                        'pending') !=
                                    'approved'
                            ? 14
                            : -27,
                      ),
                      child: Column(
                        children: [
                          if (role == 'worker' &&
                              (profile['verification_status']?.toString() ??
                                      'pending') !=
                                  'approved') ...[
                            _VerificationStatusCard(
                              user: user,
                              profile: profile,
                            ),
                            const SizedBox(height: 16),
                          ],
                          _SettingsSection(
                            title: 'ACCOUNT',
                            children: [
                              _SettingsTile(
                                icon: Icons.person_outline_rounded,
                                title:
                                    role == 'homeowner'
                                        ? 'My Details'
                                        : 'Edit Profile',
                                subtitle:
                                    role == 'homeowner'
                                        ? 'Update your name, photo and personal details'
                                        : 'Update your personal information',
                                onTap: () async {
                                  final changed = await Navigator.of(
                                    context,
                                  ).push<bool>(
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              role == 'worker'
                                                  ? WorkerPersonalInformationScreen(
                                                    user: user,
                                                    profile: profile,
                                                  )
                                                  : HomeownerPersonalInformationScreen(
                                                    user: user,
                                                    profile: profile,
                                                  ),
                                    ),
                                  );

                                  if (changed == true && context.mounted) {
                                    if (onBack != null) {
                                      onBack!();
                                    } else {
                                      Navigator.of(context).pop(true);
                                    }
                                  }
                                },
                              ),
                              _SettingsTile(
                                icon: Icons.visibility_outlined,
                                title:
                                    role == 'homeowner'
                                        ? 'My Profile View'
                                        : 'Profile View',
                                subtitle:
                                    role == 'homeowner'
                                        ? 'See the profile workers can view'
                                        : 'See how other users see your profile',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ProfileViewScreen(
                                            role: role,
                                            user: user,
                                            profile: profile,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              if (role == 'worker')
                                _SettingsTile(
                                  icon: Icons.cleaning_services_outlined,
                                  title: 'Services Offered',
                                  subtitle:
                                      'Choose services shown on your profile',
                                  onTap: () async {
                                    final changed = await Navigator.of(
                                      context,
                                    ).push<bool>(
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const WorkerServicesScreen(),
                                      ),
                                    );

                                    if (changed == true && context.mounted) {
                                      if (onBack != null) {
                                        onBack!();
                                      } else {
                                        Navigator.of(context).pop(true);
                                      }
                                    }
                                  },
                                ),
                              _SettingsTile(
                                icon: Icons.lock_outline_rounded,
                                title: 'Security',
                                subtitle: 'Keep your account and password safe',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SecurityScreen(),
                                    ),
                                  );
                                },
                              ),
                              _SettingsTile(
                                icon: Icons.manage_accounts_outlined,
                                title: 'Account Control',
                                subtitle: 'Deactivate or delete your account',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => const AccountControlScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _SettingsSection(
                            title: 'PREFERENCES',
                            children: [
                              _SettingsTile(
                                icon: Icons.notifications_none_rounded,
                                title: 'Notifications',
                                subtitle:
                                    role == 'homeowner'
                                        ? 'Choose alerts for messages, job offers and applications'
                                        : 'Choose which alerts you want to receive.',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              const NotificationSettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                              _ThemeTile(
                                value: mode == ThemeMode.dark,
                                onChanged: ThemeController.setDarkMode,
                              ),
                              _SettingsTile(
                                icon: Icons.language_rounded,
                                title: 'Language',
                                subtitle: 'Choose your preferred language',
                                trailingLabel: 'English',
                                onTap:
                                    () => _comingSoon(
                                      context,
                                      'Language settings',
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _SettingsSection(
                            title: 'SUPPORT & ABOUT',
                            children: [
                              _SettingsTile(
                                icon: Icons.help_outline_rounded,
                                title: 'Help',
                                subtitle: 'Get help using the app',
                                onTap:
                                    () => _comingSoon(context, 'Help center'),
                              ),
                              _SettingsTile(
                                icon: Icons.shield_outlined,
                                title: 'Privacy Policy',
                                subtitle: 'Read our privacy policy',
                                onTap:
                                    () =>
                                        _comingSoon(context, 'Privacy policy'),
                              ),
                              _SettingsTile(
                                icon: Icons.info_outline_rounded,
                                title: 'About WorkLink',
                                subtitle: 'App version and information',
                                trailingLabel: 'v1.0.0',
                                onTap:
                                    () => showAboutDialog(
                                      context: context,
                                      applicationName: 'WorkLink Africa',
                                      applicationVersion: '1.0.0',
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _LogoutCard(
                            onTap: () => LogoutHelper.confirmAndLogout(context),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.role,
    required this.district,
    required this.imageUrl,
    required this.verified,
    required this.onBack,
  });

  final String name;
  final String role;
  final String district;
  final String imageUrl;
  final bool verified;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.fromLTRB(18, topPadding + 14, 18, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF08253F), Color(0xFF124E6D), Color(0xFF1FB8B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(38)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -55,
            right: -48,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -65,
            child: Container(
              width: 165,
              height: 165,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.035),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _RoundButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () {
                      if (onBack != null) {
                        onBack!();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MY ACCOUNT',
                          style: TextStyle(
                            color: Color(0xFFC7E3E7),
                            fontSize: 9.5,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Profile & Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          verified
                              ? const Color(0xFF79E2C0).withValues(alpha: 0.18)
                              : Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          verified
                              ? Icons.verified_rounded
                              : Icons.schedule_rounded,
                          color:
                              verified
                                  ? const Color(0xFF9CF1D8)
                                  : Colors.white70,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          verified ? 'VERIFIED' : 'PENDING',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            letterSpacing: 0.7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.65),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 43,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.15,
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
                                        fontSize: 23,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                        if (verified)
                          Positioned(
                            right: -1,
                            bottom: 1,
                            child: Container(
                              width: 27,
                              height: 27,
                              decoration: BoxDecoration(
                                color: const Color(0xFF79E2C0),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF124E6D),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF08253F),
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.25,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            role == 'worker'
                                ? 'Worker Profile'
                                : 'Homeowner Profile',
                            style: const TextStyle(
                              color: Color(0xFFCFE5EA),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (district.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white70,
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: _PremiumAccountMiniCard(
                      icon: Icons.person_outline_rounded,
                      title: role == 'worker' ? 'Worker' : 'Homeowner',
                      subtitle: 'Account Type',
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _PremiumAccountMiniCard(
                      icon:
                          verified
                              ? Icons.verified_user_outlined
                              : Icons.pending_actions_outlined,
                      title: verified ? 'Verified' : 'Review',
                      subtitle: 'Profile Status',
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _PremiumAccountMiniCard(
                      icon: Icons.security_outlined,
                      title: 'Secure',
                      subtitle: 'Account',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountGuideCard extends StatelessWidget {
  const _AccountGuideCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: _primary, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KEEP YOUR PROFILE UPDATED',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 9.5,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Check your information before looking for work',
                  style: TextStyle(
                    color: _slate,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Make sure your availability, services, languages and documents are correct so homeowners can trust your profile.',
                  style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumAccountMiniCard extends StatelessWidget {
  const _PremiumAccountMiniCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF91E9DD), size: 18),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white60, fontSize: 8.5),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _teal,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_rounded, color: Colors.white, size: 15),
          SizedBox(width: 5),
          Text(
            'Verified',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.22 : 0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _sectionTitleColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 46,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _teal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(
            children.length,
            (index) => Column(
              children: [
                children[index],
                if (index != children.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(height: 1, color: _dividerColor(context)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _iconBackground(context),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Icon(icon, color: _teal, size: 25),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _titleColor(context),
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          subtitle,
          style: TextStyle(
            color: _subtitleColor(context),
            fontSize: 12,
            height: 1.3,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingLabel != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: _labelBackground(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                trailingLabel!,
                style: TextStyle(
                  color: _sectionTitleColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          Icon(
            Icons.chevron_right_rounded,
            color: _isDark(context) ? const Color(0xFF8BC6E8) : _blue,
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _iconBackground(context),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Icon(
          value ? Icons.dark_mode_rounded : Icons.light_mode_outlined,
          color: _teal,
          size: 25,
        ),
      ),
      title: Text(
        'Display & Appearance',
        style: TextStyle(
          color: _titleColor(context),
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        value
            ? 'Dark mode is currently enabled'
            : 'Light mode is currently enabled',
        style: TextStyle(
          color: _subtitleColor(context),
          fontSize: 12,
          height: 1.3,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: _teal,
        onChanged: onChanged,
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);

    return Material(
      color: dark ? const Color(0xFF3B1F24) : const Color(0xFFFFEDED),
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      dark
                          ? const Color(0xFF4A252B)
                          : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.logout_rounded, color: _danger),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: _danger,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Sign out of your account',
                      style: TextStyle(color: _danger, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _danger),
            ],
          ),
        ),
      ),
    );
  }
}

void _comingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$feature will be connected in a later module.'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _pageBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF0F1722) : const Color(0xFFF5F8FB);
}

Color _cardColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF182330) : Colors.white;
}

Color _titleColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFFF4F8FB) : const Color(0xFF14233B);
}

Color _sectionTitleColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFFB9DDF3) : _blueDark;
}

Color _subtitleColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFFB2C0CE) : const Color(0xFF718096);
}

Color _dividerColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF2A3847) : const Color(0xFFE8EDF3);
}

Color _iconBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF14313A) : const Color(0xFFEAF7F7);
}

Color _labelBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF263544) : const Color(0xFFF1F5F9);
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

class _VerificationStatusCard extends StatefulWidget {
  const _VerificationStatusCard({required this.user, required this.profile});

  final Map<String, dynamic> user;
  final Map<String, dynamic> profile;

  @override
  State<_VerificationStatusCard> createState() =>
      _VerificationStatusCardState();
}

class _VerificationStatusCardState extends State<_VerificationStatusCard> {
  bool _editedAfterRejection = false;
  bool _resubmitting = false;

  @override
  Widget build(BuildContext context) {
    final status =
        widget.profile['verification_status']?.toString() ?? 'pending';
    final reason =
        widget.profile['verification_rejection_reason']?.toString().trim() ??
        '';
    final rejected = status == 'rejected';
    final dark = _isDark(context);

    final background =
        rejected
            ? (dark ? const Color(0xFF351F25) : const Color(0xFFFFF7F7))
            : (dark ? const Color(0xFF352F1D) : const Color(0xFFFFFAED));

    final border =
        rejected
            ? (dark ? const Color(0xFF7A3944) : const Color(0xFFF3C3C8))
            : (dark ? const Color(0xFF6E5C24) : const Color(0xFFF0D99B));

    final accent = rejected ? _danger : const Color(0xFF9A6700);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.16 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    rejected
                        ? Icons.gpp_bad_outlined
                        : Icons.hourglass_top_rounded,
                    color: accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rejected
                            ? 'Your Profile Needs Changes'
                            : 'Your Profile Is Being Checked',
                        style: TextStyle(
                          color: _titleColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        rejected
                            ? 'Homeowners cannot see your profile yet. Fix the problem below, save your profile, then send it for review again.'
                            : 'We are checking your profile. Homeowners will be able to see you after it is approved.',
                        style: TextStyle(
                          color: _subtitleColor(context),
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (rejected && reason.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color:
                      dark
                          ? Colors.white.withValues(alpha: 0.055)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        dark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFF0D7DA),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: _danger,
                          size: 18,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'WHY YOUR PROFILE NEEDS CHANGES',
                          style: TextStyle(
                            color: _danger,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      reason,
                      style: TextStyle(
                        color: _titleColor(context),
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (rejected) ...[
              const SizedBox(height: 20),
              _VerificationStep(
                number: '1',
                title: 'Fix Your Profile',
                subtitle:
                    'Fix the problem shown above. You can change your National ID, personal details, services, languages and photos.',
                complete: _editedAfterRejection,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _openProfileEditor,
                  style: FilledButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    _editedAfterRejection
                        ? Icons.check_circle_outline_rounded
                        : Icons.edit_outlined,
                  ),
                  label: Text(
                    _editedAfterRejection
                        ? 'Profile Saved — Edit Again'
                        : 'Edit My Profile',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _VerificationStep(
                number: '2',
                title: 'Send Your Profile Again',
                subtitle:
                    _editedAfterRejection
                        ? 'You saved your changes. Now send the profile back to us so we can check it again.'
                        : 'First tap Edit My Profile and save your changes. Then this button will become available.',
                complete: false,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      !_editedAfterRejection || _resubmitting
                          ? null
                          : _resubmit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _teal,
                    disabledForegroundColor: _subtitleColor(context),
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide(
                      color:
                          _editedAfterRejection
                              ? _teal
                              : _dividerColor(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon:
                      _resubmitting
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.refresh_rounded),
                  label: Text(
                    _resubmitting ? 'Submitting...' : 'Send Profile for Review',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openProfileEditor() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => WorkerPersonalInformationScreen(
              user: widget.user,
              profile: widget.profile,
            ),
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      setState(() => _editedAfterRejection = true);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Profile saved. Now tap Send Profile for Review.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _resubmit() async {
    if (!_editedAfterRejection || _resubmitting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Send profile for review?'),
            content: const Text(
              'We will check your corrected profile and documents again. Homeowners still cannot see you until the profile is approved.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Send for Review'),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _resubmitting = true);

    final result = await WorkerProfileService().resubmitVerification();

    if (!mounted) return;

    setState(() => _resubmitting = false);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Verification updated.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

    if (result['success'] == true) {
      // Reload the Account/Profile data through its owner.
      if (widget.profile['verification_status'] != null) {
        widget.profile['verification_status'] = 'pending';
        widget.profile['verification_rejection_reason'] = null;
      }

      setState(() {});
    }
  }
}

class _VerificationStep extends StatelessWidget {
  const _VerificationStep({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.complete,
  });

  final String number;
  final String title;
  final String subtitle;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                complete
                    ? _teal
                    : _teal.withValues(alpha: _isDark(context) ? 0.18 : 0.11),
            shape: BoxShape.circle,
          ),
          child:
              complete
                  ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  )
                  : Text(
                    number,
                    style: const TextStyle(
                      color: _teal,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _titleColor(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: _subtitleColor(context),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppealSuspensionDialog extends StatefulWidget {
  const _AppealSuspensionDialog();

  @override
  State<_AppealSuspensionDialog> createState() =>
      _AppealSuspensionDialogState();
}

class _AppealSuspensionDialogState extends State<_AppealSuspensionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      title: const Row(
        children: [
          Icon(Icons.rate_review_outlined, color: _teal),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ask Us to Review',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us why you think we should check your account again. '
                'Explain clearly what happened so we can understand '
                'your request.',
                style: TextStyle(color: _subtitleColor(context), height: 1.45),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _controller,
                minLines: 5,
                maxLines: 8,
                maxLength: 2000,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Example: Please check my account again because...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: _dividerColor(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _teal, width: 1.5),
                  ),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';

                  if (text.isEmpty) {
                    return 'Please tell us why we should review your account.';
                  }

                  if (text.length < 20) {
                    return 'Please explain a little more before sending.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: _teal,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.send_outlined),
          label: const Text(
            'Send Review Request',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _SuspendedAccountCard extends StatefulWidget {
  const _SuspendedAccountCard({required this.user});
  final Map<String, dynamic> user;

  @override
  State<_SuspendedAccountCard> createState() => _SuspendedAccountCardState();
}

class _SuspendedAccountCardState extends State<_SuspendedAccountCard> {
  final AccountAppealService _service = AccountAppealService();
  bool _submitting = false;
  bool _pending = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final result = await _service.status();
    if (!mounted || result['success'] != true) return;
    final appeal = result['latest_appeal'];
    setState(() {
      _pending = appeal is Map && appeal['status']?.toString() == 'pending';
    });
  }

  Future<void> _appeal() async {
    final message = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AppealSuspensionDialog(),
    );

    if (message == null || !mounted) return;

    setState(() => _submitting = true);

    final result = await _service.submit(message);

    if (!mounted) return;

    setState(() {
      _submitting = false;
      if (result['success'] == true) {
        _pending = true;
      }
    });

    if (result['success'] == true) {
      await _showAppealSent();
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                'We could not send your review request.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _showAppealSent() async {
    if (!mounted) return;

    await showDialog<void>(
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
              color: _teal.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _teal, size: 34),
          ),
          title: const Text(
            'Review Request Sent',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'We received your request. An administrator will check your account. You can come back here to see the latest status.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(backgroundColor: _teal),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reason = widget.user['account_status_reason']?.toString().trim();
    return Container(
      margin: const EdgeInsets.only(top: 30, bottom: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            _isDark(context)
                ? const Color(0xFF35231E)
                : const Color(0xFFFFF5F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              _isDark(context)
                  ? const Color(0xFF7A4938)
                  : const Color(0xFFF2C6B5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.pause_circle_outline_rounded,
                color: _danger,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your Account Is Paused',
                  style: TextStyle(
                    color: _danger,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Homeowners cannot see your profile right now. You also cannot apply for new jobs or accept new work while your account is paused.',
            style: TextStyle(
              color: _subtitleColor(context),
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (reason != null && reason.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'WHY YOUR ACCOUNT IS PAUSED',
              style: TextStyle(
                color: _titleColor(context),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              reason,
              style: TextStyle(color: _titleColor(context), height: 1.45),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: _teal, size: 20),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _pending
                        ? 'We received your request. You can keep using the app to check messages and your account while you wait.'
                        : 'If you think this was a mistake, ask us to review your account. Explain clearly what happened.',
                    style: TextStyle(
                      color: _titleColor(context),
                      fontSize: 11.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _pending || _submitting ? null : _appeal,
              icon:
                  _submitting
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Icon(
                        _pending
                            ? Icons.schedule_rounded
                            : Icons.rate_review_outlined,
                      ),
              label: Text(
                _pending ? 'Review Request Sent' : 'Ask Us to Review',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
