
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

typedef void InitCommands(AFCommands commands);

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
abstract class AFCommand extends AFItemWithNamespace { 
  final int minArgs;
  final int maxArgs;
  AFCommand(String namespace, String key, this.minArgs, this.maxArgs): super(namespace, key);

  /// Returns true of [cmd] matches our command name, optionally prefixed with --
  bool matches(String cmd) {
    final String withDash = "--" + namespaceKey;
    return namespaceKey == cmd || withDash == cmd;
  }

  /// Override this to implement the command.   The first item in the list is the command name.
  /// 
  /// [afibConfig] contains only the values from initialization/afib.g.dart, which can be 
  /// manipulated from the command line.
  void execute(AFCommandContext ctx);

  /// Should return a simple help string summarizing the command.
  String get shortHelp;

  bool errorIfNotProjectRoot(AFCommandOutput output) {
    if(!AFProjectPaths.inRootOfAfibProject) {
      output.writeErrorLine("Please run the $namespaceKey command from the project root");
      return false;
    }
    return true;
  }

  /// Briefly describe command usage.
  void writeShortHelp(AFCommandOutput output, { int indent: 0 }) {
    startCommandColumn(output, indent: indent);
    output.write(namespaceKey + " - ");
    startHelpColumn(output);
    output.write(shortHelp);
    output.endLine();
  }


  /// Optionally override this to provide more verbose help for a command,
  /// Which is shown for afib help <command>.  By default, shows the [shortHelp]. 
  void writeLongHelp(AFCommandOutput output, String subCommand) {
    writeShortHelp(output);
  }

  void printError(String text) {
    print("Error: $text");
  }

  static void startCommandColumn(AFCommandOutput output, { int indent = 0 }) {
    int width = 20 + (indent * 4);
    output.startColumn(alignment: AFOutputAlignment.alignRight, width: width);
  }

  static void startHelpColumn(AFCommandOutput output) {
    output.startColumn(alignment: AFOutputAlignment.alignRight);
  }

  static void emptyCommandColumn(AFCommandOutput output) {
    startCommandColumn(output);
    output.write("");
  }

}

class AFCommandContext {
  final AFCommands commands;
  final AFArgs args;
  final AFConfig afibConfig;
  final AFCommandOutput output;

  AFCommandContext(this.commands, this.args, this.afibConfig, this.output);

}

/// The set of all known afib commands.
class AFCommands {
  final List<AFCommand> commands = List<AFCommand>();
  static const afCommandAfib = 1;
  static const afCommandApp  = 2;

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
  void execute(String command, List<String> args, AFConfig afibConfig) {
    final afArgs = AFArgs(args);
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

    try {
      final ctx = AFCommandContext(this, afArgs, afibConfig, output);
      cmd.execute(ctx);
    } catch(e) {
      output.writeErrorLine(e.toString());
    }
  }

}