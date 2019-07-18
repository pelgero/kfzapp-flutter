import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KFZ Kennzeichen App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(title: 'KFZAPP'),
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
    print("Change $plateId");
    setState(() {
      this.currentPlates = _findPlates(plateId);
      print("plates: ");
      print(this.currentPlates);
    });
  }

  List<Plate> _findPlates(String plateId) {
    return this.plates.where((plate) => plate.id == plateId).toList();
  }

  String _findRegion(String stateKy) {
    String state = states[stateKy];
    return state != null ? state : "";
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
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: buildContent(this.currentPlates),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent(List<Plate> plates) {
    String text = currentPlates.map((plate) {
      return '${plate.origin} (${plate.name}, ${_findRegion(plate.stateId)})';
    }).join("\n");

    return Container(
      margin: const EdgeInsets.all(50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
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
              )),
          SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: text.length > 25 ? 17 : 20),
          )
        ],
      ),
    );
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

  @override
  String toString() {
    return '$id: $origin ($name)';
  }
}
