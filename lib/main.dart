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

  Widget buildPlateWidget(PlateView plate) {
    return Container(
        child: Column(children: <Widget>[
      Text(plate.name,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      SizedBox(height: 2),
      Text(
        plate.state,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
        ),
      ),
      SizedBox(height: 2),
      Text(
        plate.region,
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 10),
    ]));
  }

  String nameWithExtra(Plate plate) {
    return plate.extra.length == 0
        ? plate.name
        : '${plate.name} (${plate.extra})';
  }

  List<PlateView> toPlateView(List<Plate> plates) {
    Map<String, PlateView> combined = {};
    for (Plate plate in plates) {
      PlateView view = PlateView(
          plate.origin, nameWithExtra(plate), _findRegion(plate.stateId));
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

  List<Widget> buildPlatesWidget(List<Plate> plates) {
    return List<Widget>.from(toPlateView(plates).map((plate) {
      return buildPlateWidget(plate);
    }));
  }

  Widget buildContent(List<Plate> plates) {
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
          SizedBox(height: 14),
          Column(children: buildPlatesWidget(currentPlates))
        ],
      ),
    );
  }
}

class PlateView {
  final String name;
  String region;
  String state;

  PlateView(this.name, this.region, this.state);
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
