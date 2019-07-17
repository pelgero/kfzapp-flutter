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
  Location currentLocation;
  String currentState;

  Map<String, Location> plates = {};
  Map<String, String> states = {};

  _MyHomePageState() {
    _loadPlates("assets/plates.json");
    _loadStates("assets/states.json");
  }

  void _changePlateNr(String plateNr) {
    setState(() {
      this.currentLocation = _findLocation(plateNr);
      this.currentState =
          this.currentLocation != null ? _findState(currentLocation.state) : "";
    });
  }

  Location _findLocation(String plateNr) {
    return plates[plateNr];
  }

  String _findState(String stateKy) {
    String state = states[stateKy];
    return state != null ? state : "";
  }

  void _loadPlates(String asset) {
    _loadJson(asset, (jsonPlates) {
      this.plates = Map.from(jsonDecode(jsonPlates).map((key, value) {
        return MapEntry(key, Location.from(value));
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
              child: buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent() {
    String text =
        (currentLocation != null ? currentLocation.names.join(" und ") : "") +
            (currentLocation != null ? "\n($currentState)" : "");

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
                  this._changePlateNr(value.toUpperCase());
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

class Location {
  final List<String> names;
  final String from;
  final String state;

  Location(this.names, this.from, this.state);

  Location.from(Map<String, dynamic> json)
      : this(List<String>.from(json["names"]), json["from"], json["state"]);

  @override
  String toString() {
    return '${names.join(" und ")}, $state, $from';
  }
}
