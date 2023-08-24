import 'package:afib/src/dart/command/af_command.dart';

/// Parent for commands executed through the afib command line app.
class AFVersionCommand extends AFCommand { 

  @override
  final String name = "version";
  @override
  final String description = "The version of the app";

  AFVersionCommand();

  @override
  Future<void> execute(AFCommandContext context) async {
    context.output.writeLine("AFib 0.5.0");
  }
}