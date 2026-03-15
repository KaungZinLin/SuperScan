import 'package:flutter/material.dart';

const double kDesktopBreakpoint = 600;

const TextStyle kNavigationBarLabelStyle = TextStyle(letterSpacing: 0.0);

const Color kAccentColor = Color(0xFF3396D3);

const String kPrivacyPolicyUrl = 'https://zennon-devhouse.blogspot.com/2026/03/privacy-policy-superscan.html';

const String kTermsAndConditionsUrl = 'https://zennon-devhouse.blogspot.com/2026/03/terms-of-use.html';

const String kKbzPayDonationMethodUrl = 'https://zennon-devhouse.blogspot.com/2026/03/donate-via-kbzpay-superscan.html';

const String kOpenAIApiKeyStorageName = 'openai_api_key';

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
