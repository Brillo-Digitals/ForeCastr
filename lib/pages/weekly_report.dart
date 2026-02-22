import 'package:flutter/material.dart';
import 'package:forecastr/data/constant.dart';
import 'package:forecastr/data/location.dart';
import 'package:forecastr/data/notifier.dart';
import 'package:forecastr/data/widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WeeklyReportPage extends StatefulWidget {
  const WeeklyReportPage({super.key});

  @override
  State<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends State<WeeklyReportPage>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      7,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 700),
        vsync: this,
      ),
    );

    // ✅ Listen to notifiers so UI rebuilds when data changes
    isLocationPermissionGiven.addListener(_onDataChanged);
    weatherDataNotifier.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    isLocationPermissionGiven.removeListener(_onDataChanged);
    weatherDataNotifier.removeListener(_onDataChanged);
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

  void _toggleExpand(int index) {
    setState(() {
      // ✅ Replace list entirely so ValueNotifier fires correctly
      final updated = List<bool>.from(expandingList.value);
      for (int i = 0; i < updated.length; i++) {
        if (i == index) {
          updated[i] = !updated[i];
          updated[i]
              ? _animationControllers[i].forward()
              : _animationControllers[i].reverse();
        } else {
          updated[i] = false;
          _animationControllers[i].reverse();
        }
      }
      expandingList.value = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLocationPermissionGiven.value == true
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
                      vertical: 10,
                      horizontal: 25,
                    ),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Center(
                              child: Text(
                                "Weekly Forecast",
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Divider(color: Colors.white54, thickness: 1),
                          ],
                        ),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SingleChildScrollView(
                            child: Skeletonizer(
                              enabled: isLoading,
                              enableSwitchAnimation: true,
                              child: Column(
                                children:
                                    List.generate(7, (index) {
                                          return GestureDetector(
                                            onTap: () => _toggleExpand(index),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 25,
                                              ),
                                              decoration: kroundedBoxDecoration,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            DailyWeather()
                                                                .getDay(index),
                                                            style:
                                                                kNormalTextStyle,
                                                          ),
                                                          SizedBox(width: 10),
                                                          getWeatherIcon(
                                                            DailyWeather()
                                                                .getCodes()[index],
                                                            false,
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Text(
                                                            "Max : ${getTempValue(DailyWeather().getMaxTemps()[index].round())}",
                                                            style:
                                                                kNormalTextStyle,
                                                          ),
                                                          Text(
                                                            "Min: ${getTempValue(DailyWeather().getMinTemps()[index].round())}",
                                                            style:
                                                                kNormalTextStyle,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizeTransition(
                                                    sizeFactor: CurvedAnimation(
                                                      parent:
                                                          _animationControllers[index],
                                                      curve:
                                                          Curves.easeInOutCubic,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Divider(
                                                          color: Colors.white54,
                                                          thickness: 1,
                                                        ),
                                                        HourForecastWidget(
                                                          hourIndex: index,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        })
                                        .expand(
                                          (element) => [
                                            element,
                                            SizedBox(height: 15),
                                          ],
                                        )
                                        .toList()
                                      ..removeLast(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
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
                child: Text("Grant Location Permission"),
              ),
            ),
    );
  }
}
