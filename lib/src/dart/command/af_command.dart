import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_screen_command.dart';
import 'package:afib/src/dart/command/commands/af_test_command.dart';
import 'package:afib/src/dart/command/commands/af_version_command.dart';
import 'package:afib/src/dart/command/templates/af_template_registry.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/args.dart' as args;
import 'package:args/command_runner.dart' as cmd;
import 'package:collection/collection.dart';

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

/// Parent for commands executed through the afib command line app.
abstract class AFCommand extends cmd.Command { 
  AFCommandContext? ctx;

  /// Override this to implement the command.   The first item in the list is the command name.
  /// 
  /// [afibConfig] contains only the values from initialization/afib.g.dart, which can be 
  /// manipulated from the command line.
  void run() {
    final ctxLocal = ctx;
    if(ctxLocal == null) return;

    // make sure we are in the project root.
    if(!errorIfNotProjectRoot(ctxLocal.out)) {
      return;
    }

    ctxLocal.arguments = argResults;
    execute(ctxLocal);
  }

  void finalize() {}
  void execute(AFCommandContext ctx);
  void registerArguments(args.ArgParser parser);

  bool errorIfNotProjectRoot(AFCommandOutput output) {
    if(!AFProjectPaths.inRootOfAfibProject) {
      output.writeErrorLine("Please run the $name command from the project root");
      return false;
    }
    return true;
  }  
}

class AFCommandContext {
  final AFCommandExtensionContext definitions;
  final AFCommandOutput output;
  final AFCodeGenerator generator;
  args.ArgResults? arguments;

  AFCommandContext({
    required this.output, 
    required this.definitions,
    required this.generator
  });

  List<String>? get unnamedArguments {
    return arguments?.rest;
  }

  AFCommandOutput get out { return output; }
}


class AFBaseExtensionContext {
  void registerConfigurationItem(AFConfigurationItem entry) {
    AFibD.registerConfigEntry(entry);
  }
}

class AFCommandThirdPartyExtensionContext extends AFBaseExtensionContext {
  final AFDartParams paramsD;
  final cmd.CommandRunner commands;
  final AFTemplateRegistry templates;

  AFCommandThirdPartyExtensionContext({
    required this.paramsD, 
    required this.commands, 
    required this.templates, 
  });

  /// Used to register a new root level command 
  /// command line.
  void register(AFCommand command) {
    commands.addCommand(command);
  }

  

  // Used to register a subcommand of afib.dart generate...
  void registerGenerateSubcommand(AFGenerateSubcommand generate) {
    final cmd = findCommandByType<AFGenerateParentCommand>();
    if(cmd == null) return;
    cmd.addSubcommand(generate);
  }

  AFCommand? findCommandByType<T extends AFCommand>() {
    final result = commands.commands.values.firstWhereOrNull((c) => c is T);
    return result as AFCommand?;
  }

  void finalize(AFCommandContext context) {
    for(final command in commands.commands.values) {
      if(command is AFCommand) {
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
  }

}

class AFCommandExtensionContext extends AFCommandThirdPartyExtensionContext {
  AFCommandExtensionContext({
    required AFDartParams paramsD, 
    required cmd.CommandRunner commands
  }): super(
      paramsD: paramsD, 
      commands: commands,
      templates: AFTemplateRegistry()
    );

    Future<void> execute(AFCommandOutput output, List<String> args) async {
      try {
        await commands.run(args);
      } on AFCommandError catch(e) {
        output.writeErrorLine("Aborted because: $e");
      }
    }

    void registerStandardCommands() {
      register(AFVersionCommand());
      register(AFConfigCommand());
      register(AFGenerateParentCommand());
      register(AFTestCommand());

      registerGenerateSubcommand(AFGenerateScreenSubcommand());
    }
}