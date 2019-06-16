import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({Key key}) : super(key: key);

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

    _controller = VideoPlayerController.asset('assets/videos/example3.mp4');

    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.play();
    _controller.setLooping(true);

    super.initState();
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
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the Aspect Ratio of the Video
//            return AspectRatio(
//              aspectRatio: _controller.value.aspectRatio,
//              // Use the VideoPlayer widget to display the video
//              child: RotatedBox(quarterTurns: 1, child: VideoPlayer(_controller)),
//            );
                return VideoPlayer(_controller);
//              return RotatedBox(quarterTurns: 1, child: VideoPlayer(_controller));
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner
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