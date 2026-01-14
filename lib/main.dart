import 'package:flutter/material.dart';
import 'package:opengoalz/app_theme.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/provider_theme_app.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:opengoalz/widgets/splash_version_check.dart';
import 'package:opengoalz/provider_version.dart';
import 'package:opengoalz/pages/splash_page.dart';
import 'package:opengoalz/config/supabase_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure WidgetsBinding is initialized

  // Use centralized SupabaseConfig for environment variables
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserSessionProvider()),
        ChangeNotifierProvider(create: (_) => VersionProvider()),
      ],
      child: SplashVersionCheck(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp();

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
                title: appName,
                home: SplashPage(),
              );
            },
          );
        },
      ),
    );
  }
}
