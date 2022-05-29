import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

//ignore: must_be_immutable
class VideoPlayerScreen extends StatefulWidget {
  String url;
  VideoPlayerScreen({Key key,@required this.url}) : super(key: key);
  @override
  _VideoPlayerScreen createState() => _VideoPlayerScreen();
}
class _VideoPlayerScreen extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.setLooping(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: GestureDetector(
            onTap: (){
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
              child: _controller.value.initialized
                ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
                : Container(
                  alignment: Alignment.center,
                  child: Icon(Icons.video_collection_rounded,color: Colors.white,size: 50,),
                ),
          )
        ),
      floatingActionButton: Align(
        alignment: Alignment.center,
        child: Visibility(
          child: FloatingActionButton(
          onPressed: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              }
              else{
                _controller.play();
              }
            });
          },
            backgroundColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
          visible: _controller.value.isPlaying ? false : true),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}