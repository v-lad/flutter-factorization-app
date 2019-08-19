import 'dart:convert';
import 'dart:io';

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
  bool _computeButtonEnable;
  
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
    _computeButtonEnable = (n != null && !(params.contains(null)) && result != null) ? true:false;

    if (_computeButtonEnable) {
      _computeButtonState = () {
        
        if (isNormal()) {
          fitPerson = [];
          while (lsEqual(fitPerson, [])) {
            try {
              var t1 = DateTime.now().millisecondsSinceEpoch;
              setState(() {
                fitPerson = geneticSearch();
                geneticTime = DateTime.now().millisecondsSinceEpoch - t1;
              });
              var t2 = DateTime.now().millisecondsSinceEpoch;
              setState(() {
                enumRes = enumerationSearch();
                enumTime = DateTime.now().millisecondsSinceEpoch - t2;
              });
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
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar (title: Text('Genetic algorithms')),
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
    setState(() {
      resultWidgets= <Widget>[];
      genWidgets = <Widget>[];
      geneticTimeWidgets = <Widget>[];
      enumResultWidgets = <Widget>[];
      enumTimeWidgets = <Widget>[];
      enumTitle = "";
      comparedString= "";
    });
  }


  Widget _GenContent() {
    return Column(
      children: <Widget>[
        PageTitle(title: "Solving diofant equations"),
        PageInfo(
          text: "${'\t'*4}" + "There you can solve your diofant equation "
                "with specified number of variables with help genetic "
                "algorithm. At the end you can compare performance "
                "results with simple enumeration.",
        ),
        PageSubtitle(
          text: "Enter the data:",
          marginTop: 30,
        ),
        Container(
          child: CustomTextInput(
            onChanged: (numb) {
              try {
                var temp = int.parse(numb);
                n = (temp > 1) ? temp : throw Exception("Bad number");
                setState(() => exprWidgets = <Widget>[]);
                clearStates();
                buildExpression(n);
              } catch (e) {
                clearStates();
                setState(() {
                  exprWidgets = <Widget>[];
                  result = null;
                  _computeButtonEnable = !(params.contains(null)) && result != null;
                });
              }
            },
            align: TextAlign.center,
            alignLabel: true,
            label: 'Count of variables',
            autofocus: true,
            wFactor: 0.5,
            helperText: '26 max and must be >= 2',
          ),
          margin: EdgeInsets.only(bottom: 20),
        ),
        StatefulBuilderWrapper(
          widget: Wrap(
            direction: Axis.horizontal,
            children: exprWidgets,
          ),
        ),
        ActionRoundedButton(
          name: 'Compute',
          onPressed: _computeButtonState,
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: StatefulBuilderWrapper(
            widget: Wrap(
              direction: Axis.horizontal,
              children: resultWidgets,
            ),
          )
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: StatefulBuilderWrapper(
            widget: Wrap(
              direction: Axis.horizontal,
              children: genWidgets,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: StatefulBuilderWrapper(
            widget: Wrap(
              direction: Axis.horizontal,
              children: geneticTimeWidgets,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            enumTitle,
            style: Styles.resultBoldTextStyle,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: StatefulBuilderWrapper(
            widget: Wrap(
              direction: Axis.horizontal,
              children: enumResultWidgets,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: StatefulBuilderWrapper(
            widget: Wrap(
              direction: Axis.horizontal,
              children: enumTimeWidgets,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Text(
            comparedString,
            style: Styles.resultBoldTextStyle,
          ),
        ),
      ],
    );
  }

  void buildResult() {
    AsciiCodec asciiCustom = AsciiCodec();
    String alphabet = asciiCustom.decode([for (int i = 97; i <= 122; i++) i]);  // "abcdf...z"
    List<Widget> expression = [];
    List<Widget> expressionGenCount = [];
    List<Widget> expressionGenTime = [];
    List<Widget> expressionEnumRes = [];
    List<Widget> expressionEnumTime = [];

    expression.add(
      Text(
        "Result: ",
        style: Styles.flatButtonStyle,
      ),
    );

    for (var i = 0; i < fitPerson.length; i++) {
      var lastElementParsed = i != fitPerson.length-1 ? alphabet[i]+'='+fitPerson[i].toString()+', ' : alphabet[i]+'='+fitPerson[i].toString();
      expression.add(
        Stack(
          children: <Widget>[
            Text(
              lastElementParsed,
              style: Styles.resultBoldTextStyle,
            ),
          ],
        )
      );
    }

    expressionGenCount.addAll([
      Text(
        "Generation count: ",
        style: Styles.flatButtonStyle,
      ),
      Text(
        generationCount.toString(),
        style: Styles.resultBoldTextStyle,
      ),
    ]);

    expressionGenTime.addAll([
      Text(
        "Genetic alg. time: ",
        style: Styles.flatButtonStyle,
      ),
      Text(
        geneticTime.toString() + ' ms',
        style: Styles.resultBoldTextStyle,
      ),
    ]);

    for (var i = 0; i < enumRes.length; i++) {
      var lastElementParsed = i != enumRes.length-1 ? alphabet[i]+'='+enumRes[i].toString()+', ' : alphabet[i]+'='+enumRes[i].toString();
      expressionEnumRes.add(
        Stack(
          children: <Widget>[
            Text(
              lastElementParsed,
              style: Styles.resultBoldTextStyle,
            ),
          ],
        )
      );
    }

    expressionEnumTime.addAll([
      Text(
        "Enumeration time: ",
        style: Styles.flatButtonStyle,
      ),
      Text(
        enumTime.toString() + ' ms',
        style: Styles.resultBoldTextStyle,
      ),
    ]);

    setState(() {
      resultWidgets = expression;
      genWidgets = expressionGenCount;
      geneticTimeWidgets = expressionGenTime;
      enumTitle = "Enumeration results:";
      enumResultWidgets = expressionEnumRes;
      enumTimeWidgets = expressionEnumTime;
      comparedString = enumTime > geneticTime ? 'Genetic alg. is faster' : 'Enumeration is faster';
    });
  }

  void buildExpression(int n) {
    AsciiCodec asciiCustom = AsciiCodec();
    String alphabet = asciiCustom.decode([for (int i = 97; i <= 122; i++) i]);  // "abcdf...z"
    List<Widget> expression = [];
    params = new List(n);
    result = null;
    setState(() => _computeButtonEnable = !(params.contains(null)) && result != null && n != null);

    for (var i = 0; i < n; i++) {
      expression.add(Wrap(children: <Widget>[CustomTextInput(
            onChanged: (numb) {
              try{
                params[i] = int.parse(numb);
              } catch (e) {
                params[i] = null;
              }
              setState(() => _computeButtonEnable = !(params.contains(null)) && result != null);
            },
            wFactor: 0.1,
            hint: 'p$i',
            align: TextAlign.end,
          )]
        ),
      );
      expression.add(
        SupportFlatButtonText(text: alphabet[i])
      );

      if (i != n-1) {
        expression.add(
          SupportFlatButtonText(text: " + ")
        );
      }
    }

    expression.add(
      SupportFlatButtonText(text: " = "),
    );

    expression.add(Wrap(children: <Widget>[CustomTextInput(
        onChanged: (numb) {
          try {
            result = int.parse(numb);
          } catch (e) {                
            result = null;
          }
          setState(() => _computeButtonEnable = !(params.contains(null)) && result != null);
        },
        wFactor: 0.13,
        hint: 'N',
        align: TextAlign.start,
      )]
    ));
    
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
    AsciiCodec ascii = AsciiCodec();
    String alphabet = ascii.decode([for (var i=97; i <= 122; i++) i]);
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

    newPerson[ind1] = rand.nextInt((result ~/ maxValue(params)) + 1)+1;
    newPerson[ind2] = rand.nextInt((result ~/ maxValue(params)) + 1)+1;

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