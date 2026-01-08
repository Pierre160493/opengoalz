import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

ThemeData getTheme(BuildContext context, bool isDark) {
  // Get the screen width
  double screenWidth = MediaQuery.of(context).size.width;

  // Use ScreenUtil for responsive scaling
  double screenMultiplier = 1.0; // Not needed anymore, kept for compatibility

  // Determine which text theme to use based on screen width
  TextTheme textTheme = getTextTheme(isDark);

  // Base theme, light or dark
  final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

  // Apply the custom text theme
  return baseTheme.copyWith(
    textTheme: textTheme,
  );
}

// Function to generate TextTheme using ScreenUtil
TextTheme getTextTheme(bool isDark) {
  // Define the default text color based on the theme
  Color defaultTextColor = isDark ? Colors.white : Colors.black;

  /// Set the font sizes using ScreenUtil
  return TextTheme(
    displayLarge: TextStyle(fontSize: 96.sp, color: defaultTextColor),
    displayMedium: TextStyle(fontSize: 60.sp, color: defaultTextColor),
    displaySmall: TextStyle(fontSize: 48.sp, color: defaultTextColor),
    headlineLarge: TextStyle(fontSize: 48.sp, color: defaultTextColor),
    headlineMedium: TextStyle(fontSize: 34.sp, color: defaultTextColor),
    headlineSmall: TextStyle(fontSize: 24.sp, color: defaultTextColor),
    titleLarge: TextStyle(fontSize: 20.sp, color: defaultTextColor),
    titleMedium: TextStyle(fontSize: 16.sp, color: defaultTextColor),
    titleSmall: TextStyle(fontSize: 14.sp, color: defaultTextColor),
    bodySmall: TextStyle(fontSize: 12.sp, color: defaultTextColor),
    bodyMedium: TextStyle(fontSize: 14.sp, color: defaultTextColor),
    bodyLarge: TextStyle(fontSize: 16.sp, color: defaultTextColor),
    labelSmall: TextStyle(fontSize: 10.sp, color: defaultTextColor),
    labelMedium: TextStyle(fontSize: 12.sp, color: defaultTextColor),
    labelLarge: TextStyle(fontSize: 14.sp, color: defaultTextColor),
  );
}
