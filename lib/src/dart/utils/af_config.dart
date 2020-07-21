
import 'dart:core';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/generator_code/af_code_generator.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_exception.dart';


/// A config is used to agreggate, universal and environment specific configuration settings
/// for use throughout your AFib app.
/// 
/// An Afib app combines the settings in config/application.dart with those in your current
/// environment specific file (e.g. config/environments/production.dart).
/// 
/// All get methods return null if the key does not have a value. 
class AFConfig {

  final Map<AFConfigEntry, dynamic> values = Map<AFConfigEntry, dynamic>();


  /// Finds a configuration entry based on its command line name.
  AFConfigEntry find(String cmdLine) {
    
    for(final entry in values.keys) {
      if(entry.namespaceKey == cmdLine) {
        return entry;
      }
    }
    return null;
  }

  /// This should only be used for validated values of the correct type, you should
  /// use [setValue] in most cases.
  void putInternal(AFConfigEntry entry, dynamic value) {
    values[entry] = value;
  }

  /// Performs validation and type conversion on the value before placing it in our
  /// list of values.
  void setValue(AFConfigEntry entry, dynamic value) {
    entry.setValue(this, value);
  }

  /// Returns a text-version of the current AFConfigConstants.environmentKey value.
  String get environment  {
    return stringFor(AFConfigEntries.environment);
  }

  /// 
  bool get isWidgetTesterContext {
    return boolFor(AFConfigEntries.widgetTesterContext);
  }

  /// Casts the value for [entry] to a string and returns it.
  String stringFor(AFConfigEntry entry) {
    return valueFor(entry);
  }

  List<String> stringListFor(AFConfigEntry entry) {
    List result = valueFor(entry);
    if(result.length == 0) {
      return List<String>();
    }
    return result;
  }

  /// Casts the value for [entry] to a boolean and returns it.
  bool boolFor(AFConfigEntry entry) {
    return valueFor(entry);
  }

  dynamic valueFor(AFConfigEntry entry) {
    dynamic val = values[entry];
    return val ?? entry.defaultValue;
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
  bool get enableInternalLogging {
    return boolFor(AFConfigEntries.internalLogging);
  }

  String get projectFolderName {
    final projectName = stringFor(AFConfigEntries.projectName);
    return AFCodeGenerator.toSnakeCase(projectName);
  }

  Iterable<AFConfigEntry> get all {
    return values.keys;
  }

  void dumpAll(List<AFConfigEntry> entries, AFCommandOutput output) {
    output.writeLine("Configuration values from initialization/afib.g.dart");
    for(final entry in entries) {
      dumpEntry(entry, output);
    }
  }

  void dumpOne(String key, AFCommandOutput output) {
    final entry = find(key);
    if(entry == null) {
      output.writeErrorLine("No conifguration value for $key");
      return;
    }
    dumpEntry(entry, output);
  }

  void dumpEntry(AFConfigEntry entry, AFCommandOutput output) {
      AFCommand.startCommandColumn(output);
      output.write(entry.namespaceKey + ": ");
      AFCommand.startHelpColumn(output);
      output.writeLine(valueFor(entry).toString());    
  }

  
  //void setJson(String key, HashMap<String, dynamic> json) { jsonSettings[key] = json; }
  //HashMap<String, dynamic> getJson(String key) { return jsonSettings[key]; }
}