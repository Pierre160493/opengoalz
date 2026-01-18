import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/user_page/user_page.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:opengoalz/pages/offline_page.dart'; // Import the offline page
import 'package:opengoalz/provider_version.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  bool _showOfflineButton = false;
  bool _isConnected = false;
  bool _isUpdateRequired = false;

  @override
  void initState() {
    super.initState();
    _startTimeout();
    _runFullyParallelStartupTasksWithGate();
  }

  void _runFullyParallelStartupTasksWithGate() async {
    // Start both tasks in parallel
    Future<bool> versionCheckFuture = _checkVersion();
    Future<bool?> userSessionFuture = _fetchUserSession();

    // Wait for version check to finish first
    final updateRequired = await versionCheckFuture;

    if (updateRequired) {
      print(
          '[SplashPage] Version check finished. Update required: $updateRequired');
      setState(() {
        _isUpdateRequired = true;
        _showOfflineButton = false;
      });
      await _showUpdateDialog();
      if (mounted &&
          Provider.of<VersionProvider>(context, listen: false)
              .isUpdateMandatory) {
        return;
      }
    }
    // Wait for user session and route
    final userFetched = await userSessionFuture;
    _routeBasedOnUserSession(userFetched);
  }

  Future<bool> _checkVersion() async {
    String localVersion = 'Unknown';
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      localVersion = packageInfo.version;
    } catch (e) {
      print('[SplashPage: Version Check] Error reading local version: $e');
    }
    await Provider.of<VersionProvider>(context, listen: false)
        .checkVersion(localVersion);
    final versionProvider =
        Provider.of<VersionProvider>(context, listen: false);
    bool needsUpdate = versionProvider.needsUpdate;
    print(
        '[SplashPage: Version Check] Remote version: ${versionProvider.latestVersion}, Local version: ${localVersion}, Needs update: ${needsUpdate}');

    return needsUpdate;
  }

  Future<void> _showUpdateDialog() async {
    final versionProvider =
        Provider.of<VersionProvider>(context, listen: false);
    if (versionProvider.needsUpdate && mounted) {
      final bool isMandatory = versionProvider.isUpdateMandatory;
      await showDialog(
        context: context,
        barrierDismissible: !isMandatory,
        builder: (context) => PopScope(
          canPop: !isMandatory,
          child: AlertDialog(
            title: Text(isMandatory ? 'Update Required' : 'Update Recommended',
                style: TextStyle(
                    fontSize: fontSizeLarge, fontWeight: FontWeight.bold)),
            content: Text(
                isMandatory
                    ? 'A new version (${versionProvider.latestVersion}) is required to continue. Your version is too old.'
                    : 'A new version (${versionProvider.latestVersion}) is available. Please update your app.',
                style: TextStyle(fontSize: fontSizeMedium)),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isMandatory)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: persoRowWithIcon(iconContinue, 'Continue',
                          color: Colors.orange),
                    ),
                  TextButton(
                    onPressed: () async {
                      final url =
                          versionProvider.updateUrl ?? githubReleasesUrl;
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        if (mounted) {
                          context
                              .showSnackBarError('Could not launch update URL');
                        }
                      }
                    },
                    child: persoRowWithIcon(iconUpdate, 'Update',
                        color: Colors.green),
                  ),
                ],
              )
            ],
          ),
        ),
      );

      if (isMandatory) {
        print(
            '[SplashPage: Version Check] Mandatory update required. Blocking navigation.');
        // Stay here if mandatory
        return;
      }
      print(
          '[SplashPage: Version Check] Optional update dialog dismissed. Proceeding...');
    }
  }

  Future<bool?> _fetchUserSession() async {
    await Future.delayed(Duration.zero); // Await for the widget to mount
    if (supabase.auth.currentSession == null) {
      print('[SplashPage: Fetch User] No active session found.');
      return null;
    } else {
      try {
        await Provider.of<UserSessionProvider>(context, listen: false)
            .providerFetchUser(context, userId: supabase.auth.currentUser!.id);
        setState(() {
          _isConnected = true;
        });
        return true;
      } catch (error) {
        print('[SplashPage: Fetch User] Error fetching user data: ');
        print('# ${error.toString()}');

        return false;
      }
    }
  }

  void _routeBasedOnUserSession(bool? userFetched) {
    if (userFetched == null) {
      print(
          '[SplashPage: Fetch User] No active session found. Redirecting to LoginPage.');
      Navigator.of(context)
          .pushAndRemoveUntil(LoginPage.route(), (route) => false);
    } else if (userFetched) {
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
      if (mounted && !_isUpdateRequired) {
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
