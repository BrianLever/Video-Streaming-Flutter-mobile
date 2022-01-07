import 'package:americonictv_mobile/logic/api/videos_api.dart';
import 'package:flutter/material.dart';
import 'package:americonictv_mobile/ui/screens/livestreams/animated_arrows.dart';
import 'package:americonictv_mobile/ui/screens/livestreams/player/livestream_player.dart';
import 'package:video_player/video_player.dart';

class LivestreamsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LivestreamsScreenState();
  }
}

class _LivestreamsScreenState extends State<LivestreamsScreen> {
  final _pageController = PageController();

  void _goToPage(int page) => _pageController.animateToPage(page,
      duration: const Duration(milliseconds: 200), curve: Curves.ease);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: VideosAPI.getLivestreams(),
        builder: (context, livestreams) => livestreams.connectionState !=
                    ConnectionState.done ||
                livestreams.hasData && livestreams.data.runtimeType == String ||
                livestreams.hasError ||
                livestreams.hasData && livestreams.data['error'] != false ||
                livestreams.hasData && livestreams.data['applications'].isEmpty
            ? Center(
                child: livestreams.connectionState != ConnectionState.done
                    ? CircularProgressIndicator()
                    : Text(
                        livestreams.hasData &&
                                livestreams.data.runtimeType == String
                            ? 'No livestreams found.'
                            : livestreams.hasError
                                ? livestreams.error.toString()
                                : livestreams.data['error'] != false
                                    ? livestreams.data['error']
                                    : 'No livestreams active at this time!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
              )
            : PageView(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                children: [
                  for (int i = 0;
                      i < livestreams.data['applications'].length;
                      i++)
                    Stack(
                      children: [
                        GestureDetector(
                          child: Stack(
                            children: [
                              Image.network(
                                livestreams.data['applications'][0]['poster'],
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                              ),
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 12,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(13),
                                      child: Image.network(
                                        livestreams.data['applications'][0]
                                            ['UserPhoto'],
                                        fit: BoxFit.cover,
                                        width: 26,
                                        height: 26,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        livestreams.data['applications'][0]
                                            ['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierColor:
                                  Theme.of(context).primaryColor.withAlpha(200),
                              builder: (context) => WillPopScope(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                                onWillPop: () async => false,
                              ),
                            );
                            final VideoPlayerController playerController =
                                VideoPlayerController.network(livestreams
                                    .data['applications'][0]['source']);
                            try {
                              await playerController.initialize();
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      LivestreamPlayer(
                                    playerController: playerController,
                                  ),
                                ),
                              );
                            } catch (e) {
                              Navigator.pop(context);
                              playerController.dispose();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('$e')));
                            }
                          },
                        ),
                        Center(
                          child: AnimatedArrows(
                            index: i,
                            length: livestreams.data['applications'].length,
                            goToPage: _goToPage,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
