
import 'package:afib/src/commands/af_args.dart';
import 'package:afib/src/commands/environment.dart';
import 'package:afib/src/commands/help.dart';
import 'package:afib/src/commands/version.dart';

//--------------------------------------------------------------------------------
/// Parent for commands executed through the afib command line app.
abstract class AFCommand { 
  final String name;
  final int minArgs;
  final int maxArgs;
  AFCommand(this.name, this.minArgs, this.maxArgs);

  /// Returns true of [cmd] matches our command name, optionally prefixed with --
  bool matches(String cmd) {
    final String withDash = "--" + name;
    return name == cmd || withDash == cmd;
  }

  /// Override this to implement the command.   The first item in the list is the command name.
  void execute(AFArgs args);

  /// Briefly describe command usage.
  String shortHelp();

  /// Optionally override this to provide more verbose help for a command,
  /// Which is shown for afib help <command>.  By default, shows the [shortHelp]. 
  void longHelp() {
    StringBuffer sb = StringBuffer(name);
    sb.write(" - ");
    sb.write(shortHelp());
    printHelp(0, sb.toString());
  }

  /// Utility for printing help with a particular indent level.
  void printHelp(int indentLevel, String text) {
    StringBuffer sb = StringBuffer();
    for(int i = 0; i < indentLevel; i++) {
      sb.write("  ");
    }
    sb.write(text);
    print(sb.toString());
  }

  void printError(String text) {
    print("Error: $text");
  }
}

//--------------------------------------------------------------------------------
/// The set of all known afib commands.
class AFCommands {
  // TODO: Eventually allow other packages to add items to this list, 
  // like rails does.
  final List<AFCommand> commands = List<AFCommand>();

  /// Construct a list of all commands.
  AFCommands() {
    commands.add(HelpCommand(all: this));
    commands.add(VersionCommand());
    commands.add(EnvironmentCommand());
  }

  /// Given "help" or "--help", returns the HelpCommand, etc.
  AFCommand find(String command) {
    return commands.firstWhere((cmd) => cmd.matches(command), orElse: () => null);
  }

  void execute(String command, List<String> args) {
    AFArgs afArgs = AFArgs(args);
    AFCommand cmd = find(command);
    if(cmd == null) {
      print("Unknown command: $command");
      return;
    }

    if(afArgs.count < cmd.minArgs) {
      print("Command $command must have at least ${cmd.minArgs} arguments.");
    }
    if(afArgs.count > cmd.maxArgs) {
      print("Command $command must have at most ${cmd.maxArgs} arguments.");
    }

    cmd.execute(afArgs);
  }

}