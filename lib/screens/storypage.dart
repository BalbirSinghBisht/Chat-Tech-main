import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

//ignore: must_be_immutable
class StoryPageView extends StatelessWidget {
  String image;

  StoryPageView({this.image});
  
  final _storyController = StoryController();
  @override
  Widget build(BuildContext context) {
    final controller = StoryController();
    final List<StoryItem> storyItems = [
      StoryItem.pageImage(
          url: image,
          controller: _storyController,
          imageFit: BoxFit.contain,
      ),
    ];
    return Material(
      child: StoryView(
        storyItems: storyItems,
        controller: controller,
        inline: false,
        repeat: false,
        onComplete: (){
          Navigator.pop(context);
        },
      ),
    );
  }
}