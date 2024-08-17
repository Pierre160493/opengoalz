import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

ThemeData getTheme(BuildContext context, bool isDark) {
  // Get the screen width
  double screenWidth = MediaQuery.of(context).size.width;

  // Get the multiplier based on the screen width
  // double multiplier = screenWidth > maxWidth ? 1.0 : screenWidth / maxWidth;
  double multiplier = screenWidth > maxWidth ? 1.0 : 0.75;

  // Determine which text theme to use based on screen width
  TextTheme textTheme = getTextTheme(multiplier);

  // Base theme, light or dark
  final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

  // Apply the custom text theme
  return baseTheme.copyWith(
    textTheme: textTheme,
  );
}

// Function to generate TextTheme with a size multiplier
TextTheme getTextTheme(double multiplier) {
  /// Modify the icons size based on the multiplier
  iconSizeSmall = 24 * multiplier;
  iconSizeMedium = 30 * multiplier;
  iconSizeLarge = 36 * multiplier;

  /// Set the font sizes based on the multiplier
  return TextTheme(
    displayLarge: TextStyle(fontSize: 96 * multiplier),
    displayMedium: TextStyle(fontSize: 60 * multiplier),
    displaySmall: TextStyle(fontSize: 48 * multiplier),
    headlineLarge: TextStyle(fontSize: 48 * multiplier),
    headlineMedium: TextStyle(fontSize: 34 * multiplier),
    headlineSmall: TextStyle(fontSize: 24 * multiplier),
    titleLarge: TextStyle(fontSize: 20 * multiplier),
    titleMedium: TextStyle(fontSize: 16 * multiplier),
    titleSmall: TextStyle(fontSize: 14 * multiplier),
    bodySmall: TextStyle(fontSize: 12 * multiplier),
    bodyMedium: TextStyle(fontSize: 14 * multiplier),
    bodyLarge: TextStyle(fontSize: 16 * multiplier),
    labelSmall: TextStyle(fontSize: 10 * multiplier),
    labelMedium: TextStyle(fontSize: 12 * multiplier),
    labelLarge: TextStyle(fontSize: 14 * multiplier),
  );
}
