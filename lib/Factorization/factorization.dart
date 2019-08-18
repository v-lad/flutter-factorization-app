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
      backgroundColor: Theme.of(context).backgroundColor,
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
        PageTitle(title: "Factorize a number"),
        PageInfo(
          text: "${'\t'*4}" + "lorem ipsum dolor sit amet",
        ),
        Center(
          child: Column(
            children: <Widget>[
              CustomTextInput(
                onChanged: (numb) { n = int.parse(numb); },
                label: 'Input a number',
                autofocus: true,
                alignLabel: true,
              ),

              ActionRoundedButton(
                name: 'Compute',
                onPressed: () { factorizeNumber(n); },
              ),
            ],
          )
        ),
        PageInfo(
          text: primes.join(';  ') + (primes.length != 0 ? '.' : ''),
          style: Styles.resultBoldTextStyle,
          align: TextAlign.center,
          isSizeMin: true,
        )
      ],
    );
  }
}