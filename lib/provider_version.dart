import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'constants.dart';

class VersionProvider extends ChangeNotifier {
  bool _needsUpdate = false;
  bool _checked = false;
  String? _latestVersion;
  String? _minSupportedVersion;
  String? _updateUrl = githubReleasesUrl;

  bool get needsUpdate => _needsUpdate;
  bool get checked => _checked;
  String? get latestVersion => _latestVersion;
  String? get minSupportedVersion => _minSupportedVersion;
  String? get updateUrl => _updateUrl;

  Future<void> checkVersion(String localVersion) async {
    try {
      // Fetch remote version file from Supabase bucket
      final response = await Supabase.instance.client.storage
          .from('app-config')
          .download('app_version.json');
      final jsonData = jsonDecode(utf8.decode(response));
      _latestVersion = jsonData['latest_version'];
      _minSupportedVersion = jsonData['min_supported_version'];

      // Only override the updateUrl if the JSON actually provides a valid one
      final remoteUrl = jsonData['update_url'];
      if (remoteUrl != null && remoteUrl.toString().isNotEmpty) {
        _updateUrl = remoteUrl;
      }

      // Compare versions
      if (_latestVersion != null && _latestVersion != localVersion) {
        _needsUpdate = true;
      }
      _checked = true;
      notifyListeners();
    } catch (e) {
      // On error, allow app to continue
      _checked = true;
      notifyListeners();
    }
  }
}
