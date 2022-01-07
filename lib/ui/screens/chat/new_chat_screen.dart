import 'dart:async';

import 'package:flutter/material.dart';
import 'package:americonictv_mobile/data/auth/user_data.dart';
import 'package:americonictv_mobile/logic/api/chat.dart';
import 'package:americonictv_mobile/ui/screens/chat/chat_screen/chat_screen.dart';
import 'package:americonictv_mobile/ui/shared/future_builder_no_data.dart';

class NewChatsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewChatsScreenState();
  }
}

class _NewChatsScreenState extends State<NewChatsScreen> {
  final _searchTextController = TextEditingController();

  final _searchController = StreamController.broadcast();

  String _lastSearch;

  Key _futureKey = UniqueKey();
  static Future _getUsers;
  void _updateSearchParams() {
    _futureKey = UniqueKey();
    _getUsers = ChatApi.searchForUsers(
      _searchTextController.text,
    );
  }

  @override
  void initState() {
    super.initState();
    _searchTextController.addListener(() {
      _searchController.add(_searchTextController.text);
      if (_lastSearch != _searchTextController.text) {
        setState(() => _updateSearchParams());
        _lastSearch = _searchTextController.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('User Search'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 64),
          child: DecoratedBox(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    autofocus: true,
                    controller: _searchTextController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      hintText: 'Search',
                      suffixIcon: Icon(Icons.search),
                      contentPadding: const EdgeInsets.fromLTRB(10, 6, 48, 6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _searchController.stream,
        builder: (context, searchTerm) => searchTerm.hasData &&
                searchTerm.data.length > 2
            ? FutureBuilder(
                key: _futureKey,
                future: _getUsers,
                builder: (context, AsyncSnapshot users) => users
                                .connectionState !=
                            ConnectionState.done ||
                        users.hasError ||
                        users.hasData && users.data['error'] != false ||
                        users.hasData && users.data['response'].isEmpty
                    ? users.hasData && users.data['response'].isEmpty
                        ? Center(
                            child: Text(
                              'No users found.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        : FutureBuilderNoData(users)
                    : ListView.builder(
                        itemCount: users.data['response'].length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, i) => GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 9),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xff1a1a1d),
                                    foregroundImage: users.data['response'][i]
                                                ['photo'] !=
                                            null
                                        ? NetworkImage(
                                            users.data['response'][i]['photo'])
                                        : null,
                                    radius: 20,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      users.data['response'][i]['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      users.data['response'][i]['user'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          onTap: users.data['response'][i]['id'] !=
                                  User.instance.id
                              ? () {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          ChatScreen(
                                        userId: users.data['response'][i]['id']
                                            .toString(),
                                        name: users.data['response'][i]['name'],
                                        messages: [],
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    !searchTerm.hasData || searchTerm.data == ''
                        ? 'Enter your search term'
                        : 'Enter at least 3 characters.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }
}
