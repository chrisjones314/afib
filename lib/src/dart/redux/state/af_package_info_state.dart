import 'package:afib/src/dart/redux/state/af_app_state.dart';

/// A utility containing package info that is placed in your own app state 
class AFPackageInfoState {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;

  AFPackageInfoState({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber
  });
}