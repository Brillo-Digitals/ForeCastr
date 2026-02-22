import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forecastr/data/constant.dart';
import 'package:forecastr/data/notifier.dart';
import 'package:forecastr/data/search_location.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.city});
  final String city;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    getBackGrounds(SearchCurrentWeather().code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: kWhiteTransparent,
        title: Row(
          children: [
            Icon(Icons.location_on_outlined, color: Colors.white),
            SizedBox(width: 5),
            Text(
              "Search Result",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image(image: searchBgImage.value, fit: BoxFit.cover),
          ),
          RefreshIndicator(
            displacement: 20,
            edgeOffset: 0,
            color: Colors.white,
            backgroundColor: kWhiteTransparent,
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            onRefresh: () async {
              setState(() {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Weather Updated",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.greenAccent,
                        ),
                      ],
                    ),
                    backgroundColor: kWhiteTransparent,
                    duration: Duration(seconds: 2),
                  ),
                );
              });
            },
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 60, 30, 20),
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
                                  calcTemp(
                                    SearchCurrentWeather().temp,
                                  ).toString(),
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
                                          SearchCurrentWeather().code,
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
                                          widget.city,
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
                                      child: Image(
                                        image: searchBgIllustrator.value,
                                      ),
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
                                "${SearchCurrentWeather().humidity}%",
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: kweatherConditionContainer(
                                "Wind",
                                "${SearchCurrentWeather().windSpeed}Km/h",
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: kweatherConditionContainer(
                                "Feels like :",
                                getTempValue(
                                  SearchCurrentWeather().feelsLikeTemp,
                                ),
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
                                "[${getWeatherCondition(SearchDailyWeather().getCodes()[0])}] Maximum : ${getTempValue(SearchDailyWeather().getMaxTemps()[0].round())} Minimum : ${getTempValue(SearchDailyWeather().getMinTemps()[0].round())}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Divider(color: Colors.white54, thickness: 1),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      List.generate(24, (index) {
                                            return Column(
                                              children: [
                                                Text(
                                                  "${SearchHourlyWeather(0).getTimes()[index]} :",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    getWeatherIcon(
                                                      SearchHourlyWeather(
                                                        0,
                                                      ).getCodes()[index],
                                                      SearchHourlyWeather(
                                                        0,
                                                      ).isNightTime(index),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      getTempValue(
                                                        SearchHourlyWeather(0)
                                                            .getTemps()[index]
                                                            .round(),
                                                      ),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          })
                                          .expand(
                                            (element) => [
                                              element,
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                  vertical: 1,
                                                  horizontal: 10,
                                                ),
                                                color: Colors.white54,
                                                width: 1,
                                                height: 50,
                                              ),
                                            ],
                                          )
                                          .toList()
                                        ..removeLast(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
