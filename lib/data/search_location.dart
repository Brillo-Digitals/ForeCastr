import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forecastr/data/notifier.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// Lazy getters to avoid accessing null data on import
Map<String, dynamic> get data => searchWeatherDataNotifier.value;

Map<String, dynamic> get hourly => data['hourly'] ?? {};
Map<String, dynamic> get daily => data['daily'] ?? {};
Map<String, dynamic> get current => data['current'] ?? {};
const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class SearchCurrentWeather {
  int get temp => current['temperature_2m'].round() ?? 0;
  int get feelsLikeTemp => current['apparent_temperature'].round() ?? 0;
  String? get currentTime => current['time'] as String?;
  int get humidity => current['relativehumidity_2m'] ?? 0;
  double get windSpeed => current['windspeed_10m'].toDouble() ?? 0.0;
  int get code => current['weathercode'] ?? 0;
}

bool isNowNightTime() {
  try {
    final sunriseList = SearchDailyWeather().getSunRise();
    final sunsetList = SearchDailyWeather().getSunSet();
    if (sunriseList.isEmpty || sunsetList.isEmpty) return false;

    final now = DateTime.now();
    final start = DateTime.parse(sunriseList[0]);
    final end = DateTime.parse(sunsetList[0]);
    return !(now.isAfter(start) && now.isBefore(end));
  } catch (_) {
    return false;
  }
}

class SearchHourlyWeather {
  final int index;
  SearchHourlyWeather(this.index);

  Map<String, dynamic> get hourly => data['hourly'] ?? {};

  List getTimes() {
    int i = index * 24;
    int j = (index * 24) + 24;
    final rawTimes = hourly['time'] as List?;
    if (rawTimes == null || rawTimes.length < j) return []; // ✅ safe
    List normalTimeList = [];
    final List times = rawTimes.sublist(i, j);
    for (var time in times) {
      DateTime dt = DateTime.parse(time);
      String hour =
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      normalTimeList.add(hour);
    }
    return normalTimeList;
  }

  int getCurrentHourIndex() {
    final now = DateTime.now();
    List timeList = getTimes();
    for (int i = 0; i < timeList.length; i++) {
      if (timeList[i].substring(0, 2) == now.hour.toString().padLeft(2, '0')) {
        return i; // ✅ indexed loop, not .indexOf()
      }
    }
    return 0;
  }

  List getTemps() {
    int i = index * 24;
    int j = (index * 24) + 24;
    final rawTemps = hourly['temperature_2m'] as List?;
    if (rawTemps == null || rawTemps.length < j) return []; // ✅ safe
    return rawTemps.sublist(i, j);
  }

  List getCodes() {
    int i = index * 24;
    int j = (index * 24) + 24;
    final rawCodes = hourly['weathercode'] as List?;
    if (rawCodes == null || rawCodes.length < j) return []; // ✅ safe
    return rawCodes.sublist(i, j);
  }

  bool isNightTime(int hourIndex) {
    try {
      int j = (index * 24) + hourIndex;
      final rawTimes = hourly['time'] as List?;
      if (rawTimes == null || j >= rawTimes.length) return false; // ✅ safe
      final String time = rawTimes[j];
      final DateTime dt = DateTime.parse(time);

      final start = DateTime.parse(SearchDailyWeather().getSunRise()[index]);
      final end = DateTime.parse(SearchDailyWeather().getSunSet()[index]);

      return !(dt.isAfter(start) && dt.isBefore(end));
    } catch (_) {
      return false; // ✅ never crashes
    }
  }
}

class SearchDailyWeather {
  Map<String, dynamic> get daily => data['daily'] ?? {};

  List getTimes() {
    final times = daily['time'] as List?;
    if (times == null) return []; // ✅ safe
    return List<String>.from(times);
  }

  List getNormalTime() {
    List times = getTimes();
    List normalTimeList = [];
    for (var time in times) {
      DateTime dt = DateTime.parse(time);
      String day =
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      normalTimeList.add(day);
    }
    return normalTimeList;
  }

  List getDays() {
    List times = getTimes();
    List dayList = [];
    // ✅ Indexed loop instead of .indexOf() — O(1) per step, no duplicate issues
    for (int i = 0; i < times.length; i++) {
      DateTime dt = DateTime.parse(times[i]);
      dayList.add(i == 0 ? "Today" : days[dt.weekday - 1]);
    }
    return dayList;
  }

  String getDay(int index) {
    final d = getDays();
    if (index >= d.length) return ''; // ✅ safe
    return d[index];
  }

  List getMinTemps() => daily['temperature_2m_min'] as List? ?? [];
  List getMaxTemps() => daily['temperature_2m_max'] as List? ?? [];
  List getCodes() => daily['weathercode'] as List? ?? [];
  List getSunRise() => daily['sunrise'] as List? ?? [];
  List getSunSet() => daily['sunset'] as List? ?? [];
}

String getWeatherCondition(int code) {
  if (code == 0) {
    return "Clear";
  } else if (code == 1 || code == 2 || code == 3) {
    return "Cloudy";
  } else if (code == 45 || code == 48) {
    return "Fog";
  } else if (code == 51 ||
      code == 53 ||
      code == 55 ||
      code == 56 ||
      code == 57) {
    return "Drizzle";
  } else if (code == 61 ||
      code == 63 ||
      code == 65 ||
      code == 66 ||
      code == 67 ||
      code == 80 ||
      code == 81 ||
      code == 82) {
    return "Rain";
  } else if (code == 71 ||
      code == 73 ||
      code == 75 ||
      code == 77 ||
      code == 85 ||
      code == 86) {
    return "Snow";
  } else if (code == 95 || code == 96 || code == 99) {
    return "Thunderstorm";
  } else {
    return "Unknown";
  }
}

void getBackGrounds(int code) {
  bool isNighttime = isNowNightTime();
  isSearchTransparentColorDark.value = isNighttime;

  if (code == 0) {
    searchBgImage.value = AssetImage(
      isNighttime
          ? "assets/images/night_bg.jpeg"
          : "assets/images/sunny_bg.jpeg",
    );
    searchBgIllustrator.value = AssetImage(
      isNighttime
          ? "assets/images/clear_night_illustration.png"
          : "assets/images/clear_illustration.png",
    );
  } else if (code == 1 || code == 2 || code == 3) {
    searchBgImage.value = AssetImage(
      isNighttime
          ? "assets/images/night_bg.jpeg"
          : "assets/images/cloudy_bg.jpeg",
    );
    searchBgIllustrator.value = AssetImage(
      isNighttime
          ? "assets/images/cloudy_night_illustration.png"
          : "assets/images/cloudy_illustration.png",
    );
  } else if (code == 45 || code == 48) {
    searchBgImage.value = AssetImage(
      isNighttime
          ? "assets/images/night_bg.jpeg"
          : "assets/images/foggy_bg.jpg",
    );
    searchBgIllustrator.value = AssetImage(
      "assets/images/foggy_illustration.png",
    );
  } else if (code == 51 ||
      code == 53 ||
      code == 55 ||
      code == 56 ||
      code == 57) {
    searchBgImage.value = AssetImage("assets/images/rainy_bg.jpg");
    searchBgIllustrator.value = AssetImage(
      "assets/images/rainy_illustration.png",
    );
  } else if (code == 61 ||
      code == 63 ||
      code == 65 ||
      code == 66 ||
      code == 67 ||
      code == 80 ||
      code == 81 ||
      code == 82) {
    searchBgImage.value = AssetImage("assets/images/rainy_bg.jpg");
    searchBgIllustrator.value = AssetImage(
      "assets/images/rainy_illustration.png",
    );
  } else if (code == 71 ||
      code == 73 ||
      code == 75 ||
      code == 77 ||
      code == 85 ||
      code == 86) {
    searchBgImage.value = AssetImage(
      isNighttime
          ? "assets/images/night_bg.jpeg"
          : "assets/images/snowy_bg.jpg",
    );
    searchBgIllustrator.value = AssetImage(
      "assets/images/snowy_illustration.png",
    );
  } else if (code == 95 || code == 96 || code == 99) {
    searchBgImage.value = AssetImage("assets/images/thunder_bg.png");
    searchBgIllustrator.value = AssetImage(
      "assets/images/thunder_illustration.png",
    );
  } else {
    searchBgImage.value = AssetImage(
      isNighttime
          ? "assets/images/night_bg.jpeg"
          : "assets/images/sunny_bg.png",
    );
    searchBgIllustrator.value = AssetImage(
      isNighttime
          ? "assets/images/clear_night_illustration.png"
          : "assets/images/clear_illustration.png",
    );
  }
}

Icon getWeatherIcon(int code, bool isNightTime) {
  if (code == 0) {
    return isNightTime
        ? Icon(Icons.nightlight_round_outlined, color: Colors.white)
        : Icon(Icons.wb_sunny, color: Colors.yellowAccent);
  } else if (code == 1 || code == 2 || code == 3) {
    return isNightTime
        ? Icon(CupertinoIcons.cloud_moon_fill, color: Colors.white)
        : Icon(Icons.cloud, color: Colors.white);
  } else if (code == 45 || code == 48) {
    return Icon(Icons.foggy, color: Colors.white);
  } else if (code == 51 ||
      code == 53 ||
      code == 55 ||
      code == 56 ||
      code == 57) {
    return Icon(Icons.grain, color: Colors.white);
  } else if (code == 61 ||
      code == 63 ||
      code == 65 ||
      code == 66 ||
      code == 67 ||
      code == 80 ||
      code == 81 ||
      code == 82) {
    return Icon(Icons.grain, color: Colors.white);
  } else if (code == 71 ||
      code == 73 ||
      code == 75 ||
      code == 77 ||
      code == 85 ||
      code == 86) {
    return Icon(Icons.ac_unit, color: Colors.white);
  } else if (code == 95 || code == 96 || code == 99) {
    return Icon(Icons.flash_on, color: Colors.white);
  } else {
    return Icon(Icons.help_outline, color: Colors.white);
  }
}

Future<Position?> getSearchedCurrentLocation() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null; // ✅ returns null instead of throwing

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null; // ✅ returns null instead of throwing
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  } catch (e) {
    debugPrint('Search location error: $e');
    return null; // ✅ never crashes caller
  }
}

// ✅ Returns null on any failure — caller decides what to show
Future<Map<String, dynamic>?> getSearchedWeatherJson(
  double lat,
  double lon,
) async {
  final url = Uri.parse(
    'https://api.open-meteo.com/v1/forecast'
    '?latitude=$lat'
    '&longitude=$lon'
    '&current=temperature_2m,apparent_temperature,weathercode,'
    'windspeed_10m,relativehumidity_2m,uv_index,cloudcover'
    '&hourly=temperature_2m,apparent_temperature,weathercode,'
    'relativehumidity_2m,uv_index,cloudcover'
    '&daily=weathercode,temperature_2m_max,temperature_2m_min,'
    'uv_index_max,sunrise,sunset'
    '&forecast_days=7'
    '&timezone=auto',
  );
  try {
    final response = await http.get(url);
    if (response.statusCode != 200) return null; // ✅ bad response = null
    return jsonDecode(response.body) as Map<String, dynamic>;
  } catch (e) {
    debugPrint('Search weather fetch error: $e');
    return null; // ✅ network error = null
  }
}
