import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class AK {
  final String apiKey;
  AK({this.apiKey = ""});
  factory AK.fromJson(Map<String, dynamic> jsonMap) {
    return new AK(apiKey: jsonMap["api_key"]);
  }
}

class AKLoader {
  final String akPath;

  AKLoader({this.akPath});
  Future<AK> load() {
    return rootBundle.loadStructuredData<AK>(this.akPath,
            (jsonStr) async {
          final ak = AK.fromJson(json.decode(jsonStr));
          return ak;
        });
  }
}