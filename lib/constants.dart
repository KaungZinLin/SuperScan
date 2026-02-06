import 'package:flutter/material.dart';

const double kDesktopBreakpoint = 600;

const TextStyle kNavigationBarLabelStyle = TextStyle(letterSpacing: 0.0);

const Color kAccentColor = Color(0xFF00c8ff);

const kTextLetterSpacing =  TextStyle(
    letterSpacing: 0.0);

final ThemeData kLightThemeData = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kAccentColor,
    brightness: Brightness.light,
  ),
);

final ThemeData kDarkThemeData = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    // Changed color theme for dark mode
    seedColor: kAccentColor,
    brightness: Brightness.dark,
  ),
);