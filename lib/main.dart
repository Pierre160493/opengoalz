import 'package:flutter/material.dart';
import 'package:opengoalz/app_theme.dart';
import 'package:opengoalz/provider_theme_app.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:opengoalz/pages/splash_page.dart';
import 'package:opengoalz/config/supabase_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure WidgetsBinding is initialized

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseKey,
  );

  final version = await _readVersion();

  runApp(ChangeNotifierProvider.value(
    value: UserSessionProvider(),
    child: MyApp(version: version),
  ));
}

Future<String> _readVersion() async {
  try {
    final file = File('version.txt');
    return await file.readAsString();
  } catch (e) {
    return 'Unknown';
  }
}

class MyApp extends StatelessWidget {
  final String version;

  MyApp({required this.version});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ScreenUtilInit(
            designSize: Size(393, 852), // Samsung Galaxy S23 logical size
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: getTheme(context, themeProvider.isDarkTheme),
                title: 'OpenGoalz v$version',
                home: SplashPage(),
              );
            },
          );
        },
      ),
    );
  }
}
