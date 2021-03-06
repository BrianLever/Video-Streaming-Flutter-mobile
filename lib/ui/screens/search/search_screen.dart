import 'dart:async';

import 'package:americonictv_mobile/logic/api/models/videos_response.dart';
import 'package:americonictv_mobile/logic/api/videos_api.dart';
import 'package:americonictv_mobile/ui/screens/search/bloc/filter_controller.dart';
import 'package:americonictv_mobile/ui/screens/search/filter_option.dart';
import 'package:americonictv_mobile/ui/shared/future_builder_no_data.dart';
import 'package:americonictv_mobile/ui/shared/video_details.dart';
import 'package:americonictv_mobile/ui/shared/video_entry/video_entry.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchTextController = TextEditingController();

  final _searchController = StreamController.broadcast();

  int _currentPage = 1;

  int _seriesFilter;

  StreamSubscription _seriesFilterSubscription;

  Key _futureKey = UniqueKey();
  static Future<VideosResponse> _getVideos;
  void _updateSearchParams() {
    _futureKey = UniqueKey();
    _getVideos = VideosAPI.searchVideos(
      _searchTextController.text,
      _currentPage,
      _seriesFilter,
    );
  }

  String _lastSearch;

  @override
  void initState() {
    super.initState();
    FilterController.init();
    _updateSearchParams();
    _searchTextController.addListener(() {
      _searchController.add(_searchTextController.text);
      if (_lastSearch != _searchTextController.text) {
        setState(() => _updateSearchParams());
        _lastSearch = _searchTextController.text;
      }
    });
    _seriesFilterSubscription = FilterController.stream.listen((value) {
      _seriesFilter = value;
      _searchController.add(_searchTextController.text);
      setState(() => _updateSearchParams());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Search'),
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
                future: _getVideos,
                builder: (context, AsyncSnapshot<VideosResponse> videos) =>
                    videos.connectionState != ConnectionState.done ||
                            videos.hasError ||
                            videos.hasData && videos.data.error != false ||
                            videos.hasData && videos.data.response.rows.isEmpty
                        ? videos.hasData && videos.data.response.rows.isEmpty
                            ? Center(
                                child: Text(
                                  'No videos found.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              )
                            : FutureBuilderNoData(videos)
                        : Stack(
                            children: [
                              GridView.builder(
                                padding: MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? EdgeInsets.zero
                                    : const EdgeInsets.symmetric(
                                        horizontal: 14),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      MediaQuery.of(context).orientation ==
                                              Orientation.portrait
                                          ? 1
                                          : 2,
                                  childAspectRatio: 4 / 3,
                                  crossAxisSpacing: 10,
                                ),
                                itemCount: videos.data.response.rows.length,
                                itemBuilder: (context, i) => FeedVideoDetails(
                                  data: videos.data.response.rows[i],
                                  index: i,
                                ),
                              ),
                              if (_currentPage != 1)
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  child: GestureDetector(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: kElevationToShadow[2],
                                        color: Theme.of(context).accentColor,
                                      ),
                                      child: SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: Center(
                                          child: Icon(
                                            Icons.keyboard_arrow_left_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () =>
                                        setState(() => _currentPage -= 1),
                                  ),
                                ),
                              if (videos.data.response.rows.length == 60)
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: GestureDetector(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: kElevationToShadow[2],
                                        color: Theme.of(context).accentColor,
                                      ),
                                      child: SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: Center(
                                          child: Icon(
                                            Icons.keyboard_arrow_right,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () =>
                                        setState(() => _currentPage += 1),
                                  ),
                                ),
                            ],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(Icons.build),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            barrierColor: Colors.transparent,
            builder: (context) => DecoratedBox(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilterOption(label: 'Movies', number: 0),
                    const SizedBox(width: 8),
                    FilterOption(label: 'Series', number: 1),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _searchController.close();
    FilterController.dispose();
    _seriesFilterSubscription.cancel();
    super.dispose();
  }
}
