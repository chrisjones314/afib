
import 'package:meta/meta.dart';

/// Used in Afib.g.dart to specify the environment to run under.
enum AFEnvironment {
  /// Used for production builds.
  production,

  /// Used for debug builds.
  debug,

  /// Used to start in prototype mode, which displays a list of all prototype screens
  /// and includes a drawer used to run tests against them.
  prototype,

  /// Used in command-line tests.
  test,
}

/// You can override [AFFunctionalTheme.deviceFormFactor] to modify
/// the meanings of these defintions.  
/// 
/// In your code, you can use methods like [AFFunctionalTheme.deviceHasFormFactor]
/// to conditionally change your UI build based on the device form factor.  
enum AFFormFactor {
  /// Similar to an iPhone mini
  smallPhone, 

  /// Similar to standard iPhones
  standardPhone, 

  /// Similar to iPhone max.
  largePhone, 

  /// Similar to 9.7" iPad
  smallTablet, 
  
  /// Similar to standard iPad
  standardTablet,

  /// Similar to 12" ipad.
  largeTablet,
}

@immutable
class AFFormFactorSize {
  static const idTabletLarge = 'tablet-large';
  static const idTabletStandard = 'tablet-standard';
  static const idTabletSmall = 'tablet-small';
  static const idPhoneLarge = 'phone-large';
  static const idPhoneStandard = 'phone-standard';
  static const idOrientationPortrait = 'portrait';
  static const idOrientationLandscape = 'landscape';

  static const sizeTabletLarge = AFFormFactorSize(identifier: AFFormFactorSize.idTabletLarge, width: 2048, height: 2732);
  static const sizeTabletStandard = AFFormFactorSize(identifier: AFFormFactorSize.idTabletStandard, width: 1640.0, height: 2360.0);
  static const sizeTabletSmall = AFFormFactorSize(identifier: AFFormFactorSize.idTabletSmall, width: 1536.0, height: 2048.0);
  static const sizePhoneStandard = AFFormFactorSize(identifier: AFFormFactorSize.idPhoneStandard, width: 1170.0, height: 2532.0);
  static const sizePhoneLarge = AFFormFactorSize(identifier: AFFormFactorSize.idPhoneLarge, width: 1284.0, height: 2778.0);

  final String identifier;
  final double height;
  final double width;
  const AFFormFactorSize({
    required this.identifier,
    required this.width, 
    required this.height,
  });

  String get dimensionsText {
    return "$width x $height";
  }

  String summaryText() {
    return "$identifier / $dimensionsText";
  }

  AFFormFactorSize withOrientation(String orient) {
    final bigger   = width > height ? width : height;
    final smaller  = width > height ? height: width;
    if(orient == idOrientationPortrait) {
      return AFFormFactorSize(width: smaller, height: bigger, identifier: "$identifier:$orient");
    } else {
      return AFFormFactorSize(width: bigger, height: smaller, identifier: "$identifier:$orient");
    }
  }
}