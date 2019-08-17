import 'package:flutter/material.dart';

import 'Factorization/factorization.dart';
import 'GenAlg/genetic.dart';
import 'Neural/neural.dart';


void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RTS',
      theme: ThemeData(
        primaryColor: Colors.orange[800],
        primarySwatch: Colors.deepOrange,

        // textTheme: TextTheme(
        //   title: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.orangeAccent[700],),
        //   supportingText: TextStyle(),
          
        // ),
      ),
      home: HomePage(),
      routes: <String, WidgetBuilder> {
        '/factorization': (BuildContext context) => new FactorizationPage(),
        '/gen': (BuildContext context) => new GenAlgPage(),
        '/neural': (BuildContext context) => new NeuralPage(),
        '/testNeural': (BuildContext context) => new TestLearningSpeed(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {    
    return new Scaffold(
      appBar: new AppBar(
        title: Text('RTS'),
      ),
      body: new Container(
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new FlatButton(
                child: Text(
                  "Factorization",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.orange
                    ),
                ),
                onPressed: () {Navigator.of(context).pushNamed("/factorization");},
              ),
              new FlatButton(
                child: Text(
                  "Neural",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.orange
                    ),
                ),
                onPressed: () {Navigator.of(context).pushNamed('/neural');},
              ),
              new FlatButton(
                child: Text(
                  "Gen. algorithms",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.orange
                    ),
                ),
                onPressed: () {Navigator.of(context).pushNamed('/gen');},
              )
            ],
          ),
        ),
      ),
    );
  }
}
