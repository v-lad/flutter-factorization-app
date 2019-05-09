import 'package:flutter/material.dart';
import 'dart:math';
import 'package:collection/collection.dart';
import 'dart:collection';

class NeuralPage extends StatefulWidget {
  @override
  _NeuralPageState createState() => _NeuralPageState();
}

class _NeuralPageState extends State<NeuralPage> {
  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
      appBar: AppBar (
        title: Text('Neural networks'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              _NeuralContent()
            ]),
          )
        ],
      ),
    );
  }

  Widget _NeuralContent() {
    return new Column(
      children: <Widget>[],
    );
  }
}