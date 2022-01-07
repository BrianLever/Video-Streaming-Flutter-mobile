
import 'dart:convert';
import 'package:americonictv_mobile/logic/api/models/videos_response.dart';
import 'package:americonictv_mobile/ui/shared/serie_entry/Series_entry_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SerieslistDisplay extends StatefulWidget {
  final List<Playlist> response;

  SerieslistDisplay({@required this.response});

  @override
  State<StatefulWidget> createState() {
    return _SerieslistDisplayState();
  }
}

class _SerieslistDisplayState extends State<SerieslistDisplay> {

  @override
  Widget build(BuildContext context) {
    if (widget.response==null)
    {
      return Center(
        child: Text(
          'No Serieslist found.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else {
      return Stack(
        children: [
          GridView.builder(
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
            itemCount: widget.response.length,
            itemBuilder: (context, i) => SeriesEntryButton(
              video: widget.response[i],
              index: i,
            ),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
