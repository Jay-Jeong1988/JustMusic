//import 'package:flutter/material.dart';
//import 'package:video_player/video_player.dart';
//
//class VideoPlayerScreen extends StatefulWidget {
//  String sourcePath;
//  PageController pageController;
//  VideoPlayerScreen({sourcePath, pageController})
//
//  @override
//  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
//}
//
//class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//  VideoPlayerController _controller;
//  Future<void> _initializeVideoPlayerFuture;
//
//  @override
//  void initState() {
//    // Create an store the VideoPlayerController. The VideoPlayerController
//    // offers several different constructors to play videos from assets, files,
//    // or the internet.
//    _controller = VideoPlayerController.network(widget.sourcePath)
//        ..addListener((){
//          if (_controller.value.hasError){
//            print("Error: ${_controller.value.errorDescription}");
//          }
//      if(_controller.value.duration != null && _controller.value.position >= _controller.value.duration) autoSwipe(widget.pageController);
//    });
//    _initializeVideoPlayerFuture = _controller.initialize();
//    _controller.play();
//
//
////    _controller.setLooping(true);
//
//    super.initState();
//  }
//
//  void autoSwipe(PageController pageController) {
//    setState((){
//      pageController.nextPage(duration: Duration(milliseconds: 1000), curve: Curves.decelerate);
//    });
//  }
//
//  @override
//  void dispose() {
//    // Ensure you dispose the VideoPlayerController to free up resources
//    _controller.dispose();
//
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // Show the video in the next step
//    return GestureDetector(
//        child: Scaffold(
//          body: FutureBuilder(
//            future: _initializeVideoPlayerFuture,
//            builder: (context, snapshot) {
//              if (snapshot.connectionState == ConnectionState.done) {
//                return Center(child: Stack(children: [Container(height: MediaQuery.of(context).size.height,child: Center(child: AspectRatio(
//                    aspectRatio: _controller.value.aspectRatio,
//                    child: VideoPlayer(_controller)))),
//                Positioned(width: MediaQuery.of(context).size.width, bottom: 35.0,child: VideoProgressIndicator(_controller,
//                    allowScrubbing: false,
//                    colors: VideoProgressColors(playedColor: Color.fromRGBO(255, 255, 255, 1),
//                    backgroundColor: Color.fromRGBO(100, 100, 100, 0.7)),
//                    padding: EdgeInsets.symmetric(vertical: 15.0),)),
//                  _controller.value.isPlaying ? Container() : Center(child: Icon(Icons.play_arrow, color: Color.fromRGBO(255, 255, 255, 0.4), size: 75.0)),
//                ]));
////              return RotatedBox(quarterTurns: 1, child: VideoPlayer(_controller));
//              } else {
//                return Center(child: CircularProgressIndicator());
//              }
//            },
//          ),
//        ),
//        onTap: (){
//          setState((){
//            if (_controller.value.isPlaying) {
//              _controller.pause();
//            } else {
//              // If the video is paused, play it
//              _controller.play();
//            }
//          });
//        });
//  }
//}