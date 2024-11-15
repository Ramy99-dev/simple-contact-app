import 'dart:async';

import 'package:contact_app/screen/contacts.dart';
import 'package:contact_app/screen/login.dart';
import 'package:contact_app/util/storage.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  dynamic homeWidget = Login();
  Future<void> checkConnection() async {
    String connected = await Storage.getStorage("connected");
    setState(() {
      if (connected == "true") {
        homeWidget = Contacts();
      }
    });
  }

  bool firstlaunch = false;
  late AnimationController controller;
  late Animation<double> animation;
  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    controller.repeat(reverse: true);
    checkConnection();
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => homeWidget)));
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
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: animation,
              child: Image.asset(
                "assets/logo.png",
                width: 200,
              ),
            ),
          ],
        )),
      ),
    );
  }
}
