import 'dart:ui';

import 'package:forecastr/data/location.dart';
import 'package:forecastr/data/notifier.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:forecastr/data/constant.dart';
import 'package:forecastr/data/widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLocationGotten.addListener(_onDataChanged);
    isLocationPermissionGiven.addListener(_onDataChanged);
    weatherDataNotifier.addListener(_onDataChanged);
    cityName.addListener(_onDataChanged);
    bgIllustrator.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    // ✅ Always remove listeners to avoid memory leaks
    isLocationGotten.removeListener(_onDataChanged);
    isLocationPermissionGiven.removeListener(_onDataChanged);
    weatherDataNotifier.removeListener(_onDataChanged);
    cityName.removeListener(_onDataChanged);
    bgIllustrator.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    setState(() => isLoading = true);
    await loadLocation();
    if (!mounted) return;
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Weather Updated", style: TextStyle(color: Colors.white)),
            SizedBox(width: 10),
            Icon(Icons.check_circle_outline, color: Colors.greenAccent),
          ],
        ),
        backgroundColor: kWhiteTransparent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _requestPermission() async {
    setState(() => isLoading = true);
    await loadLocation();
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return isLocationPermissionGiven.value == true
        ? RefreshIndicator(
            displacement: 20,
            edgeOffset: 0,
            color: Colors.white,
            backgroundColor: kWhiteTransparent,
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            onRefresh: _refresh,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 30,
                  ),
                  child: Skeletonizer(
                    textBoneBorderRadius: TextBoneBorderRadius.fromHeightFactor(
                      1,
                    ),
                    enabled: isLoading,
                    enableSwitchAnimation: true,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  calcTemp(CurrentWeather().temp).toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 120,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tempSign(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        getWeatherCondition(
                                          CurrentWeather().code,
                                        ),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          cityName.value,
                                          style: kNormalTextStyle,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            ClipOval(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  width: 320,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.elliptical(100, 80),
                                      topRight: Radius.elliptical(100, 80),
                                      bottomLeft: Radius.elliptical(200, 50),
                                      bottomRight: Radius.elliptical(200, 50),
                                    ),
                                    color: kWhiteTransparent,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Skeleton.ignore(
                                      child: Image(image: bgIllustrator.value),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: kweatherConditionContainer(
                                "Humidity :",
                                "${CurrentWeather().humidity}%",
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: kweatherConditionContainer(
                                "Wind",
                                "${CurrentWeather().windSpeed}Km/h",
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: kweatherConditionContainer(
                                "Feels like :",
                                getTempValue(CurrentWeather().feelsLikeTemp),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          decoration: kroundedBoxDecoration,
                          width: double.infinity,
                          child: Column(
                            children: [
                              Text(
                                "[${getWeatherCondition(DailyWeather().getCodes()[0])}] Maximum : ${getTempValue(DailyWeather().getMaxTemps()[0].round())} Minimum : ${getTempValue(DailyWeather().getMinTemps()[0].round())}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Divider(color: Colors.white54, thickness: 1),
                              HourForecastWidget(hourIndex: 0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: FilledButton(
              onPressed: _requestPermission,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Grant Location Permission", style: kBoldTextStyle),
            ),
          );
  }
}
