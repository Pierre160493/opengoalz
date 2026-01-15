import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/user_page/user_page.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:opengoalz/pages/offline_page.dart'; // Import the offline page
import 'package:opengoalz/provider_version.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import 'dart:convert';

// Helper class for user session result
class UserSessionResult {
  final bool sessionExists;
  final bool userFetched;
  UserSessionResult({required this.sessionExists, required this.userFetched});
}

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  bool _showOfflineButton = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _startTimeout();
    _runFullyParallelStartupTasksWithGate();
  }

  void _runFullyParallelStartupTasksWithGate() async {
    // Start both tasks in parallel
    Future<bool> versionCheckFuture = _checkVersion();
    Future<UserSessionResult> userSessionFuture = _fetchUserSession();

    // Wait for version check to finish first
    final updateRequired = await versionCheckFuture;

    if (updateRequired) {
      print(
          '[SplashPage] Version check finished. Update required: $updateRequired');
      await _showUpdateDialogIfNeeded();
      // Do not wait for user session
      return;
    }
    // If no update required, wait for user session and route
    final userSessionResult = await userSessionFuture;
    _routeBasedOnUserSession(userSessionResult);
  }

  Future<bool> _checkVersion() async {
    final stopwatch = Stopwatch()..start();
    print('[SplashPage: Version Check] Starting version check...');
    String localVersion = 'Unknown';
    try {
      final jsonStr = await DefaultAssetBundle.of(context)
          .loadString('assets/app_version.json');
      final jsonData = jsonDecode(jsonStr);
      localVersion = jsonData['latest_version'] ?? 'Unknown';
      print(
          '[SplashPage: Version Check] Local version from asset: $localVersion');
    } catch (e) {
      print('[SplashPage: Version Check] Error reading local version: $e');
    }
    await Provider.of<VersionProvider>(context, listen: false)
        .checkVersion(localVersion);
    final versionProvider =
        Provider.of<VersionProvider>(context, listen: false);
    bool needsUpdate = versionProvider.needsUpdate;
    if (needsUpdate) {
      print(
          '[SplashPage: Version Check] Update required! Remote version: ${versionProvider.latestVersion}, Local version: ${localVersion}');
    }
    stopwatch.stop();
    print(
        '[SplashPage: Version Check] Version check finished in ${stopwatch.elapsedMilliseconds}ms. Update required: ${needsUpdate}');
    return needsUpdate;
  }

  Future<void> _showUpdateDialogIfNeeded() async {
    final versionProvider =
        Provider.of<VersionProvider>(context, listen: false);
    if (versionProvider.needsUpdate && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Update Required',
              style: TextStyle(
                  fontSize: fontSizeLarge, fontWeight: FontWeight.bold)),
          content: Text(
              'A new version (${versionProvider.latestVersion}) is available. Please update your app.',
              style: TextStyle(fontSize: fontSizeMedium)),
          actions: [
            TextButton(
              onPressed: () {
                // Optionally open update URL
                // launch(versionProvider.updateUrl ?? '');
              },
              child: Text('Update', style: TextStyle(fontSize: fontSizeMedium)),
            ),
          ],
        ),
      );
      print(
          '[SplashPage: Version Check] Blocking navigation due to update requirement.');
    }
  }

  Future<UserSessionResult> _fetchUserSession() async {
    final stopwatch = Stopwatch()..start();
    print('[SplashPage: Fetch User] Checking user session for redirection...');
    await Future.delayed(Duration.zero); // Await for the widget to mount
    if (supabase.auth.currentSession == null) {
      print('[SplashPage: Fetch User] No active session found.');
      stopwatch.stop();
      print(
          '[SplashPage: Fetch User] Finished in ${stopwatch.elapsedMilliseconds}ms');
      return UserSessionResult(sessionExists: false, userFetched: false);
    } else {
      print(
          '[SplashPage: Fetch User] Active session found. Fetching user data...');
      try {
        await Provider.of<UserSessionProvider>(context, listen: false)
            .providerFetchUser(context, userId: supabase.auth.currentUser!.id);
        print('[SplashPage] User session fetched successfully.');
        setState(() {
          _isConnected = true;
        });
        stopwatch.stop();
        print(
            '[SplashPage: Fetch User] Finished in ${stopwatch.elapsedMilliseconds}ms');
        return UserSessionResult(sessionExists: true, userFetched: true);
      } catch (error) {
        print('[SplashPage: Fetch User] Error fetching user data: ');
        print('# ${error.toString()}');
        stopwatch.stop();
        print(
            '[SplashPage: Fetch User] Finished (with error) in ${stopwatch.elapsedMilliseconds}ms');
        return UserSessionResult(sessionExists: true, userFetched: false);
      }
    }
  }

  void _routeBasedOnUserSession(UserSessionResult result) {
    if (!result.sessionExists) {
      print(
          '[SplashPage: Fetch User] No active session found. Redirecting to LoginPage.');
      Navigator.of(context)
          .pushAndRemoveUntil(LoginPage.route(), (route) => false);
    } else if (result.userFetched) {
      print(
          '[SplashPage] User session fetched successfully. Redirecting to UserPage.');
      Navigator.of(context)
          .pushAndRemoveUntil(UserPage.route(), (route) => false);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error',
                style: TextStyle(
                    fontSize: fontSizeLarge, fontWeight: FontWeight.bold)),
            content: Text('User not found. Redirecting to login page.',
                style: TextStyle(fontSize: fontSizeMedium)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK', style: TextStyle(fontSize: fontSizeMedium)),
              ),
            ],
          );
        },
      );
      context.showSnackBarError('User not found. Redirecting to login page.');
      supabase.auth.signOut(); // Sign out the user
      Navigator.of(context)
          .pushAndRemoveUntil(LoginPage.route(), (route) => false);
    }
  }

  void _startTimeout() {
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showOfflineButton = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: preloader),
          if (_showOfflineButton)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        OfflinePage.route(onReturn: _onReturnFromOffline));
                  },
                  child: Text('Go to Offline Page'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onReturnFromOffline() {
    if (_isConnected) {
      Navigator.of(context)
          .pushAndRemoveUntil(UserPage.route(), (route) => false);
    }
  }
}
