import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class VersionProvider extends ChangeNotifier {
  bool _needsUpdate = false;
  bool _isUpdateMandatory = false;
  bool _checked = false;
  String? _latestVersion;
  String? _minSupportedVersion;
  String? _updateUrl = githubReleasesUrl;

  bool get needsUpdate => _needsUpdate;
  bool get isUpdateMandatory => _isUpdateMandatory;
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
      print(
          'Pubspec.yaml from Github: Latest Version= [$_latestVersion] Min Supported Version= [$_minSupportedVersion]');
      _updateUrl =
          RegExp(r'update_url:\s*([^\s\n]+)').firstMatch(content)?.group(1);
    }
  }

  Future<void> checkVersion(String localVersion) async {
    try {
      await _fetchFromGithub();

      final normalizedLocal = localVersion.split('+').first;

      // Compare versions
      if (_latestVersion != null) {
        _needsUpdate = _isVersionNewer(normalizedLocal, _latestVersion!);

        if (_minSupportedVersion != null) {
          _isUpdateMandatory =
              _isVersionNewer(normalizedLocal, _minSupportedVersion!);
        }
      }

      _checked = true;
      notifyListeners();
    } catch (e) {
      // On error, allow app to continue
      print('[VersionProvider] Error checking version: $e');
      _checked = true;
      notifyListeners();
    }
  }

  bool _isVersionNewer(String current, String target) {
    List<int> currentParts =
        current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> targetParts =
        target.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    int maxLength = currentParts.length > targetParts.length
        ? currentParts.length
        : targetParts.length;

    for (int i = 0; i < maxLength; i++) {
      int curr = i < currentParts.length ? currentParts[i] : 0;
      int targ = i < targetParts.length ? targetParts[i] : 0;
      if (targ > curr) return true;
      if (targ < curr) return false;
    }
    return false;
  }
}
