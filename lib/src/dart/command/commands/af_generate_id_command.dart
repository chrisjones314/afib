

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';

class AFGenerateIDSubcommand extends AFGenerateSubcommand {

  AFGenerateIDSubcommand();
  
  @override
  String get description => "Declare an ID in the xxx_id.dart file";

  @override
  String get name => "id";

  String get usage {
    return '''
$usageHeader
  $nameOfExecutable generate id XXXKindID.yourWhatever

$descriptionHeader
  $description

$optionsHeader
  None
''';
  }

  @override
  Future<void> execute(AFCommandContext context) async {
    final unnamed = context.rawArgs;
    if(unnamed.isEmpty ) {
      throwUsageError("Expected at least one argument");
    }

    final idName = unnamed[0];
    context.createDeclareId(idName);
        
    // replace any default 
    context.generator.finalizeAndWriteFiles(context);

  }

}