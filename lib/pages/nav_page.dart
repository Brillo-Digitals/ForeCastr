import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forecastr/data/constant.dart';
import 'package:forecastr/data/notifier.dart';
import 'package:forecastr/pages/home_page.dart';
import 'package:forecastr/pages/settings.dart';
import 'package:forecastr/pages/weekly_report.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  List<Widget>? pages;

  @override
  void initState() {
    super.initState();
    // Initialize pages immediately
    pages = [WeeklyReportPage(), HomePage(), SettingsPage()];
  }

  @override
  Widget build(BuildContext context) {
    // pages should always be initialized, but check just in case
    if (pages == null) {
      return Scaffold(
        body: Container(decoration: kBgDecoration, child: SizedBox.expand()),
      );
    }

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: kBgDecoration,
        child: Stack(
          children: [
            SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Image(image: bgImage.value, fit: BoxFit.cover),
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.3, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(currentPage.value),
                child: pages![currentPage.value],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: currentPage.value,
        backgroundColor: Colors.transparent,
        color: kWhiteTransparent,
        items: <Widget>[
          Icon(Icons.weekend_outlined, size: 30, color: kNavColor),
          Icon(CupertinoIcons.house, size: 30, color: kNavColor),
          Icon(
            Icons.settings_accessibility_outlined,
            size: 30,
            color: kNavColor,
          ),
        ],
        onTap: (index) {
          setState(() {
            currentPage.value = index;
          });
        },
      ),
    );
  }
}
