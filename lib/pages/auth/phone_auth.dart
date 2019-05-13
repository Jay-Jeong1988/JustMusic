import "package:flutter/material.dart";

class PhoneAuth extends StatelessWidget {
  String phoneNo;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: Container(
          padding: EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(hintText: 'Enter Phone number'),
                onChanged: (value) {
                  this.phoneNo = value;
                }
              ),
              SizedBox(height: 10.0),
              RaisedButton(
                onPressed: (){},
                child: Text("Verify"),
                textColor: Colors.white,
                elevation: 7.0,
                color: Colors.blue
              )
            ]
          )
        )
      )
    );
  }

//  verifyPhone
}