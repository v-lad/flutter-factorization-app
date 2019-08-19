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
  bool isButtonEnable;

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
          text: "${'\t'*4}" + "Get factorization of entered number "
          "(decomposition by prime factors) via trial division algorithm ",
        ),
        Center(
          child: Column(
            children: <Widget>[
              CustomTextInput(
                onChanged: (numb) {
                  try{
                    var parsed = int.parse(numb);
                    n = parsed >= 1 ? parsed : throw Exception('Bad number');
                    setState(() => isButtonEnable = true);
                  } catch (e) {
                    setState(() => isButtonEnable = false);
                  }
                },
                label: 'Input a number',
                autofocus: true,
                alignLabel: true,
                helperText: 'Must be >= 1',
              ),

              ActionRoundedButton(
                name: 'Compute',
                onPressed: isButtonEnable ?? false ? () { factorizeNumber(n); } : null,
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