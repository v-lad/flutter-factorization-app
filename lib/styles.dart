import 'package:flutter/material.dart';


@immutable
class Styles {

  static final inputTextStyle = TextStyle(fontSize: 20, color: Colors.white);
    
  static final flatButtonStyle = TextStyle(
    fontSize: 20.0,
    color: Colors.white,
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
    color: Colors.white,
  );

  static final helperTextStyle = TextStyle(
    fontSize: 13,
    color: Color(0xff888888),
  );

  static final hintTextStyle = TextStyle(
    fontSize: 18,
    color: Color(0xff888888),
  );

  static final labelTextStyle = TextStyle(
    color: Color(0xff888888),
  );

  static final resultBoldTextStyle = TextStyle(
    fontSize: 20.0,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static final smallTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  static final smallBoldTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
}