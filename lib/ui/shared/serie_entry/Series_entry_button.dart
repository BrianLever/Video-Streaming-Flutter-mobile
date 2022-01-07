
import 'package:americonictv_mobile/logic/api/models/videos_response.dart';
import 'package:americonictv_mobile/ui/shared/serie_view/serie_view_screen.dart';
import 'package:flutter/material.dart';

import 'Serie_display.dart';


class SeriesEntryButton extends StatelessWidget {
  final Playlist video;
  final int index;
  final Function rebuildParent;
  final bool saved;

  SeriesEntryButton({
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
        onTap: ()
        async {
          if(video.videos!=null) {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    SerieViewScreen(video: video, saved: saved)));
          }
          else{
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    SerieDisplay(video: video,saved: saved)));
          }

        },
      ),
    );

  }
}
