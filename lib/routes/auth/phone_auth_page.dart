import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/user.dart';
import '../../main.dart';
import './country_code_widget.dart';
import '../../models/country.dart';

class PhoneAuth extends StatefulWidget {
  PhoneAuth({@required this.country});
  Country country;
  @override
  _PhoneAuthState createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  String phoneNo;
  String smsCode;
  String verificationId;
  Country _selectedCountry;
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    this._selectedCountry = widget.country;
    super.initState();
    _signOut();
    FirebaseAuth.instance.onAuthStateChanged.listen((FirebaseUser user) {
      var authState =
          user == null ? "No current firebase user" : "Firebase user online";
      print("AuthState: $authState");
    });
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
      smsCodeDialog(context);
    };

    final PhoneVerificationCompleted verificationSuccess =
        (AuthCredential user) {
      print('auto verified and signed in user: $user');
      print('phone number: $this.phoneNo');
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

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter sms Code'),
            content: TextField(
              onChanged: (value) {
                this.smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                child: Text('Done'),
                onPressed: () {
//                  FirebaseAuth.instance.currentUser().then((user) {
//                    if (user != null) {
//                      print("current user already exists: $user");
//                      Navigator.of(context).pop();
//                    } else {
//                      signInWithPhoneNumber(this.smsCode);
//                      Navigator.of(context).pop();
//                    }
//                  });
                  signInWithPhoneNumber(this.smsCode);
                },
              )
            ],
          );
        });
  }

  Future<void> signInWithPhoneNumber(String smsCode) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: this.verificationId,
      smsCode: smsCode,
    );
    final FirebaseUser user =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
//    final token = await user.getIdToken();
    assert(user.uid == currentUser.uid);
    print('signed into firebase: $user');

    saveUserRequest(user);
    Navigator.of(context).pop();
//    print('token: $token');
  }

  Future<void> saveUserRequest(FirebaseUser user) async {
    var response;
    var url = 'http://10.0.2.2:3000/users/signup';
    try {
      response = await http.post(url, body: {'phoneNumber': user.phoneNumber});
    } catch (e) {
      print(e);
    }
    Map<String, dynamic> decodedResponse = jsonDecode(response.body);
    print('Response status: ${response.statusCode}');
    print("${response.body}");

    if (response.statusCode == 200) {
      print(decodedResponse['user']);
      User user = User.fromJson(decodedResponse);

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => AppScreen(user: user)));
    } else {
      FirebaseAuth.instance.signOut();
      print("validation error: ${decodedResponse["error"]}");
      print("Firebase user logged out");
      throw Exception('Failed to save or load a user');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                      color: Color.fromRGBO(140, 140, 140, 1.0),
                                      style: BorderStyle.solid,
                                      width: 1.0))),
                          child: Row(mainAxisSize: MainAxisSize.max, children: [
                            Flexible(
                                child: RawMaterialButton(
                                    child: Container(
                                        padding: EdgeInsets.only(left: 0.0),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                right: BorderSide(
                                                    color: Color.fromRGBO(
                                                        140, 140, 140, 1.0),
                                                    style: BorderStyle.solid,
                                                    width: 1.0))),
                                        child: Text(
                                            '${_selectedCountry.isoCode} +${_selectedCountry.dialingCode} \u25BE  ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
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
                                          "+${_selectedCountry.dialingCode}$value";
                                    }))
                          ])),
                      Container(
                          padding: EdgeInsets.only(
                              top: 15.0, right: 8.0, bottom: 15.0),
                          decoration: BoxDecoration(),
                          child: Text(
                              "By signing up, you confirm that you agree to our Terms "
                              "of Use and have read and understood our Privacy Policy."
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
  }
}
