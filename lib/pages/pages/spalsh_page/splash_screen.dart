import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final double progression;
  SplashScreen({
    Key key,
    this.progression = 0
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red,
        child: Center(
          child: Text("${widget.progression.toStringAsFixed(2)} %"),
        )
      ),
    );
  }
}