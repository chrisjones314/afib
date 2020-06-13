
import 'dart:core';

import 'package:afib/src/dart/utils/af_config_constants.dart';


/// A config is used to agreggate, universal and environment specific configuration settings
/// for use throughout your AFib app.
/// 
/// An Afib app combines the settings in config/application.dart with those in your current
/// environment specific file (e.g. config/environments/production.dart).
/// 
/// All get methods return null if the key does not have a value. 
class AFConfig {

  final Map<String, int>    intSettings = Map<String, int>();
  final Map<String, String> strSettings = Map<String, String>();
  final Map<String, double> dblSettings = Map<String, double>();
  final Map<String, bool> boolSettings = Map<String, bool>();
  //final Map<String, HashMap<String, dynamic> >() jsonSettings = Map<String, HashMap<String, dynamic> >();

  void setInt(String key, int i) { intSettings[key] = i; }
  int getInt(String key) { return intSettings[key]; }
  bool equalsInt(String key, int compare) { return intSettings[key] == compare; }

  void setString(String key, String s) { strSettings[key] = s; }
  String getString(String key) { return strSettings[key]; }

  void setDouble(String key, double d) { dblSettings[key] = d; }
  double getDouble(String key) { return dblSettings[key]; }

  void setBool(String key, bool b) { boolSettings[key] = b; }
  bool getBool(String key) { return boolSettings[key]; }

  /// Returns a text-version of the current AFConfigConstants.environmentKey value.
  String get environment  {
    return getString(AFConfigConstants.environmentKey);
  }

  bool get isWidgetTesterContext {
    return getBool(AFConfigConstants.widget_tester_context) ?? false;
  }

  // Returns true if our current mode requires prototype data.
  bool get requiresPrototypeData {
    final String env = environment;
    return (env == AFConfigConstants.prototype);
  }

  bool get requiresTestData {
    final String env = environment;
    return (env != AFConfigConstants.production && env != AFConfigConstants.debug);
  }

  
  //void setJson(String key, HashMap<String, dynamic> json) { jsonSettings[key] = json; }
  //HashMap<String, dynamic> getJson(String key) { return jsonSettings[key]; }
}