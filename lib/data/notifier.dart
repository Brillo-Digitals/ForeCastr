import 'package:flutter/material.dart';

ValueNotifier<AssetImage> bgImage = ValueNotifier(
  AssetImage("assets/images/sunny_bg.jpeg"),
);
ValueNotifier<AssetImage> bgIllustrator = ValueNotifier(
  AssetImage("assets/images/clear_illustration.png"),
);
ValueNotifier<AssetImage> searchBgImage = ValueNotifier(
  AssetImage("assets/images/sunny_bg.jpeg"),
);
ValueNotifier<AssetImage> searchBgIllustrator = ValueNotifier(
  AssetImage("assets/images/clear_illustration.png"),
);
ValueNotifier<bool> istransparentColorDark = ValueNotifier(true);
ValueNotifier<bool> isSearchTransparentColorDark = ValueNotifier(true);
ValueNotifier<bool> isFarheit = ValueNotifier(false);
ValueNotifier<bool> isLocationPermissionGiven = ValueNotifier(true);
ValueNotifier<bool> isLocationGotten = ValueNotifier(true);
ValueNotifier<String> cityName = ValueNotifier("Unknown");
ValueNotifier<int> currentPage = ValueNotifier(1);
ValueNotifier<List<String>> recentSearchList = ValueNotifier([
  "Rome",
  "Berlin",
  "Mumbai",
]);
ValueNotifier<double> latitudeNotifier = ValueNotifier(0.0);
ValueNotifier<double> longitudeNotifier = ValueNotifier(0.0);
ValueNotifier<List> expandingList = ValueNotifier(
  List.generate(7, (_) => false),
);
ValueNotifier<Map<String, dynamic>> weatherDataNotifier = ValueNotifier({});
ValueNotifier<Map<String, dynamic>> searchWeatherDataNotifier = ValueNotifier(
  {},
);
