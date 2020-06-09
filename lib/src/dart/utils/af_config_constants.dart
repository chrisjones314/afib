
/// Constants used to specify values in [AF.config].
/// 
/// All keys end in ...Key.
class AFConfigConstants {
  /// Used to indicate an environment of [debug], [production], [prototype] or [release].
  /// 
  /// Use the command afib environment debug|production|prototype|release to set the 
  /// environment.
  static final environmentKey = "environment";
  
  static final production = "production";
  static final debug = "debug";
  static final prototype = "prototype";
  static final test_store = "test_store";
  static final allEnvironments = [production, debug, prototype, test_store];

  /// Used to turn on debug logging that may be useful in finding problems in 
  /// the Afib framework, off by default.
  static final internal_logging = "internal_logging";

  /// Set to true only when running under a flutter WidgetTester test.
  /// 
  /// The WidgetTester is thrown off by 'infinite' animations like CircularProgressIndicator:
  /// it thinks the screen is never done rendering.   Consequently, 
  /// you should use widgets like [AFCircularProgressIndicator], which use this flag,
  /// by way of the utility [AFConfig.isWidgetTesterContext] to return static widgets
  /// instead of an infinite animation in the widget tester context.
  static final widget_tester_context = "widget_tester_context";


}