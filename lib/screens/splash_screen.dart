import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_statuses/model/user_model.dart';
import 'package:my_statuses/screens/auth/login_screen.dart';
import 'package:my_statuses/screens/home_screen.dart';
import 'package:my_statuses/screens/padre_screen.dart';
import 'package:my_statuses/utilities/firebase_utils.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), ()async {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
      } else {
        setRuta();
      }
    });
  }

  void setRuta() async {
    UserModel usuario =
            await FirebaseUtils.datosPadre(FirebaseAuth.instance.currentUser.uid);
    if (usuario.rol == "Padre") {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => PadreScreen()), (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Image.asset("assets/logo.png"),
        ),
      ),
    );
  }
}
