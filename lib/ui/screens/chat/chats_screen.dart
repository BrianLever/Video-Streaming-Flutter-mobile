import 'package:flutter/material.dart';
import 'package:americonictv_mobile/data/auth/user_data.dart';
import 'package:americonictv_mobile/logic/api/chat.dart';
import 'package:americonictv_mobile/ui/screens/chat/new_chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChatsScreenState();
  }
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
          future: ChatApi.getChatsWithUser(User.instance.id.toString()),
          builder: (context, chats) => Stack(
            children: [
              chats.connectionState != ConnectionState.done ||
                      chats.hasError ||
                      chats.hasData && chats.data['messages'].isEmpty
                  ? Center(
                      child: chats.connectionState != ConnectionState.done
                          ? CircularProgressIndicator()
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                chats.hasError
                                    ? chats.error.toString()
                                    : 'No chats found',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: chats.data['messages'].length,
                      itemBuilder: (context, i) => GestureDetector(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white54),
                            ),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 64,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        onTap: () {},
                      ),
                    ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).accentColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => NewChatsScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
