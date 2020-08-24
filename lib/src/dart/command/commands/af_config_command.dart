
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';

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

    String get argumentString {
      return key;
    }

    String get argumentHelp {
      return "";
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
    String validate(dynamic value);

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

class AFConfigEntryList extends AFConfigEntry {
  final List<String> allowed;
  final help;
  AFConfigEntryList(String namespace, String key, dynamic defaultValue, {String declaringClass = AFConfigEntries.declaredIn, this.allowed, this.help}): super(namespace, key, defaultValue, declaringClass: declaringClass);

  @override
  String validate(dynamic value) {
    if(allowed == null) {
      return null;
    }

    if(value is String) {
      if(!allowed.contains(value)) {
        return "$namespaceKey must be one of $allowed";
      }
    }
    return null;
  }
  
  @override
  String codeValue(AFConfig config) {
    final sb = StringBuffer("[");
    final vals = config.stringListFor(this);
    for(int i = 0; i < vals.length; i++) {
      sb.write('"');
      sb.write(vals[i]);
      sb.write('"');
      if(i+1 < vals.length) {
        sb.write(", ");
      }
    }
    sb.write("]");
    return sb.toString();
  }

  void writeHelp(AFCommandOutput output, { int indent = 0 }) {
    writeCommandHelp(output, help, indent: indent);
  }

}

class AFConfigEntryEnabledTests extends AFConfigEntryList {
  static const allTests = "all";
  static const stateTests = "state";
  static const unitTests = "unit";
  static const screenTests = "screen";
  static const queryTests = "query";
  static const multiScreenTests = "multiscreen";
  static const allAreas = [allTests, unitTests, stateTests, screenTests, queryTests, multiScreenTests];

  AFConfigEntryEnabledTests(): super(AFConfigEntries.afNamespace, "enabledTestList", [allTests], help: "Space separated list of [${allAreas.join('|')}|test_id|test_tag]");

  bool isAreaEnabled(AFConfig config, String area) {
    List<String> areas = config.stringListFor(this);
    if(hasNoAreas(areas)) {
      return true;
    }
    return areas.contains(area) || areas.contains(allTests);
  }

  bool isTestEnabled(AFConfig config, AFTestID id) {
    List<String> areas = config.stringListFor(this);
    if(hasOnlyAreas(areas)) {
      return true;
    }
    if(areas.contains(id.code)) {
      return true;
    }
    for(final area in areas) {
      if(id.hasTag(area)) {
        return true;
      }
    }
    return false;
  }

  bool hasNoAreas(List<String> areas) {
    for(final area in allAreas) {
      if(areas.contains(area)) {
        return false;
      }
    }
    return true;
  }

  bool hasOnlyAreas(List<String> areas) {
    for(final area in areas) {
      if(!allAreas.contains(area)) {
        return false;
      }
    }
    return true;
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

  String validate(dynamic value) {
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

class AFConfigEntryString extends AFConfigEntry {
  static const optionLowercase = 1;
  static const optionIdentifier = 2;
  static const optionMixedCase = 4;

  final int maxChars;
  final int minChars;
  final String help;
  final int options;

  AFConfigEntryString(String namespace, String key, this.help, {this.minChars = -1, this.maxChars = -1, this.options = 0}): super(namespace, key, "");
  
  @override
  String validate(dynamic value) {
    if(minChars > 0 && value.length < minChars ) {
      return "$value must be at least $minChars characters long.";
    }
    if(maxChars > 0 && value.length > maxChars) {
      return "$value must be at most $maxChars characters long.";
    }
    if(hasOption(optionLowercase)) {
      if(value.toLowerCase() != value) {
        return "$value must be all lowercase";
      }
    }
    return null;
  }  

  String get argumentHelp {
    bool extraDetails = (maxChars > 0 || minChars > 0 || options != 0);
    final sb = StringBuffer();
    sb.write(help);
    if(extraDetails) {
      final dets = List<String>();
      if(minChars > 0) {
        dets.add("min: $minChars");
      }
      if(maxChars > 0) {
        dets.add("max: $maxChars");
      }
      if(options != 0) {
        if(hasOption(optionLowercase)) {
          dets.add("all lowercase");
        }
        if(hasOption(optionMixedCase)) {
          dets.add("mixed case");
        }
        if(hasOption(optionIdentifier)) {
          dets.add("valid identifier");
        }
      }
      if(dets.isNotEmpty) {
        sb.write(" (");
        sb.write(dets.join(", "));
        sb.write(")");
      }
    }
    return sb.toString();
  }


  void writeHelp(AFCommandOutput output, { int indent = 0 }) {    
    writeCommandHelp(output, this.argumentString, indent: indent);
  }

  bool hasOption(int opt) {
    return (options & opt) != 0;
  }
}


/// Command that displays or modified values from [AFConfig], and
/// that modifed values under the initialization/afib.g.dart.
class AFConfigCommand extends AFCommand { 
  final configs = Map<String, AFConfigEntry>();
  static const cmdKey = "config";

  AFConfigCommand(): super(AFConfigEntries.afNamespace, cmdKey, 0, 2) {
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

  void writeLongHelp(AFCommandContext ctx, String subCommand) {
    final output = ctx.o;
    writeShortHelp(ctx);
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
  void execute(AFCommandContext ctx) {    
    final args = ctx.args;
    final afibConfig = ctx.afibConfig;
    final output = ctx.output;
    
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
      output.writeErrorLine("Unknown configuration entry $configKey");
      return;
    }

    /// set the value.  this will throw an exception if it is an invalid value.
    afibConfig.setValue(entry, configVal);
    output.writeLine("Set ${entry.codeIdentifier} to $configVal");

    if(!errorIfNotProjectRoot(output)) {
      return;
    }
    
    
    final generateCmd = ctx.commands.generateCmd;
    final configGenerator = generateCmd.configGenerator;
    final files = ctx.files;
    if(!configGenerator.validateBefore(ctx, files)) {
      return;

    }
    configGenerator.execute(ctx, files);    

    files.saveChangedFiles(output);
  }

  @override
  String get shortHelp {
    return "Set the values below, which are written to ${AFProjectPaths.relativePathFor(AFProjectPaths.afibConfigPath)}";
  }
}