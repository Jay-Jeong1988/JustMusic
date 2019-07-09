import 'dart:convert';
import '../../models/category.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/custom_scroll_physics.dart';

class UploadMusicPage extends StatefulWidget {
  List<String> selectedCategoryTitles;
  UploadMusicPage({this.selectedCategoryTitles});

  State<UploadMusicPage> createState() => UploadMusicPageState();
}

class UploadMusicPageState extends State<UploadMusicPage> {
  String _description;
  ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollPhysics _textFieldScrollPhysics = new CustomScrollPhysics();
  List<String> _selectedCategoryTitles = new List<String>();
  List<String> _allCategoryTitles = new List<String>();
  final _storage = FlutterSecureStorage();
  var _ak;
  Map<String, dynamic> _videoInfo = {};

  @override
  void initState() {
    _scrollController.addListener(_textFieldScrollListener);
    _selectedCategoryTitles = widget.selectedCategoryTitles;
    _storage.read(key: "ak").then((key) {
      setState(() {
        _ak = key;
      });
    }).catchError((error){
      print(error);
    });
    Category.getCategoriesRequest().then((categories) {
      categories.sort((a, b) {
        return a['title'].toLowerCase().compareTo(b['title'].toLowerCase());
      });
      setState(() {
        _allCategoryTitles.addAll(categories.map((category) {
          String title = category["title"][0].toUpperCase() +
              category["title"].substring(1);
          return title;
        }));
      });
    });
  }

  void _getDescription(value){
    setState((){
      _description = value;
    });
  }

  void _textFieldScrollListener(){
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent){
      if (_scrollController.position.axisDirection == AxisDirection.down) {
        print("down");
        print(_textFieldScrollPhysics);
        setState(() {
        });
      }else {
        print("imback");
      }
    }else if (_scrollController.offset <= _scrollController.position.minScrollExtent){
      if (_scrollController.position.axisDirection == AxisDirection.up) {
        print("top");
      }
    }
  }

  void _getVideoIdAndCallApi(String url) {
    var regExp = RegExp("v=", caseSensitive: true);
    var videoId = "";
    if (regExp.hasMatch(url) && _ak != null) {
      videoId = url.split("v=")[1];
      getYoutubeObject(_getYoutubeV3ApiUrl(_ak, videoId)).then((info) {
        setState(() {
          _videoInfo = info['pageInfo']['totalResults'] >= 1
              ? info
              : new Map<String, dynamic>();
          print(_videoInfo);
        });
      });
    } else {
      setState(() {
        _videoInfo = new Map<String, dynamic>();
        print(_videoInfo);
      });
      print("Invalid Youtube URL or Api key is missing");
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
              child: SingleChildScrollView(
                physics: _textFieldScrollPhysics,
                controller: _scrollController,
                  child: Column(children: [
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
                  "${_videoInfo['items'][0]['snippet']['thumbnails']['medium']['url']}"))),
    );
  }

  Future<void> saveMusicRequest(music) async {
    var response;
    var url = 'http://10.0.2.2:3000/music/create';
    try {
      response = await http.post(url, body: music);
    } catch (e) {
      print(e);
    }
    Map<String, dynamic> decodedResponse = jsonDecode(response.body);
    print('Response status: ${response.statusCode}');
    print("${response.body}");

    if (response.statusCode == 200) {
//      Navigator.push(context,
//          MaterialPageRoute(builder: (context) => ProfilePage(widget.user)));
    } else {
      print("error: ${decodedResponse["error"]}");
      throw Exception('Failed to save music');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(43, 47, 57, 1.0),
        appBar: AppBar(
            elevation: 15.0,
            backgroundColor: Colors.transparent,
            title: Center(
                child: Text("Post your favorite music video \nfrom Youtube",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'NotoSans',
                        color: Colors.white,
                        fontSize: 16)))),
        body: SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _textField(
                      text: "Video URL",
                      padding: EdgeInsets.all(25),
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
                                      color: Color.fromRGBO(240, 240, 250, .5),
                                      blurRadius: 10.0,
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
                  _textField(
                      text: "Comment",
                      maxLines: 3,
                      padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
                      onChangeMethod: _getDescription),
                ]))));
  }
}
