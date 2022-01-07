import 'dart:async';

import 'package:americonictv_mobile/logic/api/models/videos_response.dart';
import 'package:americonictv_mobile/logic/api/social.dart';
import 'package:americonictv_mobile/ui/screens/saved_videos/bloc/selected_folder_controller.dart';
import 'package:americonictv_mobile/ui/screens/saved_videos/folder_filter.dart';
import 'package:americonictv_mobile/ui/shared/video_details.dart';
import 'package:flutter/material.dart';

class SavedVideoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SavedVideoScreenState();
  }
}

class _SavedVideoScreenState extends State<SavedVideoScreen> {
  Future<List<VideoData>> _getFavorites() async =>
      Social.getFavorites().then((value) => value.videos);

  Future<List<VideoData>> _getWatchLater() async =>
      Social.getWatchLater().then((value) => value.videos);

  final _futureController = StreamController.broadcast();

  final _pageController = PageController();

  void _goToPage(int page) => _pageController.animateToPage(page,
      duration: const Duration(milliseconds: 400), curve: Curves.ease);

  @override
  void initState() {
    super.initState();
    SelectedFolderController.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(
                children: [
                  FolderFilter(
                    label: 'Favorites',
                    page: 0,
                    goToPage: _goToPage,
                  ),
                  const SizedBox(width: 8),
                  FolderFilter(
                    label: 'Watch Later',
                    page: 1,
                    goToPage: _goToPage,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < 2; i++)
                  FutureBuilder(
                    future: i == 0 ? _getFavorites() : _getWatchLater(),
                    builder: (context, AsyncSnapshot<List<VideoData>> videos) =>
                        videos.connectionState != ConnectionState.done ||
                                videos.hasError ||
                                videos.hasData && videos.data.isEmpty
                            ? Center(
                                child: videos.connectionState ==
                                        ConnectionState.done
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(
                                          videos.hasData && videos.data.isEmpty
                                              ? 'No saved videos'
                                              : videos.error.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      )
                                    : CircularProgressIndicator(),
                              )
                            : GridView.builder(
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
                                itemCount: videos.data.length,
                                itemBuilder: (context, i) {
                                  return FeedVideoDetails(
                                    data: videos.data[i],
                                    index: i,
                                    saved: true,
                                  );
                                },
                              ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SelectedFolderController.dispose();
    _pageController.dispose();
    _futureController.close();
    super.dispose();
  }
}
