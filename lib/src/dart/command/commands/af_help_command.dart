// @dart=2.9
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

/// Parent for commands executed through the afib command line app.
class AFHelpCommand extends AFCommand { 
  final AFCommands all;

  AFHelpCommand({this.all}): super(AFConfigEntries.afNamespace, "help", 0, 0);

  void execute(AFCommandContext ctx) {    
    final output = ctx.output;
    final args = ctx.args;
    if(this.all.isAfib) {
      
      output.writeSeparatorLine();
      output.writeLine("Note: The afib command is only used for operations that are not application specific.");
      output.writeLine("Look in your project's bin folder for an XX_afib command that has");
      output.writeLine("application-specific commands.");
      output.writeSeparatorLine();
    }

    if(args.count == 0) {
      output.writeLine("AFib commands, use afib help <command> for details: ");
      for(final cmd in all.commands) {
        cmd.writeShortHelp(ctx);
      }
      return;
    }

    if(args.count >= 1) {
      final command = args.first;
      final subCommand = args.second;
      final cmd = all.find(command);
      if(cmd == null) {
        output.writeLine("Unknown command: $command");
      } else {
        cmd.writeLongHelp(ctx, subCommand);
      }
    }
  }

  @override
  String get shortHelp {
    return "show help";
  }
}