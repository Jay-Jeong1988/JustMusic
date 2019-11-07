import 'dart:convert';

import 'package:JustMusic/global_components/app_ads.dart';
import 'package:JustMusic/global_components/empty_widgets.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  FlutterSecureStorage _storage = FlutterSecureStorage();
  ScrollController _listViewScrollController;
  var _ak;
  List<dynamic> _searchResults = [];
  String _searchType = "video";
  String _nextPageToken;
  String _textFieldValue = "";
  String _keyword = "";
  Singleton _singleton = Singleton();

  @override
  void initState(){
    _listViewScrollController = new ScrollController()
      ..addListener(_scrollListener);

    _storage.read(key: "ak").then((key) {
      setState(() {
        _ak = key;
      });
    }).catchError((error) {
      print(error);
    });
    _showAd();
  }

  void _showAd() async {
    await Future.delayed(const Duration(milliseconds: 500));
    AppAds.init(bannerUnitId: 'ca-app-pub-7258776822668372/7065456288');
    AppAds.showBanner();
    _singleton.adSize = "full";
  }

  void _scrollListener() {
    if (_listViewScrollController.position.extentAfter <= 0) {
      _getSearchResults().then((results){
        setState(() {
          _searchResults.addAll(results);
        });
      });
    }
  }

  Future<List<dynamic>> _getSearchResults() async{
    var response;
    String host = "www.googleapis.com";
    String path = "youtube/v3/search";
    Map<String, String> queryParameters = {
      "part": "snippet",
      "maxResults": "50",
      "q": _keyword,
      "key": _ak,
      "type": _searchType,
    };
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'If-None-Match': "p4VTdlkQv3HQeTEaXgvLePAydmU/ooaAD6rpOkqf2Pw24d-HQO5UhD8"
    };
    if (_nextPageToken != null) queryParameters["pageToken"] = _nextPageToken;
    var uri = Uri.https(host, path, queryParameters);
    try {
      response = await http.get(uri, headers: headers);
    } catch (e) {
      print(e);
    }
    var decodedResponse = jsonDecode(response.body);
    print('Response status: ${response.statusCode}');
    print(decodedResponse["etag"]);

    if (response.statusCode == 200) {
      if (decodedResponse["nextPageToken"] != null) setState(() {
        _nextPageToken = decodedResponse["nextPageToken"];
      });
      return decodedResponse["items"];
    } else {
      print(decodedResponse);
      throw Exception('Failed to load music data');
    }
  }

  Widget _searchField() {
    return Container(
        padding: EdgeInsets.fromLTRB(23.0, 10.0, 23.0, 10.0),
        child: Row(
            children: <Widget> [
              Container(
                  width: MediaQuery.of(context).size.width * .65,
                  child: TextField(
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.white),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: "Keyword",
                        contentPadding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(145, 145, 155, 1.0),
                                width: 1.5)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(185, 185, 195, 1.0),
                                width: 1.5)),
                        filled: true,
                        fillColor: Color.fromRGBO(75, 75, 85, 1.0)),
                    onChanged: (val){
                      setState((){
                        _textFieldValue = val;
                      });
                    },
                  )),
              Flexible(
                  child: Container(
                      child: FlatButton(
                        padding: EdgeInsets.symmetric(vertical: 7.0),
                        color: Colors.blueGrey,
                        child: Icon(Icons.search, color: Color.fromRGBO(255, 255, 255, .7), size: 30.0),
                        onPressed: (){
                          _keyword = _textFieldValue;
                          _nextPageToken = null;
                          if (_keyword != "" && _keyword.replaceAll(RegExp(r"\s"), "").length != 0) _getSearchResults().then((results){
                            setState(() {
                              _searchResults = results;
                            });
                          });
                        },
                      )))
            ]));
  }

  Widget _listView(listItem) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Stack(children: [
          Container(
              decoration: BoxDecoration(color: Colors.transparent),
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70),
                  controller: _listViewScrollController,
                  itemCount: _searchResults.length,
                  padding: EdgeInsets.only(top: 20, bottom: 50),
                  itemBuilder: (context, index) {
                    dynamic searchResult = _searchResults[index];
                    return _searchResults.isEmpty ? EmptySearchWidget(textInput: "No result.") : listItem(searchResult);
                  })),
        ]));
  }

  Widget _listItem(searchResult) {
    var unescape = HtmlUnescape();
    dynamic snippet = searchResult["snippet"];
    String videoId = searchResult["id"]["videoId"];
    String channelTitle = snippet["channelTitle"];
    String thumbnailUrl = snippet['thumbnails']["high"]["url"];
    String title = unescape.convert(snippet["title"]);
    String publishedAt = snippet["publishedAt"].split("T")[0];
    String description = snippet["description"];
    return Container(
        height: MediaQuery.of(context).size.width * .23,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          GestureDetector(child:
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white54, width: 0.5),
                  image: DecorationImage(image: NetworkImage(thumbnailUrl), fit: BoxFit.cover)
              ),
              width: MediaQuery.of(context).size.width * 0.35,
              height: MediaQuery.of(context).size.width * 0.199,
            ),
            onTap: (){},
          ),
          Expanded(
              child: GestureDetector(
                  onTap: (){},
                  child: Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       Text(title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              height: 1.0,
                              fontSize: 12.5,
                                color: Colors.white)),
                     Container(
                       margin: EdgeInsets.only(top: 4.0),
                         child: Text("$channelTitle · $publishedAt",
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                       style: TextStyle(
                        fontSize: 9.0,
                      color: Colors.white70
                    ),
                    )),
                    Container(
                      margin: EdgeInsets.only(top: 4.0),
                        child: Text(description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1.0,
                        fontSize: 9.0,
                        color: Color.fromRGBO(235, 235, 235, 1),
                    ),
                    ))
                  ])))),
            GestureDetector(
              onTap: (){
                showDialog(
                  context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: SingleChildScrollView(child: Container(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                ]))),
                        contentPadding: EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 0),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text('CONFIRM'),
                            onPressed: () {
                            },
                          ),
                          new FlatButton(
                            child: new Text('CANCEL'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ]
                );
              });},
                  child: Container(
                    margin: EdgeInsets.only(left: 3.0),
              child: Icon(Icons.more_vert, color: Colors.white70)
            ))
        ]));
  }

  Widget _searchTypeButton(String type) {
    return FlatButton(
      textColor: _searchType == type ? Colors.white : Colors.white54,
      child: Text("${type[0].toUpperCase()}${type.substring(1)}"),
      onPressed: () {
        setState(() {
          _listViewScrollController.jumpTo(0);
          _searchType = type;
          _nextPageToken = null;
          if (_keyword != "") _getSearchResults().then((results){
            _searchResults = results;
          });
        });
      },
    );
  }

  Widget _verticalDivider({thickness, color, height}) {
    return Center(
        child: Container(
          width: thickness ?? 1.0,
          height: height ?? 20.0,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: color ?? Colors.black , width: thickness ?? 1.0),
            ),
          ),
        ),
      );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                appBar: EmptyAppBar(),
                body: Container(
                    child: Column(children: <Widget>[
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(12.0),
                            child: Text("Search for a Youtube video.",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold)))
                      ]),
                      _searchField(),
                      Container(
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _searchTypeButton("video"),
                          _verticalDivider(height: 14.0, color: Color.fromRGBO(230, 230, 215, 1.0)),
                          _searchTypeButton("channel"),
                          _verticalDivider(height: 14.0, color: Color.fromRGBO(230, 230, 215, 1.0)),
                          _searchTypeButton("playlist")
                        ])),
                      Flexible(child: Container(
                          padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 110.0),
                          child: _listView(_listItem)
                      ))])
                ))));
  }
}
