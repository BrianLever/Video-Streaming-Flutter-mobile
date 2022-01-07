import 'package:flutter/material.dart';
import 'package:americonictv_mobile/data/auth/user_data.dart';
import 'package:americonictv_mobile/logic/api/chat.dart';

class ChatMessage extends StatefulWidget {
  final String userId, toUserId;
  final Map message;
  final bool delivered;

  ChatMessage({
    @required this.userId,
    @required this.toUserId,
    @required this.message,
    @required this.delivered,
  });

  @override
  State<StatefulWidget> createState() {
    return _ChatMessageState();
  }
}

class _ChatMessageState extends State<ChatMessage> {
  bool _sent;

  @override
  void initState() {
    super.initState();
    _sent = widget.delivered;
    if (!_sent)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final decoded = await ChatApi.newMessage(
            widget.toUserId,
            widget.message['message'],
          );
        } catch (e) {
          print(e);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.message['from_users_id'] == User.instance.id
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.message['from_users_id'] == User.instance.id
                ? Theme.of(context).accentColor
                : const Color(0xff1a1a1d),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.message['message'],
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    widget.message['humanTiming'],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
