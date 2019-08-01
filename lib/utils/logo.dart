import 'package:flutter/material.dart';

class Logo extends StatefulWidget {
  State<Logo> createState() => LogoState();
}

class LogoState extends State<Logo> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState(){
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = Tween<double>(begin: 190, end: 200).animate(controller)
      ..addListener((){
        setState(() {
        });
      })
      ..addStatusListener((status) {
        if(status == AnimationStatus.completed) {
          controller.reverse();
        }else if(status == AnimationStatus.dismissed){
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Image.asset("assets/images/justmusic_logo.png",
          width: animation.value,
          height: animation.value
          )
      )
    ));
  }
}