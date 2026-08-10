import 'dart:async';

import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'models/chat_models.dart';
import 'services/chat_service.dart';
import 'services/notification_badge_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversation,
    this.currentUserName = 'You',
    this.currentUserPhoto,
  });

  final ChatConversation conversation;

  /// Optional until the current-user profile is passed by the calling screen
  /// or returned inside every message by Laravel.
  final String currentUserName;
  final String? currentUserPhoto;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _service = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  Timer? _timer;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _refreshMessages(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _service.getMessages(widget.conversation.id);
      await _service.markRead(widget.conversation.id);
      await NotificationBadgeService.instance.refreshAfterMessageRead();

      if (!mounted) return;

      setState(() {
        _messages = messages;
        _loading = false;
        _error = null;
      });

      _scrollToBottom();
    } on ChatServiceException catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _refreshMessages() async {
    if (!mounted || _loading || _sending) return;

    try {
      final messages = await _service.getMessages(widget.conversation.id);
      await _service.markRead(widget.conversation.id);
      await NotificationBadgeService.instance.refreshAfterMessageRead();

      if (!mounted || _sameMessages(_messages, messages)) return;

      setState(() => _messages = messages);
      _scrollToBottom();
    } catch (_) {
      // Polling errors stay silent; manual retry remains available.
    }
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      final message = await _service.sendTextMessage(
        conversationId: widget.conversation.id,
        message: text,
      );

      if (!mounted) return;

      _messageController.clear();
      setState(() {
        _messages = [..._messages, message];
        _sending = false;
      });
      _scrollToBottom();
    } on ChatServiceException catch (error) {
      if (!mounted) return;

      setState(() => _sending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _edit(ChatMessage message) async {
    final controller = TextEditingController(text: message.message ?? '');

    final updated = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit message'),
            content: TextField(
              controller: controller,
              autofocus: true,
              minLines: 1,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Change your message',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.isNotEmpty) Navigator.pop(context, value);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (!mounted) {
      controller.dispose();
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 100));
    controller.dispose();

    if (updated == null) return;

    try {
      await _service.editMessage(message.id, updated);
      await _refreshMessages();
    } on ChatServiceException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _delete(ChatMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete message'),
            content: const Text('Delete this message?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await _service.deleteMessage(message.id);

      if (!mounted) return;

      setState(() {
        _messages = _messages.where((item) => item.id != message.id).toList();
      });
    } on ChatServiceException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _showActions(ChatMessage message) async {
    if (!message.isMine) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Edit message'),
                onTap: () {
                  Navigator.of(sheetContext).pop('edit');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade700,
                ),
                title: Text(
                  'Delete message',
                  style: TextStyle(color: Colors.red.shade700),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop('delete');
                },
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'edit') {
      await _edit(message);
    } else if (action == 'delete') {
      await _delete(message);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final otherPhotoUrl = ApiConfig.storageUrl(
      widget.conversation.otherUserPhoto,
    );
    final currentPhotoUrl = ApiConfig.storageUrl(widget.currentUserPhoto);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ChatHeader(
              name: widget.conversation.otherUserName,
              jobTitle: widget.conversation.jobTitle,
              photoUrl: otherPhotoUrl,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      theme.brightness == Brightness.dark
                          ? colors.surfaceContainerLowest
                          : const Color(0xFFF4F8FA),
                ),
                child:
                    _loading
                        ? const Center(
                          child: CircularProgressIndicator(color: _primary),
                        )
                        : _error != null
                        ? _ChatState(
                          icon: Icons.cloud_off_rounded,
                          message: _error!,
                          buttonLabel: 'Try Again',
                          onPressed: _loadMessages,
                        )
                        : _messages.isEmpty
                        ? const _ChatState(
                          icon: Icons.waving_hand_outlined,
                          message:
                              'No messages yet.\nSay hello and explain what you need.',
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
                          itemCount: _messages.length,
                          itemBuilder: (_, index) {
                            final message = _messages[index];
                            final senderPhoto = ApiConfig.storageUrl(
                              message.senderPhoto,
                            );

                            return _MessageBubble(
                              message: message,
                              incomingPhotoUrl:
                                  senderPhoto.isNotEmpty
                                      ? senderPhoto
                                      : otherPhotoUrl,
                              incomingName:
                                  message.senderName ??
                                  widget.conversation.otherUserName,
                              outgoingPhotoUrl:
                                  senderPhoto.isNotEmpty
                                      ? senderPhoto
                                      : currentPhotoUrl,
                              outgoingName:
                                  message.senderName ?? widget.currentUserName,
                              onLongPress: () => _showActions(message),
                            );
                          },
                        ),
              ),
            ),
            _MessageComposer(
              controller: _messageController,
              sending: _sending,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.name,
    required this.jobTitle,
    required this.photoUrl,
    required this.onBack,
  });

  final String name;
  final String? jobTitle;
  final String photoUrl;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      padding: const EdgeInsets.fromLTRB(8, 10, 14, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF177989), _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          _ChatAvatar(imageUrl: photoUrl, name: name, radius: 22),
          const SizedBox(width: 11),
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
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  jobTitle ?? 'Messages',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.incomingPhotoUrl,
    required this.incomingName,
    required this.outgoingPhotoUrl,
    required this.outgoingName,
    required this.onLongPress,
  });

  final ChatMessage message;
  final String incomingPhotoUrl;
  final String incomingName;
  final String outgoingPhotoUrl;
  final String outgoingName;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mine = message.isMine;

    final imageUrl = mine ? outgoingPhotoUrl : incomingPhotoUrl;
    final displayName = mine ? outgoingName : incomingName;

    return Padding(
      padding: EdgeInsets.only(
        left: mine ? 48 : 0,
        right: mine ? 0 : 48,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            _ChatAvatar(imageUrl: imageUrl, name: displayName, radius: 17),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 11, 11, 8),
                decoration: BoxDecoration(
                  gradient:
                      mine
                          ? const LinearGradient(
                            colors: [Color(0xFF177989), Color(0xFF1FB8B3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : null,
                  color: mine ? null : colors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(21),
                    topRight: const Radius.circular(21),
                    bottomLeft: Radius.circular(mine ? 21 : 5),
                    bottomRight: Radius.circular(mine ? 5 : 21),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha:
                            theme.brightness == Brightness.dark ? 0.25 : 0.09,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        message.message ?? '',
                        style: TextStyle(
                          color: mine ? Colors.white : colors.onSurface,
                          height: 1.4,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.isEdited)
                          Text(
                            'edited  ',
                            style: TextStyle(
                              color:
                                  mine
                                      ? Colors.white70
                                      : colors.onSurfaceVariant,
                              fontSize: 9,
                            ),
                          ),
                        Text(
                          _messageTime(message.createdAt),
                          style: TextStyle(
                            color:
                                mine ? Colors.white70 : colors.onSurfaceVariant,
                            fontSize: 9.5,
                          ),
                        ),
                        if (mine) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.readAt != null
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 15,
                            color:
                                message.readAt != null
                                    ? const Color(0xFFDFF9FF)
                                    : Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (mine) ...[
            const SizedBox(width: 8),
            _ChatAvatar(imageUrl: imageUrl, name: displayName, radius: 17),
          ],
        ],
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({
    required this.imageUrl,
    required this.name,
    required this.radius,
  });

  final String imageUrl;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: colors.surfaceContainerHighest,
        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
        child:
            imageUrl.isEmpty
                ? Text(
                  _initials(name),
                  style: TextStyle(
                    color: _primary,
                    fontSize: radius * 0.62,
                    fontWeight: FontWeight.w900,
                  ),
                )
                : null,
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      elevation: 16,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Write a message...',
                    prefixIcon: const Icon(Icons.chat_bubble_outline_rounded),
                    filled: true,
                    fillColor: colors.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: const BorderSide(color: _primary, width: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF177989), _primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.30),
                      blurRadius: 11,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: sending ? null : onSend,
                  color: Colors.white,
                  icon:
                      sending
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatState extends StatelessWidget {
  const _ChatState({
    required this.icon,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
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
            Icon(icon, color: _primary, size: 60),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.45),
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

bool _sameMessages(List<ChatMessage> current, List<ChatMessage> updated) {
  if (current.length != updated.length) return false;

  for (var i = 0; i < current.length; i++) {
    if (current[i].id != updated[i].id ||
        current[i].readAt != updated[i].readAt ||
        current[i].message != updated[i].message ||
        current[i].isEdited != updated[i].isEdited ||
        current[i].senderPhoto != updated[i].senderPhoto) {
      return false;
    }
  }

  return true;
}

String _messageTime(DateTime? date) {
  if (date == null) return '';

  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';

  return '$hour:$minute $period';
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
