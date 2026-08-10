import '../../../notifications.dart';
import '../../../services/notification_badge_service.dart';
import 'package:flutter/material.dart';

import '../../../config/api_config.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.fullName,
    required this.firstName,
    required this.location,
    required this.imagePath,
    required this.onSearch,
    required this.onLogout,
  });

  final String fullName;
  final String firstName;
  final String location;
  final String imagePath;
  final VoidCallback onSearch;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.storageUrl(imagePath);
    final compact = MediaQuery.sizeOf(context).width < 390;
    final greeting = _greetingForCurrentTime();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 20,
        MediaQuery.paddingOf(context).top + 14,
        compact ? 16 : 20,
        28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF123F67), Color(0xFF176B80), Color(0xFF1FB8B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: compact ? 24 : 27,
                  backgroundColor: Colors.white.withValues(alpha: 0.20),
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child:
                      imageUrl.isEmpty
                          ? Text(
                            _initials(fullName),
                            style: const TextStyle(
                              color: _navy,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                          : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      firstName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 18 : 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                        NotificationBadgeService.instance.refresh();
                      },
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: NotificationBadgeService.instance,
                    builder: (context, _) {
                      final count =
                          NotificationBadgeService.instance.unreadNotifications;

                      if (count <= 0) {
                        return const SizedBox.shrink();
                      }

                      return Positioned(
                        top: -5,
                        right: -5,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 19,
                            minHeight: 19,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            count > 99 ? '99+' : count.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Find trusted help for your home',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 21 : 24,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse verified workers, post jobs and manage hiring in one place.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Material(
            color: Colors.white.withValues(alpha: 0.88),
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onSearch,
              child: SizedBox(
                height: compact ? 58 : 62,
                child: Row(
                  children: [
                    const SizedBox(width: 17),
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF718197),
                      size: 25,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Search services or workers',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF718197),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      height: compact ? 46 : 50,
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF176B80), _primary],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Browse',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onLongPress: onLogout,
            child: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Hold profile photo to sign out',
                style: TextStyle(color: Colors.white54, fontSize: 9.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _greetingForCurrentTime() {
  final hour = DateTime.now().toLocal().hour;

  if (hour >= 5 && hour < 12) return 'Good morning';
  if (hour >= 12 && hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
