import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerScreen extends StatefulWidget {
  PageController _pageController;
  String _sourcePath;
  YoutubePlayerScreen(this._sourcePath, this._pageController, {Key key}) : super(key: key);
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  var _controller = YoutubePlayerController();
  String _sourcePath;

  void initState(){
    _sourcePath = widget._sourcePath;
  }

  void autoSwipe(PageController pageController) {
    setState(() {
      pageController.nextPage(
          duration: Duration(milliseconds: 1000), curve: Curves.decelerate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(children: [
        Center(
          child: YoutubePlayer(
            context: context,
            videoId: YoutubePlayer.convertUrlToId(_sourcePath),
            flags: YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              showVideoProgressIndicator: true,
            ),
            videoProgressIndicatorColor: Colors.amber,
            progressColors: ProgressColors(
              playedColor: Colors.amber,
              handleColor: Colors.amberAccent,
            ),
            onPlayerInitialized: (controller) {
              _controller = controller;
              _controller.cue();
              _controller.addListener(() {
                if (_controller.value.playerState == PlayerState.ENDED) {
                  autoSwipe(widget._pageController);
                }
                if (_controller.value.hasError) {
                  print("Error: ${_controller.value.errorCode}");
                  setState((){
                    _sourcePath = "https://youtu.be/HoXNpjUOx4U";
                  });
                }
              });
            },
          ),
        ),
        Positioned(
            left: 100,
            top: 20,
            child: Text("dkfjlskd", style: TextStyle(color: Colors.white)))
      ]),
    );
  }
}
