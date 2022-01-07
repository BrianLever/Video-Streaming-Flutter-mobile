import 'package:americonictv_mobile/logic/api/models/videos_response.dart';
import 'package:americonictv_mobile/logic/api/videos_api.dart';
import 'package:americonictv_mobile/ui/shared/future_builder_no_data.dart';
import 'package:americonictv_mobile/ui/shared/video_details.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static final Future<VideosResponse> _getVideos = VideosAPI.getLatest();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getVideos,
      builder: (context, AsyncSnapshot<VideosResponse> videos) =>
          videos.connectionState != ConnectionState.done ||
                  videos.hasError ||
                  videos.hasData && videos.data.error != false ||
                  videos.hasData && videos.data.response.rows.isEmpty
              ? FutureBuilderNoData(videos)
              : GridView.builder(
                  padding:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(horizontal: 14),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).orientation ==
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
    );
  }
}
