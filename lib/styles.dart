import 'package:flutter/material.dart';


@immutable
class Styles {

  static final inputTextStyle = TextStyle(fontSize: 20, color: Colors.black);
    
  static final flatButtonStyle = TextStyle(
    fontSize: 20.0,
    color: Colors.black,
    fontStyle: FontStyle.normal,
  );

  static final titleTextStyle = TextStyle(
    fontSize: 30,
    color: Colors.orangeAccent[700],
    fontWeight: FontWeight.bold, 
  );

  static final subtitleTextStyle = TextStyle(
    fontSize: 24,
    color: Colors.orangeAccent[700],
    fontWeight: FontWeight.bold, 
  );

  static final infoTextStyle = TextStyle(
    fontSize: 18,
    color: Colors.black,
  );

  static final resultBoldTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );
}