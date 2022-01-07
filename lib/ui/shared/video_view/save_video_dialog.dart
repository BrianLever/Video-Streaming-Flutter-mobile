import 'dart:convert';

import 'package:americonictv_mobile/logic/api/models/videos_response.dart';
import 'package:americonictv_mobile/logic/api/social.dart';
import 'package:americonictv_mobile/logic/cache/prefs.dart';
import 'package:flutter/material.dart';

class SaveVideoOption extends StatefulWidget {
  final String label, folder;
  final int videoID;
  final save, remove;

  SaveVideoOption({
    @required this.label,
    @required this.folder,
    @required this.videoID,
    @required this.save,
    @required this.remove,
  });

  @override
  State<StatefulWidget> createState() {
    return _SaveVideoOptionState();
  }
}

class _SaveVideoOptionState extends State<SaveVideoOption> {
  bool _saved;

  @override
  void initState() {
    super.initState();
    _saved =
        Prefs.instance.getBool('${widget.videoID} ${widget.folder}') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                widget.folder == 'later'
                    ? _saved
                        ? Icons.playlist_add
                        : Icons.playlist_add_check
                    : _saved
                        ? Icons.favorite
                        : Icons.favorite_border,
                color: Colors.white,
              ),
            ),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_saved)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check,
                  color: Colors.green.shade300,
                ),
              ),
          ],
        ),
      ),
      onTap: () async {
        showDialog(
          context: context,
          barrierColor: Theme.of(context).primaryColor,
          barrierDismissible: false,
          builder: (context) => WillPopScope(
              child: Center(child: CircularProgressIndicator()),
              onWillPop: () async => false),
        );
        final decoded = jsonDecode(
            (_saved ? await widget.remove() : await widget.save()).body);
        Navigator.pop(context);
        Navigator.pop(context);
        if (!_saved && decoded['status'] == false)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Couldn\'t save this video. Please try again')));
        await Prefs.instance
            .setBool('${widget.videoID} ${widget.folder}', !_saved);
      },
    );
  }
}

class SaveVideoDialog extends StatelessWidget {
  final VideoData video;

  SaveVideoDialog({@required this.video});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SaveVideoOption(
          label: 'Save to favorites',
          folder: 'saved',
          save: () async => await Social.favorite(video.id),
          videoID: video.id,
          remove: () async => await Social.removeFavorite(video.id),
        ),
        const Divider(height: 0, color: Colors.white),
        SaveVideoOption(
          label: 'Save for later',
          folder: 'later',
          save: () async => await Social.watchLater(video.id),
          videoID: video.id,
          remove: () async => await Social.removeWatchLater(video.id),
        ),
      ],
    );
  }
}
