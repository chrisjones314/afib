
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
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
  void execute(AFArgs args, AFConfig afibConfig, AFCommandOutput output);

  /// Should return a simple help string summarizing the command.
  String get shortHelp;

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
  void writeLongHelp(AFCommandOutput output) {
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
  /// 
  void register(AFCommand command) {
    commands.add(command);
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
    if(afArgs.count > cmd.maxArgs) {
      output.writeErrorLine("Command $command must have at most ${cmd.maxArgs} arguments.");
    }
    cmd.execute(afArgs, afibConfig, output);
  }

}