import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

ThemeData getTheme(BuildContext context, bool isDark) {
  // Get the screen width
  double screenWidth = MediaQuery.of(context).size.width;

  // Get the multiplier based on the screen width
  // double multiplier = screenWidth > maxWidth ? 1.0 : screenWidth / maxWidth;
  double multiplier = screenWidth > maxWidth ? 1.0 : 0.75;

  // Determine which text theme to use based on screen width
  TextTheme textTheme = getTextTheme(multiplier, isDark);

  // Base theme, light or dark
  final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

  // Apply the custom text theme
  return baseTheme.copyWith(
    textTheme: textTheme,
  );
}

// Function to generate TextTheme with a size multiplier
TextTheme getTextTheme(double multiplier, bool isDark) {
  // Define the default text color based on the theme
  Color defaultTextColor = isDark ? Colors.white : Colors.black;

  /// Modify the icons size based on the multiplier
  iconSizeSmall = 24 * multiplier;
  iconSizeMedium = 30 * multiplier;
  iconSizeLarge = 36 * multiplier;

  /// Set the font sizes based on the multiplier
  return TextTheme(
    displayLarge: TextStyle(fontSize: 96 * multiplier, color: defaultTextColor),
    displayMedium:
        TextStyle(fontSize: 60 * multiplier, color: defaultTextColor),
    displaySmall: TextStyle(fontSize: 48 * multiplier, color: defaultTextColor),
    headlineLarge:
        TextStyle(fontSize: 48 * multiplier, color: defaultTextColor),
    headlineMedium:
        TextStyle(fontSize: 34 * multiplier, color: defaultTextColor),
    headlineSmall:
        TextStyle(fontSize: 24 * multiplier, color: defaultTextColor),
    titleLarge: TextStyle(fontSize: 20 * multiplier, color: defaultTextColor),
    titleMedium: TextStyle(fontSize: 16 * multiplier, color: defaultTextColor),
    titleSmall: TextStyle(fontSize: 14 * multiplier, color: defaultTextColor),
    bodySmall: TextStyle(fontSize: 12 * multiplier, color: defaultTextColor),
    bodyMedium: TextStyle(fontSize: 14 * multiplier, color: defaultTextColor),
    bodyLarge: TextStyle(fontSize: 16 * multiplier, color: defaultTextColor),
    labelSmall: TextStyle(fontSize: 10 * multiplier, color: defaultTextColor),
    labelMedium: TextStyle(fontSize: 12 * multiplier, color: defaultTextColor),
    labelLarge: TextStyle(fontSize: 14 * multiplier, color: defaultTextColor),
  );
}
