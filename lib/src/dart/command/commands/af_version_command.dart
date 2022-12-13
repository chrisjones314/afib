import 'package:afib/src/dart/command/af_command.dart';

/// Parent for commands executed through the afib command line app.
class AFVersionCommand extends AFCommand { 

  final String name = "version";
  final String description = "The version of the app";

  AFVersionCommand();

  @override
  Future<void> execute(AFCommandContext context) async {
    context.output.writeLine("Afib 0.0.10");
  }
}