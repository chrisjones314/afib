import 'dart:io';

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_query_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_state_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';
import 'package:afib/src/dart/command/commands/af_integrate_command.dart';
import 'package:afib/src/dart/command/commands/af_override_command.dart';
import 'package:afib/src/dart/command/commands/af_test_command.dart';
import 'package:afib/src/dart/command/commands/af_version_command.dart';
import 'package:afib/src/dart/command/templates/af_template_registry.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/args.dart' as args;
import 'package:collection/collection.dart';
import 'package:path/path.dart';

class AFItemWithNamespace {
  /// The namespace used to differentiate third party commands.
  final String namespace;

  /// The name of the command itself (e.g. help)
  /// 
  /// Note that packages which are not native to afib must be referenced
  /// using package:command as the command.
  final String key;
  
  AFItemWithNamespace(this.namespace, this.key);

  String get namespaceKey {
    final sb = StringBuffer();
    if(namespace != AFConfigEntries.afNamespace) {
      sb.write(namespace);
      sb.write(":");
    }
    sb.write(key);
    return sb.toString();
  }

  static List<T> sortIterable<T extends AFItemWithNamespace>(Iterable<T> it) {
    final result = List<T>.of(it);
    result.sort((l, r) {
      return l.namespaceKey.compareTo(r.namespaceKey);
    });
    return result;
  }

}

class AFCommandArgumentsParsed {
  static const argTrue = "true";
  final List<String> unnamed;
  final Map<String, String?> named;

  AFCommandArgumentsParsed({
    required this.unnamed,
    required this.named,
  });
}

/// Parent for commands executed through the afib command line app.
abstract class AFCommand { 
  static const optionPrefix = "--";
  static const argPrivate = "private";
  static const argPrivateOptionHelp = "--${AFCommand.argPrivate} - if specified for a library, does not export the generated class via [YourAppNamespace]_flutter.dart";
  
  
  final subcommands = <String, AFCommand>{};

  String get name;
  String get description;
  String get usage {
    return "";
  }

  String get usageHeader {
    return "Usage";
  }

  String get descriptionHeader {
    return "Description";
  }

  String get optionsHeader {
    return "Options";
  }

  String get nameOfExecutable {
    return "bin/${AFibD.config.appNamespace}_afib.dart";
  }

  /// Override this to implement the command.   The first item in the list is the command name.
  /// 
  /// [afibConfig] contains only the values from initialization/afib.g.dart, which can be 
  /// manipulated from the command line.
  void run(AFCommandContext ctx) {
    // make sure we are in the project root.
    if(!errorIfNotProjectRoot(ctx)) {
      return;
    }

    execute(ctx);
  }

  void addSubcommand(AFCommand cmd) {
    subcommands[cmd.name] = cmd;
  }

  void finalize() {}
  void execute(AFCommandContext context);

  bool errorIfNotProjectRoot(AFCommandContext ctx) {
    if(!AFProjectPaths.inRootOfAfibProject(ctx)) {
      ctx.output.writeErrorLine("Please run the $name command from the project root");
      return false;
    }
    return true;
  }  

  Never throwUsageError(String error) {
    throw AFCommandError(error: error, usage: usage);
  }

  static Never throwUsageErrorStatic(String error, String usage) {
    throw AFCommandError(error: error, usage: usage);
  }

  String verifyEndsWith(String value, String endsWith) {
    if(!value.endsWith(endsWith)) {
      throwUsageError("$value must end with $endsWith");
    }
    return value;
  }

  void verifyEndsWithOneOf(String value, List<String> suffixes) {
    for(final suffix in suffixes) {
      if(value.endsWith(suffix)) {
        return;
      }
    }
    throwUsageError("$value must end with one of $suffixes");
  }

  void verifyAllUppercase(String value) {
    for(var i = 0; i < value.length; i++) {
      final c = value[i];
      if(c != c.toUpperCase()) {
        throwUsageError("Expected $value to be all uppercase");
      }
    }
  }

  void verifyOneOf(String value, List<String> oneOf) {
    final found = oneOf.contains(value);
    if(!found) {
      throwUsageError("Expected $value to be one of $oneOf");
    }

  }


  void verifyAllLowercase(String value) {
    for(var i = 0; i < value.length; i++) {
      final c = value[i];
      if(c != c.toLowerCase()) {
        throwUsageError("Expected $value to be all lowercase");
      }
    }
  }


  String convertToPrefix(String value, String suffix) {
    final lower = suffix.toLowerCase();
    final prefix = value.substring(0, value.length-suffix.length);
    return "$lower$prefix";
  }

  void verifyMixedCase(String value, String valueKindInError) {
    if(value[0].toUpperCase() != value[0]) {
      throwUsageError("The $valueKindInError should be mixed case");
    }
  }

  void verifyNotOption(String value) {
    if(value.startsWith(optionPrefix)) {
      throwUsageError("Options must come after other values in the command");
    }
  }

  AFCommandArgumentsParsed parseArguments(List<String> source, {
    required Map<String, String?> defaults
  }) {
    final unnamed = <String>[];
    final named = Map<String, String?>.from(defaults);

    for(var i = 0; i < source.length; i++) {
      final arg = source[i];
      if(arg.startsWith(optionPrefix)) {
        var argValue = AFCommandArgumentsParsed.argTrue;
        if((i+1 < source.length)) {
          final next = source[i+1];
          if(!next.startsWith(optionPrefix)) {
            argValue = next;
            i++;
          }
        }
        final argEntry = arg.substring(2);
        named[argEntry] = argValue;
      } else {
        unnamed.add(arg);
      }
    }

    return AFCommandArgumentsParsed(
      named: named,
      unnamed: unnamed,
    );

    /*
    final result = Map<String, dynamic>.from(defaults);
    result[argPrivate] = false;
    var startWith = 0;
    while(startWith < source.length) {
      final arg = source[startWith];
      if(arg.startsWith(optionPrefix)) {
        break;
      }
      startWith++;
    }

    var i = startWith;
    while(i < source.length) {
      final value = source[i];
      final valueNext = source.length > (i+1) ? source[i+1] : null; 
      i++;
      if(value.startsWith(optionPrefix)) {
        final key = value.substring(2);
        if(valueNext == null || valueNext.startsWith(optionPrefix)) {
          result[key] = true;
        } else {
          result[key] = valueNext;
          i++;
        }        
      }
    }
    return result;
    */
  }

  void verifyDoesNotEndWith(String value, String excluded) {
    if(value.endsWith(excluded)) {
      throwUsageError("Please do not add '$excluded' to the end of $value, AFib will add it for you");
    }
  }

  void verifyUsageOption(String value, List<String> options) {
    if(options.contains(value)) {
      return;
    }

    final msg = StringBuffer("$value must be one of (");
    for(final key in options) {
      msg.write(key);
      msg.write(", ");
    }    
    msg.write(")");
    throwUsageError(msg.toString());
  }

  AFGeneratedFile createStandardFile(AFCommandContext ctx, List<String> path, AFUISourceTemplateID templateId) {
    final appCommandFile = ctx.generator.createFile(ctx, path, templateId);
    appCommandFile.executeStandardReplacements(ctx);
    return appCommandFile;
  }

}

abstract class AFCommandGroup extends AFCommand {

  @override 
  String get usage {
    final result = StringBuffer();
    result.write('''
Usage 
  afib $name <subcommand>...

Available subcommands
''');


    for(final sub in subcommands.values) {
      result.write("  ${sub.name} - ${sub.description}\n");
    }
    
    return result.toString();
  }

}

class AFCommandContext {
  final List<AFCommandContext> parents;
  final AFCommandAppExtensionContext definitions;
  final AFCommandOutput output;
  final AFCodeGenerator generator;
  final args.ArgResults arguments;
  final AFSourceTemplateInsertions? coreInsertions;

  int commandArgCount = 1;

  AFCommandContext({
    required this.parents,
    required this.output, 
    required this.definitions,
    required this.generator,
    required this.arguments,
    this.coreInsertions,
  });

  bool get isRootCommand => parents.isEmpty;

  factory AFCommandContext.withArguments({
    required AFCommandAppExtensionContext definitions,
    required AFCommandOutput output,
    required AFCodeGenerator generator,
    required AFArgs arguments,
    required AFSourceTemplateInsertions? coreInsertions,
    List<AFCommandContext>? parents
  }) {
    final parsed = args.ArgParser.allowAnything();
    final argsParsed = parsed.parse(arguments.args);
    return AFCommandContext(
      parents: parents ?? <AFCommandContext>[],
      output: output, 
      definitions: definitions, 
      generator: generator, 
      arguments: argsParsed,
      coreInsertions: coreInsertions
    );
  }

  AFCommandContext reviseWithArguments({
    required AFSourceTemplateInsertions? insertions,
    required AFArgs arguments,
  }) {
    final revisedParents = parents.toList();
    revisedParents.add(this);
    var revisedArgs = arguments;
    if(isExportTemplates) {
      revisedArgs = revisedArgs.reviseAddArg("--${AFGenerateSubcommand.argExportTemplatesFlag}");
    }

    return AFCommandContext.withArguments(
      parents: revisedParents,
      output: this.output,
      definitions: this.definitions,
      generator: this.generator,
      arguments: revisedArgs,
      coreInsertions: insertions,   
    );
  }

  void startRoot() {
    if(!isRootCommand) {
      return;
    } 

    if(isExportTemplates) {
      output.writeTwoColumns(col1: "detected ", col2: "--export-templates");
    }

    var override = findArgument(AFGenerateSubcommand.argOverrideTemplatesFlag);
    if(override != null) {
      output.writeTwoColumns(col1: "detected ", col2: "--template-overrides: $override");
    }
  }

  AFCodeBuffer createSnippet(
    AFSourceTemplate source, {
      AFSourceTemplateInsertions? extend,
      Map<AFSourceTemplateInsertion, Object>? insertions
    }
  ) {
    var fullInsert = this.coreInsertions;
    if(insertions != null) {
      fullInsert = fullInsert?.reviseAugment(insertions);
    }
    if(extend != null) {
      fullInsert = fullInsert?.reviseAugment(extend.insertions);
    }
    return source.toBuffer(this, insertions: fullInsert?.insertions);
  }

  AFGeneratedFile createFile(
    List<String> projectPath,
    AFFileSourceTemplate template, { 
      AFSourceTemplateInsertions? extend,
      Map<AFSourceTemplateInsertion, Object>? insertions 
    })  {
    var fullInsert = this.coreInsertions;
    if(insertions != null) {
      fullInsert = fullInsert?.reviseAugment(insertions);
    }
    if(extend != null) {
      fullInsert = fullInsert?.reviseAugment(extend.insertions);
    }
    return generator.createFile(this, projectPath, template, insertions: fullInsert);
  }

  Object? findArgument(String key) {
    final args = arguments.rest;
    for(var i = 0; i < args.length; i++) {
      final arg = args[i];
      if(arg.startsWith(AFCommand.optionPrefix) && arg.endsWith(key)) {
        final next = args.length > (i+1) ? args[i+1] : null;
        if(next == null || next.startsWith(AFCommand.optionPrefix)) {
          return true;
        } 
        return next;
      }
    }
    return null;
  }

  bool get isExportTemplates {
    return findArgument(AFGenerateSubcommand.argExportTemplatesFlag) != null;
  }

  List<String> findOverrideTemplate(List<String> sourceTemplate) {
    var override = findArgument(AFGenerateSubcommand.argOverrideTemplatesFlag);
    if(override == null || override is! String) {
      return sourceTemplate;
    }

    final sourcePath = joinAll(sourceTemplate);

    override = override.replaceAll('"', "");
    override = override.replaceAll(".tdart", "");

    final overrides = override.split(",");
    for(final overrideAssign in overrides) {
      final assign = overrideAssign.split("=");
      if(assign.length != 2) {
        throw AFException("Expected $overrideAssign to have the form a=b");
      }
      final left = assign[0];
      final right = assign[1];
      if(left == sourcePath) {
        output.writeTwoColumns(col1: "override ", col2: "$left -> $right");
        return right.split(Platform.pathSeparator);
      }
    }
    return sourceTemplate;
  }

  AFFileSourceTemplate? findEmbeddedTemplate(List<String> path) {
    return this.definitions.templates.findEmbeddedTemplate(path);
  }

  void setCommandArgCount(int count) {
    commandArgCount = count;
  }
  List<String> get rawArgs {
    return arguments.arguments.slice(commandArgCount);
  }

  AFCommandOutput get out { return output; }
}


class AFBaseExtensionContext {
  void registerLibrary(AFLibraryID id) {
    AFibD.registerLibrary(id);
  }
  void registerConfigurationItem(AFConfigurationItem entry) {
    AFibD.registerConfigEntry(entry);
  }
}

class AFCommandLibraryExtensionContext extends AFBaseExtensionContext {
  final AFDartParams paramsD;
  final AFCommandRunner commands;
  final AFTemplateRegistry templates;

  AFCommandLibraryExtensionContext({
    required this.paramsD, 
    required this.commands, 
    required this.templates, 
  });

  /// Used to register a new root level command 
  /// command line.
  AFCommand defineCommand(AFCommand command, { bool hidden = false }) {
    if(hidden) {
      commands.addHiddenCommand(command);
    } else {
      commands.addCommand(command);
    }
    return command;
  }
  
  AFCommand? findCommandByType<T extends AFCommand>() {
    final result = commands.all.firstWhereOrNull((c) => c is T);
    return result;
  }

  /*
  void finalize(AFCommandContext context) {
  for(final command in commands.all) {
      command.ctx = context;
      command.registerArguments(command.argParser);
      command.finalize();

      for(final sub in command.subcommands.values) {
        if(sub is AFCommand) {
          sub.ctx = context;
          sub.registerArguments(sub.argParser);
          sub.finalize();
        }
      }
    }
    
  }
  */

}

class AFCommandRunner {
  List<AFCommand> commands = <AFCommand>[];
  List<AFCommand> commandsHidden = <AFCommand>[];
  final String name;
  final String description;
  AFCommandRunner(this.name, this.description);

  List<AFCommand> get all {
    return commands;
  }

  void run(AFCommandContext ctx) {
    final args = ctx.arguments.arguments;
    if(args.isEmpty) {
      printUsage();
      return;
    }

    final commandName = args.first;
    final command = findByName(commandName);
    if(command == null) {
      printUsage(error: "Unknown command $commandName");
      return;
    }

    if(command.subcommands.isNotEmpty) {
      if(args.length < 2) {
        printUsage(error: "Command $commandName expects a subcommand", command: command);
        return;
      }
      final subcommandName = args[1];
      final subcommand = command.subcommands[subcommandName];
      if(subcommand == null) {
        printUsage(error: "Command $commandName does not have a subcommand named $subcommandName, command: command");
        return;
      }
      ctx.setCommandArgCount(2);
      subcommand.run(ctx);
    } else {
      ctx.setCommandArgCount(1);
      command.run(ctx);
    }
  }

  void printUsage({
    String? error,
    AFCommand? command,
  }) {
    final result = StringBuffer();
    
    if(command != null) {
      result.write(command.usage);
    } else {
      result.write('''
$description

Usage: $name <command> [arguments]

Available Commands
''');
      for(final command in commands) {
        result.write("  ${command.name} - ${command.description}\n");
      }
    }

    if(error != null) {
      result.write("$error\n");
    }
    print(result.toString());
  }

  AFCommand? findByName(String name) {
    var result = commands.firstWhereOrNull((c) => c.name == name);
    if(result == null) {
      result = commandsHidden.firstWhereOrNull((c) => c.name == name);
    }
    return result;
  }

  void addCommand(AFCommand command) {
    commands.add(command);
  }

  void addHiddenCommand(AFCommand command) {
    commandsHidden.add(command);
  }

}

class AFHelpCommand extends AFCommand {
  final name = "help";
  final description = "Show help for other commands";
  
  
  final usage = "afib help <command> [<subcommand>]";

  bool errorIfNotProjectRoot(AFCommandContext ctx) {
    return true;
  }

  void printFullUsage(AFCommandContext ctx) {
    final result = StringBuffer('''
Usage: $usage

Available commands:
''');

    for(final command in ctx.definitions.commands.all) {
      result.writeln("  ${command.name} - ${command.description}");
    }

    result.writeln("\nNote: to create a new afib project, use the afib_bootstrap command");
    print(result.toString());
  }

  void execute(AFCommandContext ctx) {
    final args = ctx.arguments.arguments;
    if(args.length < 2) {
      printFullUsage(ctx);
      return;
    }

    final cmdName = args[1];
    final command = ctx.definitions.commands.findByName(cmdName);
    if(command == null) {
      print("Error: Unknown command $cmdName");
      return;
    } else {
      if(args.length > 2) {
        final subcommandName = args[2];
        final subcommand = command.subcommands[subcommandName];
        if(subcommand == null) {
          print("Error: Unknown subcommand $subcommandName");
          return;
        } else {
          print(subcommand.usage);
        }
      } else {
        print(command.usage);
      }
    }
  }
}


class AFCommandAppExtensionContext extends AFCommandLibraryExtensionContext {
  AFCommandAppExtensionContext({
    required AFDartParams paramsD, 
    required AFCommandRunner commands
  }): super(
      paramsD: paramsD, 
      commands: commands,
      templates: AFTemplateRegistry()
    );

    Future<void> execute(AFCommandContext context) async {
      final output = context.output;
      try {
        commands.run(context);
      } on AFCommandError catch(e) {
        final usage = e.usage;
        if(usage != null && usage.isNotEmpty) {
          output.writeLine(usage);
        }
        output.writeErrorLine(e.error);
      }
    }


    void registerBootstrapCommands() {
      defineCommand(AFHelpCommand());
      defineCommand(AFVersionCommand());
      defineCommand(AFCreateAppCommand());
      _defineGenerateCommand(hidden: true);
    }


    void registerStandardCommands() {
      //register(AFVersionCommand());
      defineCommand(AFConfigCommand());
      _defineGenerateCommand(hidden: false);
      defineCommand(AFTestCommand());
      defineCommand(AFHelpCommand());
      defineCommand(AFInstallCommand());
      defineCommand(AFOverrideCommand());
    }

    void _defineGenerateCommand({ required bool hidden }) {
      final generateCmd = defineCommand(AFGenerateParentCommand(), hidden: hidden);
      generateCmd.addSubcommand(AFGenerateUISubcommand());
      generateCmd.addSubcommand(AFGenerateStateSubcommand());
      generateCmd.addSubcommand(AFGenerateQuerySubcommand());
      generateCmd.addSubcommand(AFGenerateCommandSubcommand());      
    }
}