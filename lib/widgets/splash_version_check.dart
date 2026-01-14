import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:opengoalz/provider_version.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class SplashVersionCheck extends StatefulWidget {
  final Widget child;
  const SplashVersionCheck({required this.child});

  @override
  State<SplashVersionCheck> createState() => _SplashVersionCheckState();
}

class _SplashVersionCheckState extends State<SplashVersionCheck> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    // Read local version from asset
    String localVersion = 'Unknown';
    try {
      final jsonStr = await rootBundle.loadString('assets/app_version.json');
      final jsonData = jsonDecode(jsonStr);
      localVersion = jsonData['latest_version'] ?? 'Unknown';
    } catch (_) {}
    await Provider.of<VersionProvider>(context, listen: false)
        .checkVersion(localVersion);
    setState(() {
      _checked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final versionProvider = Provider.of<VersionProvider>(context);
    if (!_checked || !versionProvider.checked) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (versionProvider.needsUpdate) {
      return Scaffold(
        body: Center(
          child: AlertDialog(
            title: Text('Update Required'),
            content: Text(
                'A new version (${versionProvider.latestVersion}) is available. Please update your app.'),
            actions: [
              TextButton(
                onPressed: () {
                  // Optionally open update URL
                  // launch(versionProvider.updateUrl ?? '');
                },
                child: Text('Update'),
              ),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}
