import 'dart:convert';
import 'dart:io';

import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:JustMusic/global_components/speech_bubble.dart';
import 'package:JustMusic/routes/home/home_page.dart';
import 'package:JustMusic/utils/image_uploader.dart';
import 'package:JustMusic/utils/slide_right_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../main.dart';

var cardAspectRatio = 12.0 / 16.0;
var widgetAspectRatio = cardAspectRatio * 1.2;

class PlayListsPage extends StatefulWidget {
  @override
  PlayListsPageState createState() => PlayListsPageState();
}

class PlayListsPageState extends State<PlayListsPage> {
  List<dynamic> playLists = [{
  "title": "Create \nyour play list",
  "songs": [],
  "bgUrl": ""
  }];
  PageController controller;
  double currentPage;
  Singleton _singleton = Singleton();
  String _title = '';
  Future<List<dynamic>> _getMyPlayLists;
  String _bgImageUrl;

  @override
  void initState() {
    super.initState();
    _getMyPlayLists = PlayListApi.getMyPlayLists(_singleton.user.id);
    _getMyPlayLists.then((lists) {
      setState(() {
        playLists.addAll(lists);
        currentPage = playLists.length - 1.0;
        controller = PageController(initialPage: playLists.length - 1)
          ..addListener(() {
            setState(() {
              currentPage = controller.page;
            });
          });
      });
    });
  }

  Widget _titleAndPlayBtn() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 20, vertical: 0),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
              child: Container(
                  height: MediaQuery.of(context)
                      .size
                      .width *
                      .23,
                  padding: EdgeInsets.only(
                      right: 10),
                  child: Center(
                      child: Text(
                          playLists[currentPage.floor()]
                          [
                          'title']
                              .length <
                              23
                              ? playLists[
                          currentPage
                              .floor()]
                          ['title']
                              : "${playLists[currentPage.floor()]['title'].substring(0, 14)} ...",
                          style: TextStyle(
                            height: 0.7,
                            color: Colors.white,
                            fontSize: 38.0,
                            fontFamily:
                            "BalooChettan",
                            letterSpacing: 1.0,
                          )))))
          ,
          currentPage == 0
              ? Container(width: 48, height: 48)
              : IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(
              Icons.play_arrow,
              size: 40.0,
              color: Colors.red,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  SlideRightRoute(
                      rightToLeft: false,
                      page: AppScreen(
                          navigatedPage: HomePage(
                              inheritedSources: playLists[
                              currentPage
                                  .floor()]
                              ['songs']))));
              _singleton.widgetLayers+=1;
              _singleton.removeNavbar=true;
            },
          )
        ],
      ),
    );
  }

  Widget _displayingCards() {
    return AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(
          builder: (context, constraints) {
            var width = constraints.maxWidth;
            var height = constraints.maxHeight;

            var safeWidth = width - 2 * 20;
            var safeHeight = height - 2 * 20;

            var heightOfPrimaryCard = safeHeight;
            var widthOfPrimaryCard =
                heightOfPrimaryCard * cardAspectRatio;

            var primaryCardLeft =
                safeWidth - widthOfPrimaryCard;
            var horizontalInset = primaryCardLeft / 2;

            List<Widget> cardList = new List();

            for (var i = 0; i < playLists.length; i++) {
              var delta = i - currentPage;
              bool isOnRight = delta > 0;

              var start = 20 +
                  max(
                      primaryCardLeft -
                          horizontalInset *
                              -delta *
                              (isOnRight ? 15 : 1),
                      0.0);

              var cardItem = i == 0
                  ? Positioned.directional(
                  top: 20 +
                      20 *
                          max(-delta, 0.0),
                  bottom: 20 +
                      20 *
                          max(-delta, 0.0),
                  start: start,
                  textDirection: TextDirection.rtl,
                  child: ClipRRect(
                      borderRadius: BorderRadius
                          .circular(13.0),
                      child: DottedBorder(
                          dashPattern: [20, 20],
                          color: Colors.white54,
                          strokeWidth: 20,
                          child: Container(
                              decoration:
                              BoxDecoration(
                                  color: Colors
                                      .transparent,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color
                                            .fromRGBO(
                                            0,
                                            0,
                                            0,
                                            .1),
                                        offset:
                                        Offset(
                                            3.0,
                                            6.0),
                                        blurRadius:
                                        10.0)
                                  ]),
                              child: AspectRatio(
                                  aspectRatio:
                                  cardAspectRatio,
                                  child: Stack(
                                      fit: StackFit
                                          .expand,
                                      children: <
                                          Widget>[
                                        Center(
                                          child:
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                  icon: Icon(Icons.add),
                                                  iconSize: 120,
                                                  color: Colors.white54,
                                                  onPressed: () {
                                                  })
                                            ],
                                          ),
                                        )
                                      ]))))))
                  : Positioned.directional(
                top: 20 +
                    20 *
                        max(-delta, 0.0),
                bottom: 20 +
                    20 *
                        max(-delta, 0.0),
                start: start,
                textDirection: TextDirection.rtl,
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color:
                              Colors.black12,
                              offset: Offset(
                                  3.0, 6.0),
                              blurRadius: 10.0)
                        ]),
                    child: AspectRatio(
                      aspectRatio:
                      cardAspectRatio,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.network(
                              playLists[i]
                              ['bgUrl'],
                              fit: BoxFit.cover),
                          Align(
                            alignment: Alignment
                                .bottomLeft,
                            child: Column(
                              mainAxisSize:
                              MainAxisSize
                                  .min,
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                  const EdgeInsets
                                      .only(
                                      left:
                                      20.0),
                                  child:
                                  Container(
                                    padding: EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        17,
                                        vertical:
                                        6),
                                    decoration:
                                    BoxDecoration(
                                      color: Colors
                                          .redAccent,
                                      borderRadius:
                                      BorderRadius.circular(
                                          20.0),
                                    ),
                                    child: Text(
                                        "${playLists[i]['songs'].length} songs",
                                        style: TextStyle(
                                            color:
                                            Colors.white)),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets
                                      .symmetric(
                                      horizontal:
                                      20.0,
                                      vertical:
                                      8.0),
                                  child: Text(
                                      playLists[i]
                                      [
                                      'title'],
                                      style: TextStyle(
                                          color: Colors
                                              .white,
                                          fontSize:
                                          25.0,
                                          fontFamily:
                                          "SF-Pro-Text-Regular")),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            ),
                          ),
                          currentPage == 0
                              ? Container()
                              : Positioned(
                            top: 10,
                            left: 10,
                            child: Icon(
                              Icons.delete,
                              size: 30.0,
                              color: Colors
                                  .white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              cardList.add(cardItem);
            }
            return Stack(
              children: cardList,
            );
          }),
    );
  }

  Widget _pageControllerLayer(){

    return Builder(builder: (context) {
      return Positioned.fill(
          child: PageView(
              reverse: true,
              controller: controller,
              children:
              []..addAll(
                  playLists.map((playList) {
                    return currentPage == 0
                        ? Container(
                        child: Center(
                            child:
                            GestureDetector(
                              child: Container(
                                color: Colors
                                    .transparent,
                                width: 160,
                                height: 120,
                              ),
                              onTap: () {
                                _createNewPlayListDialog();
                              },
                            )))
                        : Stack(children: [
                      Positioned(
                          top: 20,
                          left: 20,
                          child:
                          GestureDetector(
                            child: Container(
                              color: Colors
                                  .transparent,
                              width: 70,
                              height: 70,
                            ),
                            onTap: () {
                              _deletePlayListDialog();
                            },
                          )),
                      Positioned(
                          top: 90,
                          left: 20,
                          child:
                          GestureDetector(
                              child:
                              Container(
                                color: Colors
                                    .transparent,
                                width: MediaQuery.of(context)
                                    .size
                                    .width -
                                    90,
                                height: MediaQuery.of(context)
                                    .size
                                    .height *
                                    .5,
                              ),
                              onTap: () {
                                _speechBubbleDialog();
                              }))
                    ]);
                  }))));
    });
  }

  _createNewPlayListDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('New Play List'),
            content: SingleChildScrollView(child: Container(
                child:
                Column(
                  mainAxisSize: MainAxisSize.min,
                    children: [
              Flexible(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                      child: TextField(
                    decoration: InputDecoration(hintText: "Title"),
                    onChanged: (value) {
                      setState(() {
                        _title = value;
                      });
                    },
                  ))),
              RaisedButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                      children: [Text("Background Image"), _bgImageUrl != null ? Icon(Icons.check, color: Colors.green) : Container() ]),
              color: Colors.white70,
              onPressed: () async{
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => ImageCapture(navigatedFrom: "playlist")),
                );
                if (result != null) {
                  setState((){
                    _bgImageUrl = result;
                  });
                }
              },),
                  PreviewContainer(bgImageUrl: _bgImageUrl)
            ]))),
            contentPadding: EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 0),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CONFIRM'),
                onPressed: () {
                  Map<String, dynamic> playList = new Map<String, dynamic>();
                  playList["title"] = _title;
                  playList["bgUrl"] = _bgImageUrl;
                  PlayListApi.create(jsonEncode(playList), _singleton.user.id)
                      .then((res) {
                    if (res["error"] == null) {
                      setState(() {
                        playLists.add(res['playList']);
                        controller.animateToPage(playLists.length - 1,
                            duration: Duration(seconds: 1),
                            curve: Curves.easeInOut);
                        Navigator.of(context).pop();
                      });
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Center(
                                  child: Text(
                                      "Title is too long! It must be shorter than 40 letters.")),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text('Alright'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    }
                  });
                },
              ),
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  setState((){
                    _title = '';
                    _bgImageUrl = null;
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _deletePlayListDialog(){
    showDialog(
        context: context,
        builder: (context) {
    return AlertDialog(
        title: Text("Are you sure you want to delete the play list?"),
        actions: [
          FlatButton(
              child: new Text("CONFIRM"),
              onPressed: () {
                PlayListApi.remove(
                    playLists[currentPage.floor()]
                    [
                    '_id'])
                    .then(
                        (statusCode) {
                      if (statusCode ==
                          200) {
                        setState(
                                () {
                              playLists.removeAt(
                                  currentPage
                                      .floor());
                              controller.jumpToPage(
                                  currentPage.floor() -
                                      1);
                            });
                      }
                    });
                Navigator.of(context).pop();
              }
          ),
          FlatButton(
            child: new Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ]
    );});
  }

  _speechBubbleDialog() async {
    showGeneralDialog(
        barrierDismissible:
        true,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
        barrierColor:
        null,
        transitionDuration: const Duration(
            milliseconds:
            150),
        context:
        context,
        pageBuilder: (context,
            animation,
            secondaryAnimation) {
          return SafeArea(child:
          Builder(builder: (context) {
            return Align(
              alignment: Alignment(0.5, 0.2),
              child: SpeechBubble(
                nipHeight: 14,
                nipLocation: NipLocation.LEFT,
                child: Column(mainAxisSize: MainAxisSize.min,children: [
                  Text("Play List", style: TextStyle(color: Colors.white)),
                  ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * .4,
                          maxHeight: MediaQuery.of(context).size.height * .4,
                          minHeight: MediaQuery.of(context).size.height * .05),
                      child:
                      Container(height: playLists[currentPage.floor()]['songs'].length * 50.0,child: ListView.builder(
                          itemCount: playLists[currentPage.floor()]['songs'].length,
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          itemBuilder: (context, index) {
                            return ListTile(title: Text("${index+1}. ${playLists[currentPage.floor()]['songs'][index]['title']} ⌫", style: TextStyle(color: Colors.white, fontSize: 12)), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text("Do you want to remove \n\n${playLists[currentPage.floor()]['songs'][index]['title']} \n\nfrom the list?"),
                                      actions: <Widget>[
                                        new FlatButton(
                                          child: new Text('CONFIRM'),
                                          onPressed: () {
                                            PlayListApi.removeMusicFromPlayList(playLists[currentPage.floor()]['songs'][index]['_id'], playLists[currentPage.floor()]['_id']).then((res){
                                              setState((){
                                                playLists[currentPage.floor()] = res;
                                                Navigator.of(context).pop();
                                              });
                                              Navigator.of(context).pop();
                                            });
                                          },
                                        ),
                                        new FlatButton(
                                          child: new Text('CANCEL'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  });
                            });
                          })))]),
              ),
            );
          }));
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getMyPlayLists,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                          Color.fromRGBO(20, 23, 41, 1),
                          Color.fromRGBO(50, 47, 61, 1),
                          Color.fromRGBO(50, 67, 81, 1),
                          Color.fromRGBO(50, 87, 101, 1),
                        ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            tileMode: TileMode.clamp)),
                    child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _titleAndPlayBtn(),
                              Stack(children: [
                                _displayingCards(),
                                _pageControllerLayer()
                              ]),
                              Container(
                                  height: MediaQuery.of(context).size.width *
                                      .05) // buffer
                            ]))));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Column(children: <Widget>[
              Text('Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 14.0, color: Colors.white)),
              RaisedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Exit"),
                  textColor: Colors.white,
                  elevation: 7.0,
                  color: Colors.blue)
            ]));
          } else {
            return Center(
                child: Text("${snapshot.connectionState}",
                    style: TextStyle(fontSize: 12, color: Colors.white)));
          }
        });
  }
}

class PreviewContainer extends StatefulWidget {
  final String bgImageUrl;
  PreviewContainer({Key key, this.bgImageUrl});
  createState() => PreviewContainerState();
}

class PreviewContainerState extends State<PreviewContainer> {
  Widget build(context) {
    return widget.bgImageUrl != null ?
    Container(
      width: MediaQuery.of(context).size.width * .5,
      child: Image.network(widget.bgImageUrl)
    ) : Container();
  }
}