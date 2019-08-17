import 'package:flutter/material.dart';
import 'dart:math';
import 'package:collection/collection.dart';
import 'dart:collection';

import 'package:rts_factorization/styles.dart';
import 'package:rts_factorization/widgets.dart';

Function lsEqual = ListEquality().equals;

class GenAlgPage extends StatefulWidget {
  @override
  _GenAlgPageState createState() => _GenAlgPageState();
}

class _GenAlgPageState extends State<GenAlgPage> {

  int n;
  List<Widget> exprWidgets = <Widget>[];
  List<Widget> resultWidgets = <Widget>[];
  List<Widget> genWidgets = <Widget>[];
  List<Widget> geneticTimeWidgets = <Widget>[];

  var enumTitle = "";
  var comparedString = "";
  List<Widget> enumResultWidgets = <Widget>[];
  List<Widget> enumTimeWidgets = <Widget>[];
  var rand = Random();

  static List<int> params = [];
  static int result;

  var _computeButtonState;
  bool _computeButtonEnable = !(params.contains(null)) && result != null ? true:false;
  
  List<List<int>> firstGen;
  List<List<int>> currentGen;
  List<List<int>> nextParents;
  int generationCount = 0;
  int geneticTime = 0;
  int enumTime = 0;
  int comparedTime = 0;

  List<int> fitness = [];
  List<int> deltas = [];
  List<double> probabilities = [];

  List<int> fitPerson = [];
  List<int> enumRes = [];
  List<List<int>> nextGen = [];

  LinkedHashMap<String, int> enumValues = new LinkedHashMap();

  _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  @override
  Widget build(BuildContext context) {    

    if (_computeButtonEnable) {
      _computeButtonState = () {
        
        if (isNormal()) {
          fitPerson = [];
          while (lsEqual(fitPerson, [])) {
            try {
              var t1 = DateTime.now().millisecondsSinceEpoch;
              setState(() => fitPerson = geneticSearch());
              setState(() => geneticTime = DateTime.now().millisecondsSinceEpoch - t1);
              var t2 = DateTime.now().millisecondsSinceEpoch;
              setState(() => enumRes = enumerationSearch());
              setState(() => enumTime = DateTime.now().millisecondsSinceEpoch - t2);
              buildResult();
            } catch (e) {
              fitPerson = [];
            }
          }
        } else {
          clearStates();
          setState(() => resultWidgets = [Text("It's not diofant equation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)]);
        }
      };
    } else {
      _computeButtonState = null;
    }
    
    return new GestureDetector(
      onTap: () {
        this._dismissKeyboard(context);
      },
      child: Scaffold(
        appBar: AppBar (
          title: Text('Genetic algorithms'),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                _GenContent()
              ]),
            )
          ],
        ),
      )
    );
  }

  void clearStates() {    
    setState(() => resultWidgets= <Widget>[]);
    setState(() => genWidgets = <Widget>[]);
    setState(() => geneticTimeWidgets = <Widget>[]);
    setState(() => enumResultWidgets = <Widget>[]);
    setState(() => enumTimeWidgets = <Widget>[]);
    setState(() => enumTitle = "");
    setState(() => comparedString= "");
  }


  Widget _GenContent() {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            "Solving diofant equations",
            style: Styles.titleText
          ),
        ),
        PageInfo(
          text: "There you can solve your diofant equation "
                "with specified number of variables with help genetic "
                "algorithm. At the end you can compare performance "
                "results with simple enumeration.",
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          child: Text(
            "Enter data",
            style: Styles.subtitleText
          ),
        ),
        Container(
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              onChanged: (numb) {
                try {
                  n = int.parse(numb);
                  setState(() => exprWidgets = <Widget>[]);
                  clearStates();
                  buildExpression(n);
                } catch (e) {
                  setState(() => exprWidgets = <Widget>[]);
                  clearStates();
                  setState(() => result = null);
                  setState(() => _computeButtonEnable = !(params.contains(null)) && result != null);
                }
              },
              decoration: InputDecoration(
                labelText: 'Count of variables',
                // hintText: 'Enter here...',
                alignLabelWithHint: true,
              ),
              style: TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          margin: EdgeInsets.only(bottom: 20),
        ),
        Wrap(
          direction: Axis.horizontal,
          children: exprWidgets,
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
            padding: const EdgeInsets.all(13),
            color: Theme.of(context).accentColor,
            elevation: 1.0,
            splashColor: Colors.limeAccent,
            onPressed: _computeButtonState,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: Wrap(
            direction: Axis.horizontal,
            children: resultWidgets,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: Wrap(
            direction: Axis.horizontal,
            children: genWidgets,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: Wrap(
            direction: Axis.horizontal,
            children: geneticTimeWidgets,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            enumTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: Wrap(
            direction: Axis.horizontal,
            children: enumResultWidgets,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: Wrap(
            direction: Axis.horizontal,
            children: enumTimeWidgets,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Text(
            comparedString,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  void buildResult() {
    String alph = "abcdefghijklmnopqrstuvwxyz";
    List<String> alphabet = alph.split('');
    List<Widget> expression = [];
    List<Widget> expressionGenCount = [];
    List<Widget> expressionGenTime = [];
    List<Widget> expressionEnumRes = [];
    List<Widget> expressionEnumTime = [];

    expression.add(
      Text(
        "Result: ",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    );

    for (var i = 0; i < fitPerson.length; i++) {
      var govnocode = i != fitPerson.length-1 ? alphabet[i]+'='+fitPerson[i].toString()+', ' : alphabet[i]+'='+fitPerson[i].toString();
      expression.add(
        Stack(
          children: <Widget>[
            Text(
              govnocode,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        )
      );
    }

    expressionGenCount.addAll([
      Text(
        "Generation count: ",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      Text(
        generationCount.toString(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
      ),
    ]);

    expressionGenTime.addAll([
      Text(
        "Genetic alg. time: ",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      Text(
        geneticTime.toString() + ' ms',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
      ),
    ]);

    for (var i = 0; i < enumRes.length; i++) {
      var govnocode = i != enumRes.length-1 ? alphabet[i]+'='+enumRes[i].toString()+', ' : alphabet[i]+'='+enumRes[i].toString();
      expressionEnumRes.add(
        Stack(
          children: <Widget>[
            Text(
              govnocode,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        )
      );
    }

    expressionEnumTime.addAll([
      Text(
        "Enumeration time: ",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      Text(
        enumTime.toString() + ' ms',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
      ),
    ]);

    setState(() => resultWidgets = expression);
    setState(() => genWidgets = expressionGenCount);
    setState(() => geneticTimeWidgets = expressionGenTime);
    setState(() => enumTitle = "Enumeration results:");
    setState(() => enumResultWidgets = expressionEnumRes);
    setState(() => enumTimeWidgets = expressionEnumTime);
    setState(() => comparedString = enumTime > geneticTime ? 'Genetic alg. is faster' : 'Enumeration is faster');
  }

  void buildExpression(int n) {
    String alph = "abcdefghijklmnopqrstuvwxyz";
    List<String> alphabet = alph.split('');
    List<Widget> expression = [];
    params = new List(n);
    result = null;
    setState(() => _computeButtonEnable = !(params.contains(null)) && result != null);

    for (var i = 0; i < n; i++) {
      expression.add(Wrap(children: <Widget>[FractionallySizedBox(
            widthFactor: 0.10,
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (numb) {
                try{
                  params[i] = int.parse(numb);
                } catch (e) {
                  params[i] = null;
                }
                setState(() => _computeButtonEnable = !(params.contains(null)) && result != null);
              },
              decoration: InputDecoration(
                hintText:'p${i}',
              ),
              style: TextStyle(fontSize: 20, color: Colors.black,),
              textAlign: TextAlign.end,
            ),
          ),]
        ),
      );
      expression.add(
        SizedBox(
          child: FlatButton(
            child: Text(
              alphabet[i],
              style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontStyle: FontStyle.normal
                ),
            ),
            onPressed: null,
            padding: EdgeInsets.all(0),
          ),
          width: 20.0,
        )
      );

      if (i != n-1) {
        expression.add(
          SizedBox(
            child: FlatButton(
              child: Text(
                " + ",
                style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.black,
                    fontStyle: FontStyle.normal
                  ),
              ),
              onPressed: null,
              padding: EdgeInsets.all(0),
            ),
            width: 20.0,
          )
        );
      }
    }

    expression.add(
      SizedBox(
        child: FlatButton(
          child: Text(
            " = ",
            style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.black,
                fontStyle: FontStyle.normal
              ),
          ),
          onPressed: null,
          padding: EdgeInsets.all(0),
        ),
        width: 20.0,
      )
    );

    expression.add(Wrap(children: <Widget>[FractionallySizedBox(
          widthFactor: 0.13,
          child: TextField(
            keyboardType: TextInputType.number,
            onChanged: (numb) {
              try {
                result = int.parse(numb);
              } catch (e) {                
                result = null;
              }
              setState(() => _computeButtonEnable = !(params.contains(null)) && result != null);
            },
            decoration: InputDecoration(
              hintText: 'N',
            ),
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),]
      ),
    );
    
    // return expression;
    setState(() => exprWidgets = expression); 
  }

  bool isFit(List<int> curEnum) {
    List<int> tmp = new List(curEnum.length);
    for (var i = 0; i < tmp.length; i++) {
      tmp[i] = curEnum[i];
      tmp[i] *= params[i];      
    }

    if(tmp.reduce((a, b) => a+b) == result) {
      return true;
    }

    return false;
  }

  bool isNormal() {
    var s = params.reduce((a, b) => a+b);
    if (s <= result) {
      return true;
    }

    return false;
  }

  List<int> enumerationSearch() {
    String alph = "abcdefghijklmnopqrstuvwxyz";
    List<String> alphabet = alph.split('');
    int parCount = params.length;
    enumValues = new LinkedHashMap();
    List<int> temp = new List(params.length);
    int maxVal = result ~/ maxValue(params);

    for (var i = 0; i < parCount; i++) {
      enumValues[alphabet[i]] = 1;
      temp[i] = 1;
    }

    var iter = 0;
    var val = 2;
    var curChng = 0;

    while (!isFit(temp)) {
      temp = enumValues.values.toList();
      temp[iter] = val;


      if (val == maxVal) {
        iter++;
        val = 1;
      }

      if (iter == parCount) {
        iter = 0;
        enumValues[alphabet[curChng]]++;
        curChng++;
        if (curChng == parCount) {
          curChng = 0;
        }
      }
      val++;
    }

    return temp;
  }

  List<int> geneticSearch() {
    if (!isNormal()) {
      
    }
    int perCount = params.length*2;
    firstGen = generatePopulations(perCount);
    setState(() => currentGen = firstGen);
    generationCount =0;
    fitPerson = [];

    while (true) {
      fitness.clear();
      for (var p in currentGen) {
        fitness.add(countFitness(p));
      }

      deltas.clear();
      for (var f in fitness) {
        deltas.add((f-result).abs());
      }

      setState(() => generationCount++);
      if (deltas.contains(0)) {
        return currentGen[deltas.indexOf(0)];
      }

      probabilities = countProbabilities();
      nextParents = generateNextParents();

      nextGen = [];
      List<int> tmpChild;

      for (var parent in nextParents) {
        tmpChild = crossOne(parent);
        if (nextGen.every((p)=>lsEqual(p, tmpChild))) {
          tmpChild = mutateOne(tmpChild);
        }
        nextGen.add(tmpChild);
      }

      currentGen = nextGen;
    }
  }

  List<List<int>> generatePopulations(int count) {

    List<List<int>> firstGen = [];
    List<int> temp = [];

    for (var i = 0; i < count; i++) {
      temp = [];
      for (var j = 0; j < n; j++) {
        temp.add(rand.nextInt(result ~/ maxValue(params))+1);
      }
      firstGen.add(temp);
    }

    return firstGen;
  }

  int countFitness (List<int> pars) {
    List<int> temp = [];

    for (var i = 0; i < pars.length; i++) {
      temp.add(params[i] * pars[i]); 
    }

    return temp.reduce((a, b) => a + b);
  }

  List<double> countProbabilities() {
    List<double> temp = [];

    for (var d in deltas) {
      temp.add(1/d);
    }

    double sumD = temp.reduce((a, b) => a+b);
    temp.clear();

    for (var d in deltas) {
      temp.add(num.parse(((1/d)/sumD).toStringAsFixed(5)));
    }

    return temp;
  }

  int chooseSector() {
    num r = rand.nextDouble();
    num before = 0;

    for (var i = 0; i < probabilities.length; i++) {
      if (before < r && r < probabilities[i] + before) {
        return i;
      } else {
        before += probabilities[i];
      }
    }
  }

  List<int> chooseParents() {
    int p1 = chooseSector();
    int p2 = chooseSector();

    while (p2 == p1) {
      p2 = chooseSector();
    }

    return <int>[p1, p2];
  }

  List<List<int>> generateNextParents() {
    List<List<int>> temp = [];

    for (var i = 0; i < params.length*2; i++) {
      temp.add(chooseParents());
    }

    return temp;
  }

  List<int> crossOne(List<int> parents) {
    List<int> fatherPer = currentGen[parents[0]];
    List<int> motherPer = currentGen[parents[1]];
    List<int> childPer = [];

    int divider = rand.nextInt(fatherPer.length-1)+1;

    childPer.addAll(fatherPer.getRange(0, divider));
    childPer.addAll(motherPer.getRange(divider, motherPer.length));

    while (currentGen.map((p) => lsEqual(p, childPer)).toList().every((p)=>p==true)) {
      childPer = mutateOne(childPer);
    }

    return childPer;
  }

  List<int> mutateOne(List<int> person) {
    List<int> newPerson = person;
    int ind1 = rand.nextInt(person.length);
    int ind2 = rand.nextInt(person.length);

    while (ind2 == ind1) {
      ind2 = rand.nextInt(person.length);
    }

    newPerson[ind1] = rand.nextInt(result ~/ maxValue(params))+1;
    newPerson[ind2] = rand.nextInt(result ~/ maxValue(params))+1;

    return newPerson;
  }

  num maxValue(List<num> ls) {
    num min_ = ls[0];

    for (var i in ls) {
      if (i > min_) {
        min_ = i;
      }
    }

    return min_;
  }
}