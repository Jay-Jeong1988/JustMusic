import 'package:flutter/material.dart';
import '../routes/auth/phone_auth_page.dart';

void setModalBottomSheet(context, country) {
  Widget _login = Container(
      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
      decoration: BoxDecoration(
          color: Color.fromRGBO(250, 250, 250, 1.0),
          border: Border(top: BorderSide(color: Colors.grey, width: 0.3))),
      child: Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Already have an account? ", style: TextStyle(fontSize: 13.0)),
            Text("Log in",
                style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600))
          ])));

  Widget _agreeNotice = Container(
      padding: EdgeInsets.only(top: 26.0, bottom: 26.0, left: 80, right: 80),
      child: Center(
          child: Text(
              "By signing up, you confirm that you agree to our Terms of Use"
                  "and have read and understood our Privacy Policy.",
              softWrap: true,
              style: TextStyle(fontSize: 10),
              textAlign: TextAlign.center)));

  GestureDetector _oAuthLink(String imagePath) {
    return GestureDetector(
        child: Container(
            margin: EdgeInsets.only(left: 8.0),
            width: 48.0,
            child: Image.asset(imagePath)),
        onTap: () {
          print("clicked");
        });
  }

  Widget _oAuth = Center(
      child: Container(
          width: 230,
          height: 42.0,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _oAuthLink("assets/images/kakao.png"),
            _oAuthLink("assets/images/facebook.png"),
            _oAuthLink("assets/images/google.png"),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              iconSize: 16.0,
              onPressed: () {},
            ),
          ])));

  Widget _orDivider = Container(
      padding:
      EdgeInsets.only(left: 32.0, right: 32.0, top: 12.0, bottom: 18.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Divider(height: 1.0, color: Colors.grey),
            ),
            Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text("OR",
                    style: TextStyle(fontSize: 11, letterSpacing: 0.5))),
            Expanded(child: Divider(height: 1.0, color: Colors.grey))
          ]));

  Widget _textSection = Container(
      padding: const EdgeInsets.only(left: 48, bottom: 14, right: 48),
      child: Center(
          child: Text(
            'You need a JustMusic \n account to continue',
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              wordSpacing: 3.0,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          )));

  Widget _signupButton = Container(
      padding: EdgeInsets.only(
        left: 32.0,
        right: 32.0,
      ),
      child: RawMaterialButton(
        child: Container(
            margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
            padding: EdgeInsets.only(
                top: 10.0, right: 14.0, bottom: 10.0, left: 14.0),
            decoration: BoxDecoration(
                color: Colors.pink[400],
                borderRadius: BorderRadius.all(Radius.circular(3.0))),
            child: Center(
                child: Text("Sign Up With Phone Number",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400)))),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PhoneAuth(country: country)),
          );
        },
      ));

  Widget _icons = Container(
      padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
      child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(
            iconSize: 20.0,
            icon: Icon(Icons.info_outline),
            onPressed: () {}),
        IconButton(
            iconSize: 20.0,
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            })
      ]));

  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 0.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20.0),
                  topRight: const Radius.circular(20.0)),
            ),
            child: Wrap(
              children: <Widget>[
                _icons,
                _textSection,
                _signupButton,
                _orDivider,
                _oAuth,
                _agreeNotice,
                _login
              ],
            )));
      });
}