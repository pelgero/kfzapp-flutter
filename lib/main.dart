import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KFZ App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(title: 'KFZApp'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // There may exist multiple plates per PlateId (Bennzeichen), e.g. "BK" has two different plates
  List<Plate> currentPlates = [];

  List<Plate> plates = [];
  Map<String, String> states = {};

  _MyHomePageState() {
    _loadPlates("assets/plates.json");
    _loadStates("assets/states.json");
  }

  void _changePlateId(String plateId) {
    setState(() {
      this.currentPlates =
          this.plates.where((plate) => plate.id == plateId).toList();
    });
  }

  void _loadPlates(String asset) {
    _loadJson(asset, (jsonPlates) {
      this.plates = List<Plate>.from(jsonDecode(jsonPlates).map((jsonPlate) {
        return Plate.from(jsonPlate);
      }));
    }, (err) => print(err));
  }

  void _loadStates(asset) {
    _loadJson(asset, (states) {
      this.states = Map.from(jsonDecode(states).map((key, value) {
        return MapEntry(key, value.toString());
      }));
    }, (err) => print(err));
  }

  void _loadJson(
      String assetName, Function onComplete, Function onError) async {
    rootBundle.loadString(assetName).then(onComplete).catchError(onError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                buildContent(this.currentPlates),
              ],
            ),
          ),
        ));
  }

  Widget buildContent(List<Plate> plates) {
    return Container(
      margin: const EdgeInsets.all(50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          buildInputField(),
          SizedBox(height: 14),
          buildResult()
        ],
      ),
    );
  }

  Widget buildInputField() {
    return Container(
        width: 100,
        child: TextField(
          autofocus: true,
          maxLength: 3,
          decoration: InputDecoration(
              labelText: 'Kennzeichen',
              labelStyle: TextStyle(fontSize: 13),
              border: OutlineInputBorder(),
              counterText: ""),
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          style: TextStyle(decoration: TextDecoration.none, fontSize: 30),
          onChanged: (value) {
            this._changePlateId(value.toUpperCase());
          },
        ));
  }

  Widget buildResult() {
    List<PlateView> plateViews =
        PlateView.fromAll(this.currentPlates, this.states);
    return Column(
        children: List<Widget>.from(
            plateViews.map((plate) => buildPlateViewWidget(plate))));
  }

  Widget buildPlateViewWidget(PlateView plate) {
    return Column(children: <Widget>[
      Text(plate.name,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      SizedBox(height: 2),
      Text(
        plate.state,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12),
      ),
      SizedBox(height: 2),
      Text(
        plate.region,
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 10),
    ]);
  }
}

class Plate {
  final String id;
  final String stateId;
  final String origin;
  final String name;
  final String extra;

  Plate(this.id, this.stateId, this.origin, this.name, this.extra);
  Plate.from(Map<String, dynamic> json)
      : this(json["id"], json["stateId"], json["origin"], json["name"],
            json["name_extra"]);

  String nameWithExtra() => extra.length == 0 ? name : '$name ($extra)';

  @override
  String toString() {
    return '$id: $origin ($name)';
  }
}

class PlateView {
  final String name;
  String region;
  String state;

  PlateView(this.name, this.region, this.state);
  PlateView.from(Plate plate, String state)
      : this(plate.origin, plate.nameWithExtra(), state);

  static List<PlateView> fromAll(
      List<Plate> plates, Map<String, String> states) {
    Map<String, PlateView> combined = {};
    for (Plate plate in plates) {
      PlateView view = PlateView.from(plate, _findByKey(plate.stateId, states));
      if (!combined.containsKey(plate.origin)) {
        combined.putIfAbsent(plate.origin, () => view);
      } else {
        combined.update(plate.origin, (existing) {
          existing.region += ', ${view.region}';
          if (existing.state != view.state) {
            existing.state += ', ${view.state}';
          }
          return existing;
        });
      }
    }

    return List<PlateView>.from(combined.values);
  }

  static String _findByKey(String stateKey, Map<String, String> map) {
    String value = map[stateKey];
    return value != null ? value : "";
  }
}
