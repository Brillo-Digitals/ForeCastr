import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:forecastr/data/notifier.dart';

Color kBgColor = Color.fromRGBO(170, 200, 216, 1);
Color kNavColor = Colors.white;
BoxDecoration kBgDecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [
      Color.fromRGBO(170, 200, 216, 1),
      Color.fromRGBO(155, 158, 191, 1),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
);
Color kWhiteTextTransparent = Color.fromRGBO(255, 255, 255, .7);
Color kWhiteTransparent = istransparentColorDark.value == true
    ? Color.fromRGBO(255, 255, 255, 0.2)
    : Color.fromRGBO(65, 65, 65, 0.1);

TextStyle kNormalTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 14,
  fontWeight: FontWeight.w500,
);
TextStyle kBoldTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

int calcTemp(int celcius) {
  int farheit = ((celcius * 9 / 5) + 32).round();
  if (isFarheit.value == true) {
    return farheit;
  } else {
    return celcius;
  }
}

String tempSign() {
  if (isFarheit.value == true) {
    return "\u00B0F";
  } else {
    return "\u00B0C";
  }
}

String getTempValue(int celcius) {
  return "${calcTemp(celcius)}${tempSign()}";
}

BoxDecoration kroundedBoxDecoration = BoxDecoration(
  color: kWhiteTransparent,
  borderRadius: BorderRadius.circular(20),
);

BoxDecoration ksettingsDecoration = BoxDecoration(
  color: Colors.white70,
  borderRadius: BorderRadius.circular(20),
);

Container kweatherConditionContainer(String leading, String following) {
  return Container(
    decoration: kroundedBoxDecoration,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(leading, style: kNormalTextStyle),
          Text(following, style: kNormalTextStyle),
        ],
      ),
    ),
  );
}

DefaultTextStyle typeWrite(String text, TextStyle textStyle) {
  return DefaultTextStyle(
    style: textStyle,
    child: AnimatedTextKit(
      animatedTexts: [
        TyperAnimatedText(text, speed: Duration(milliseconds: 50)),
      ],
      isRepeatingAnimation: false,
    ),
  );
}

DefaultTextStyle wavyTexts(String text, TextStyle textStyle) {
  return DefaultTextStyle(
    style: textStyle,
    child: AnimatedTextKit(
      animatedTexts: [
        WavyAnimatedText(text, speed: Duration(milliseconds: 70)),
      ],
      isRepeatingAnimation: true,
    ),
  );
}
