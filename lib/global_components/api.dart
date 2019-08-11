import 'dart:convert';
import 'dart:io' show Platform;
import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;

class Api {
  static String host = "34.222.61.255";
  static String port = "3000";

  Api(){
    if (Platform.isAndroid) {
      getAndroidDeviceInfo().then((info){
        if (info.isPhysicalDevice == true){
          host = "34.222.61.255";
          print("Running on a physical Android device");
        }else {
          host = "10.0.2.2";
          print("Running on an android emulator");
        }
      });
    } else if (Platform.isIOS) {
      getIosDeviceInfo().then((info){
        if (info.isPhysicalDevice == true){
          host = "34.222.61.255";
          print("Running on a physical IOS device");
        }else {
          host = "10.0.2.2";
          print("Running on an IOS emulator");
        }
      });
    }else {
      print("Platform: ${Platform()}");
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
    var body = {"phoneNumber": user.phoneNumber};
    print(uri);

    try {
      response = await http.post(uri, body: body);
    } catch (e) {
      print(e);
    }
    print('Response status: ${response.statusCode}');
    print("${response.body}");
    return response;
  }

  static Future<bool> authenticateUser(String phoneNumber) async {
    http.Response response;
    String path = "/$_userPath/authenticate";
    Map<String, String> queryParam = {"pnum": phoneNumber};
    Uri uri = Uri.http("${Api.host}:${Api.port}", path, queryParam);
    print(uri);
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
    print('Response status: ${response.statusCode}');
    print("${response.body}");
    return response.statusCode == 200 ? true : false;
  }
}

class MusicApi {
  static String _musicPath = "music";

  static Future<http.Response> postMusic(body) async{
    http.Response response;
    String path = "/$_musicPath/create";
    Uri uri = Uri.http("${Api.host}:${Api.port}", path);
    print(uri);
    try {
      response = await http.post(uri, body: body, headers: {'Content-type': 'application/json'});
    } catch (e) {
      print(e);
    }
    print('Response status: ${response.statusCode}');
    print("${response.body}");
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
    print('Response status: ${response.statusCode}');
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
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print("Decoded response: $decodedResponse");
      return decodedResponse;
    } else {
      print(decodedResponse);
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
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print("Decoded response: $decodedResponse");
      return decodedResponse;
    } else {
      print(decodedResponse);
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
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print("Decoded response: $decodedResponse");
      return decodedResponse;
    } else {
      print(decodedResponse);
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
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print("Decoded response: $decodedResponse");
      return decodedResponse;
    } else {
      throw Exception('Failed to check $isLikedOrIsBlocked');
    }
  }
}