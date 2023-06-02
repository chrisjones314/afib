
import 'package:afib/afib_command.dart';

class AFEchoCommand extends AFCommand { 
  @override
  final name = "echo";
  @override
  final description = "Echo text on the command-line, used in project styles";
  static const argWarning = "warning";
  static const argSuccess = "success";

  @override
  String get usage {
    return '''
$usageHeader
  $nameOfExecutable $name --$argWarning [your text]

$descriptionHeader
  $description

$optionsHeader
  --$argWarning - specify warning text to display.
  --$argSuccess - specify success text to display.

''';
  }

  @override
  Future<void> execute(AFCommandContext context) async {
    final args = context.parseArguments(
      command: this, 
      named: {
        argWarning: "",
        argSuccess: "",
      }
    );

    final output = context.output;
    final warning = args.accessNamed(argWarning);
    if(warning.isNotEmpty) {
      output.writeTwoColumnsWarning(col1: "WARNING ", col2: warning);
    }
    final success = args.accessNamed(argSuccess);
    if(success.isNotEmpty) {
      output.writeTwoColumns(col1: "SUCCESS ", col2: success);
    }
  }


}