
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_call_install.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_import_from_package.t.dart';

class AFEchoCommand extends AFCommand { 
  final name = "echo";
  final description = "Echo text on the command-line, used in project styles";
  static const argWarning = "warning";
  static const argSuccess = "success";

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