import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Our GestureDetector wraps our button
    return GestureDetector(
      // When the child is tapped, show
      onTap: () {
        _setModalBottomSheet(context);
      },
      // Our Custom Button!
      child: Center(
        child: Text('My Button'),
      ),
    );
  }

  void _setModalBottomSheet(context) {
    showModalBottomSheet<void>(context: context,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.music_note),
                title: new Text('Music'),
                onTap: () => {},
              ),
              new ListTile(
                leading: new Icon(Icons.photo_album),
                title: new Text('Photos'),
                onTap: () => {},
              ),
              new ListTile(
                leading: new Icon(Icons.videocam),
                title: new Text('Video'),
                onTap: () => {},
              ),
            ],
          );
        });
  }
}