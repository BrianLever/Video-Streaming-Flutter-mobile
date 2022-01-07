import 'dart:convert';

import 'package:americonictv_mobile/data/auth/user_data.dart';
import 'package:americonictv_mobile/logic/api/models/videos_response.dart';
import 'package:americonictv_mobile/logic/api/social.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RatingSection extends StatefulWidget {
  final VideoData video;
  final bool saved;

  RatingSection({
    @required this.video,
    this.saved: false,
  });

  @override
  State<StatefulWidget> createState() {
    return _RatingSectionState();
  }
}

class _RatingSectionState extends State<RatingSection> {
  bool _updating = true;
  bool _updated = false;

  bool _liked;
  bool _disliked;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final liked = await Social.isLiked(widget.video.id);
      if (liked == true) {
        _liked = true;
        _disliked = false;
      } else if (liked == false) {
        _liked = false;
        _disliked = true;
      } else {
        _liked = false;
        _disliked = false;
      }
      setState(() => _updating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _updating
        ? SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.thumb_up,
                  color: _liked ? Colors.green.shade300 : Colors.white,
                ),
                onTap: User.loggedIn
                    ? () async {
                        setState(() => _updating = true);
                        try {
                          final response = await Social.like(widget.video.id);
                          final decoded = jsonDecode(response.body);
                          if (decoded['error'] == false) {
                            setState(() {
                              _updated = true;
                              _liked = decoded['response']['myVote'] == 1;
                              if (_liked) _disliked = false;
                            });
                          } else
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(decoded['message'])));
                        } catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('$e')));
                        }
                        setState(() => _updating = false);
                      }
                    : () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('You must be logged in to do that'))),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 16,
                ),
                child: Text(
                  NumberFormat.compact().format(
                    widget.video.likes + (_updated && _liked ? 1 : 0),
                  ),
                ),
              ),
              if (!widget.saved)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Icon(
                    Icons.thumb_down,
                    color: _disliked ? Colors.red.shade300 : Colors.white,
                  ),
                  onTap: User.loggedIn
                      ? () async {
                          setState(() => _updating = true);
                          try {
                            final response =
                                await Social.dislike(widget.video.id);
                            final decoded = jsonDecode(response.body);
                            if (decoded['error'] == false) {
                              setState(() {
                                _updated = true;
                                _disliked = decoded['response']['myVote'] == -1;
                                if (_disliked) _liked = false;
                              });
                            } else
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(decoded['message'])));
                          } catch (e) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('$e')));
                          }
                          setState(() => _updating = false);
                        }
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('You must be logged in to do that'))),
                ),
              if (!widget.saved)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    NumberFormat.compact().format(
                      widget.video.dislikes + (_updated && _disliked ? 1 : 0),
                    ),
                  ),
                ),
            ],
          );
  }
}
