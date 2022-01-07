

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:americonictv_mobile/logic/api/models/videos_response.dart';
import 'package:americonictv_mobile/ui/shared/video_view/video_view_screen.dart';

class SerieDisplay extends StatefulWidget {
  final VideoData data;
  final int index;
  final bool saved;

  SerieDisplay(
      {@required this.data, @required this.index, this.saved: false});

  @override
  State<StatefulWidget> createState() {
    return _FeedVideoDetailsState();
  }
}

class _FeedVideoDetailsState extends State<SerieDisplay> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).orientation == Orientation.portrait
          ? EdgeInsets.fromLTRB(14, widget.index == 0 ? 16 : 0, 14, 14)
          : EdgeInsets.fromLTRB(
          0, widget.index == 0 || widget.index == 1 ? 12 : 0, 0, 10),
      child: GestureDetector(
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[2],
            color: Colors.grey..shade200,
          ),
          child: Container(
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? (MediaQuery.of(context).size.width / 3)
                : (MediaQuery.of(context).size.width * (3 / 5)),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  widget.data.images.thumbsJpg,
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Stack(
                        children: [
                          Text(
                            widget.data.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2,
                            ),
                          ),
                          Text(
                            widget.data.title,
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
                DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!widget.saved)
                          Row(
                            children: [
                              Icon(Icons.thumb_up, size: 20),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 16,
                                ),
                                child: Text(
                                  NumberFormat.compact().format(
                                    widget.data.likes,
                                  ),
                                ),
                              ),
                              Icon(Icons.thumb_down, size: 20),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  NumberFormat.compact().format(
                                    widget.data.dislikes,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        Text(
                          NumberFormat.compact().format(
                            widget.data.viewsCount,
                          ) +
                              ' views',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => VideoViewScreen(
              video: widget.data,
            ),
          ),
        ),
      ),
    );
  }
}
