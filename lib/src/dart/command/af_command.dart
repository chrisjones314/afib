
// @dart=2.9
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:meta/meta.dart';
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/af_template_registry.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:args/command_runner.dart' as cmd;

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
  AFCommandContext ctx;

  /// Override this to implement the command.   The first item in the list is the command name.
  /// 
  /// [afibConfig] contains only the values from initialization/afib.g.dart, which can be 
  /// manipulated from the command line.
  void run() {
    // make sure we are in the project root.
    if(!errorIfNotProjectRoot(ctx.out)) {
      return;
    }

    execute(ctx);
  }

  void finalize() {}
  void execute(AFCommandContext ctx);

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
  final AFTemplateRegistry templates;
  final AFGeneratorRegistry generators;
  final files = AFGeneratedFiles();
  AFCommandContext({
    @required this.output, 
    @required this.templates, 
    @required this.generators,
    @required this.definitions,
  });

  List<String> unnamedArguments(AFCommand command) {
    return command.argResults.rest;
  }

  AFCommandOutput get out { return output; }
}

/*
/// The set of all known afib commands.
class AFCommands {
  final List<AFCommand> commands = <AFCommand>[];
  static const afCommandAfib = 1;
  static const afCommandApp  = 2;

  /// When you are registerying commands, you can also register your own templates,
  /// or overwrite the existing templates.
  final templates = AFTemplateRegistry();

  final generators = AFGeneratorRegistry();

  /// Either [afCommandAfib] if the command is afib, or [afCommandApp] if this is the 
  /// app-specific command
  final int command;

  /// Create a set of commands which can be executed in the specified [command]
  AFCommands({this.command});

  /// Returns true if this is the native afib command and not the application-specific command.
  bool get isAfib { 
    return command == afCommandAfib;
  }

  /// Register a command.
  /// 
  /// The command will display in the help and be executable.   It will generally
  void register(AFCommand command) {
    commands.add(command);
  }

  /// Access the [AFGenerateCommand] command, which can be modified/extended by third parties.
  AFGenerateCommand get generateCmd {
    return find(AFGenerateCommand.cmdKey);
  }

  /// Access the [AFConfigCommand] command, which can be modified/extended by third parties.
  AFConfigCommand get configCmd {
    return find(AFConfigCommand.cmdKey);
  }

  /// Get the configuration commnd, which can be extended to allow for 3rd party configuration values.
  AFConfigCommand findConfigCommand() {
    return find(AFConfigCommand.cmdKey);
  }

  /// Given "help" or "--help", returns the HelpCommand, etc.
  AFCommand find(String command) {
    return commands.firstWhere((cmd) => cmd.matches(command), orElse: () => null);
  }

  /// Execute a command with the specified arguments.
  void execute(String command, AFArgs afArgs, AFConfig afibConfig) {
    final cmd = find(command);
    final output = AFCommandOutput();

    if(cmd == null) {
      output.writeErrorLine("Unknown command: $command");
      return;
    }

    if(afArgs.count < cmd.minArgs) {
      output.writeErrorLine("Command $command must have at least ${cmd.minArgs} arguments.");
    }
    if(afArgs.count > cmd.maxArgs && cmd.maxArgs != 0) {
      output.writeErrorLine("Command $command must have at most ${cmd.maxArgs} arguments.");
    }

    generators.registerGlobals();
    try {
      final ctx = AFCommandContext(this, afArgs, afibConfig, output, templates, generators);
      cmd.execute(ctx);
    } on Exception catch(e) {
      output.writeErrorLine(e.toString());
    }
  }

}
*/

abstract class AFBaseExtensionContext {
  void registerConfigEntry(AFConfigItem entry) {
    AFibD.registerConfigEntry(entry);
  }
}

class AFCommandThirdPartyExtensionContext extends AFBaseExtensionContext {
  final AFDartParams paramsD;
  final cmd.CommandRunner commands;

  AFCommandThirdPartyExtensionContext({this.paramsD, this.commands});

  /// Used to register a new root level command 
  /// command line.
  void register(AFCommand command) {
    commands.addCommand(command);
  }

  /// Used to register sub-commands on the specified parent command.
  void registerSubcommand(List<String> path, AFCommand command) {
    
  }

  AFGenerateCommand get generateCommand {
    for(final cmd in commands.commands.values) {
      if(cmd is AFGenerateCommand) {
        return cmd;
      }
    }
    return null;
  }

  void finalize(AFCommandContext context) {
    for(final command in commands.commands.values) {
      if(command is AFCommand) {
        command.ctx = context;
        command.finalize();
      }
    }
  }

}

class AFCommandExtensionContext extends AFCommandThirdPartyExtensionContext {
  AFCommandExtensionContext({AFDartParams paramsD, cmd.CommandRunner commands}):
    super(paramsD: paramsD, commands: commands);

    void execute(List<String> args) {
      commands.run(args);
    }
}