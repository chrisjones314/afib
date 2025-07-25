import 'dart:convert';
import 'dart:core';

import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/args.dart' as args;
import 'package:collection/collection.dart';

/// Superclass for all configuration definitions.
abstract class AFConfigurationItem {
  static const validContextInternalOnly = 0;
  static const validContextConfigCommand = 1;
  static const validContextNewProjectCommand = 2;
  static const validContextAFibGFile = 4;
  static const validContextsNewProjectAndConfig = validContextNewProjectCommand | validContextAFibGFile;
  static const validContextsAllButNew = validContextConfigCommand | validContextAFibGFile;
  static const validContextsAll = validContextConfigCommand | validContextNewProjectCommand | validContextAFibGFile;

  final AFLibraryID libraryId;
  final String name;
  final String help;
  final dynamic defaultValue;
  final int validContexts;
  final double ordinal;
    
  AFConfigurationItem({ 
    required this.libraryId,
    required this.name, 
    required this.defaultValue,  
    required this.validContexts, 
    required this.help, 
    required this.ordinal 
  }) {
    if(libraryId != AFUILibraryID.id) {
      final prefix = "${libraryId.codeId}_";
      if(!name.startsWith(prefix)) {
        throw AFException("Please start the custom configuration item named $name in $libraryId with the prefix $prefix");
      }
    }
  }

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

  static void sortByOrdinal(List<AFConfigurationItem> items) {
    items.sort((l, r) {
      return l.ordinal.compareTo(r.ordinal);
    });
  }

  String comment() {
      final argParser = args.ArgParser();
      addArguments(argParser);
      final usage = argParser.usage;
      const ls = LineSplitter();
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

  String? codeValue(AFConfig config) {
    dynamic val = config.valueFor(this);
    if(val == null) {
      return null;
    }
    if(val is String) {
      if(val.contains("\n")) {
        return "'''\n$val'''";
      }
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
  String? validate(dynamic value);

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
    final err = validate(value);
    if(err != null) {
      throw AFException("Invalid value $value for $name: $err");
    }
  }
}

/// Used to define choices for a configuration value.
class AFConfigEntryDescription {
  final String textValue;
  final dynamic runtimeValue;
  final String help;
  final String? title;
  AFConfigEntryDescription({
    required this.help,
    required this.textValue,
    required this.runtimeValue,
    this.title,
  });

}


/// Superclass for configuration definitions that offer a list of string values,
/// for example 'debug', 'production', 'test'
class AFConfigurationItemOptionChoice extends AFConfigurationItem {
  static const wildcardValue = "*";
  final choices = <AFConfigEntryDescription>[];
  final bool allowMultiple;
  
  AFConfigurationItemOptionChoice({ 
    required super.libraryId,
    required super.name, 
    required super.defaultValue, 
    required super.validContexts, 
    required super.ordinal, 
    super.help = "", 
    this.allowMultiple = false });

  void addChoiceSection(String title) {
    choices.add(AFConfigEntryDescription(
      textValue: "title",
      runtimeValue: "",
      help: "",
      title: title,
    ));

  }

  void addChoice({
    required String textValue, 
    required String help, 
    dynamic runtimeValue }) {
    runtimeValue ??= name;
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

  String get argumentHelpShort {
    final choicesText = choices.map((c) => c.textValue);
    return choicesText.join("|");
  }

  @override
  String get argumentHelp {
    final choicesText = choices.map((c) => "  ${c.textValue} - ${c.help}");
    return choicesText.join("\n");
  }

  @override
  void addArguments(args.ArgParser argParser) {
    var allowed;
    var allowedHelp;
  
    if(findChoice(wildcardValue) == null) {
       allowed = choices.map((e) => e.textValue);
    }
    if(choices.first.help.isNotEmpty) {
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

  @override
  String? validate(dynamic value) {
    if(value is! List) {
      if(value is! String) {
        return "Expected value for $name to be a list";
      }
      value = value.split("[ ,]");
    }

    if(findChoice(wildcardValue) == null) {
      for(final textValue in value) {
        final choice = findChoice(textValue);
        if(choice == null) {
          return "$textValue is not a valid choice for $name";
        }
      }
    }
    return null;
  }

  AFConfigEntryDescription? findChoice(String val) {
    return choices.firstWhereOrNull((e) => e.textValue == val);
  }
}

/// A configuration item that is a string value.
class AFConfigurationItemString extends AFConfigurationItem {

  AFConfigurationItemString({ 
    required super.libraryId,
    required super.name, 
    required super.validContexts, 
    required super.ordinal, 
    required String super.defaultValue, 
    required super.help 
  });

   @override
  void addArguments(args.ArgParser argParser) {
    argParser.addOption(name, help: help);
   }

  @override
  String? validate(dynamic value) {
    return null;
  }


  @override
  void setValue(AFConfig dest, dynamic value) {
    dest.putInternal(this, value);
  } 
}


/// A configuration item that is a boolean value.
class AFConfigurationItemTrueFalse extends AFConfigurationItemOptionChoice {

  AFConfigurationItemTrueFalse({ 
    required super.libraryId,
    required super.name, 
    required super.validContexts, 
    required super.ordinal, 
    required bool super.defaultValue, 
    required super.help 
  }) {
    addChoice(textValue: "true", runtimeValue: true, help: "");
    addChoice(textValue: "false", runtimeValue: false, help: "");
  }

  @override
  void setValue(AFConfig dest, dynamic value) {
    if(value is String) {
      dest.putInternal(this, value == "true");
    } else {
      dest.putInternal(this, value);
    }
  }
   
}

/// A configuration item that is an integer.
class AFConfigurationItemInt extends AFConfigurationItem {
  final int min;
  final int max;

  AFConfigurationItemInt({ 
    required super.libraryId,
    required super.name, 
    required super.validContexts, 
    required super.ordinal, 
    required int super.defaultValue, 
    required this.min,
    required this.max,
    required super.help 
  });

  @override
  void addArguments(args.ArgParser argParser) {
    argParser.addOption(name, help: help);
  }

  /// Return an error message if the value is invalid, otherwise return null.
  @override
  String? validate(dynamic value) {
    return null;
  }


  @override
  void setValue(AFConfig dest, dynamic value) {
    int? val;
    if(value is String) {
      val = int.tryParse(value);
    } else if(value is int){
      val = value;
    } 

    if(val == null) {
      throw AFException("Unsupported integer value $value for $name");
    }
    if(val < min || val > max) {
      throw AFException("Value $val outside range $min-$max for $name");
    }
    dest.putInternal(this, val);
  }
   
}

/// Superclass for various configuration items that offer a set of options.
class AFConfigurationItemOption extends AFConfigurationItem {
  static const optionLowercase = 1;
  static const optionIdentifier = 2;
  static const optionMixedCase = 4;

  final int maxChars;
  final int minChars;
  final int options;

  AFConfigurationItemOption({
    required super.libraryId,
    required super.name, 
    required super.help, 
    required super.validContexts, 
    required super.ordinal, 
    String super.defaultValue = "",
    this.minChars = -1, 
    this.maxChars = -1, 
    this.options = 0 
  });

  @override
  void addArguments(args.ArgParser argParser) {
    argParser.addOption(name, help: help);
  }

  
  @override
  String? validate(dynamic value) {
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


/// Accessor for values in xxx_config.g.dart, accessible via [AFibD.config].
class AFConfig {
  AFPrototypeID? startupWireframe;
  AFPrototypeID? startupScreenPrototype;
  AFStateTestID? startupStateTestId;
  List<AFBaseTestID>? favoriteTestIds;
  bool isLibraryCommand = false;
  final Map<AFConfigurationItem, dynamic> values = <AFConfigurationItem, dynamic>{};

  void setStartupWireframe(AFPrototypeID id) {
    startupWireframe = id;
  }  

  void setStartupScreenPrototype(AFPrototypeID id) {
    startupScreenPrototype = id;
  }

  void setStartupStateTest(AFStateTestID testId) {
    startupStateTestId = testId;
  }

  void setIsLibraryCommand({required bool isLib}) {
    isLibraryCommand = isLib;
  }

  void setFavoriteTests(List<AFBaseTestID> testIds) {
    favoriteTestIds = testIds;
  }

  AFID get startupPrototypeId {
    final env = environment;
    AFID? proto;
    String? call;
    if(env == AFEnvironment.startupInWireframe) {
      proto = startupWireframe;
      call = "Wireframe";
    } else if(env == AFEnvironment.startupInScreenPrototype) {
      proto = startupScreenPrototype;
      call = "ScreenPrototype";
    } else if(env == AFEnvironment.startupInStateTest) {
      // we need to go through all the 
      proto = startupStateTestId;
    } else { 
      throw AFException("Invalid environment $env for calling startPrototypeId");
    }

    if(proto == null) {
      throw AFException("You set the environment to $env, but you also need to call AFConfig.setStartup$call to specify which prototype to start");
    }
    return proto;
  }
  
  String get appNamespace {
    return stringFor(AFConfigEntries.appNamespace);
  }

  String get packageName { 
    return stringFor(AFConfigEntries.packageName);
  }

  String get fileHeader { 
    return stringFor(AFConfigEntries.generatedFileHeader);
  }

  List<String> get recentTests {
    return stringListFor(AFConfigEntries.testsRecent);
  }

  void establishDefaults() {
    // establish the defaults.
    final all = AFibD.configEntries;
    for(final item in all) {
      if(!values.containsKey(item)) {
        putInternal(item, item.defaultValue);
      }
    }

  }  

  /// This should only be used for validated values of the correct type, you should
  /// use [setValue] in most cases.
  void putInternal(AFConfigurationItem entry, dynamic value) {
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

  bool get isPrototypeEnvironment {
      return ( 
        environment == AFEnvironment.prototype ||
        environment == AFEnvironment.startupInWireframe || 
        environment == AFEnvironment.startupInScreenPrototype || 
        environment == AFEnvironment.startupInStateTest
      );
  }

  

  /// 
  bool get isWidgetTesterContext {
    return boolFor(AFConfigEntries.widgetTesterContext);
  }

  bool get startInDarkMode {
    return boolFor(AFConfigEntries.forceDarkMode);
  }

  bool get enableGenerateAugment {
    return boolFor(AFConfigEntries.enableGenerateAugment);
  }

  bool get generateBeginnerComments {
    return boolFor(AFConfigEntries.generateBeginnerComments);
  }

  bool get generateUIPrototypes {
    return boolFor(AFConfigEntries.generateUIPrototypes);
  }

  bool get strictTranslationMode {
    return boolFor(AFConfigEntries.strictTranslationMode);
  }

  int get absoluteBaseYear {
    return intFor(AFConfigEntries.absoluteBaseYear);
  }

  int get baseSimulatedLatency {
    return intFor(AFConfigEntries.baseSimulatedLatency);
  }

  DateTime get absoluteBaseDate {
    return DateTime(absoluteBaseYear, DateTime.january, 1);
  }

  /// Casts the value for [entry] to a string and returns it.
  String stringFor(AFConfigurationItem entry) {
    return valueFor(entry);
  }

  List<String> stringListFor(AFConfigurationItem entry) {
    final result = valueFor(entry);
    if(result is String) {
      return [result];
    }
    if(result is List) {
      if(result.isEmpty) {
        return <String>[];
      }
      return result.map((x) => x.toString()).toList();
    }
    throw AFException("Unexpected data type ${result.runtimeType} for entry ${entry.name}");
  }

  /// Casts the value for [entry] to a boolean and returns it.
  bool boolFor(AFConfigurationItem entry) {
    return valueFor(entry);
  }

  /// Casts the value for [entry] to a boolean and returns it.
  int intFor(AFConfigurationItem entry) {
    return valueFor(entry);
  }

  dynamic valueFor(AFConfigurationItem entry) {
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
      _addIfMissing(result, AFConfigEntryLogArea.afState);
      _addIfMissing(result, AFConfigEntryLogArea.query);
      _addIfMissing(result, AFConfigEntryLogArea.ui);
    }

    return result;
  }

  Iterable<AFConfigurationItem> get all {
    return values.keys;
  }

  void _addIfMissing(List<String> items, String item) {
    if(!items.contains(item)) {
      items.add(item);
    }
  }
}