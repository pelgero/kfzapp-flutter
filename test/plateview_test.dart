import 'package:flutter_test/flutter_test.dart';
import 'package:kfzapp/main.dart';

void main() {
  test("PlateView.fromAll with empty plates", () {
    List<PlateView> views = PlateView.fromAll([], {});
    expect(views, equals([]));
  });

  test("PlateView.fromAll w/ single Plate creates 1 PlateView", () {
    List<PlateView> views = PlateView.fromAll(
        [Plate("RO", "BY", "Rosenheim", "Stadt Rosenheim", "")],
        {"BY": "Bayern"});
    expect(views.length, equals(1));
  });

  test("PlateView.fromAll w/ single Plate maps fields", () {
    List<PlateView> views = PlateView.fromAll(
        [Plate("RO", "BY", "Rosenheim", "Stadt Rosenheim", "")],
        {"BY": "Bayern"});
    expect(views[0].name, equals("Rosenheim"));
    expect(views[0].region, equals("Stadt Rosenheim"));
    expect(views[0].state, equals("Bayern"));
  });

  test("PlateView.fromAll w/ single Plate w/o matching state, maps fields", () {
    List<PlateView> views = PlateView.fromAll(
        [Plate("RO", "BY", "Rosenheim", "Stadt Rosenheim", "")], {});
    expect(views[0].name, equals("Rosenheim"));
    expect(views[0].region, equals("Stadt Rosenheim"));
    expect(views[0].state, equals(""));
  });

  test(
      "PlateView.fromAll combines fields for plates with same id and same origin",
      () {
    List<PlateView> views = PlateView.fromAll([
      Plate("RO", "BY", "Rosenheim", "Stadt Rosenheim", ""),
      Plate("RO", "BY", "Rosenheim", "Landkreis Rosenheim", "")
    ], {
      "BY": "Bayern"
    });
    expect(views.length, equals(1));
    expect(views[0].name, equals("Rosenheim"));
    expect(views[0].region, equals("Stadt Rosenheim, Landkreis Rosenheim"));
    expect(views[0].state, equals("Bayern"));
  });

  test(
      "PlateView.fromAll combines fields for plates with same id and different origin",
      () {
    List<PlateView> views = PlateView.fromAll([
      Plate("RO", "BY", "Rosenheim", "Stadt Rosenheim", ""),
      Plate("RO", "BY", "Rosenheim", "Landkreis Rosenheim", ""),
      Plate("RO", "MV", "Rostocksdorf", "Kreis Rostock", "")
    ], {
      "BY": "Bayern",
      "MV": "Mecklenburg-Vorpommern"
    });
    expect(views.length, equals(2));
    expect(views[0].name, equals("Rosenheim"));
    expect(views[0].region, equals("Stadt Rosenheim, Landkreis Rosenheim"));
    expect(views[0].state, equals("Bayern"));

    expect(views[1].name, equals("Rostocksdorf"));
    expect(views[1].region, equals("Kreis Rostock"));
    expect(views[1].state, equals("Mecklenburg-Vorpommern"));
  });

  test(
      "PlateView.fromAll combines fields for plates with same id and same state and different origin",
      () {
    List<PlateView> views = PlateView.fromAll([
      Plate("RO", "BY", "Rosenheim", "Stadt Rosenheim", ""),
      Plate("RO", "BY", "Rosenheim", "Landkreis Rosenheim", ""),
      Plate("RO", "MV", "Rosenheim", "Kreis Rostock", "")
    ], {
      "BY": "Bayern",
      "MV": "Mecklenburg-Vorpommern"
    });
    expect(views.length, equals(1));
    expect(views[0].name, equals("Rosenheim"));
    expect(views[0].region,
        equals("Stadt Rosenheim, Landkreis Rosenheim, Kreis Rostock"));
    expect(views[0].state, equals("Bayern, Mecklenburg-Vorpommern"));
  });
}
