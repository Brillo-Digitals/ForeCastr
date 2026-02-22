import 'package:flutter/material.dart';
import 'package:forecastr/data/constant.dart';
import 'package:forecastr/data/location.dart';

class HourForecastWidget extends StatefulWidget {
  const HourForecastWidget({super.key, required this.hourIndex});
  final int hourIndex;

  @override
  State<HourForecastWidget> createState() => _HourForecastWidgetState();
}

class _HourForecastWidgetState extends State<HourForecastWidget> {
  final List<GlobalKey> hourKeys = List.generate(24, (_) => GlobalKey());

  void scrollToHour(int index) {
    if (widget.hourIndex == 0) {
      Scrollable.ensureVisible(
        hourKeys[index].currentContext!,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.5, // centers the item
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToHour(HourlyWeather(widget.hourIndex).getCurrentHourIndex());
    });
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            List.generate(24, (index) {
                  return Column(
                    key: hourKeys[index],
                    children: [
                      Text(
                        "${HourlyWeather(widget.hourIndex).getTimes()[index]} :",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          getWeatherIcon(
                            HourlyWeather(widget.hourIndex).getCodes()[index],
                            HourlyWeather(widget.hourIndex).isNightTime(index),
                          ),
                          SizedBox(width: 5),
                          Text(
                            getTempValue(
                              HourlyWeather(
                                widget.hourIndex,
                              ).getTemps()[index].round(),
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
                      margin: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                      color: Colors.white54,
                      width: 1,
                      height: 50,
                    ),
                  ],
                )
                .toList()
              ..removeLast(),
      ),
    );
  }
}
