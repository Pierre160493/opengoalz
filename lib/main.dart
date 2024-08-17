import 'package:flutter/material.dart';
import 'package:opengoalz/app_theme.dart';
import 'package:opengoalz/provider_theme_app.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:opengoalz/pages/splash_page.dart';

const supabaseUrl =
    'https://kaderxuszmqjknsoyjpi.supabase.co'; // Get from Supabase Dashboard

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure WidgetsBinding is initialized

  await dotenv.load(fileName: ".env");
  var supabaseKey = dotenv.env['SUPABASE_KEY']; // Get value from .env file

  // Check if the SUPABASE_KEY is null
  if (supabaseKey == null) {
    // print('SUPABASE_KEY not found in .env file.');
    return;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(ChangeNotifierProvider.value(
    value: SessionProvider(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: getTheme(context, themeProvider.isDarkTheme),
            home: SplashPage(),
          );
        },
      ),
    );
  }
}
