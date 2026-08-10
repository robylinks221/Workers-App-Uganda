import 'package:flutter/material.dart';

const _primary = Color(0xFFD87C53);
const _navy = Color(0xFF2A3D4E);

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool push = true;
  bool messages = true;
  bool jobs = true;
  bool reviews = true;
  bool promotions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Push Notifications'),
            subtitle: const Text('Allow notifications on this device'),
            value: push,
            activeColor: _primary,
            onChanged: (value) => setState(() => push = value),
          ),
          const Divider(height: 1),
          SwitchListTile.adaptive(
            title: const Text('Messages'),
            subtitle: const Text('New chat messages and replies'),
            value: messages,
            activeColor: _primary,
            onChanged:
                push ? (value) => setState(() => messages = value) : null,
          ),
          SwitchListTile.adaptive(
            title: const Text('Job Updates'),
            subtitle: const Text('Applications, acceptance and completion'),
            value: jobs,
            activeColor: _primary,
            onChanged: push ? (value) => setState(() => jobs = value) : null,
          ),
          SwitchListTile.adaptive(
            title: const Text('Reviews'),
            subtitle: const Text('Ratings and review activity'),
            value: reviews,
            activeColor: _primary,
            onChanged: push ? (value) => setState(() => reviews = value) : null,
          ),
          SwitchListTile.adaptive(
            title: const Text('Promotions'),
            subtitle: const Text('Offers and marketplace promotions'),
            value: promotions,
            activeColor: _primary,
            onChanged:
                push ? (value) => setState(() => promotions = value) : null,
          ),
        ],
      ),
    );
  }
}
