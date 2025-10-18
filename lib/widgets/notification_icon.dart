import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationIcon extends StatefulWidget implements PreferredSizeWidget {
  final double size;
  const NotificationIcon({this.size = 24, super.key});

  @override
  State<NotificationIcon> createState() => _NotificationIconState();

  @override
  Size get preferredSize => Size(size, size);
}

class _NotificationIconState extends State<NotificationIcon> {
  late final NotificationService _service;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _service = NotificationService.instance;
    _service.unreadStream.listen((count) {
      if (mounted) setState(() => _unread = count);
    });
  }

  void _openNotifications() {
    final messages = _service.getMessages();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Notifications')),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    return ListTile(
                      title: Text(m['message'] ?? ''),
                      subtitle: Text(m['timestamp'] ?? ''),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() => _service.clearUnread());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: _openNotifications,
        ),
        if (_unread > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  _unread > 99 ? '99+' : '$_unread',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
