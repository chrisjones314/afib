

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

  /// Used to indicate an environment of [debug], [production], [prototype] or [release].
  /// 
  /// Use the command afib environment debug|production|prototype|release to set the 
  /// environment.
  static final environment = AFConfigEntryEnvironment();

  /// Used to turn on debug logging that may be useful in finding problems in 
  /// the Afib framework, off by default.
  static final internalLogging = AFConfigEntryBool(afNamespace, "internal_logging", false, "Set to true to show internal afib log statements");

  /// Set to true only when running under a flutter WidgetTester test.
  /// 
  /// The WidgetTester is thrown off by 'infinite' animations like CircularProgressIndicator:
  /// it thinks the screen is never done rendering.   Consequently, 
  /// you should use widgets like [AFCircularProgressIndicator], which use this flag,
  /// by way of the utility [AFConfig.isWidgetTesterContext] to return static widgets
  /// instead of an infinite animation in the widget tester context.
  static final widgetTesterContext = AFConfigEntryBool(afNamespace, "widget_tester_context", false, "Internal value set to true when we are doing widget tests");




}