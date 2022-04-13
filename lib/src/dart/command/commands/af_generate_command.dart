import 'package:afib/src/dart/command/af_command.dart';


class AFGenerateParentCommand extends AFCommandGroup {
  final name = "generate";
  final description = "Generate AFib source code for screens, queries, models, and more";
  

  @override
  void execute(AFCommandContext ctx) {

  }
}


abstract class AFGenerateSubcommand extends AFCommand {

}

