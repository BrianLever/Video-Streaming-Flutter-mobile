

import 'package:americonictv_mobile/logic/api/models/series_model.dart';
import 'package:americonictv_mobile/ui/shared/serie_view/serie_display.dart';
import 'package:americonictv_mobile/ui/shared/serie_view/serie_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:americonictv_mobile/logic/api/videos_api.dart';



class SerieEntryButton extends StatelessWidget {
  final VideoData video;
  final int index;
  final Function rebuildParent;
  final bool saved;

  SerieEntryButton({
    @required this.video,
    @required this.index,
    this.rebuildParent,
    this.saved: false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: GestureDetector(
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[2],
            color: Colors.grey.shade900,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: (MediaQuery.of(context).size.width * 0.44) /
                    (MediaQuery.of(context).orientation ==
                        Orientation.portrait
                        ? 1
                        : 2) -
                    (MediaQuery.of(context).orientation == Orientation.portrait
                        ? 0
                        : 27),
                child: Stack(
                  children: [ FutureBuilder(
                    future: VideosAPI.getThumb(video.videosId),
                    builder: (context, thumb) => thumb.connectionState !=
                        ConnectionState.done ||
                        thumb.hasError
                        ? Center(
                           child: thumb.hasError
                            ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(thumb.error.toString()),
                      )
                          : Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: CircularProgressIndicator(),
                      ),
                    ):
                    Image.network(
                      thumb.data.response.images.thumbsJpg,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                    ),
                  ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                      child: Stack(
                        children: [
                          Text(
                            video.title,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2,
                            ),
                          ),
                          Text(
                            video.title,
                            style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  SerieView(video: video, saved: saved)));
        },
      ),
    );

  }
}
