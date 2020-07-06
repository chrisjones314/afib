
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/generators/af_config_generator.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/utils/af_exception.dart';

import '../af_command_output.dart';

/// Superclass for all configuration definitions.
abstract class AFConfigEntry extends AFItemWithNamespace {
    final dynamic defaultValue;
    final String declaringClass;
    
    AFConfigEntry(String namespace, String key, this.defaultValue, {this.declaringClass = AFConfigEntries.declaredIn}): super(namespace, key);

    void writeHelp(AFCommandOutput output, {int indent = 0});

    String get codeIdentifier {
      return "$declaringClass.$key";
    }

    String codeValue(AFConfig config) {
      dynamic val = config.valueFor(this);
      if(val == null) {
        return null;
      }
      if(val is String) {
        return "\"$val\"";
      }
      return val.toString();
    }
    
    /// Return an error message if the value is invalid, otherwise return null.
    String validate(String value);

    void setValueWithString(AFConfig dest, String value) {
      validateWithException(value);
      dest.putInternal(this, value);
    }

    void setValue(AFConfig dest, dynamic value) {
      if(value is String) {
        setValueWithString(dest, value);
      } else {
        dest.putInternal(this, value);
      }
    }
    
    void writeCommandHelp(AFCommandOutput output, String help, {int indent = 0}) {
      AFCommand.startCommandColumn(output, indent: indent);
      output.write(namespaceKey + " - ");
      AFCommand.startHelpColumn(output);
      output.write(help);
      output.endLine();
    }    

    void validateWithException(String value) {
      final val = validate(value);
      if(val != null) {
        throw AFException("Invalid value $value for $namespaceKey");
      }
    }


}


/// Used to define choices for a configuration value.
class AFConfigEntryDescription {
  String choice;
  String help;
  AFConfigEntryDescription(this.choice, this.help);

}

/// Superclass for configuration definitions that offer a list of string values,
/// for example 'debug', 'production', 'test'
abstract class AFConfigEntryChoice extends AFConfigEntry {
  final choices = List<AFConfigEntryDescription>();
  
  AFConfigEntryChoice(String namespace, String key, dynamic defaultValue, {String declaringClass = AFConfigEntries.declaredIn}): super(namespace, key, defaultValue, declaringClass: declaringClass);

  void addChoice(String choice, String help) {
    choices.add(AFConfigEntryDescription(choice, help));
  }  

  void writeHelp(AFCommandOutput output, { int indent = 0 }) {
    writeCommandHelp(output, "set the $key configuration value to one of:", indent: indent);
    for(var choice in choices) {
      AFCommand.startCommandColumn(output, indent: indent+1);
      output.write(choice.choice + " - ");
      AFCommand.startHelpColumn(output);
      output.write(choice.help);
      output.endLine();
    }
  }

  String validate(String value) {
    final choice = findChoice(value);
    if(choice == null) {
      return "$value is not a valid choice for $namespaceKey";
    }
    return null;
  }

  AFConfigEntryDescription findChoice(String val) {
    for(var choice in choices) {
      if(choice.choice == val) {
        return choice;
      }
    }
    return null;
  }
}

class AFConfigEntryBool extends AFConfigEntryChoice {
  static const trueValue = "true";
  static const falseValue = "false";

  final String help;
  
  AFConfigEntryBool(String namespace, String key, bool defaultValue, this.help, {String declaringClass = AFConfigEntries.declaredIn}): super(namespace, key, defaultValue, declaringClass: declaringClass) {
    addChoice(trueValue, "");
    addChoice(falseValue, "");
  }

  void writeHelp(AFCommandOutput output, { int indent = 0 }) {
    writeCommandHelp(output, this.help, indent: indent);
  }

  void setValueWithString(AFConfig dest, String value) {
    validateWithException(value);
    bool val = (value == "true");
    dest.putInternal(this, val);
  }

}


/// Command that displays or modified values from [AFConfig], and
/// that modifed values under the initialization/afib.g.dart.
class AFConfigCommand extends AFCommand { 
  final configs = Map<String, AFConfigEntry>();
  static const cmdName = "config";

  AFConfigCommand(): super(AFConfigEntries.afNamespace, cmdName, 0, 2) {
    registerEntry(AFConfigEntries.environment);
    registerEntry(AFConfigEntries.internalLogging);
  }

  /// Only register entries that are stored in afib.g.dart and can be manipulated
  /// from the command line.
  /// 
  /// Most entries don't need to be registered, they can simply be initialized
  /// in one of the command-line entries.
  void registerEntry(AFConfigEntry entry) {
    configs[entry.key] = entry;
  }

  void writeLongHelp(AFCommandOutput output, String subCommand) {
    writeShortHelp(output, );
    List<AFConfigEntry> entries = AFItemWithNamespace.sortIterable<AFConfigEntry>(configs.values);
    for(final entry in entries) {
      entry.writeHelp(output, indent: 2);
    }
  }

  /// Adds default values for all the registered configuration entries.
  void initAfibDefaults(AFConfig config) {
    for(final entry in configs.values) {
      config.putInternal(entry, entry.defaultValue);
    }
  }
  
  @override
  void execute(AFArgs args, AFConfig afibConfig, AFCommandOutput output) {    
    // dump out the current value of all arguments.
    if(args.count == 0) {
      final sorted = AFItemWithNamespace.sortIterable<AFConfigEntry>(afibConfig.all);
      afibConfig.dumpAll(sorted, output);
      return;
    }

    // dump out the current value of a specific argument
    String configKey = args.first;
    if(args.count == 1) {
      afibConfig.dumpOne(configKey, output);
      return;
    }

    String configVal = args.second;
    final entry = afibConfig.find(configKey);
    if(entry == null) {
      output.writeError("Unknown configuration entry $configKey");
      return;
    }

    /// set the value.  this will throw an exception if it is an invalid value.
    afibConfig.setValue(entry, configVal);
    output.writeLine("Set ${entry.codeIdentifier} to $configVal");

    if(!errorIfNotProjectRoot(output)) {
      return;
    }
    
    final generator = AFConfigGenerator();
    if(!generator.validateBefore(args, afibConfig, output)) {
      return;
    }

    generator.execute(args, afibConfig, output);    
  }

  @override
  String get shortHelp {
    return "Set the values below, which are written to initialization/afib.g.dart:";
  }
}