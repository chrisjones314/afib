import 'package:afib/src/commands/af_command.dart';
import 'package:afib/src/commands/af_args.dart';

/// Parent for commands executed through the afib command line app.
class HelpCommand extends AFCommand { 
  final AFCommands all;

  HelpCommand({this.all}): super("help", 0, 1);

  void execute(AFArgs args) {    

    if(args.count == 0) {
      printHelp(0, "AFib commands, use afib help <command> for details: ");
      all.commands.forEach((cmd) {
        printHelp(1, "${cmd.name} - ${cmd.shortHelp()}");
      });
      return;
    }

    if(args.count == 1) {
      String command = args.first;
      AFCommand cmd = all.find(command);
      if(cmd == null) {
        printHelp(0, "Unknown command: $command");
      } else {
        cmd.longHelp();
      }
    }
  }

  @override
  String shortHelp() {
    return "show help";
  }
}