library all_about_forced_update;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_store/open_store.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AllAboutForcedUpdate {
  AllAboutForcedUpdate._();

  static final AllAboutForcedUpdate _instance = AllAboutForcedUpdate._();

  static AllAboutForcedUpdate get instance => _instance;

  String? _iosAppStoreId;
  String? _androidPackageName;

  Future<bool> forcedUpdateNeeded(String updateConfigUrl) async {
    try {
      int? localVersion = int.tryParse((await PackageInfo.fromPlatform()).buildNumber);

      Uri url = Uri.parse(updateConfigUrl);
      var response = await http.get(url).timeout(const Duration(seconds: 2));
      var json = jsonDecode(response.body);

      int? onlineVersion = Platform.isAndroid ? json['minVersionCodeAndroid'] : json['minVersionCodeIos'];
      _iosAppStoreId = json['iosAppStoreId'];
      _androidPackageName = json['androidPackageName'];
      if (localVersion != null && onlineVersion != null && _iosAppStoreId != null && _androidPackageName != null) {
        if (localVersion < onlineVersion) {
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Download or parsing of forced updated file failed! $updateConfigUrl: $e');
      }
    }
    return false;
  }

  Future<void> openAppStore() async {
    if (_iosAppStoreId == null || _androidPackageName == null) return;
    await OpenStore.instance.open(
      appStoreId: _iosAppStoreId,
      androidAppBundleId: _androidPackageName,
    );
  }
}
