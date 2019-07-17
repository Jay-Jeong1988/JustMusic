import 'dart:convert';

import 'package:http/http.dart' as http;

class Category {

  final String id;
  final String title;
  final String imageUrl;
  final int preference;

  const Category({this.id, this.title, this.imageUrl, this.preference});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        id: json['_id'],
        title: json['title'],
        imageUrl: json['imageUrl'],
        preference: json['preference']
    );
  }

  static Future<List<dynamic>> getCategoriesRequest() async {
    var response;
    var url = 'http://34.222.61.255:3000/music/categories';
    try {
      response = await http.get(url);
    } catch (e) {
      print(e);
    }
    List<dynamic> decodedResponse = jsonDecode(response.body);
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print(decodedResponse);
      return decodedResponse;
    } else {
      throw Exception('Failed to load categories');
    }
  }
}