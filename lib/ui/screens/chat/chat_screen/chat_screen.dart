import 'package:flutter/material.dart';
import 'package:americonictv_mobile/ui/screens/chat/chat_screen/message.dart';

class ChatScreen extends StatefulWidget {
  final String userId, name;
  final List<Map> messages;

  ChatScreen({
    @required this.userId,
    @required this.name,
    @required this.messages,
  });

  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      for (var message in widget.messages)
        ChatMessage(
          userId: message['from_users_id'],
          toUserId: message['to_users_id'],
          message: message['message'],
          delivered: true,
        ),
    ];
  }

  void _sendMessage(ChatMessage message) {
    setState(() => _messages.add(message));
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? SizedBox.expand(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text(
                          'Start your conversation\nby sending a message',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    reverse: true,
                    children: [
                      for (var message in _messages) message,
                    ],
                  ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 0, 9),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () async {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
