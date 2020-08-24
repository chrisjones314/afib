import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

/// Parent for commands executed through the afib command line app.
class AFVersionCommand extends AFCommand { 

  AFVersionCommand(): super(AFConfigEntries.afNamespace, "version", 0, 0);

  void execute(AFCommandContext ctx) {
    ctx.output.writeLine("Afib 0.0.10");
  }


  @override
  String get shortHelp {
    return "display the Afib version";
  }
}