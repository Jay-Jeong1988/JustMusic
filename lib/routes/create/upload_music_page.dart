import 'dart:convert';
import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:JustMusic/models/user.dart';
import 'package:JustMusic/routes/profile/profile_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'categories_page.dart';

class UploadMusicPage extends StatefulWidget {
  State<UploadMusicPage> createState() => UploadMusicPageState();
}

class UploadMusicPageState extends State<UploadMusicPage> {
  String _comment;
  ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0.0);
  List<String> _selectedCategoryTitles = new List<String>();
  List<String> _allCategoryTitles = new List<String>();
  final _storage = FlutterSecureStorage();
  var _ak;
  Map<String, dynamic> _videoInfo = {};
  bool _httpError = false;
  User _user;
  Singleton _singleton = Singleton();

  @override
  void initState() {
    super.initState();
    _user = _singleton.user;
    _scrollController.addListener((){});
    _storage.read(key: "ak").then((key) {
      MusicApi.getCategories().then((categories) {
        categories.sort((a, b) {
          return a['title'].toLowerCase().compareTo(b['title'].toLowerCase());
        });
        setState(() {
          _ak = key;
          _allCategoryTitles.addAll(categories.map((category) {
            String title = category["title"][0].toUpperCase() +
                category["title"].substring(1);
            return title;
          }));
        });
      });
    }).catchError((error) {
      print(error);
    });
  }

  void _getComment(value) {
    setState(() {
      _comment = value;
    });
  }

  void _getVideoIdAndCallApi(String receivedUri) {
    var uri = Uri.parse(receivedUri);
    void _setVideoInfo(videoId){
      getYoutubeObject(_getYoutubeV3ApiUrl(_ak, videoId)).then((info) {
        setState(() {
          _httpError = false;
          _videoInfo = info['pageInfo']['totalResults'] >= 1
              ? info
              : new Map<String, dynamic>();
          print(_videoInfo["items"][0]["snippet"]["thumbnails"]);
        });
      });
    }

    if ( _ak != null) {
      if (uri.queryParameters.containsKey("v")) {
        _setVideoInfo(uri.queryParameters["v"]);
      } else if (uri.host == "youtu.be") {
        _setVideoInfo(uri.path.replaceFirst("/", ""));
      } else {
        setState(() {
          _videoInfo = new Map<String, dynamic>();
          print(_videoInfo);
        });
        print("Invalid Youtube URL");
      }
    }else {
      print("Api key is missing");
    }
  }

  String _getYoutubeV3ApiUrl(ak, videoId) {
    return "https://www.googleapis.com/youtube/v3/videos?key=$ak&part=snippet&id=$videoId";
  }

  Future<dynamic> getYoutubeObject(String url) async {
    var response;
    try {
      response = await http.get(url);
    } catch (e) {
      print(e);
    }
    Map<String, dynamic> decodedResponse = jsonDecode(response.body);
    return decodedResponse;
  }

  Widget _textField(
      {@required text, maxLines, padding, @required onChangeMethod}) {
    return Flexible(
        child: Container(
            padding: padding,
            child: TextField(
              autofocus: false,
              maxLines: maxLines != null ? maxLines : 1,
              keyboardType: TextInputType.text,
              style: TextStyle(color: Colors.white, fontFamily: "NotoSans"),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  hintStyle:
                      TextStyle(color: Colors.grey, fontFamily: "NotoSans"),
                  hintText: text,
                  contentPadding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(145, 145, 155, 0.5),
                          width: 2.5)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(145, 145, 155, 1), width: 2.5)),
                  filled: true,
                  fillColor: Color.fromRGBO(75, 75, 85, 0.5)),
              onChanged: onChangeMethod,
            )));
  }

  Widget _aboutVideo() {
    Map<String, dynamic> snippet;
    String title;
    String description;
    String publishedAt;

    if (_videoInfo.isNotEmpty) {
      snippet = _videoInfo["items"][0]["snippet"];
      title = snippet["title"];
      description = snippet["description"];
      publishedAt = snippet["publishedAt"].split("T")[0];
      return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.15,
            maxHeight: MediaQuery.of(context).size.height * 0.20,
          ),
          child: Container(
              padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
              child:
              SingleChildScrollView(
                  controller: _scrollController,
                  child:  Column(children: [
                    Text("$title\n",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            fontSize: 16)),
                    Text("$description\n\nPublished on: $publishedAt",
                        style: TextStyle(color: Colors.white))
                  ]))));
    } else {
      return Container();
    }
  }

  Widget _previewContainer() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                  _videoInfo['items'][0]['snippet']['thumbnails']['maxres'] != null ?
                  "${_videoInfo['items'][0]['snippet']['thumbnails']['maxres']['url']}" :
                  "${_videoInfo['items'][0]['snippet']['thumbnails']['high']['url']}"
                  ))),
    );
  }

  Future<void> saveMusicRequest() async {
    Map<String, dynamic> music = new Map<String, dynamic>();
    Map<String, dynamic> snippet = _videoInfo["items"][0]["snippet"];
    music["thumbnailUrl"] = snippet['thumbnails']['maxres'] != null ? snippet['thumbnails']['maxres']['url'] : snippet['thumbnails']['high']['url'];
    music["title"] = snippet["title"];
    music["description"] = snippet["description"];
    music["publishedAt"] = snippet["publishedAt"].split("T")[0];
    music["comment"] = _comment;
    music["videoUrl"] = "https://www.youtube.com/watch?v=${_videoInfo["items"][0]["id"]}";
    music["channelName"] = snippet["channelTitle"];
    music["categoryTitles"] = _selectedCategoryTitles;
    music["userId"] = _user.id;

    print("sending body: ${jsonEncode(music)}");

    MusicApi.postMusic(jsonEncode(music)).then((response){
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _singleton.clicked = 3;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => AppScreen(navigatedPage: ProfilePage(),)),
        );
      } else {
        print("error: ${decodedResponse["error"]}");
        setState((){
          _httpError = true;
        });
        throw Exception('Failed to save music');
      }
    });
  }

  Iterable<Widget> sortedCategoryIterable() {
    _selectedCategoryTitles.sort((a, b) {
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    return _selectedCategoryTitles.map((e) {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Text(e, style: TextStyle(color: Colors.white)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [Container(
        decoration: BoxDecoration(gradient: LinearGradient(
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
        appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 15.0,
            titleSpacing: 0,
            backgroundColor: Colors.transparent,
            title: Center(
                child: _videoInfo.isNotEmpty &&
                        _selectedCategoryTitles.isNotEmpty
                    ? Container(
                  height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                        color: Color.fromRGBO(200, 200, 210, 1)),
                        padding: EdgeInsets.only(
                            left: _httpError == true ?
                            MediaQuery.of(context).size.width * 0.2
                            : MediaQuery.of(context).size.width * 0.7
                        ),
                        child: RaisedButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => saveMusicRequest(),
                            child: _httpError == false ? Row(children: [
                              Text("POST ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Icon(Icons.arrow_forward_ios, size: 20)
                            ]) : Row(children: [
                              Text("The video already exists ! ",
                                  style: TextStyle(
                                    color: Colors.red,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Icon(Icons.block, size: 20, color: Colors.red)
                            ]),
                            textColor: Color.fromRGBO(44, 47, 57, 1),
                            elevation: 0,
                            color: Colors.transparent))
                    : _videoInfo.isNotEmpty && _selectedCategoryTitles.isEmpty
                        ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  stops: [0, 1],
                                    colors: [
                              Color.fromRGBO(143, 147, 157, 1),
                                      Colors.transparent
                            ])),
                            child: Center(child: Text(
                                "You should select at least one category",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'NotoSans',
                                    color: Colors.white,
                                    fontSize: 16))))
                        : Container(
                            child: Text(
                                "Post your favorite music video \nfrom Youtube",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'NotoSans',
                                    color: Colors.white,
                                    fontSize: 16))))),
        body: SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _textField(
                      text: "Video URL",
                      padding: EdgeInsets.fromLTRB(25, 10, 25, 25),
                      onChangeMethod: _getVideoIdAndCallApi),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.35,
                      padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
                      child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              _videoInfo.isNotEmpty
                                  ? BoxShadow(
                                      color: Color.fromRGBO(240, 240, 250, .7),
                                      blurRadius: 12.0,
                                    )
                                  : BoxShadow(color: Colors.transparent)
                            ],
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            border: Border.all(
                                color: _videoInfo.isNotEmpty
                                    ? Color.fromRGBO(175, 175, 185, 1)
                                    : Color.fromRGBO(145, 145, 155, 0.5),
                                width: 4.5,
                                style: BorderStyle.solid),
                          ),
                          child: _videoInfo.isNotEmpty
                              ? _previewContainer()
                              : Center(
                                  child: Icon(Icons.slideshow,
                                      size: 90.0,
                                      color: Color.fromRGBO(
                                          145, 145, 155, 0.4))))),
                  _aboutVideo(),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: RaisedButton(
                          hoverColor: Color.fromRGBO(175, 175, 185, 1),
                          onPressed: () async {
                            List<String> result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        CategoriesPage(_allCategoryTitles,
                                            _selectedCategoryTitles)));
                            if (result != null) {
                              setState(() {
                                _selectedCategoryTitles = result;
                              });
                            }
                          },
                          child: Text("Category Selections"),
                          textColor: Colors.white,
                          elevation: 5,
                          color: Color.fromRGBO(175, 175, 185, 0.6))),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                          children: []..addAll(sortedCategoryIterable()))),
                  _textField(
                      text: "Comment (optional)",
                      maxLines: 3,
                      padding: EdgeInsets.fromLTRB(25, 10, 25, 90),
                      onChangeMethod: _getComment),
                ]))))),
      _singleton.tutorialStatus["uploadMusicPage"] ? Positioned.fill(child: UploadMusicPageTutorialScreen()) : Container()
    ]);
  }
}

class UploadMusicPageTutorialScreen extends StatefulWidget {
  createState() => UploadMusicPageTutorialScreenState();
}

class UploadMusicPageTutorialScreenState extends State<UploadMusicPageTutorialScreen> {
  Singleton _singleton = Singleton();
  bool _isFinished = false;

  Future<void> _saveTutorialStatusToDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("tutorialStatus", jsonEncode(_singleton.tutorialStatus));
  }

  @override
  Widget build(BuildContext context) {
    return _isFinished ? Container() : GestureDetector(
        onTap: (){
          _singleton.tutorialStatus["uploadMusicPage"] = false;
          _saveTutorialStatusToDisk().then((v){
            setState(() {
              _isFinished = true;
            });
          });
        },
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                color: Colors.black45
            ),
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(children: [
                  Positioned(
                      top: MediaQuery.of(context).size.height * .1 + 75,
                      left: MediaQuery.of(context).size.width * .9 - 280,
                      child: Container(
                          width: 210,
                          height: 50,
                          child: Text("1. Paste a copied link\n from Youtube app here.", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "PermanentMarker"))
                      )
                  ),
                  Positioned(
                      top: MediaQuery.of(context).size.height * .1 + 90,
                      left: MediaQuery.of(context).size.width * .9 - 120,
                      child: Container(
                          width: 70,
                          height: 70,
                          child: SvgPicture.asset("assets/images/semicircular-up-arrow.svg",
                            semanticsLabel: "A white curve up arrow",
                            fit: BoxFit.cover,
                            color: Colors.white
                          )
                      )
                  ),
                  Positioned(
                      top: MediaQuery.of(context).size.height * .1 + 250,
                      left: MediaQuery.of(context).size.width * .9 - 280,
                      child: Container(
                          width: 240,
                          height: 50,
                          child: Text("2. Choose suitable\n categories for the music", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "PermanentMarker"))
                      )
                  ),
                  Positioned(
                      top: MediaQuery.of(context).size.height * .1 + 270,
                      left: MediaQuery.of(context).size.width * .9 - 80,
                      child: Container(
                          width: 40,
                          height: 40,
                          child: SvgPicture.asset("assets/images/curve-arrow.svg",
                            semanticsLabel: "A white curve down arrow",
                            fit: BoxFit.cover,
                              color: Colors.white
                          )
                      )
                  ),
                  Positioned(
                      left: MediaQuery.of(context).size.width * .5 - 70,
                      top: MediaQuery.of(context).size.height * .75,
                      child: Container(
                          width: 170,
                          height: 30,
                          child: Text("Tap to dismiss", style: TextStyle(color: Colors.white70, fontSize: 20, fontFamily: "PermanentMarker"))
                      )
                  ),
                ])
            )));
  }
}