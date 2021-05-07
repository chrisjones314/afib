import 'package:afib/src/dart/command/af_command.dart';
import 'package:args/args.dart' as args;

/// Parent for commands executed through the afib command line app.
class AFVersionCommand extends AFCommand { 

  final String name = "version";
  final String description = "The version of the app";

  AFVersionCommand();

  @override
  void registerArguments(args.ArgParser argParser) {

  }

  void execute(AFCommandContext ctx) {
    ctx.output.writeLine("Afib 0.0.10");
  }
}