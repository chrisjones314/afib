

import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';

/// Constants used to specify values in [AF.config].
/// 
/// All keys end in ...Key.
class AFConfigEntries {  
  
  /// The namespace Afib uses for its native commands, configuration values, etc.
  /// 
  /// Third parties can extend this namespace.
  static const afNamespace = 'af';
  static const afNamespaceSeparator = ':';
  static const declaredIn = 'AFConfigEntries';

  /// Used to indicate an environment of [debug], [production], [prototype] or [release].
  /// 
  /// Use the command afib environment debug|production|prototype|release to set the 
  /// environment.
  static final environment = AFConfigEntryEnvironment();

  /// Used to turn on debug logging that may be useful in finding problems in 
  /// the Afib framework, off by default.
  static final logAreas = AFConfigEntryLogArea();

  /// Used to start the app in dark mode, rather than having to configure the device/emulator for 
  /// dark mode.
  static final startInDarkMode = AFConfigEntryBool(afNamespace, "startInDarkMode", "Set to true if you'd like to run the app in dark mode, regardless of the device setting", defaultValue: false);

  /// Set to true only when running under a flutter WidgetTester test.
  /// 
  /// The WidgetTester is thrown off by 'infinite' animations like CircularProgressIndicator:
  /// it thinks the screen is never done rendering.   Consequently, 
  /// you should use widgets like [AFCircularProgressIndicator], which use this flag,
  /// by way of the utility [AFConfig.isWidgetTesterContext] to return static widgets
  /// instead of an infinite animation in the widget tester context.
  static final widgetTesterContext = AFConfigEntryBool(afNamespace, "widgetTesterContext", "Internal value set to true when we are doing widget tests", defaultValue: false);

  /// A two or three character value which is used as the namespace for app-specific
  /// commands, and also the prefix on certain app-specific classs names.
  /// 
  /// For example, if the AppNamespace is ab, then the widget ID container class will be 
  /// named ABWidgetID, and a custom command called fixupdb will be ab:fixupdb.
  static final appNamespace = AFConfigEntryString(afNamespace, "appNamespace", "A short identifier which is unique to your app", minChars: 2, maxChars: 3,
   options: AFConfigEntryString.optionLowercase | AFConfigEntryString.optionIdentifier);

  static final projectName = AFConfigEntryString(afNamespace, "projectName", "The project name for your app", minChars: 4,
   options: AFConfigEntryString.optionMixedCase | AFConfigEntryString.optionIdentifier);

  /// Specify a list of test categories, ids or tags.  This is used automatically in
  /// test/afib/afib_test_config.g.dart
  static final enabledTestList = AFConfigEntryEnabledTests();
}