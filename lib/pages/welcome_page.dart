import 'package:flutter/material.dart';
import 'package:forecastr/data/constant.dart';
import 'package:forecastr/data/location.dart';
import 'package:forecastr/data/notifier.dart';
import 'package:forecastr/pages/nav_page.dart';
import 'package:geolocator/geolocator.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String pagetext = "Detecting your location...";
  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final position = await getCurrentLocation();
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        setState(() => pagetext = "Permission granted");

        if (position != null) {
          isLocationPermissionGiven.value = true;
          longitudeNotifier.value = position.longitude;
          latitudeNotifier.value = position.latitude;

          final results = await Future.wait([
            getCityName(position.latitude, position.longitude),
            getWeatherJson(position.latitude, position.longitude),
          ]);

          final fetchedCity = results[0] as String?;
          final fetchedWeather = results[1] as Map<String, dynamic>;

          if (fetchedCity == null) {
            // no internet
            setState(() => pagetext = "No internet, using default data...");
            isLocationGotten.value = false;
            weatherDataNotifier.value = getDefaultWeatherJson();
          } else {
            cityName.value = fetchedCity;
            weatherDataNotifier.value = fetchedWeather;
            getBackGrounds(CurrentWeather().code);
          }
        } else {
          // Permission given but position came back null (e.g. GPS timeout)
          isLocationPermissionGiven.value = false;
          weatherDataNotifier.value = getDefaultWeatherJson();
        }
      } else {
        isLocationPermissionGiven.value = false;
        setState(() => pagetext = "Permission not granted");
        weatherDataNotifier.value = getDefaultWeatherJson();
      }
    } catch (e) {
      debugPrint("WelcomePage error: $e");
      isLocationPermissionGiven.value = false;
      weatherDataNotifier.value = getDefaultWeatherJson();
    } finally {
      goToNavPage();
    }
  }

  void goToNavPage() {
    if (!mounted) return; // ✅ Avoid navigating on a disposed widget
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NavPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: kBgDecoration,
        child: Column(
          children: [
            Expanded(
              flex: 12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(255, 255, 255, .1),
                      ),
                      child: Image(
                        image: AssetImage("assets/images/logo_no_bg.png"),
                        opacity: AlwaysStoppedAnimation(.8),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  typeWrite(
                    "Welcome to ForeCastr",
                    TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: kWhiteTextTransparent,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: wavyTexts(
                  pagetext,
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: kWhiteTextTransparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
