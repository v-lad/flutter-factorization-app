import 'package:flutter/material.dart';
import 'dart:math';
import 'package:rts_factorization/styles.dart';
import 'package:rts_factorization/widgets.dart';


class FactorizationPage extends StatefulWidget {
  @override
  _FactorizationPageState createState() => _FactorizationPageState();
}

class _FactorizationPageState extends State<FactorizationPage> {
  int n, result;
  List<String> primes = [];
  List<int> intPrimes = [];

  int factorSingle(int numb) {
    var i = 2;
    var j = 0;

    while (true) {
      if (pow(i, 2) <= numb && j != 1) {
        if (numb % i == 0) {
          j = 1;
        } else {
          i += 1;
        }        
      } else {
        if (j == 1) {
          numb = (numb / i).round();
          this.intPrimes.add(i);
          return factorSingle(numb);
        }else{
          this.intPrimes.add(numb);
          break;
        }
      }
    }
  }

  void factorizeNumber(int n) {
    List<String> textPrimes = [];
    this.intPrimes.clear();
    if (n == 1) {
      return this.updatePrimes(["One is one"]);
    }
    
    if (isPrime(n)) {
      return this.updatePrimes(["Entered number is prime"]);      
    }  

    factorSingle(n);
    textPrimes = this.intPrimes.map((prime) => prime.toString()).toList();

    return this.updatePrimes(textPrimes);
  }

  bool isPrime(int n) {
    if (n == 1) {
      return false;
    }

    for (var i = 2; i < sqrt(n+1); i++) {
      if (n % i == 0) {
        return false;
      }
    }

    return true;
  }

  void updatePrimes(List<String> l) {
    setState(() => this.primes = l);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Factorization'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              _FPContent()
            ]),
          )
        ],
      )
    );
  }

  Widget _FPContent() {
    return Column(
      children: <Widget> [
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            "Factorize a number",
            style: Styles.titleText
          ),
        ),
        PageInfo(
          text: "lorem ipsum",
        ),
        Center(
          child: Column(
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 0.9,
                child: TextField(
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  onChanged: (numb) {
                    n = int.parse(numb);
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter here...',
                    // hintText: 'Enter here...',
                    alignLabelWithHint: true,
                  ),
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                child: RaisedButton(
                  child: const Text(
                    'Compute',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).accentColor,
                  elevation: 1.0,
                  splashColor: Colors.limeAccent,
                  onPressed: () {
                    factorizeNumber(n);
                  },
                ),
              ),
            ],
          )
        ),
        ListView.builder(
          itemBuilder: (context, i) {
            return ListTile(
              title: Center(
                child: Text(
                  primes[i],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              )
            );
          },
          itemCount: primes.length,                      
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
        ),
      ],
    );
  }
}