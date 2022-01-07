


import 'package:americonictv_mobile/logic/api/models/videos_response.dart';
import 'package:americonictv_mobile/logic/api/videos_api.dart';
import 'package:americonictv_mobile/ui/shared/serie_entry/Series_entry_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../future_builder_no_data.dart';
import 'Serie_entry_button.dart';


class SerieDisplay extends StatefulWidget {
  final Playlist video;
  final bool saved;

  SerieDisplay({@required this.video,this.saved: false});

  @override
  State<StatefulWidget> createState() {
    return _SerieslistDisplayState();
  }
}

class _SerieslistDisplayState extends State<SerieDisplay> {


  @override
  Widget build(BuildContext context) {
      return  FutureBuilder(
        future: VideosAPI.getVideosByPlaylist(widget.video.seriePlaylistsId
        ),
        builder: (context, series) =>
        series.connectionState != ConnectionState.done ||
            series.hasError ||
            series.hasData && series.data.error != false ||
            series.hasData && series.data==null
            ? FutureBuilderNoData(series)
            : GridView.builder(
             padding: MediaQuery.of(context).orientation ==
              Orientation.portrait
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 14),
             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
             crossAxisCount: MediaQuery.of(context).orientation ==
                Orientation.portrait
                ? 1
                : 2,
             childAspectRatio: 16 / 10,
             crossAxisSpacing: 10,
              ),
              itemCount: series.data.response.videos.length,
              itemBuilder: (context, i) => SerieEntryButton(
              video: series.data.response.videos[i],
            index: i,
          ),
        ),
      );
    }


  @override
  void dispose() {
    super.dispose();
  }
}
