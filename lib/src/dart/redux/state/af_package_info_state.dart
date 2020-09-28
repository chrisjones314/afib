

import 'package:afib/src/dart/redux/state/af_app_state.dart';

/// A utility containing package info that is placed in your own app state 
class AFPackageInfoState extends AFAppStateModel {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;

  AFPackageInfoState({
    this.appName,
    this.packageName,
    this.version,
    this.buildNumber
  });
}