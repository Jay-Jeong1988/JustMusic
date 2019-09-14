import 'package:JustMusic/global_components/AK.dart';
import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:JustMusic/models/user.dart';
import 'package:JustMusic/routes/create/upload_music_page.dart';
import 'package:JustMusic/routes/playLists/play_lists_page.dart';
import 'package:JustMusic/routes/profile/profile_page.dart';
import 'package:JustMusic/utils/slide_right_route.dart';
import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../main.dart';
import './country_code_widget.dart';
import '../../models/country.dart';

class PhoneAuth extends StatefulWidget {
  @override
  _PhoneAuthState createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  String phoneNo;
  String smsCode;
  String verificationId;
  Country _selectedCountry;
  TextEditingController _controller = new TextEditingController();
  final _storage = FlutterSecureStorage();
  var loadCountryFromDisk;
  Future<dynamic> _getCountryFromStorage;
  Singleton _singleton = Singleton();

  @override
  void initState() {
    _getCountryFromStorage = _loadCountryFromDisk();
    _getCountryFromStorage.then((country){
      if (country != null) {
        _selectedCountry = Country.fromDecodedJson(jsonDecode(country));
        print("selected country: ${_selectedCountry.name}");
      }
    });
    super.initState();
    _signOut();
    FirebaseAuth.instance.onAuthStateChanged.listen((FirebaseUser user) {
      var authState =
          user == null ? "No current firebase user" : "Firebase user online";
      print("AuthState: $authState");
    });
  }

  _loadCountryFromDisk() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var country = prefs.getString('country');
    return country;
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (String verId) {
      print("autoretrieval has timed out");
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      setState(() {
        this.verificationId = verId;
      });
      print('Code has been sent');
//      smsCodeDialog(context);
      Navigator.push(
          context,
          SlideRightRoute(
              rightToLeft: false,
              page: SMSVerificationPage(verificationId: verificationId)
              ));
    };

    final PhoneVerificationCompleted verificationSuccess =
        (AuthCredential credential) async {
      print('auto verified and signed in user: $credential');
      print('phone number: $phoneNo');
      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
//    final token = await user.getIdToken();
          assert(authResult.user.uid == currentUser.uid);
          print('signed into firebase: ${authResult.user}');
      saveUserRequest(authResult.user);
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException exception) {
      print('${exception.message}');
      print("authentication failed");
//      if (exception is FirebaseAuthInvalidCredentialsException) {
//        // Invalid request
//        // ...
//      } else if (exception is FirebaseTooManyRequestsException) {
//        // The SMS quota for the project has been exceeded
//        // ...
//
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        codeAutoRetrievalTimeout: autoRetrievalTimeout,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 30),
        verificationCompleted: verificationSuccess,
        verificationFailed: verificationFailed);
  }

  Future<void> saveUserRequest(FirebaseUser user) async {

    UserApi.signUpRequest(user).then((response){
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _singleton.user = User.fromDecodedJson(decodedResponse["user"]);

        if (decodedResponse["isNew"]){
          Navigator.push(
              context,
              SlideRightRoute(
                  rightToLeft: false,
                  page: NicknameCreationPage()
              ));
        }else {
          _storage.deleteAll().then((result){
            _storeKey();
            _storage.write(key: "user", value: jsonEncode(decodedResponse["user"]));
          }).catchError((error){
            print(error);
          });
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) =>
                  AppScreen(navigatedPage:
                  _singleton.clicked == 3 ? ProfilePage() : _singleton
                      .clicked == 1 ? UploadMusicPage() : PlayListsPage()
                  )), (_) => false);
        }
      } else {
        FirebaseAuth.instance.signOut();
        print("validation error: ${decodedResponse["error"]}");
        print("Firebase user logged out");
        throw Exception('Failed to save or load a user');
      }
    });
  }

  Future<dynamic> _storeKey() async{
    await AKLoader(akPath: "ak.json").load().then((AK ak){
      _storage.write(key: "ak", value: ak.apiKey).catchError((error){
        print(error);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getCountryFromStorage,
        builder: (BuildContext context, snapshot)
    {
      if (snapshot.connectionState == ConnectionState.done) {
        return new Scaffold(
            body: new Center(
                child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    padding: EdgeInsets.all(25.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Color.fromRGBO(
                                              140, 140, 140, 1.0),
                                          style: BorderStyle.solid,
                                          width: 1.0))),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max, children: [
                                Flexible(
                                    child: RawMaterialButton(
                                        child: Container(
                                            padding: EdgeInsets.only(left: 0.0),
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    right: BorderSide(
                                                        color: Color.fromRGBO(
                                                            140, 140, 140, 1.0),
                                                        style: BorderStyle
                                                            .solid,
                                                        width: 1.0))),
                                            child: Text(
                                                _selectedCountry != null
                                                    ?
                                                '${_selectedCountry
                                                    .isoCode} +${_selectedCountry
                                                    .dialingCode} \u25BE  '
                                                    : "",
                                                style: TextStyle(
                                                    fontWeight: FontWeight
                                                        .normal,
                                                    color: Color.fromRGBO(
                                                        80, 80, 80, 1.0)))),
                                        onPressed: () async {
                                          Country result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CountryCodeWidget(
                                                          selectedCountry:
                                                          _selectedCountry)));
                                          if (result != null) {
                                            setState(() {
                                              _selectedCountry = result;
                                              _controller.clear();
                                              print("selected country: ${result.name}");
                                            });
                                          }
                                        })),
                                Expanded(
                                    child: TextField(
                                        controller: _controller,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Phone number'),
                                        onChanged: (value) {
                                          this.phoneNo =
                                          "+${_selectedCountry
                                              .dialingCode}$value";
                                        }))
                              ])),
                          Container(
                              padding: EdgeInsets.only(
                                  top: 15.0, right: 8.0, bottom: 15.0),
                              decoration: BoxDecoration(),
                              child: Text(
//                                  "By signing up, you confirm that you agree to our Terms "
//                                      "of Use and have read and understood our Privacy Policy."
                                  "This app is free for all users. "
                                      "No user data will be used in any way."
                                      " You will receive an SMS to confirm your phone number."
                                      " SMS fee may apply.",
                                  style: TextStyle(fontSize: 12.0))),
                          RaisedButton(
                              onPressed: verifyPhone,
                              child: Text("Verify"),
                              textColor: Colors.white,
                              elevation: 7.0,
                              color: Colors.blue)
                        ]))));
      } else if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else {
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
      }
    });
  }
}


class SMSVerificationPage extends StatefulWidget {
  String verificationId;
  SMSVerificationPage({Key key, @required this.verificationId});
  SMSVerificationState createState() => SMSVerificationState();
}

class SMSVerificationState extends State<SMSVerificationPage> {
  String _smsCode;
  Singleton _singleton = Singleton();
  final _storage = FlutterSecureStorage();

  Future<dynamic> _storeKey() async{
    await AKLoader(akPath: "ak.json").load().then((AK ak){
      _storage.write(key: "ak", value: ak.apiKey).catchError((error){
        print(error);
      });
    });
  }

  Future<void> signInWithPhoneNumber(String smsCode) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );
    final AuthResult authResult =
    await FirebaseAuth.instance.signInWithCredential(credential);
    final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
//    final token = await user.getIdToken();
    assert(authResult.user.uid == currentUser.uid);

    print('signed into firebase: ${authResult.user}');
    saveUserRequest(authResult.user);
//    print('token: $token');
  }

  Future<void> saveUserRequest(FirebaseUser user) async {
    UserApi.signUpRequest(user).then((response){
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _singleton.user = User.fromDecodedJson(decodedResponse["user"]);

        if (decodedResponse["isNew"]){
          Navigator.push(
              context,
              SlideRightRoute(
                  rightToLeft: false,
                  page: NicknameCreationPage()
              ));
        }else {
          _storage.deleteAll().then((result){
            _storeKey();
            _storage.write(key: "user", value: jsonEncode(decodedResponse["user"]));
          }).catchError((error){
            print(error);
          });
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) =>
                  AppScreen(navigatedPage:
                  _singleton.clicked == 3 ? ProfilePage() : _singleton
                      .clicked == 1 ? UploadMusicPage() : PlayListsPage()
                  )), (_) => false);
        }
      } else {
        FirebaseAuth.instance.signOut();
        print("validation error: ${decodedResponse["error"]}");
        print("Firebase user logged out");
        throw Exception('Failed to save or load a user');
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body: Center(child: Container(
                width: MediaQuery.of(context).size.width * .8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text("Enter SMS Code"),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (val){
                      setState(() {
                        _smsCode = val;
                      });
                    },
                  ),
                  FlatButton(
                    child: Text('Done'),
                    onPressed: () {
                      signInWithPhoneNumber(_smsCode);
                    },
                  )
                ]
                ))));
  }
}

class NicknameCreationPage extends StatefulWidget {
  NicknameCreationPageState createState() => NicknameCreationPageState();
}

class NicknameCreationPageState extends State<NicknameCreationPage> {
  String _nickname = "";
  bool _isValidationError = false;
  Singleton _singleton = Singleton();
  final _storage = FlutterSecureStorage();

  Future<dynamic> _storeKey() async{
    await AKLoader(akPath: "ak.json").load().then((AK ak){
      _storage.write(key: "ak", value: ak.apiKey).catchError((error){
        print(error);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body: Center(child: Container(
                width: MediaQuery.of(context).size.width * .8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text("Create Your Nickname"),
                  TextField(
                    onChanged: (val){
                      setState(() {
                        _nickname = val;
                      });
                    },
                  ),
                  _isValidationError ?
                  Text("Nickname is too long. \nMaximum length is 20 characters.",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12.0
                      ))
                      :
                      Container(),
                  RaisedButton(
                    child: Text("Done"),
                    onPressed: (){
                      UserApi.updateNickname(_singleton.user.id, _nickname).then((res){
                        if(res.statusCode == 200) {
                          _singleton.user.nickname = _nickname;
                          Map<String, dynamic> decodedResponse = jsonDecode(
                              res.body);
                          _storage.deleteAll().then((result) {
                            _storeKey();
                            _storage.write(key: "user",
                                value: jsonEncode(decodedResponse));
                          }).catchError((error) {
                            print(error);
                          });
                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (context) =>
                                  AppScreen(navigatedPage:
                                  _singleton.clicked == 3
                                      ? ProfilePage()
                                      : _singleton
                                      .clicked == 1
                                      ? UploadMusicPage()
                                      : PlayListsPage()
                                  )), (_) => false);
                        }else{
                          setState(() {
                            _isValidationError = true;
                          });
                        }
                    });
                    },
                  )
                ]
                ))));
  }
}