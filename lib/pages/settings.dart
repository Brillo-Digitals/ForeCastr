import 'package:flutter/material.dart';
import 'package:forecastr/data/constant.dart';
import 'package:forecastr/data/json_file.dart';
import 'package:forecastr/data/notifier.dart';
import 'package:forecastr/data/search_location.dart';
import 'package:forecastr/pages/search_page.dart';
import 'package:forecastr/pages/socials.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController searchController = TextEditingController();

  int currentTemperature = 0;

  Map cityMap = cities;
  List cityList = [];
  List cityTempList = [];

  @override
  void initState() {
    super.initState();
    _loadTempSign();
    _loadCityMap();
  }

  void readRecentList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    recentSearchList.value =
        prefs.getStringList('recentCity') ?? ["Rome", "Berlin", "Mumbai"];
  }

  void _loadCityMap() {
    cityList = cityMap.keys.toList();
  }

  void _loadTempSign() {
    if (isFarheit.value == true) {
      currentTemperature = 1;
    } else {
      currentTemperature = 0;
    }
  }

  Future<void> _searchCityByIndex(int index) async {
    final cityName = cityTempList[index];
    final lat = cities[cityName]?["lat"];
    final lon = cities[cityName]?["lon"];
    setState(() {
      changeRecentSearch(cityName);
    });

    _searchCity(lat, lon, cityName);
  }

  Future<void> _searchCityByName(String name) async {
    final cityName = name;
    final lat = cities[cityName]?["lat"];
    final lon = cities[cityName]?["lon"];

    _searchCity(lat, lon, cityName);
  }

  Future<void> _searchCity(double? lat, double? lon, String cityName) async {
    if (lat == null || lon == null) return;

    _removeOverlay();

    try {
      final weather = await getSearchedWeatherJson(lat, lon);
      if (weather == null) {
        // ✅ show "No internet or failed to load" to user
        return;
      }
      searchWeatherDataNotifier.value = weather;
      getBackGrounds(SearchCurrentWeather().code);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage(city: cityName)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load weather data')));
      }
    }
    searchController.text = '';
  }

  void changeRecentSearch(String lastCity) async {
    final List<String> currentList = List<String>.from(recentSearchList.value);

    // Remove if already exists to avoid duplicates and move to top
    currentList.remove(lastCity);

    // Insert at the beginning
    currentList.insert(0, lastCity);

    // Keep only the last 3 searches
    if (currentList.length > 3) {
      currentList.removeRange(3, currentList.length);
    }

    recentSearchList.value = currentList; // This triggers ValueNotifier

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentCity', currentList);
  }

  void _showOverlay(int no) {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: MediaQuery.of(context).size.width - 100,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: const Offset(40, 56), // height of TextField
            showWhenUnlinked: false,
            child: Material(
              color: Colors.transparent,
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children:
                        List.generate(
                              no,
                              (index) => GestureDetector(
                                onTap: () => _searchCityByIndex(index),
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(cityTempList[index]),
                                ),
                              ),
                            )
                            .expand((element) => [element, SizedBox(height: 2)])
                            .toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    searchController.dispose();
    super.dispose();
  }

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Search",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20),
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          List tempList;
                          tempList = cityList
                              .where(
                                (city) => city.toLowerCase().startsWith(
                                  value.toLowerCase(),
                                ),
                              )
                              .toList();
                          cityTempList = tempList;
                          if (value.isNotEmpty) {
                            _showOverlay(cityTempList.length);
                          } else {
                            _removeOverlay();
                          }
                        });
                      },
                      controller: searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(style: BorderStyle.none),
                        ),
                        icon: Icon(Icons.search, color: Colors.white),
                        hintText: "Enter City Name",
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                      autofocus: true,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Recent Searches: ", style: kBoldTextStyle),
                  SizedBox(height: 10),
                  ValueListenableBuilder<List<String>>(
                    valueListenable: recentSearchList,
                    builder: (context, recentList, _) {
                      return Row(
                        children: List.generate(recentList.length, (index) {
                          return Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () =>
                                    _searchCityByName(recentList[index]),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                  decoration: kroundedBoxDecoration,
                                  child: Center(
                                    child: Text(
                                      recentList[index],
                                      style: kNormalTextStyle.copyWith(
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 200),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 70,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: ksettingsDecoration,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Temperature Unit",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            RadioGroup<int>(
                              groupValue: currentTemperature,
                              onChanged: (value) {
                                setState(() {
                                  currentTemperature = value!;
                                  if (currentTemperature == 0) {
                                    isFarheit.value = false;
                                  } else {
                                    isFarheit.value = true;
                                  }
                                  currentPage.value = 1;
                                });
                              },
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Radio(
                                          value: 0,
                                          activeColor: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        '\u00B0C',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Radio(
                                          value: 1,
                                          activeColor: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        '\u00B0F',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: ksettingsDecoration.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Developed by",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Uthman Adesiyan Adeolu",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Brillo Digitals",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Divider(height: 30, thickness: 0.5),
                        _buildContactRow(
                          Icons.phone_android,
                          "+234 8146269699",
                        ),
                        SizedBox(height: 10),
                        _buildContactRow(
                          Icons.email_outlined,
                          "uthmanadesiyan112@gmail.com",
                        ),
                        SizedBox(height: 20),
                        SocialButtons(
                          isOneColor: true,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        // Handle permissions settings tap
                      });
                    },
                    child: Container(
                      height: 70,
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: ksettingsDecoration,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Permissions",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Text("Location Access"),
                              SizedBox(width: 10),
                              Icon(Icons.check_circle, color: Colors.green),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
