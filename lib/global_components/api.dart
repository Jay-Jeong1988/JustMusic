import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Api {
  static String host = "44.230.225.211";
  static String port = "3000";

  Api(){
    if (Platform.isAndroid) {
      getAndroidDeviceInfo().then((info){
        if (info.isPhysicalDevice == true){
          host = "44.230.225.211";
//          print("Running on a physical Android device");
        }else {
          host = "44.230.225.211";
//          print("Running on an android emulator");
        }
      });
    } else if (Platform.isIOS) {
      getIosDeviceInfo().then((info){
        if (info.isPhysicalDevice == true){
          host = "44.230.225.211";
//          print("Running on a physical IOS device");
        }else {
          host = "10.0.2.2";
//          print("Running on an IOS emulator");
        }
      });
    }else {
//      print("Platform: ${Platform()}");
    }
  }

  static Future<AndroidDeviceInfo> getAndroidDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo;
  }

  static Future<IosDeviceInfo> getIosDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo;
  }

}

class UserApi extends Api{
  static String _userPath = "users";

  static Future<http.Response> signUpRequest(user) async{
    http.Response response;
    String path = "/$_userPath/signup";
    Uri uri = Uri.http("${Api.host}:${Api.port}", path);
    var body = {"phoneNumber": user.phoneNumber, "accountId": user.uid};
//    print(uri);

    try {
      response = await http.post(uri, body: body);
    } catch (e) {
      print(e);
    }
//    print('Response status: ${response.statusCode}');
//    print("${response.body}");
    return response;
  }

  static Future<bool> authenticateUser(String phoneNumber) async {
    http.Response response;
    String path = "/$_userPath/authenticate";
    Map<String, String> queryParam = {"pnum": phoneNumber};
    Uri uri = Uri.http("${Api.host}:${Api.port}", path, queryParam);
//    print(uri);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
//    print('Response status: ${response.statusCode}');
//    print("${response.body}");
    return response.statusCode == 200 ? true : false;
  }

  static Future<void> updateProfileImage(userId, pictureUrl) async {
    Map<String, String> queryParam = {"pictureUrl": pictureUrl};
    String path = "/$_userPath/$userId/updateProfile";
    var response;
    Uri uri = Uri.http("${Api.host}:${Api.port}", path, queryParam);
//    print(uri);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
//    print('Response status: ${response.statusCode}');
//    print("${response.body}");
  }

  static Future<void> updateBannerImage(userId, pictureUrl) async {
    Map<String, String> queryParam = {"pictureUrl": pictureUrl};
    String path = "/$_userPath/$userId/updateBanner";
    var response;
    Uri uri = Uri.http("${Api.host}:${Api.port}", path, queryParam);
//    print(uri);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
//    print('Response status: ${response.statusCode}');
//    print("${response.body}");
  }

  static Future<Response> updateNickname(userId, nickname) async {
    Map<String, String> queryParam = {"nickname": nickname};
    String path = "/$_userPath/$userId/updateNickname";
    Response response;
    Uri uri = Uri.http("${Api.host}:${Api.port}", path, queryParam);
//    print(uri);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
//    print('Response status: ${response.statusCode}');
//    print("${response.body}");
    return response;
  }
}

class MusicApi {
  static String _musicPath = "music";

  static Future<http.Response> postMusic(body) async{
    http.Response response;
    String path = "/$_musicPath/create";
    Uri uri = Uri.http("${Api.host}:${Api.port}", path);
//    print(uri);
    try {
      response = await http.post(uri, body: body, headers: {'Content-type': 'application/json'});
    } catch (e) {
      print(e);
    }
//    print('Response status: ${response.statusCode}');
//    print("${response.body}");
    return response;
  }

  static Future<List<dynamic>> getCategories() async {
    http.Response response;
    String path = "/$_musicPath/categories";
    Uri uri = Uri.http("${Api.host}:${Api.port}", path);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
    List<dynamic> decodedResponse = jsonDecode(response.body);
//    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      return decodedResponse;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<dynamic>> getMusics(categories, {userId}) async {
    var response;
    String path = "/$_musicPath/all/${userId ?? '111111111111111111111111'}"; //due to mongodb error check, userId has to be 24 digits number
    Map<String, String> queryParameters = {};
    int index = 0;
    categories.forEach((category){
      queryParameters["category${index++}"] = category;
    });
    var uri = queryParameters.isNotEmpty ?
    Uri.http("${Api.host}:${Api.port}", path, queryParameters) :
    Uri.http("${Api.host}:${Api.port}", path);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
    var decodedResponse = jsonDecode(response.body);
//    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return decodedResponse;
    } else {
//      print(decodedResponse);
      throw Exception('Failed to load music data');
    }
  }

  static Future<dynamic> getMyPosts(userId, lastIndex) async {
    var response;
    String path = "/$_musicPath/myposts/$userId/$lastIndex";
    var uri = Uri.http("${Api.host}:${Api.port}", path);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
    var decodedResponse = jsonDecode(response.body);
//    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
//      print("Decoded response: $decodedResponse");
      return decodedResponse;
    } else {
//      print(decodedResponse);
      throw Exception('Failed to load music data');
    }
  }

  static Future<void> perform(action, userId, musicId) async {
    var response;
    var paths = {
      "like": "/$_musicPath/likes/create",
      "unlike": "/$_musicPath/likes/delete",
      "block": "/$_musicPath/blocks/create",
      "unblock": "/$_musicPath/blocks/delete"
    };
    String path = paths[action];
    Map<String, String> queryParameters = {};
    queryParameters["userId"] = userId;
    queryParameters["musicId"] = musicId;
    var uri = Uri.http("${Api.host}:${Api.port}", path, queryParameters);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to perform $action');
    }
  }

  static Future<dynamic> getVideosFor(likesOrBlocks, userId, lastIndex) async {
    var response;
    String path = "/$_musicPath/$likesOrBlocks/$userId/$lastIndex";
    var uri = Uri.http("${Api.host}:${Api.port}", path);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
    var decodedResponse = jsonDecode(response.body);
//    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return decodedResponse;
    } else {
//      print(decodedResponse);
      throw Exception('Failed to load liked music');
    }
  }

  static Future check(isLikedOrIsBlocked, userId, musicId) async {
    var response;
    String path = "/$_musicPath/$isLikedOrIsBlocked";
    Map<String, String> queryParameters = {};
    queryParameters["userId"] = userId;
    queryParameters["musicId"] = musicId;
    var uri = Uri.http("${Api.host}:${Api.port}", path, queryParameters);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
    var decodedResponse = jsonDecode(response.body);
//    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
//      print("Decoded response: $decodedResponse");
      return decodedResponse;
    } else {
      throw Exception('Failed to check $isLikedOrIsBlocked');
    }
  }

  static Future<List<dynamic>> getSearchResult(keyword, lastIndex) async {
    var response;
    String path = "/$_musicPath/searchResult/$lastIndex";
    Map<String, String> queryParameters = {};
    queryParameters["keyword"] = keyword;
    var uri = Uri.http("${Api.host}:${Api.port}", path, queryParameters);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
    var decodedResponse = jsonDecode(response.body);
//    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return decodedResponse;
    } else {
//      print(decodedResponse);
      throw Exception('Failed to load music data');
    }
  }
}

class PlayListApi {
  static String _playListPath = "playLists";

  static Future<dynamic> create(body, userId) async {
    http.Response response;
    String path = "/$_playListPath/create";
    Map<String, String> queryParameters = {};
    queryParameters["userId"] = userId;
    Uri uri = Uri.http("${Api.host}:${Api.port}", path, queryParameters);
//    print(uri);
    try {
      response = await http.post(uri, body: body, headers: {'Content-type': 'application/json'});
    } catch (e) {
      print(e);
    }
//    print('Response status: ${response.statusCode}');
//    print("${response.body}");
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getMyPlayLists(userId) async {
    var response;
    String path = "/$_playListPath/$userId";
    var uri = Uri.http("${Api.host}:${Api.port}", path);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
    var decodedResponse = jsonDecode(response.body);
//    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return decodedResponse;
    } else {
//      print(decodedResponse);
      throw Exception('Failed to load play lists');
    }
  }

  static Future<dynamic> getOne(playListId) async {
    var response;
    String path = "/$_playListPath/one";
    Map<String, String> queryParameters = {};
    queryParameters["playListId"] = playListId;
    var uri = Uri.http("${Api.host}:${Api.port}", path, queryParameters);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
    var decodedResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decodedResponse;
    } else {
      throw Exception('Failed to get a play list');
    }
  }

  static Future<dynamic> addMusicToPlayList(musicId,playListId) async {
    var response;
    String path = "/$_playListPath/addMusic";
    Map<String, String> queryParameters = {};
    queryParameters["musicId"] = musicId;
    queryParameters["playListId"] = playListId;
    var uri = Uri.http("${Api.host}:${Api.port}", path, queryParameters);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
    return response.statusCode;
  }

  static Future<dynamic> removeMusicFromPlayList(musicId,playListId) async {
    var response;
    String path = "/$_playListPath/removeMusic";
    Map<String, String> queryParameters = {};
    queryParameters["musicId"] = musicId;
    queryParameters["playListId"] = playListId;
    var uri = Uri.http("${Api.host}:${Api.port}", path, queryParameters);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
    var decodedResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decodedResponse;
    } else {
      throw Exception('Failed to remove a song from play list');
    }
  }

  static Future<int> remove(playListId) async {
    var response;
    String path = "/$_playListPath/remove/$playListId";
    var uri = Uri.http("${Api.host}:${Api.port}", path);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }

    if (response.statusCode == 200) {
      return response.statusCode;
    } else {
      throw Exception('Failed to remove a play list');
    }
  }
}

class RemoteUpdateApi {
  static Future<dynamic> checkUpdates() async {
    var response;
    String path = "/update/check";
    var uri = Uri.http("${Api.host}:${Api.port}", path);
    try {
      response = await http.get(uri);
    }catch(e) {
      print(e);
    }
    var decodedResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return decodedResponse;
    } else {
      throw Exception('Failed to remove a play list');
    }
  }
}