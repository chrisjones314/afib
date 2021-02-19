import 'dart:convert';

import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:args/args.dart' as args;

/// Superclass for all configuration definitions.
abstract class AFConfigItem {
  static const validContextInternalOnly = 0;
  static const validContextConfigCommand = 1;
  static const validContextNewProjectCommand = 2;
  static const validContextAFibGFile = 4;
  static const validContextsNewProjectAndConfig = validContextNewProjectCommand | validContextAFibGFile;
  static const validContextsAllButNew = validContextConfigCommand | validContextAFibGFile;
  static const validContextsAll = validContextConfigCommand | validContextNewProjectCommand | validContextAFibGFile;

  final String name;
  final String help;
  final dynamic defaultValue;
  final int validContexts;
  final double ordinal;
    
  AFConfigItem({ 
    @required this.name, 
    @required this.defaultValue,  
    @required this.validContexts, 
    @required this.help, 
    @required this.ordinal 
  });

  String get codeIdentifier {
    return name;
  }

  String get argumentString {
    return name;
  }

  String get argumentHelp {
    return "";
  }

  bool allowedIn(int validContext) {
    return (validContext & validContexts) != 0;
  }

  static void sortByOrdinal(List<AFConfigItem> items) {
    items.sort((l, r) {
      return l.ordinal.compareTo(r.ordinal);
    });
  }

  String comment() {
      final argParser = args.ArgParser();
      addArguments(argParser);
      final usage = argParser.usage;
      final ls = LineSplitter();
      final lines = ls.convert(usage);
      final result = StringBuffer();
      for(var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if(i > 0) {
          result.writeln();
          result.write("  ");
        }
        result.write("// $line");
      }
      return result.toString();
  }

  String codeValue(AFConfig config) {
    dynamic val = config.valueFor(this);
    if(val == null) {
      return null;
    }
    if(val is String) {
      return "\"$val\"";
    }
    if(val is List) {
      final result = StringBuffer("[");
      for(var i = 0; i < val.length; i++) {
        final item = val[i];
        if(i > 0) {
          result.write(', ');
        } 
        result.write('"$item"');
      }
      result.write("]");
      return result.toString();
    }
    return val.toString();
  }

  void addArguments(args.ArgParser argParser);
  
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
  
  void validateWithException(String value) {
    final val = validate(value);
    if(val != null) {
      throw AFException("Invalid value $value for $name");
    }
  }
}

/// Used to define choices for a configuration value.
class AFConfigEntryDescription {
  final String textValue;
  final dynamic runtimeValue;
  final String help;
  AFConfigEntryDescription({
    @required this.help,
    @required this.textValue,
    @required this.runtimeValue,
  });

}


/// Superclass for configuration definitions that offer a list of string values,
/// for example 'debug', 'production', 'test'
class AFConfigEntryOptionChoice extends AFConfigItem {
  static const wildcardValue = "*";
  final choices = <AFConfigEntryDescription>[];
  final bool allowMultiple;
  
  AFConfigEntryOptionChoice({ 
    @required String name, 
    @required dynamic defaultValue, 
    @required int validContexts, 
    @required double ordinal, 
    String help, 
    this.allowMultiple = false }): super(
      name: name, 
      defaultValue: defaultValue, 
      validContexts: validContexts, 
      ordinal: ordinal, 
      help: help
    );

  void addChoice({@required String textValue, String help, dynamic runtimeValue }) {
    if(runtimeValue == null) {
      runtimeValue = name;
    }
    choices.add(AFConfigEntryDescription(
      textValue: textValue,
      runtimeValue: runtimeValue,
      help: help
    ));
  }  

  void addWildcard(String help) {
    choices.add(AFConfigEntryDescription(
      textValue: wildcardValue,
      runtimeValue: wildcardValue,
      help: help,
    ));
  }

  void addArguments(args.ArgParser argParser) {
    var allowed;
    var allowedHelp;
  
    if(findChoice(wildcardValue) == null) {
       allowed = choices.map((e) => e.textValue);
    }
    if(choices.first.help != null) {
      allowedHelp = <String, String>{};

      for(final choice in choices) {
        allowedHelp[choice.textValue] = choice.help;
      }
    }

    if(allowMultiple) {
      argParser.addMultiOption(name,
        help: help,
        allowed: allowed,
        allowedHelp: allowedHelp);
    } else {
      argParser.addOption(name, 
        help: help,
        allowed: allowed,
        allowedHelp: allowedHelp,
      );
    }
    
    
  }

  String validate(dynamic listValue) {
    if(listValue is! List) {
      if(listValue is! String) {
        return "Expected value for $name to be a list";
      }
      listValue = listValue.split("[ ,]");
    }

    if(findChoice(wildcardValue) == null) {
      for(final textValue in listValue) {
        final choice = findChoice(textValue);
        if(choice == null) {
          return "$textValue is not a valid choice for $name";
        }
      }
    }
    return null;
  }

  AFConfigEntryDescription findChoice(String val) {
    return choices.firstWhere((e) => e.textValue == val, orElse: () => null);
  }
}



class AFConfigEntryFlag extends AFConfigEntryOptionChoice {

  AFConfigEntryFlag({ 
    @required String name, 
    @required int validContexts, 
    @required double ordinal, 
    @required bool defaultValue, 
    @required String help 
  }): super(
    name: name, 
    defaultValue: defaultValue, 
    validContexts: validContexts, 
    ordinal: ordinal, help: help
  ) {
    addChoice(textValue: "true", runtimeValue: true);
    addChoice(textValue: "false", runtimeValue: false);
  }

  void setValue(AFConfig dest, dynamic value) {
    if(value is String) {
      dest.putInternal(this, value == "true");
    } else {
      dest.putInternal(this, value);
    }
  }
   
}

class AFConfigEntryOption extends AFConfigItem {
  static const optionLowercase = 1;
  static const optionIdentifier = 2;
  static const optionMixedCase = 4;

  final int maxChars;
  final int minChars;
  final String help;
  final int options;

  AFConfigEntryOption({
    @required String name, 
    this.help, 
    @required int validContexts, 
    @required double ordinal, 
    String defaultValue = "",
    this.minChars = -1, 
    this.maxChars = -1, 
    this.options = 0 
  }): super(
    name: name, 
    help: help,
    validContexts: validContexts, 
    ordinal: ordinal,
    defaultValue: defaultValue,
  );

  void addArguments(args.ArgParser argParser) {
    argParser.addOption(name, help: help);
  }

  
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

  bool hasOption(int opt) {
    return (options & opt) != 0;
  }
}


/// Command that displays or modified values from [AFConfig], and
/// that modifed values under the initialization/afib.g.dart.
class AFConfigCommand extends AFCommand { 
  final name = "config";
  final description = "Set configuration values in afib.g.dart";

  AFConfigCommand(): super() {

    /*
    argParser.addOption("environment", 
      allowed: ["production", "test", "debug", "prototype"],
      allowedHelp: {
        "production": "Used for running in production",
        "test": "Used during command-line testing, not usually used by developers directly",
        "debug": "Used when running the app in debug mode",
        "prototype": "Used to run the app in prototype mode"
      }
    );
    */
    //registerEntry(AFConfigEntries.logAreas);
  }

  @override
  void finalize() {
    for(final option in AFibD.configEntries) {
      if(option.allowedIn(AFConfigItem.validContextConfigCommand)) {
        option.addArguments(argParser);
      }
    }
  }

  static void updateConfig(AFCommandContext ctx, AFConfig config, List<AFConfigItem> items, args.ArgResults argResults) {
    final output = ctx.output;
    // go through all the options that were set, and convert them into values
    // in the config.
    for(final entry in items) {
      if(!entry.allowedIn(AFConfigItem.validContextConfigCommand)) {
        continue;
      }
      final key = entry.name;
      final value = argResults[key];
      if(value == null) {
        continue;
      }

      if(value is List && value.isEmpty) {
        continue;
      }

      final error = entry.validate(value);
      if(error != null) {
        output.writeErrorLine(error);
        return;
      }

      entry.setValue(config, value);
    }
  } 
  
  @override
  void execute(AFCommandContext ctx) {    
    final output = ctx.output;

    updateConfig(ctx, AFibD.config, AFibD.configEntries, argResults);



    // now, write out that configuration to the afib.g.dart file.
    final generateCmd = ctx.definitions.generateCommand;
    final configGenerator = generateCmd.configGenerator;
    final files = ctx.files;
    if(!configGenerator.validateBefore(ctx, files)) {
      return;
    }
    configGenerator.execute(ctx, files);    

    files.saveChangedFiles(output);
  }
}