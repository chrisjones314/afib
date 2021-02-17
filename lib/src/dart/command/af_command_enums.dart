
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
