import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class LivestreamPlayer extends StatefulWidget {
  final VideoPlayerController playerController;

  LivestreamPlayer({@required this.playerController});

  @override
  State<StatefulWidget> createState() {
    return _LivestreamPlayerState();
  }
}

class _LivestreamPlayerState extends State<LivestreamPlayer>
    with WidgetsBindingObserver {
  final _visibilityController = StreamController.broadcast();

  Timer _timer;
  void _setTimer() {
    _timer?.cancel();
    _timer = Timer(
      const Duration(seconds: 5),
      () => _visibilityController.add(false),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.playerController.play().whenComplete(() => _setTimer());
  }

  bool _muted = false;
  bool _fullscreen = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _fullscreen)
      SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor,
      child: SizedBox.expand(
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.playerController.value.aspectRatio,
                child: VideoPlayer(
                  widget.playerController,
                ),
              ),
            ),
            StreamBuilder(
              stream: _visibilityController.stream,
              initialData: true,
              builder: (context, visible) => Listener(
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: MediaQuery.of(context).padding.top,
                      child: AnimatedOpacity(
                        opacity: visible.data ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: visible.data
                              ? () => Navigator.pop(context)
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: visible.data ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  StatefulBuilder(
                                    builder: (context, newState) => IconButton(
                                      icon: Icon(
                                        _muted
                                            ? Icons.volume_off
                                            : Icons.volume_up,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        newState(() => _muted = !_muted);
                                        widget.playerController
                                            .setVolume(_muted ? 0 : 1);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: Icon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _fullscreen = !_fullscreen;
                                      _fullscreen
                                          ? SystemChrome
                                              .setEnabledSystemUIOverlays([])
                                          : SystemChrome
                                              .setEnabledSystemUIOverlays(
                                                  SystemUiOverlay.values);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                onPointerDown: (_) {
                  _visibilityController.add(true);
                  _setTimer();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    widget.playerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
