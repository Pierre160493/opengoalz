import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/splash_page.dart';

const supabaseUrl =
    'https://kaderxuszmqjknsoyjpi.supabase.co'; // Get from Supabase Dashboard

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure WidgetsBinding is initialized

  await dotenv.load(fileName: ".env");
  var supabaseKey = dotenv.env['SUPABASE_KEY']; // Get value from .env file

  if (supabaseKey == null) {
    if (kDebugMode) {
      print('SUPABASE_KEY not found in .env file.');
    }
    return;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  final sessionProvider = SessionProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessionProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: appTheme,
      home: const SplashPage(),
    );
  }
}
