




import 'dart:async';
import 'dart:convert';
import 'package:americonictv_mobile/logic/api/models/series_model.dart';
import 'package:americonictv_mobile/logic/api/videos_api.dart';
import 'package:americonictv_mobile/ui/shared/serie_view/save_serie_dialog.dart';
import 'package:americonictv_mobile/ui/shared/serie_view/serie_rating_section.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:americonictv_mobile/data/auth/user_data.dart';
import 'package:americonictv_mobile/logic/api/auth.dart';
import 'package:americonictv_mobile/logic/api/models/user_model.dart';
import 'package:americonictv_mobile/logic/string_processing.dart';
import 'package:americonictv_mobile/ui/screens/channel/channel_screen.dart';
import 'package:americonictv_mobile/ui/screens/view.dart';
import 'package:americonictv_mobile/ui/shared/webview.dart';
import 'package:americonictv_mobile/ui/shared/video_view/bloc/buffering_controller.dart';
import 'package:americonictv_mobile/ui/shared/video_view/player/player_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
class SerieView extends StatefulWidget {
  final VideoData video;
  final bool saved;

  SerieView({
    @required this.video,
    this.saved: false,
  });

  @override
  State<StatefulWidget> createState() {
    return _VideoViewScreenState();
  }
}

class _VideoViewScreenState extends State<SerieView> {
  VideoPlayerController _videoPlayerController;

  int _currentPosition;

  StreamController _positionController;
  void _setPositionController(
      [int currenPosition = 0, VideoPlayerController controller]) {
    _currentPosition = currenPosition;
    _positionController = StreamController.broadcast();
    VideoPlayerController currentController =
        controller ?? _videoPlayerController;
    currentController.addListener(() {
      _currentPosition = currentController.value.position.inSeconds;
      _positionController.add(currentController.value.position.inSeconds);
      if (currentController.value.isBuffering && !BufferingController.buffering)
        BufferingController.change(true);
      else if (!currentController.value.isBuffering &&
          BufferingController.buffering) BufferingController.change(false);
    });
  }

  Set<String> _videoQualities;

  @override
  void initState() {
    super.initState();
    BufferingController.init();
    _videoPlayerController =
        VideoPlayerController.network(widget.video.path);
    _videoPlayerController.addListener(() =>
        BufferingController.change(_videoPlayerController.value.isBuffering));
  }

  // Future<bool> _getLargeImage() async {
  //   await precacheImage(
  //     NetworkImage(widget.video.images.poster),
  //     context,
  //   );
  //   return true;
  // }

  Future<void> _changeVideoQuality(String videoURL) async {
    _videoPlayerController.pause();
    Navigator.pop(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Theme.of(context).primaryColor,
      builder: (context) => WillPopScope(
        child: Center(child: CircularProgressIndicator()),
        onWillPop: () async => false,
      ),
    );
    final int currentPositionInSecs =
    (_videoPlayerController.value.position.inMilliseconds / 1000).round();
    try {
      _videoPlayerController.removeListener(() {});
      final _newPlayerController = VideoPlayerController.network(videoURL);
      await _newPlayerController.initialize();
      await _newPlayerController
          .seekTo(Duration(seconds: currentPositionInSecs));
      _newPlayerController.play();
      _setPositionController(currentPositionInSecs, _newPlayerController);
      Navigator.pop(context);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => VideoPlayerScreen(
            UniqueKey(),
            videoPlayerController: _newPlayerController,
            positionController: _positionController,
            currentPosition: _currentPosition,
            videoQualities: _videoQualities,
            changeVideoQuality: _changeVideoQuality,
          ),
        ),
      );
      await _videoPlayerController.dispose();
      _videoPlayerController = _newPlayerController;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.video.title),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    GestureDetector(
                      child: Stack(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width * 0.625,
                            child: FutureBuilder(
                              future: VideosAPI.getThumb(widget.video.videosId),
                              builder: (context, thumb) => AnimatedCrossFade(
                                firstChild:  thumb.connectionState !=
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
                                ):Image.network(
                                  thumb.data.response.images.thumbsJpg,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                ),
                                secondChild:  thumb.connectionState !=
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
                                ):Image.network(
                                  thumb.data.response.images.poster,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                ),
                                crossFadeState: thumb.hasData
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 200),
                              ),
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(color: Colors.black54),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width * 0.625,
                              child: Center(
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: (User.loggedIn &&
                          User.instance.subscription.isEmpty &&
                          widget.video.onlyForPaid == 1) ||
                          !User.loggedIn && widget.video.onlyForPaid == 1
                          ? () => User.loggedIn
                          ? ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'You must purchase a subscription in order to view this video.'),
                        ),
                      )
                          : showDialog(
                        context: context,
                        barrierColor: Theme.of(context).primaryColor,
                        builder: (context) => Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 22, 16, 16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'In order to watch this video, you must login or register and purchase a subscription.',
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 14,
                                      ),
                                      child: Row(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            child: Text('Cancel'),
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context),
                                          ),
                                          const SizedBox(width: 10),
                                          ElevatedButton(
                                            child: Text('Continue'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              MainView.state
                                                  .showAuthScreen(0);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                          : /*(Prefs.instance.getBool('nativePlayer') ?? false)
                              ?*/
                          () async {
                        bool error = false;
                        if (_currentPosition == null) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: Colors.transparent,
                              builder: (context) => Center(
                                  child: CircularProgressIndicator()));
                          try {
                            await _videoPlayerController.initialize();
                            _setPositionController();
                          } catch (e) {
                            error = true;
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$e')));
                          }
                          Navigator.pop(context);
                        }
                        if (!error) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  VideoPlayerScreen(
                                    UniqueKey(),
                                    videoPlayerController:
                                    _videoPlayerController,
                                    positionController: _positionController,
                                    currentPosition: _currentPosition,
                                    videoQualities: _videoQualities,
                                    changeVideoQuality: _changeVideoQuality,
                                  ),
                            ),
                          );
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(right: 9),
                                        child: Icon(
                                          Icons.add_to_photos_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text('Save'),
                                    ],
                                  ),
                                  onTap: () => showModalBottomSheet(
                                    context: context,
                                    barrierColor: Colors.transparent,
                                    backgroundColor:
                                    Theme.of(context).primaryColor,
                                    builder: (context) => SaveSerieDialog(
                                      // video: widget.video,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // SerieRatingSection(
                            //   video: widget.video,
                            //   saved: widget.saved,
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (User.loggedIn)
                            GestureDetector(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Theme.of(context)
                                      .accentColor
                                      .withOpacity(
                                    User.instance.subscription.isNotEmpty
                                        ? 0.5
                                        : 1,
                                  ),
                                ),
                                child: Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(24, 12, 24, 12),
                                  child: Text(
                                    'Subscribe' +
                                        (User.instance.subscription.isNotEmpty
                                            ? 'd'
                                            : ''),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: User.instance.subscription.isNotEmpty
                                  ? null
                                  : () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        WebviewScreen(),
                                  ),
                                );
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  barrierColor:
                                  Theme.of(context).primaryColor,
                                  builder: (context) => WillPopScope(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    onWillPop: () async => false,
                                  ),
                                );
                                try {
                                  final response = await Auth.login(
                                    User.instance.user,
                                    User.instance.pass,
                                  );
                                  final decoded =
                                  jsonDecode(response.body);
                                  await User.setInstance(
                                      UserData.fromJson(decoded), true);
                                  Navigator.pop(context);
                                } catch (e) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Couldn\'t update your info. Please exit and enter the app.',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              // child: Text(
                              //   widget.video.title,
                              //   style: TextStyle(
                              //     fontSize: 16,
                              //     fontWeight: FontWeight.w900,
                              //     color: Theme.of(context).accentColor,
                              //   ),
                              // ),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ChannelScreen(
                                      channelName: "Channel View",
                                      channelIdentifier: widget.video.pchannel,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                      child: Linkify(
                        text: StringProcessing.removeAllHtmlTags(
                          (widget.video.description ?? ''),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        onOpen: (linkable) async {
                          if (await canLaunch(linkable.url))
                            launch(linkable.url);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(height: 64),
            ],
          ),
          // Uncomment below and line 8 and 283 for comment display
          /*
          CommentsDisplay(
            comments: widget.video.comments,
            videoID: widget.video.id,
          ),
          */
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    BufferingController.dispose();
    super.dispose();
  }
}
