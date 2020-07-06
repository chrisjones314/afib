import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

/// Parent for commands executed through the afib command line app.
class AFHelpCommand extends AFCommand { 
  final AFCommands all;

  AFHelpCommand({this.all}): super(AFConfigEntries.afNamespace, "help", 0, 0);

  void execute(AFArgs args, AFConfig afibConfig, AFCommandOutput output) {    

    if(this.all.isAfib) {
      output.writeSeparatorLine();
      output.writeLine("Note: The afib command is only used for operations that are not application specific.");
      output.writeLine("Look in your project's bin folder for an XX_afib command that has");
      output.writeLine("application-specific commands.");
      output.writeSeparatorLine();
    }

    if(args.count == 0) {
      output.writeLine("AFib commands, use afib help <command> for details: ");
      all.commands.forEach((cmd) {
        cmd.writeShortHelp(output);
      });
      return;
    }

    if(args.count >= 1) {
      String command = args.first;
      String subCommand = args.second;
      AFCommand cmd = all.find(command);
      if(cmd == null) {
        output.writeLine("Unknown command: $command");
      } else {
        cmd.writeLongHelp(output, subCommand);
      }
    }
  }

  @override
  String get shortHelp {
    return "show help";
  }
}