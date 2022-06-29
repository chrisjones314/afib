
/// A utility containing package info that is placed in your own app state 
class AFAppPlatformInfoState {
  static const appNameField = "appName";
  static const packageNameField = "packageName";
  static const screenSizeField = "screenSize";
  static const appVersionField = "appVersion";
  static const appBuildNumberField = "buildNumber";
  static const osField = "os";
  static const osVersionField = "osVersion";

  final String appName;
  final String packageName;
  final String appVersion;
  final String appBuildNumber;
  final String os;
  final String osVersion;
  final String screenSize;

  AFAppPlatformInfoState({
    required this.appName,
    required this.packageName,
    required this.appVersion,
    required this.appBuildNumber,
    required this.osVersion,
    required this.os,
    required this.screenSize,
  });

  String get headlineText {
    return "$os/$packageName.$appVersion";

  }

  factory AFAppPlatformInfoState.initialState() {
    return AFAppPlatformInfoState(
      appName: "",
      packageName: "",
      appVersion: "",
      appBuildNumber: "",
      os: "",
      osVersion: "",
      screenSize: "",
    );
  }

  factory AFAppPlatformInfoState.fromJson(Map<String, dynamic> json) {
    final appName = json[appNameField];
    final packageName = json[packageNameField];
    final appVersion = json[appVersionField];
    final appBuildNumber = json[appBuildNumberField];
    final os = json[osField];
    final osVersion = json[osVersionField];
    final screenSize = json[screenSizeField];
    return AFAppPlatformInfoState(
      appName: appName,
      packageName: packageName,
      appVersion: appVersion,
      appBuildNumber: appBuildNumber,
      os: os,
      osVersion: osVersion,
      screenSize: screenSize,
    );
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    result[appNameField] = appName;
    result[packageNameField] = packageName;
    result[appVersionField] = appVersion;
    result[appBuildNumberField] = appBuildNumber;
    result[osField] = os;
    result[osVersionField] = osVersion;
    result[screenSizeField] = screenSize;
    return result;
  }
}