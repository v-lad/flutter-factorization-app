import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
// import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:io' as io;
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart'
    show BaseRequest, Response, StreamedResponse;
import 'package:http/io_client.dart';

import '../styles.dart';
import '../widgets.dart';
import 'widgets.dart';

class NeuralPage extends StatefulWidget {

  // final _DataStorage storage;
  // NeuralPage({Key key, @required this.storage}) : super(key: key);

  @override
  _NeuralPageState createState() => _NeuralPageState();
}

class _NeuralPageState extends State<NeuralPage> {

  List<int> A = [null, null];
  List<int> B = [null, null];
  List<int> C = [null, null];
  List<int> D = [null, null];

  int P;
  double W1 = 0;
  double W2 = 0;

  List<double> delta_speed = [0.001, 0.01, 0.05, 0.1, 0.2, 0.3];
  double currentSpeed;
  int deadline;
  int iterations;

  var dots_dest = new Map();

  List dots;

  List results;
  List<Widget> resultsWidgets = [];

  var _computeButtonState;
  var _goToTest;
  bool _computeButtonEnable = false;
  bool _testBtnEnable = false;
  var beginTime;

  bool dlValue = false;
  bool iterValue = false;
  int dlDefault = 1000*1000;
  int iterDefault = 1000000;
  TextEditingController dlController = TextEditingController();
  TextEditingController iterController = TextEditingController();

  var initFile = "";
  var _appDirectory;
  var _uploadInfo = "";
  GoogleSignInAccount _currentUser;

  void dlValueChanged(bool value) => setState(() {
    dlValue = value;
    dlController.text = "";
    if (!dlValue) {
      deadline = dlDefault;
    }
  });
  void iterValueChanged(bool value) => setState(() {
    iterValue = value;
    iterController.text = "";
    if (!iterValue) {
      iterations = iterDefault;
    }
  });  

  @override
  void initState() {
    currentSpeed = delta_speed[0];
    deadline = dlDefault;
    iterations = iterDefault;
    super.initState();
    _readData().then((String value) {
      setState(() {
        initFile = value;
      });
    });
  }

  Future uploadOnDrive(DriveApi api, io.File file, String filename) {
      var media = Media(file.openRead(), file.lengthSync());
      return api.files
          .create(File.fromJson({"name": filename}), uploadMedia: media)
          .then((File f) {
        print('Uploaded $file. Id: ${f.id}');
      }).whenComplete(() {
        // reload content after upload the file
      });
    }

  void uploadFile() async {
    final _googleSignIn = new GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/drive',
      ],
    );
    
    _currentUser = await _googleSignIn.signIn();
    print(_currentUser);
    final _authHeaders = await _currentUser.authHeaders;

    var client = new GoogleHttpClient(_authHeaders);
    var api = DriveApi(client);
    io.File file = await _getLocalFile();

    uploadOnDrive(api, file, "results.txt")
        .whenComplete(() => client.close());
  }

  void buildResults() {
    //#region Build res
    List<Widget> widgets = [];

    widgets.add(
      Text(
        "Result: ",
        style: Styles.resultBoldTextStyle,
      ),
    );

    widgets.add(      
      Text(
        results[0],
        style: Styles.smallTextStyle,
      ),
    );

    if (results.length == 5) {
      widgets.add(
        Column(
          children: <Widget>[
            Text(
              "W1: " + results[1].toStringAsFixed(5) + "; ",
              style: Styles.smallBoldTextStyle,
            ),
            Text(
              "W2: " + results[2].toStringAsFixed(5),
              style: Styles.smallBoldTextStyle,
            ),
          ],
        )
      );

      widgets.add(
        Text(
          "Time: " + results[4].toString(),
          style: Styles.smallTextStyle,
        ),
      );

      widgets.add(
        Text(
          "Steps: " + results[3].toString(),
          style: Styles.smallTextStyle,
        ),
      );
    } else {
      List<Widget> y_s = [];
      for (var i = 3; i < 7; i++) {
        var tmp = results[i].toStringAsFixed(5);
        y_s.add(
          Text(
            "y$i: " + (tmp == "NaN" ? (i <= 2 ? "-infinity" : "infinity") : tmp) + (i == 4 ? "" : "; "),
            style: Styles.smallBoldTextStyle,
          )
        );
      }
      widgets.add(
        Column(
          children: y_s,
        )
      );
      
      var tmp1 = results[7].toStringAsFixed(5);
      var tmp2 = results[8].toStringAsFixed(5);
      widgets.add(
        Column(
          children: <Widget>[
            Text(
              "W1: " + (tmp1 == "NaN" ? "infinity" : tmp1) + "; ",
              style: Styles.smallBoldTextStyle,
            ),
            Text(
              "W2: " + (tmp2 == "NaN" ? "infinity" : tmp2),
              style: Styles.smallBoldTextStyle,
            ),
          ],
        )
      );

      widgets.add(
        Text(
          "Time: " + results[2].toString(),
          style: Styles.smallTextStyle,
        ),
      );

      widgets.add(
        Text(
          "Steps: " + results[1].toString(),
          style: Styles.smallTextStyle,
        ),
      );
    }

    setState(() => resultsWidgets = widgets);

  }
  //#endregion
  
  @override
  Widget build(BuildContext context) {
    // #region Build
    if (_computeButtonEnable) {
      _computeButtonState = () {
        setState(() {
          beginTime = DateTime.now().millisecondsSinceEpoch;
          results = compute();
        });
        buildResults();
        };
    } else {
      _computeButtonState = null;
    }

    if (_testBtnEnable) {
      _goToTest = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestLearningSpeed(
              testDots: dots, 
              testStep: step,
              testYCount: yCount,
              wNewCount: wNewCount
            )
          ));
      };
    } else {
      _goToTest = null;
    }
    
    return new Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
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
    // #endregion 
  }
  

  Widget _NeuralContent() {
    // #region Neural Content
    return new Column(
      children: <Widget>[
        PageTitle(title:"Perceptron"),
        PageInfo(text: "${'\t'*4}" + 'Something like perceptron (questionably)'),
        PageSubtitle(
          text: "Enter the data:",
          marginTop: 30,
        ),
        
        //#region A
        Wrap(
          children: <Widget>[
            SupportFlatButtonText(text: "A: "),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: Wrap(
                children: <Widget>[CustomTextInput(
                  onChanged: (numb) {
                    try{
                      A[0] = int.parse(numb);
                    } catch (e) {
                      A[0] = null;
                    }
                    checkState();
                  },
                  wFactor: 0.15,
                  hint: 'x1',
                  align: TextAlign.center,
                )]
              ),
            ),

            Wrap(              
              children: <Widget>[CustomTextInput(
                onChanged: (numb) {
                  try{
                    A[1] = int.parse(numb);
                  } catch (e) {
                    A[1] = null;
                  }
                  checkState();
                },
                wFactor: 0.15,
                hint: 'x2',
                align: TextAlign.center,
              )]
            ),
          ],
        ),
        // #endregion
        
        //#region B
        Wrap(
          children: <Widget>[
            SupportFlatButtonText(text: "B: "),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: Wrap(
                children: <Widget>[CustomTextInput(
                  onChanged: (numb) {
                      try{
                        B[0] = int.parse(numb);
                      } catch (e) {
                        B[0] = null;
                      }
                      checkState();
                    },
                  wFactor: 0.15,
                  hint: 'x1',
                  align: TextAlign.center,
                )]
              ),
            ),

            Wrap(              
              children: <Widget>[CustomTextInput(
                  onChanged: (numb) {
                    try{
                      B[1] = int.parse(numb);
                    } catch (e) {
                      B[1] = null;
                    }
                    checkState();
                  },
                  wFactor: 0.15,
                  hint: 'x2',
                  align: TextAlign.center,
              )]
            ),
          ],
        ),
        //#endregion
        
        //#region C
        Wrap(
          children: <Widget>[
            SupportFlatButtonText(text: "C: "),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: Wrap(
                children: <Widget>[CustomTextInput(
                  onChanged: (numb) {
                      try{
                        C[0] = int.parse(numb);
                      } catch (e) {
                        C[0] = null;
                      }
                      checkState();
                    },
                  wFactor: 0.15,
                  hint: 'x1',
                  align: TextAlign.center,
                )]
              ),
            ),

            Wrap(              
              children: <Widget>[CustomTextInput(
                  onChanged: (numb) {
                    try{
                      C[1] = int.parse(numb);
                    } catch (e) {
                      C[1] = null;
                    }
                    checkState();
                  },
                  wFactor: 0.15,
                  hint: 'x2',
                  align: TextAlign.center,
              )]
            ),
          ],
        ),
        //#endregion

        //#region D
        Wrap(
          children: <Widget>[
            SupportFlatButtonText(text: "D: "),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: Wrap(
                children: <Widget>[CustomTextInput(
                  onChanged: (numb) {
                      try{
                        D[0] = int.parse(numb);
                      } catch (e) {
                        D[0] = null;
                      }
                      checkState();
                    },
                  wFactor: 0.15,
                  hint: 'x1',
                  align: TextAlign.center,
                )]
              ),
            ),
            Wrap(              
              children: <Widget>[CustomTextInput(
                  onChanged: (numb) {
                    try{
                      D[1] = int.parse(numb);
                    } catch (e) {
                      D[1] = null;
                    }
                    checkState();
                  },
                  wFactor: 0.15,
                  hint: 'x2',
                  align: TextAlign.center,
              )]
            ),
          ],
        ),
        //#endregion

        //#region P
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 20),
          child: Wrap(
            children: <Widget>[
              SupportFlatButtonText(text: "P: "),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15),
                child: Wrap(
                  children: <Widget>[CustomTextInput(
                    onChanged: (numb) {
                      try{
                        P = int.parse(numb);
                      } catch (e) {
                        P = null;
                      }
                      checkState();
                    },
                    wFactor: 0.15,
                    align: TextAlign.center,
                  )]
                ),
              ),
            ],
          ),
        ),
        //#endregion

        //#region δ
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SupportFlatButtonText(text: "δ: "),
              Container(
                // color: Theme.of(context).primaryColor,
                margin: const EdgeInsets.only(left: 15, right: 15),
                child: Wrap(
                  children: <Widget>[new Center(
                    child: Theme(
                      data: Theme.of(context).copyWith(canvasColor: Colors.orange),
                      child: DropdownButton(
                        // underline: null,
                        items: delta_speed.map((double value) {
                          return DropdownMenuItem<double>(
                            value: value, 
                            child: Text(value.toString())
                          );
                        }).toList(),
                        // value: currentSpeed,
                        hint: Text(currentSpeed.toString(), style: TextStyle(color: Colors.white)),              
                        onChanged: updateSpeed,
                      ),
                    ),
                  )]
                ),
              ),
            ],
          ),
        ),
        //#endregion

        //#region deadline
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Wrap(
            children: <Widget>[
              Container(
                child: new Column(
                  children: <Widget>[
                    Theme(
                      data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.white),
                      child: Checkbox(
                        value: dlValue, 
                        onChanged: dlValueChanged,
                        checkColor: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                child: FlatButton(
                  child: Text(
                    "deadline:",
                    style: TextStyle(
                        fontSize: 20.0,
                        color: dlValue ? Colors.white : Colors.grey[600],
                        fontStyle: FontStyle.normal
                      ),
                  ),
                  onPressed: null,
                  padding: EdgeInsets.all(0),
                ),
                width: 100.0,
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15),
                child: Wrap(
                  children: <Widget>[CustomTextInput(
                      onChanged: (numb) {
                        try{
                          deadline = int.parse(numb);
                          if (!dlValue) {
                            deadline = dlDefault;
                          }
                        } catch (e) {
                          deadline = null;
                        }
                        checkState();
                      },
                      wFactor: 0.2,
                      hint: 'ms',
                      align: TextAlign.center,
                      enabled: dlValue,
                      controller: dlController,
                  )]
                ),
              ),
            ],
          ),
        ),
        //#endregion

        //#region iterations
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Wrap(
            children: <Widget>[
              Container(
                child: new Column(
                  children: <Widget>[
                    Theme(
                      data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.white),
                      child: Checkbox(
                        value: iterValue, 
                        onChanged: iterValueChanged,
                        checkColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                child: FlatButton(
                  child: Text(
                    "iterations: ",
                    style: TextStyle(
                        fontSize: 20.0,
                        color: iterValue ? Colors.white : Colors.grey[600],
                        fontStyle: FontStyle.normal
                      ),
                  ),
                  onPressed: null,
                  padding: EdgeInsets.all(0),
                ),
                width: 100.0,
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15),
                child: Wrap(
                  children: <Widget>[CustomTextInput(
                      onChanged: (numb) {
                        try{
                          iterations = int.parse(numb);
                          if (!iterValue) {
                            iterations = iterDefault;
                          }
                        } catch (e) {
                          iterations = null;
                        }
                        checkState();
                      },
                      wFactor: 0.2,
                      align: TextAlign.center,
                      enabled: iterValue,
                      controller: iterController,
                  )]
                ),
              ),
            ],
          ),
        ),
        //#endregion

        //#region Buttons and Results
        ActionRoundedButton(
          name: 'Compute',
          onPressed: _computeButtonState,
        ),
        
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: Column(
            children: resultsWidgets,
          )
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ActionRoundedButton(
              name: 'Test learning',
              onPressed: _goToTest,
              marginVer: 0,
              paddingVer: 12,
            ),
            
            ActionRoundedButton(
              name: 'Upload',
              onPressed: _testBtnEnable ? () {
                _writeData(); 
                getAppDir();
                uploadFile();
                // setState(() {
                //   _uploadInfo = "File was uploaded!";
                // });
              } : null,
              marginVer: 0,
              paddingVer: 12,
              icon: Icon(Icons.file_upload),
            ),
          ]
        ),

        Text(_uploadInfo),
        //#endregion
      ],
    );
    // #endregion
  }

  void updateSpeed(double speed) {
    setState(() {
      currentSpeed = speed;
    });
  }

  void checkState() {
      //#region check
      if (!(A.contains(null)) && 
          !(B.contains(null)) &&
          !(C.contains(null)) &&
          !(D.contains(null)) &&
          P != null &&
          currentSpeed != null &&
          (dlValue ? deadline != null : true) &&
          (iterValue ? iterations != null : true)
          ) {
            setState(() => _computeButtonEnable = true);
      } else {
        setState(() => _computeButtonEnable = false);
      }
      //#endregion
    }

  double yCount(X, w1, w2) {
    return X[0] * w1 + X[1] * w2;
  }

  double wNewCount(x, w, delta, currentSpeed) {
    var nw = w + delta * x * currentSpeed;
    return nw;
  }

  dynamic step(double w1, double w2, currentSpeed) {
    //#region step
    List y_i = [];

    for (var i = 0; i < 4; i++) {
      y_i.add(yCount(dots[i], w1, w2));
    }

    for (var i = 0; i < 4; i++) {
      if (i < 2) {
        if (y_i[i] > P) {

          return [wNewCount(dots[i][0], w1, P-y_i[i], currentSpeed), wNewCount(dots[i][1], w2, P-y_i[i], currentSpeed)];
        }
      } else {
        if (y_i[i] < P) {
          return [wNewCount(dots[i][0], w1, P-y_i[i], currentSpeed), wNewCount(dots[i][1], w2, P-y_i[i], currentSpeed)];
        }
      }
    }
    y_i.addAll([w1, w2]);
    return y_i;
    //#endregion
  }

  List compute() {
    //#region comp
    var t1;
    var steps = 1;

    setState(() => dots = [A, B, C, D]);
    dots.sort((a, b) => a[1].compareTo(b[1]));
    _testBtnEnable = true;
    
    for (var i = 0; i < dots.length; i++) {
      if (dots.indexOf(A) < 2) {
        dots_dest["A"] = "lt";
      } else dots_dest["A"] = "gt";

      if (dots.indexOf(B) < 2) {
        dots_dest["B"] = "lt";
      } else dots_dest["B"] = "gt";

      if (dots.indexOf(C) < 2) {
        dots_dest["C"] = "lt";
      } else dots_dest["C"] = "gt";

      if (dots.indexOf(D) < 2) {
        dots_dest["D"] = "lt";
      } else dots_dest["D"] = "gt";
    }

    var iter = step(W1, W2, currentSpeed);

    while (iter.length != 6) {
      t1 = DateTime.now().millisecondsSinceEpoch;
      if (t1 - beginTime >= deadline) {
        return ["The time is over", iter[0], iter[1], steps, deadline];
      }

      if (steps >= iterations) {
        return ["Maximum steps count is reached", iter[0], iter[1], steps, t1 - beginTime];
      }

      iter = step(iter[0], iter[1], currentSpeed);
      steps++;
    }
    
    t1 = DateTime.now().millisecondsSinceEpoch;

    var r = ["Done", steps, t1 - beginTime];
    r.addAll(iter);
    
    return r;
    //#endregion
  }

  //#region WORK WITH io.File
  Future<io.File> _getLocalFile() async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new io.File('$dir/results.txt');
  }

  Future<String> _readData() async {
    try {
      io.File file = await _getLocalFile();
      // read the variable as a string from the file.
      String contents = await file.readAsString();
      return contents;
    } on io.FileSystemException {
      return "0";
    }
  }

  Future<Null> _writeData() async {
    await (await _getLocalFile()).writeAsString('${results.join("\n")}');
  }

  void getAppDir() async{
    String dir = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      _appDirectory = dir;
    });
  }
  //#endregion
}

class TestLearningSpeed extends StatelessWidget {
  //#region TestLearningSpeed
  final List<double> delta_speed = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7];
  final double W1 = 0;
  final double W2 = 0;

  List<charts.Series<LinearResults, String>> _seriesGraphData;
  var graphData;

  final List testDots;
  final testStep;
  final testYCount;
  final wNewCount;

  List results = [];
  

  TestLearningSpeed({
    Key key, 
    @required this.testDots, 
    @required this.testStep,
    @required this.testYCount,
    @required this.wNewCount,
  }) : super(key: key);

  int compute(speed) {
    var steps = 1;

    var iter = testStep(W1, W2, speed);

    while (iter.length != 6) {

      iter = testStep(iter[0], iter[1], speed);
      steps++;
    }
    return steps;
  }

  @override
  Widget build(BuildContext context) {

    for (var s in delta_speed) {
      results.add(compute(s));
    }

    List<TableRow> resWidgets = [TableRow(
        children: [
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "δ:",
                  style: Styles.resultBoldTextStyle,
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "iterations:",
                  style: Styles.resultBoldTextStyle,
              ),
            ),
          )
        ]
      )];

    resWidgets.addAll(new List<TableRow>.generate(delta_speed.length, (int i) => TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: Center(
                  child: Text(
                    delta_speed[i].toString(),
                    style: Styles.flatButtonStyle,
                  ),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Center(
                  child: Text(
                      results[i].toString(),
                      style: Styles.flatButtonStyle,
                  ),
                ),
              ),
            )
          ]
        )
      )
    );

    _seriesGraphData = List<charts.Series<LinearResults, String>>();
    graphData = new List<LinearResults>.generate(delta_speed.length, (int i) => new LinearResults(delta_speed[i], results[i]));
    _seriesGraphData.add(
      charts.Series(
        data: graphData,
        domainFn: (LinearResults lr, _) => lr.speed.toString(),
        measureFn: (LinearResults lr, _) => lr.iters,
        colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
        fillPatternFn: (_, __) => charts.FillPatternType.forwardHatch,
        id: 'Iterations'
      )
    );

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(title: Text('Test learning speed')),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              new Column(children: <Widget>[

                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  child: PageTitle(
                    title: "Test results",
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: Table(
                    border: TableBorder.all(width: 2, color: Colors.orange[700]),
                    children: resWidgets,
                    defaultColumnWidth: FractionColumnWidth(.4),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 20, right: 10, left: 10),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 400.0),
                    child: Center(
                      child: Column(children: <Widget>[
                        PageSubtitle(text: "Iterations dependency:"),
                        Expanded(
                          child: charts.BarChart(
                            _seriesGraphData,
                            animate: true,
                            animationDuration: Duration(seconds: 4),
                            domainAxis: ChartXLabelStyle().build(),
                            primaryMeasureAxis: ChartYLabelStyle().build(),
                          ),
                        )
                      ],),
                    ),
                  ),
                )
              ],)
            ]),
          )
        ],
      ),
    );
  }
  // #endregion
}

class LinearResults {
  final double speed;
  final int iters;

  LinearResults(this.speed, this.iters);
}

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<StreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}
