import 'package:americonictv_mobile/logic/api/models/videos_response.dart';
import 'package:americonictv_mobile/ui/shared/video_view/video_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VideoEntry extends StatelessWidget {
  final VideoData video;
  final int index;
  final Function rebuildParent;
  final bool saved;

  VideoEntry({
    @required this.video,
    @required this.index,
    this.rebuildParent,
    this.saved: false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: GestureDetector(
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[2],
            color: Colors.grey.shade200,
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
                  children: [
                    Hero(
                      tag: video.images.thumbsJpg,
                      child: Image.network(
                        video.images.thumbsJpg,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Stack(
                        children: [
                          Text(
                            video.title,
                            style: TextStyle(
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
              DecoratedBox(
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.thumb_up, size: 20),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 16,
                              ),
                              child: Text(
                                NumberFormat.compact().format(video.likes),
                              ),
                            ),
                            if (!saved) Icon(Icons.thumb_down, size: 20),
                            if (!saved)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  NumberFormat.compact().format(video.dislikes),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          NumberFormat.compact().format(video.viewsCount) +
                              ' views',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  VideoViewScreen(video: video, saved: saved)));
        },
      ),
    );
  }
}
