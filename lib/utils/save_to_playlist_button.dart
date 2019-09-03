import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SaveToPlayListButton extends StatefulWidget {
  final currentlyPlaying;
  final saveIcon;
  SaveToPlayListButton({Key key, @required this.currentlyPlaying, @required this.saveIcon}) : super(key: key);
  createState() => SaveToPlayListButtonState();
}


class SaveToPlayListButtonState extends State<SaveToPlayListButton> {
  List<dynamic> _myPlayLists = [];
  Singleton _singleton = Singleton();
  DateTime _currentUtilBtnTappedTime;

  @override
  void initState() {
    super.initState();
    if (_singleton.user != null) {
      PlayListApi.getMyPlayLists(_singleton.user.id).then((playLists) {
        setState(() {
          _myPlayLists.addAll(playLists);
        });
      });
    }
  }

  @override
  Widget build(context) {
    return Container(
        width: 60,
        height: 60,
        child: FlatButton(
          padding: EdgeInsets.all(0),
          child: widget.saveIcon,
          color: Colors.transparent,
          onPressed: () {
            if (_singleton.user != null) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                      titlePadding: EdgeInsets.all(0),
                      contentPadding: EdgeInsets.all(0),
                      title: Container(
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 0.3))
                          ),
                          padding: EdgeInsets.all(14),
                          child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin:
                                    EdgeInsets.only(bottom: 5),
                                    child: Text("My Play Lists",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight:
                                            FontWeight.bold))),
                                Text(
                                    "Choose a play list to save the video",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.normal))
                              ])),
                      content: ConstrainedBox(
                          constraints:
                          BoxConstraints(minHeight: 150, maxHeight: 250),
                          child: ListView.separated(
                              itemCount: _myPlayLists.length,
                              separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.black),
                              itemBuilder: (context, index) {
                                return ListTile(
                                    leading: Text("${index+1}: ", style: TextStyle(color: Colors.blueGrey),),
                                    title: Text(
                                        _myPlayLists[index]
                                        ['title'],
                                        style: TextStyle(
                                            color: Colors.blueGrey)),
                                    onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                  title: Text(
                                                      "Do you want to save the video to play list: "),
                                                  content: Text(
                                                      "\"${_myPlayLists[index]['title']}\""),
                                                  actions: [
                                                    new FlatButton(
                                                        child: new Text(
                                                            "Yes",
                                                            style: TextStyle(
                                                                fontSize:
                                                                20)),
                                                        onPressed:
                                                            () {
                                                          PlayListApi
                                                              .addMusicToPlayList(
                                                              widget
                                                                  .currentlyPlaying['_id'],
                                                              _myPlayLists[index]['_id'])
                                                              .then((
                                                              responseCode) {
                                                            if (responseCode ==
                                                                200) {
                                                              Navigator.of(
                                                                  context)
                                                                  .pop();
                                                              Navigator.of(
                                                                  context)
                                                                  .pop();
                                                            }
                                                            else {
                                                              showDialog(
                                                                context: context,
                                                                builder: (
                                                                    context) {
                                                                  return AlertDialog(
                                                                      title: Text(
                                                                          "The video already exists in the play list"),
                                                                      actions: [
                                                                        new FlatButton(
                                                                          child: new Text(
                                                                              "Okay"
                                                                          ),
                                                                          onPressed: () {
                                                                            Navigator
                                                                                .of(
                                                                                context)
                                                                                .pop();
                                                                            Navigator
                                                                                .of(
                                                                                context)
                                                                                .pop();
                                                                          },
                                                                        )
                                                                      ]
                                                                  );
                                                                },
                                                              );
                                                            }
                                                          });
                                                        }),
                                                    new FlatButton(
                                                        child: new Text(
                                                            "No",
                                                            style: TextStyle(
                                                                fontSize:
                                                                20)),
                                                        onPressed:
                                                            () {
                                                          Navigator.of(
                                                              context)
                                                              .pop();
                                                        })
                                                  ]);
                                            });
                                    });
                              })),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('CANCEL'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ]);
                });
            }else {
              DateTime now = DateTime.now();
              if (_currentUtilBtnTappedTime == null ||
                  now.difference(_currentUtilBtnTappedTime) > Duration(seconds: 3)) {
                _currentUtilBtnTappedTime = now;
                Fluttertoast.showToast(
                    msg: "You need to log in",
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Color.fromRGBO(0, 0, 0, 0.5)
                );
              }
            }
          },
        ));
  }
}