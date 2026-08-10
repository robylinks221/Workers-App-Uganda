import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'config/api_config.dart';
import 'models/chat_models.dart';
import 'services/chat_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final ChatService _service = ChatService();
  final TextEditingController _searchController = TextEditingController();

  List<ChatConversation> _items = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      if (!mounted) return;
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await _service.getConversations();

      if (!mounted) return;

      setState(() {
        _items = items;
        _loading = false;
      });
    } on ChatServiceException catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _open(ChatConversation conversation) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)),
    );

    await _load();
  }

  List<ChatConversation> get _filteredItems {
    if (_query.isEmpty) return _items;

    return _items.where((conversation) {
      final values =
          [
            conversation.otherUserName,
            conversation.jobTitle ?? '',
            conversation.lastMessage ?? '',
          ].join(' ').toLowerCase();

      return values.contains(_query);
    }).toList();
  }

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
            _MessagesHeroHeader(
              conversationCount: _items.length,
              unreadCount: _items.fold<int>(
                0,
                (total, item) => total + item.unreadCount,
              ),
              searchController: _searchController,
            ),
            Expanded(
              child:
                  _loading
                      ? const Center(
                        child: CircularProgressIndicator(color: _primary),
                      )
                      : _error != null
                      ? _MessageState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Unable to load messages',
                        message: _error!,
                        buttonLabel: 'Try Again',
                        onPressed: _load,
                      )
                      : _filteredItems.isEmpty
                      ? _MessageState(
                        icon:
                            _query.isEmpty
                                ? Icons.forum_outlined
                                : Icons.search_off_rounded,
                        title:
                            _query.isEmpty
                                ? 'No conversations yet'
                                : 'No matching messages',
                        message:
                            _query.isEmpty
                                ? 'Your conversations will appear here.'
                                : 'Try searching with another name or job.',
                      )
                      : RefreshIndicator(
                        color: _primary,
                        onRefresh: _load,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(14, 5, 14, 110),
                          itemCount: _filteredItems.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            final conversation = _filteredItems[index];

                            return _ConversationCard(
                              conversation: conversation,
                              onTap: () => _open(conversation),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesHeroHeader extends StatelessWidget {
  const _MessagesHeroHeader({
    required this.conversationCount,
    required this.unreadCount,
    required this.searchController,
  });

  final int conversationCount;
  final int unreadCount;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_navy, Color(0xFF177989), _primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -35,
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.paddingOf(context).top + 18,
                20,
                18,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.17),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: const Icon(
                          Icons.forum_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Messages',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '$conversationCount conversations'
                              '${unreadCount > 0 ? ' • $unreadCount unread' : ''}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  TextField(
                    controller: searchController,
                    style: TextStyle(color: colors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search conversations',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon:
                          searchController.text.isNotEmpty
                              ? IconButton(
                                onPressed: searchController.clear,
                                icon: const Icon(Icons.close_rounded),
                              )
                              : null,
                      filled: true,
                      fillColor:
                          isDark
                              ? colors.surface.withValues(alpha: 0.96)
                              : Colors.white.withValues(alpha: 0.97),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: _primary,
                          width: 1.5,
                        ),
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

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({required this.conversation, required this.onTap});

  final ChatConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final photoUrl = ApiConfig.storageUrl(conversation.otherUserPhoto);
    final unread = conversation.unreadCount > 0;

    return Material(
      color: colors.surface,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.30 : 0.12),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              _BorderedAvatar(
                imageUrl: photoUrl,
                name: conversation.otherUserName,
                radius: 28,
                online: false,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.otherUserName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 16,
                              fontWeight:
                                  unread ? FontWeight.w900 : FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          _timeLabel(conversation.lastMessageAt),
                          style: TextStyle(
                            color: unread ? _primary : colors.onSurfaceVariant,
                            fontSize: 10.5,
                            fontWeight:
                                unread ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (conversation.jobTitle != null) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.work_outline_rounded,
                            color: _primary,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              conversation.jobTitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage ??
                                'Start the conversation',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12.5,
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 9),
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 22,
                              minHeight: 22,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              conversation.unreadCount > 99
                                  ? '99+'
                                  : conversation.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _BorderedAvatar extends StatelessWidget {
  const _BorderedAvatar({
    required this.imageUrl,
    required this.name,
    required this.radius,
    required this.online,
  });

  final String imageUrl;
  final String name;
  final double radius;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: colors.surfaceContainerHighest,
            backgroundImage:
                imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child:
                imageUrl.isEmpty
                    ? Text(
                      _initials(name),
                      style: const TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                    : null,
          ),
        ),
        if (online)
          Positioned(
            right: 1,
            bottom: 2,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFF16A957),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
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
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _primary, size: 64),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.45),
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 17),
              FilledButton(onPressed: onPressed, child: Text(buttonLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

String _timeLabel(DateTime? date) {
  if (date == null) return '';

  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inMinutes < 1) return 'Now';
  if (difference.inHours < 1) return '${difference.inMinutes}m';
  if (difference.inDays < 1) return '${difference.inHours}h';
  if (difference.inDays == 1) return 'Yesterday';
  if (difference.inDays < 7) return '${difference.inDays}d';

  return '${date.day}/${date.month}/${date.year}';
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
