library all_about_forced_updates;

import 'dart:convert';
import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

/// Contains Logic to check if App needs an Update and to launch AppStore.
class AllAboutForcedUpdates {
  /// Widget shown when no update required
  // final Widget app;

  // /// Widget shown when update required
  // final Widget Function() updateWidget;

  // /// Online adress to JSON file with `minVersionCodeAndroid` and `minVersionCodeIos` set to a number
  // final String versionJsonAdress;

  // /// If true always display App in Debug mode (default true)
  // final bool ignoreInDebug;

  // /// If true always display App (default false)
  // final bool ignore;

  /// Link to AppStore/PlayStore, only set if new Version needed.
  static String? get appStoreLink => _appStoreLink;
  static String? _appStoreLink;

  /// If App should display Update Widget.
  static bool get forceUpdate => _forceUpdate;
  static bool _forceUpdate = false;

  /// Where Update Widget should close to when dismissed
  static String closeToRoute = '';

  /// Get if a dismiss/later button should be displayed
  static bool get allowDismiss => _allowDismiss;

  static bool _allowDismiss = false;

  /// Opens AppStore, needs init to be called with forceUpdate set to true.
  static Future<void> openAppStore() async {
    if (appStoreLink == null) return;
    if (_newVersion == null) return;
    await _newVersion?.launchAppStore(appStoreLink ?? '');
  }

  static NewVersion? _newVersion;

  // /// Wrapper for an App that looks at a json to determine if App should be run or if an update has to be made.
  // /// On default always displays `app`in Debug mode. `Do not use`.
  // const AllAboutForcedUpdates({
  //   Key? key,
  //   required this.app,
  //   required this.updateWidget,
  //   required this.versionJsonAdress,
  //   this.ignoreInDebug = true,
  //   this.ignore = false,
  // }) : super(key: key);

  static Future<void> init(String jsonAdress, {required bool allowDismiss}) async {
    _allowDismiss = allowDismiss;
    try {
      int? localVersion = int.tryParse((await PackageInfo.fromPlatform()).buildNumber);

      Uri url = Uri.parse(jsonAdress);
      var response = await http.get(url).timeout(const Duration(seconds: 2));
      var json = jsonDecode(response.body);

      int? onlineVersion = Platform.isAndroid ? json['minVersionCodeAndroid'] : json['minVersionCodeIos'];
      if (localVersion != null && onlineVersion != null) {
        if (localVersion < onlineVersion) {
          var newVersion = NewVersion(iOSAppStoreCountry: 'AT'); // TODO look how to appstore country code
          var status = await newVersion.getVersionStatus();
          _appStoreLink = status?.appStoreLink;
          _forceUpdate = true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Could not check if App should update.');
        print(e);
      }
    }
  }

  // @override
  // State<AllAboutForcedUpdates> createState() => _AllAboutForcedUpdatesState();
}

// class _AllAboutForcedUpdatesState extends State<AllAboutForcedUpdates> {
//   bool _forceUpate = false;

//   @override
//   void initState() {
//     SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
//       _init();
//     });
//     super.initState();
//   }

//   Future<void> _init() async {
//     //if (widget.ignore) return;
//     //if (widget.ignoreInDebug && kDebugMode) return;

//     try {
//       int? localVersion = int.tryParse((await PackageInfo.fromPlatform()).buildNumber);

//       Uri url = Uri.parse(widget.versionJsonAdress);
//       var response = await http.get(url);
//       var json = jsonDecode(response.body);

//       int? onlineVersion = Platform.isAndroid ? json['minVersionCodeAndroid'] : json['minVersionCodeIos'];
//       if (localVersion != null && onlineVersion != null) {
//         _forceUpate = localVersion < onlineVersion;
//         if (_forceUpate) {
//           var newVersion = NewVersion(iOSAppStoreCountry: 'AT'); // TODO look how to appstore country code
//           var status = await newVersion.getVersionStatus();
//           AllAboutForcedUpdates.appStoreLink = status?.appStoreLink;
//           setState(() {});
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Could not check if App should update.');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) => Stack(
//         alignment: Alignment.center,
//         children: [
//           widget.app,
//           if (_forceUpate) Directionality(textDirection: TextDirection.ltr, child: widget.updateWidget.call()),
//         ],
//       );
// }
