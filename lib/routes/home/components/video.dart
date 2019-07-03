import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  String sourcePath;
  PageController _pageController;
  VideoPlayerScreen(sourcePath, _pageController){
    this.sourcePath = sourcePath;
    this._pageController = _pageController;
  }

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // Create an store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.

    _controller = VideoPlayerController.network(widget.sourcePath)
        ..addListener((){
      final bool isPlaying = _controller.value.isPlaying;
      if(_controller.value.duration != null && _controller.value.position >= _controller.value.duration) autoSwipe(widget._pageController);
    });

    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.play();
//    _controller.setLooping(true);

    super.initState();
  }

  void autoSwipe(PageController pageController) {
    setState((){
      pageController.nextPage(duration: Duration(milliseconds: 1000), curve: Curves.decelerate);
    });
  }

  @override
  void dispose() {
    // Ensure you dispose the VideoPlayerController to free up resources
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show the video in the next step
    return GestureDetector(
        child: Scaffold(
          body: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Center(child: Stack(children: [Container(height: MediaQuery.of(context).size.height,child: Center(child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller)))),
                Positioned(width: MediaQuery.of(context).size.width, bottom: 35.0,child: VideoProgressIndicator(_controller,
                    allowScrubbing: false,
                    colors: VideoProgressColors(playedColor: Color.fromRGBO(255, 255, 255, 1),
                    backgroundColor: Color.fromRGBO(100, 100, 100, 0.7)),
                    padding: EdgeInsets.symmetric(vertical: 15.0),)),
                ]));
//              return RotatedBox(quarterTurns: 1, child: VideoPlayer(_controller));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
//          // Wrap the play or pause in a call to `setState`. This ensures the
//          // correct icon is shown
//          setState(() {
//            // If the video is playing, pause it.
//            if (_controller.value.isPlaying) {
//              _controller.pause();
//            } else {
//              // If the video is paused, play it
//              _controller.play();
//            }
//          });
//        },
//        // Display the correct icon depending on the state of the player.
//        child: Icon(
//          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//        ),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
        onTap: (){
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            // If the video is paused, play it
            _controller.play();
          }
        });
  }
}