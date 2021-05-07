

//import 'package:afib/id.dart';
import 'package:afib/id.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/utils/af_config.dart';

/// Constants used to specify values in [AF.afConfig].
/// 
/// All keys end in ...Key.
class AFConfigEntries {  
  
  /// The namespace Afib uses for its native commands, configuration values, etc.
  /// 
  /// Third parties can extend this namespace.
  static const afNamespace = 'af';
  static const afNamespaceSeparator = ':';

  /// Used to indicate an environment of [debug], [production], [prototype] or [release].
  /// 
  /// Use the command afib environment debug|production|prototype|release to set the 
  /// environment.
  static final environment = AFConfigEntryEnvironment();

  /// Used to turn on debug logging that may be useful in finding problems in 
  /// the Afib framework, off by default.
  static final logsEnabled = AFConfigEntryLogArea();

  /// Used to start the app in dark mode, rather than having to configure the device/emulator for 
  /// dark mode.
  static final forceDarkMode = AFConfigurationitemTrueFalse(
    libraryId: AFUILibraryID.id,
    name: "force-dark-mode", 
    validContexts: AFConfigurationItem.validContextsAllButNew,
    ordinal: 300.0,
    help: "Set to true if you'd like to run the app in dark mode, regardless of the device setting", 
    defaultValue: false);

  /// Set to true only when running under a flutter WidgetTester test.
  /// 
  /// The WidgetTester is thrown off by 'infinite' animations like CircularProgressIndicator:
  /// it thinks the screen is never done rendering.   Consequently, 
  /// you should use widgets like [AFCircularProgressIndicator], which use this flag,
  /// by way of the utility [AFConfig.isWidgetTesterContext] to return static widgets
  /// instead of an infinite animation in the widget tester context.
  static final widgetTesterContextKey = "widgetTesterContext";
  static final widgetTesterContext = AFConfigurationitemTrueFalse(
    libraryId: AFUILibraryID.id,
    name: widgetTesterContextKey, 
    validContexts: AFConfigurationItem.validContextInternalOnly,
    ordinal: 10000,
    help: "Internal value set to true when we are doing widget tests", 
    defaultValue: false
  );

  /// A two or three character value which is used as the namespace for app-specific
  /// commands, and also the prefix on certain app-specific classs names.
  /// 
  /// For example, if the AppNamespace is ab, then the widget ID container class will be 
  /// named ABWidgetID, and a custom command called fixupdb will be ab:fixupdb.
  static final appNamespace = AFConfigurationItemOption(
    libraryId: AFUILibraryID.id,
    name: "app-namespace", 
    help: "A short identifier which is unique to your app, many files and classes are prefixed with these characters, so changing it later is not advised", 
    validContexts: AFConfigurationItem.validContextsNewProjectAndConfig,
    ordinal: 700.0,
    minChars: 2, 
    maxChars: 4,
    options: AFConfigurationItemOption.optionLowercase | AFConfigurationItemOption.optionIdentifier
  );

  /// The name of the package for the app.  
  /// 
  /// e.g, the statement
  /// ```
  /// import 'package:mypackagename/id.dart';
  /// ```
  /// should import the id file from your application.
  static final packageName = AFConfigurationItemOption(
    libraryId: AFUILibraryID.id,
    name: "package-name", 
    help: "The name of your application package", 
    validContexts: AFConfigurationItem.validContextsNewProjectAndConfig,
    ordinal: 710.0,
    minChars: 4, 
    maxChars: 40,
    options: AFConfigurationItemOption.optionLowercase | AFConfigurationItemOption.optionIdentifier
  );

  /// Specify a list of test categories, ids or tags.  This is used automatically in
  /// test/afib/afib_test_config.g.dart
  static final testsEnabled = AFConfigEntryEnabledTests();

  /// The size of the screen for command line tests.
  static final testSize = AFConfigEntryTestSize();

  // The orientation of the screen for command line tests.
  static final testOrientation = AFConfigEntryTestOrientation();
}