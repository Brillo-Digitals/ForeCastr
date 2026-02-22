import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forecastr/data/json_file.dart';
import 'package:forecastr/data/notifier.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Map get data => weatherDataNotifier.value;

Map get hourly => data['hourly'];
Map get daily => data['daily'];
Map get current => data['current'];
const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class CurrentWeather {
  int get temp => current['temperature_2m'].round();
  int get feelsLikeTemp => current['apparent_temperature'].round();
  final currentTime = data['current']['time'];
  int get humidity => current['relativehumidity_2m'];
  double get windSpeed => current['windspeed_10m'].toDouble();
  int get code => current['weathercode'];
}

bool isNowNightTime() {
  final now = DateTime.now();

  final start = DateTime.parse(DailyWeather().getSunRise()[0]);
  final end = DateTime.parse(DailyWeather().getSunSet()[0]);

  final isBetween = now.isAfter(start) && now.isBefore(end);

  return !isBetween;
}

class HourlyWeather {
  final int index;
  HourlyWeather(this.index);

  List getTimes() {
    int i = index * 24;
    int j = (index * 24) + 24;
    List normalTimeList = [];
    final List times = hourly['time'].sublist(i, j);
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
    for (var time in timeList) {
      if (time.substring(0, 2) == now.hour.toString().padLeft(2, '0')) {
        return timeList.indexOf(time);
      }
    }
    return 0;
  }

  List getTemps() {
    int i = index * 24;
    int j = (index * 24) + 24;
    final List temps = hourly['temperature_2m'].sublist(i, j);
    return temps;
  }

  List getCodes() {
    int i = index * 24;
    int j = (index * 24) + 24;
    final List codes = hourly['weathercode'].sublist(i, j);
    // final now = DateTime.now();
    // List timeList = getTimes();
    // int currentHourIndex = timeList.indexOf(
    //   "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
    // );

    // if (index == 0) {
    //   List firstList = codes.sublist(currentHourIndex + 1, codes.length);
    //   List secondList = codes.sublist(0, currentHourIndex + 1);
    //   var l;
    //   for (l in secondList) {
    //     firstList.add(l);
    //   }
    //   return firstList;
    // }
    return codes;
  }

  bool isNightTime(int hourIndex) {
    int j = (index * 24) + hourIndex;
    final String time = hourly['time'][j];
    final DateTime dt = DateTime.parse(time);

    final start = DateTime.parse(DailyWeather().getSunRise()[index]);
    final end = DateTime.parse(DailyWeather().getSunSet()[index]);

    final isBetween = dt.isAfter(start) && dt.isBefore(end);

    return !isBetween;
  }
}

class DailyWeather {
  final daily = data['daily'];
  List getTimes() {
    final times = List<String>.from(daily['time']);
    return times;
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
    for (int i = 0; i < times.length; i++) {
      DateTime dt = DateTime.parse(times[i]);
      dayList.add(i == 0 ? "Today" : days[dt.weekday - 1]);
    }
    return dayList;
  }

  String getDay(int index) {
    return getDays()[index];
  }

  List getMinTemps() {
    final List minTemps = daily['temperature_2m_min'];
    return minTemps;
  }

  List getMaxTemps() {
    final List maxTemps = daily['temperature_2m_max'];
    return maxTemps;
  }

  List getCodes() {
    final List codes = daily['weathercode'];
    return codes;
  }

  List getSunRise() {
    final List time = daily['sunrise'];
    return time;
  }

  List getSunSet() {
    final List time = daily['sunset'];
    return time;
  }
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

  if (isNighttime == true) {
    istransparentColorDark.value = true;
  } else {
    istransparentColorDark.value = false;
  }

  if (code == 0) {
    isNighttime
        ? bgImage.value = AssetImage("assets/images/night_bg.jpeg")
        : bgImage.value = AssetImage("assets/images/sunny_bg.jpeg");
    isNighttime
        ? bgIllustrator.value = AssetImage(
            "assets/images/clear_night_illustration.png",
          )
        : bgIllustrator.value = AssetImage(
            "assets/images/clear_illustration.png",
          );
  } else if (code == 1 || code == 2 || code == 3) {
    isNighttime
        ? bgImage.value = AssetImage("assets/images/night_bg.jpeg")
        : bgImage.value = AssetImage("assets/images/cloudy_bg.jpeg");
    isNighttime
        ? bgIllustrator.value = AssetImage(
            "assets/images/cloudy_night_illustration.png",
          )
        : bgIllustrator.value = AssetImage(
            "assets/images/cloudy_illustration.png",
          );
  } else if (code == 45 || code == 48) {
    isNighttime
        ? bgImage.value = AssetImage("assets/images/night_bg.jpeg")
        : bgImage.value = AssetImage("assets/images/foggy_bg.jpg");
    bgIllustrator.value = AssetImage("assets/images/foggy_illustration.png");
  } else if (code == 51 ||
      code == 53 ||
      code == 55 ||
      code == 56 ||
      code == 57) {
    bgImage.value = AssetImage("assets/images/rainy_bg.jpg");
    bgIllustrator.value = AssetImage("assets/images/rainy_illustration.png");
  } else if (code == 61 ||
      code == 63 ||
      code == 65 ||
      code == 66 ||
      code == 67 ||
      code == 80 ||
      code == 81 ||
      code == 82) {
    bgImage.value = AssetImage("assets/images/rainy_bg.jpg");
    bgIllustrator.value = AssetImage("assets/images/rainy_illustration.png");
  } else if (code == 71 ||
      code == 73 ||
      code == 75 ||
      code == 77 ||
      code == 85 ||
      code == 86) {
    isNighttime
        ? bgImage.value = AssetImage("assets/images/night_bg.jpeg")
        : bgImage.value = AssetImage("assets/images/snowy_bg.jpg");
    bgIllustrator.value = AssetImage("assets/images/snowy_illustration.png");
  } else if (code == 95 || code == 96 || code == 99) {
    bgImage.value = AssetImage("assets/images/thunder_bg.png");
    bgIllustrator.value = AssetImage("assets/images/thunder_illustration.png");
  } else {
    isNighttime
        ? bgImage.value = AssetImage("assets/images/night_bg.jpeg")
        : bgImage.value = AssetImage("assets/images/sunny_bg.png");
    isNighttime
        ? bgIllustrator.value = AssetImage(
            "assets/images/clear_night_illustration.png",
          )
        : bgIllustrator.value = AssetImage(
            "assets/images/clear_illustration.png",
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

Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 1. Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled');
  }

  // 2. Check permission
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      isLocationPermissionGiven.value = false;
      // throw Exception('Location permission denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    isLocationPermissionGiven.value = false;
    // throw Exception('Location permission permanently denied');
  }

  // 3. Get location
  try {
    isLocationGotten.value = true;
    print("az");
    Position p = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );
    print(p);
    return p;
  } catch (e) {
    print("ay");
    isLocationGotten.value = false;
    return null;
  }
}

Future<String?> getCityName(double lat, double lon) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse'
    '?format=json'
    '&lat=$lat'
    '&lon=$lon'
    '&addressdetails=1',
  );
  try {
    final response = await http.get(
      url,
      headers: {'User-Agent': 'your_app_name_here'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final address = data['address'];
      String addr;
      if (address != null) {
        addr =
            address['suburb'] ??
            address['county'] ??
            address['state'] ??
            'Unknown Location';
      } else {
        addr = "Unknown Location";
      }

      return addr;
    } else {
      return "Unknown Location";
    }
  } catch (e) {
    return null;
  }
}

Future<Map<String, dynamic>> getWeatherJson(double lat, double lon) async {
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

    return jsonDecode(response.body);
  } catch (e) {
    isLocationGotten.value = false;
    return getDefaultWeatherJson();
  }
}

//Handle permission
Future<void> loadLocation() async {
  final position = await getCurrentLocation();

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) {
    if (position != null) {
      isLocationPermissionGiven.value = true;
      longitudeNotifier.value = position.longitude;
      latitudeNotifier.value = position.latitude;
      final results = await Future.wait([
        getCityName(position.latitude, position.longitude),
        getWeatherJson(position.latitude, position.longitude),
      ]);

      cityName.value = results[0] as String;
      weatherDataNotifier.value = results[1] as Map<String, dynamic>;
      getBackGrounds(CurrentWeather().code);
    }
  } else {
    isLocationPermissionGiven.value = false;
    weatherDataNotifier.value = getDefaultWeatherJson();
  }
}

Map<String, dynamic> getDefaultWeatherJson() {
  return jsonDecode(defaultJsonData);
}
