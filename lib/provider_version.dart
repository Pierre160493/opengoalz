import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  Future<void> _fetchFromGithub() async {
    const rawUrl =
        'https://raw.githubusercontent.com/Pierre160493/opengoalz/main/pubspec.yaml';
    final response = await http.get(Uri.parse(rawUrl));

    if (response.statusCode == 200) {
      final content = response.body;

      // Simple regex extraction to avoid adding yaml parser dependency
      _latestVersion = RegExp(r'version:\s*([^\s+]+)')
          .firstMatch(content)
          ?.group(1)
          ?.replaceAll('"', '')
          .replaceAll("'", "");
      _minSupportedVersion = RegExp(r'min_supported_version:\s*([^\s\n]+)')
          .firstMatch(content)
          ?.group(1);
      _updateUrl =
          RegExp(r'update_url:\s*([^\s\n]+)').firstMatch(content)?.group(1);
    }
  }

  Future<void> checkVersion(String localVersion) async {
    try {
      await _fetchFromGithub();

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
