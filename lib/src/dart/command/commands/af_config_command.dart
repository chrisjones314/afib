
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_template_command.dart';
import 'package:afib/src/dart/command/af_templates.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

import '../af_command_output.dart';

/// Superclass for all configuration definitions.
abstract class AFConfigEntry extends AFItemWithNamespace {
    final dynamic defaultValue;
    
    AFConfigEntry(String namespace, String key, this.defaultValue): super(namespace, key);

    void writeHelp(AFCommandOutput output, {int indent = 0});
    
    /// Return an error message if the value is invalid, otherwise return null.
    String validate(String value);

    void setValue(AFConfig dest, String value) {
      validateWithException(value);
      dest.putInternal(this, value);
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
  
  AFConfigEntryChoice(String namespace, String key, dynamic defaultValue): super(namespace, key, defaultValue);

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
  
  AFConfigEntryBool(String namespace, String key, bool defaultValue, this.help): super(namespace, key, defaultValue) {
    addChoice(trueValue, "");
    addChoice(falseValue, "");
  }

  void writeHelp(AFCommandOutput output, { int indent = 0 }) {
    writeCommandHelp(output, this.help, indent: indent);
  }

  void setValue(AFConfig dest, String value) {
    validateWithException(value);
    bool val = (value == "true");
    dest.putInternal(this, val);
  }

}


/// Command that displays or modified values from [AFConfig], and
/// that modifed values under the initialization/afib.g.dart.
class AFConfigCommand extends AFTemplateCommand { 
  final configs = Map<String, AFConfigEntry>();

  AFConfigCommand(): super(AFConfigEntries.afNamespace, "config", 0, 3) {
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

  void writeLongHelp(AFCommandOutput output) {
    writeShortHelp(output, );
    List<AFConfigEntry> entries = List<AFConfigEntry>.of(configs.values);
    entries.sort((l, r) { return l.namespaceKey.compareTo(r.namespaceKey); });
    for(final entry in entries) {
      entry.writeHelp(output, indent: 2);
    }
  }
  
  @override
  void executeTemplate(AFArgs args, AFConfig afibConfig, AFTemplates templates, AFCommandOutput output) {    
    if(args.count == 0) {

      List<AFConfigEntry> sorted = List<AFConfigEntry>.of(configs.values);
      sorted.sort((l, r) {
        return l.namespaceKey.compareTo(r.namespaceKey);
      });
      afibConfig.dumpAll(sorted, output);
      return;
    }

    /*
    String env = args.first;
    final allEnvs = AFConfigConstants.allEnvironments;
    if(!allEnvs.contains(env)) {
      printError("Invalid environment $env");
      return;
    }

    templates.writeEnvironment(environment: env);
    print("Switched to environment $env");
    */
  }

  @override
  String get shortHelp {
    return "Set the values below, which are written to initialization/afib.g.dart:";
  }
}