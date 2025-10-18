import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  WebSocketChannel? _channel;
  final StreamController<List<Map<String, String>>> _messagesController = StreamController.broadcast();
  final StreamController<int> _unreadController = StreamController.broadcast();

  List<Map<String, String>> _messages = [];
  int _unread = 0;

  Stream<List<Map<String, String>>> get messagesStream => _messagesController.stream;
  Stream<int> get unreadStream => _unreadController.stream;

  void init() {
    _connect();
  }

  void _connect() {
    try {
      final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
      final uri = Uri.parse('ws://$host:3000/ws');
      _channel = WebSocketChannel.connect(uri);
      _channel!.stream.listen((data) {
        try {
          final parsed = jsonDecode(data as String) as Map<String, dynamic>;
          if (parsed['type'] == 'notification' || parsed['type'] == 'welcome') {
            final id = parsed['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
            final message = parsed['message']?.toString() ?? parsed.toString();
            final timestamp = parsed['timestamp']?.toString() ?? DateTime.now().toIso8601String();
            _addMessage({'id': id, 'message': message, 'timestamp': timestamp});
          }
        } catch (e) {
          // ignore
        }
      }, onError: (err) {
        _scheduleReconnect();
      }, onDone: () {
        _scheduleReconnect();
      });
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      _connect();
    });
  }

  void _addMessage(Map<String, String> msg) {
    _messages.insert(0, msg);
    if (_messages.length > 10) _messages.removeLast();
    _unread += 1;
    _messagesController.add(List.unmodifiable(_messages));
    _unreadController.add(_unread);
  }

  List<Map<String, String>> getMessages() => List.unmodifiable(_messages);

  int getUnread() => _unread;

  void clearUnread() {
    _unread = 0;
    _unreadController.add(_unread);
  }

  void dispose() {
    _channel?.sink.close();
    _messagesController.close();
    _unreadController.close();
  }
}
