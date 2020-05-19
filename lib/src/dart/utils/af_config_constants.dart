
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
  static final test = "test";
  static final allEnvironments = [production, debug, prototype, test];
  
}