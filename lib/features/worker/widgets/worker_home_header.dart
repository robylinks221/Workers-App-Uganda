import 'package:flutter/material.dart';

import '../../../config/api_config.dart';
import '../../../models/worker_home_model.dart';
import '../../../notifications.dart';
import '../../../services/logout_helper.dart';
import '../../../services/notification_badge_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class WorkerHomeHeader extends StatelessWidget {
  const WorkerHomeHeader({
    super.key,
    required this.data,
    required this.onQueryChanged,
    required this.onOpenFilters,
  });

  final WorkerHomeData data;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.storageUrl(data.user.profilePhoto);

    final firstName =
        data.user.fullName.trim().isEmpty
            ? 'Worker'
            : data.user.fullName.trim().split(RegExp(r'\s+')).first;

    final greeting = _greetingForCurrentTime();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.paddingOf(context).top + 14,
        18,
        25,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C2D4B), Color(0xFF155A74), Color(0xFF1FB8B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -48,
            top: -58,
            child: Container(
              width: 175,
              height: 175,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onLongPress: () {
                      LogoutHelper.confirmAndLogout(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white.withValues(alpha: 0.20),
                        backgroundImage:
                            imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                        child:
                            imageUrl.isEmpty
                                ? Text(
                                  _initials(data.user.fullName),
                                  style: const TextStyle(
                                    color: _navy,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                                : null,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting,',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          firstName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Notification bell
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
                              NotificationBadgeService
                                  .instance
                                  .unreadNotifications;

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
                                border: Border.all(
                                  color: const Color(0xFF155A74),
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
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

              const SizedBox(height: 26),

              const Text(
                'What would you like to do today?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.45,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Find work, check replies, or update your profile.',
                style: TextStyle(
                  color: Color(0xFFD6E7EC),
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 18),

              Material(
                color: Colors.white,
                elevation: 7,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
                child: TextField(
                  onChanged: onQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Search jobs',
                    hintStyle: const TextStyle(
                      color: Color(0xFF718197),
                      fontSize: 12.5,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: _primary,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(6),
                      child: IconButton(
                        tooltip: 'Find jobs by location or service',
                        onPressed: onOpenFilters,
                        style: IconButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.tune_rounded),
                      ),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _greetingForCurrentTime() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return 'Good morning';
  }

  if (hour < 17) {
    return 'Good afternoon';
  }

  return 'Good evening';
}

String _initials(String name) {
  final parts =
      name
          .trim()
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

  if (parts.isEmpty) {
    return 'W';
  }

  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}
