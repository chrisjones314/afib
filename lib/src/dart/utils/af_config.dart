// @dart=2.9
import 'dart:core';
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';


/// A config is used to agreggate, universal and environment specific configuration settings
/// for use throughout your AFib app.
/// 
/// An Afib app combines the settings in config/application.dart with those in your current
/// environment specific file (e.g. config/environments/production.dart).
/// 
/// All get methods return null if the key does not have a value. 
class AFConfig {

  final Map<AFConfigItem, dynamic> values = <AFConfigItem, dynamic>{};



  /// This should only be used for validated values of the correct type, you should
  /// use [setValue] in most cases.
  void putInternal(AFConfigItem entry, dynamic value) {
    values[entry] = value;
  }

  /// Performs validation and type conversion on the value before placing it in our
  /// list of values.
  void setValue(String key, dynamic value) {
    final entry = AFibD.findConfigEntry(key);

    if(entry == null) {
      throw AFException("No entry defined for $key, try defining an AFConfigEntry in extendBase using registerConfigEntry");
    }
    entry.setValue(this, value);
  }

  /// Returns a text-version of the current AFConfigConstants.environmentKey value.
  AFEnvironment get environment  {
    return valueFor(AFConfigEntries.environment);
  }

  bool get isProduction {
    return environment == AFEnvironment.production;
  }

  /// 
  bool get isWidgetTesterContext {
    return boolFor(AFConfigEntries.widgetTesterContext);
  }

  bool get startInDarkMode {
    return boolFor(AFConfigEntries.forceDarkMode);
  }

  /// Casts the value for [entry] to a string and returns it.
  String stringFor(AFConfigItem entry) {
    return valueFor(entry);
  }

  List<String> stringListFor(AFConfigItem entry) {
    List result = valueFor(entry);
    if(result.length == 0) {
      return <String>[];
    }
    return result.map((x) => x.toString()).toList();
  }

  /// Casts the value for [entry] to a boolean and returns it.
  bool boolFor(AFConfigItem entry) {
    return valueFor(entry);
  }

  dynamic valueFor(AFConfigItem entry) {
    dynamic val = values[entry];
    return val ?? entry.defaultValue;
  }

  /// True if we are inside a running test.
  bool get isTestContext {
    return requiresTestData;
  }

  AFFormFactorSize get formFactorWithOrientation {
    final formFactor = valueFor(AFConfigEntries.testSize);
    final orient = stringFor(AFConfigEntries.testOrientation);
    return formFactor.withOrientation(orient);
  }

  /// True if we are in prototype mode
  bool get isPrototypeMode {
    return requiresPrototypeData;
  }

  /// Returns true if our current mode requires prototype data.
  bool get requiresPrototypeData {
    return AFConfigEntries.environment.requiresPrototypeData(this);
  }

  /// True if the current mode requires test data.
  bool get requiresTestData {
    return AFConfigEntries.environment.requiresTestData(this);
  }

  /// True if AFib should display internal log statements.
  List<String> get logsEnabled {
    final result = List<String>.from(AFConfigEntries.logsEnabled.areasFor(this));
    if(result.contains(AFConfigEntryLogArea.standard)) {
      _addIfMissing(result, AFConfigEntryLogArea.afRoute);
      _addIfMissing(result, AFConfigEntryLogArea.afState);
      _addIfMissing(result, AFConfigEntryLogArea.query);
      _addIfMissing(result, AFConfigEntryLogArea.ui);
    }
    return result;
  }

  Iterable<AFConfigItem> get all {
    return values.keys;
  }

  void _addIfMissing(List<String> items, String item) {
    if(!items.contains(item)) {
      items.add(item);
    }
  }
}