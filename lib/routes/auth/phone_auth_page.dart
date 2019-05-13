import "package:flutter/material.dart";

class PhoneAuth extends StatelessWidget {
  String phoneNo;

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
                      TextField(
                          decoration:
                              InputDecoration(hintText: 'Phone number'),
                          onChanged: (value) {
                            this.phoneNo = value;
                          }),
                      Container(
                          padding: EdgeInsets.only(top: 15.0, right: 8.0, bottom: 15.0),
                          decoration: BoxDecoration(),
                          child: Text(
                              "By signing up, you confirm that you agree to our Terms "
                                  "of Use and have read and understood our Privacy Policy."
                                  " You will receive an SMS to confirm your phone number."
                                  " SMS fee may apply.",
                              style: TextStyle(fontSize: 12.0))),
                      RaisedButton(
                          onPressed: () {},
                          child: Text("Verify"),
                          textColor: Colors.white,
                          elevation: 7.0,
                          color: Colors.blue)
                    ]))));
  }

//  verifyPhone
}
