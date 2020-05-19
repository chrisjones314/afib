import 'package:afib/src/commands/af_args.dart';
import 'package:afib/src/commands/af_command.dart';

/// Parent for commands executed through the afib command line app.
class VersionCommand extends AFCommand { 

  VersionCommand(): super("version", 0, 0);

  void execute(AFArgs args) {
    print("Afib 0.0.10");
  }

  String shortHelp() {
    return "display the Afib version";
  }
}