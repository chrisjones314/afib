

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

class AFGenerateIDSubcommand extends AFGenerateSubcommand {

  AFGenerateIDSubcommand();
  
  @override
  String get description => "Declare an ID in the ${AFibD.config.appNamespace}_id.dart file";

  @override
  String get name => "id";

  String get usage {
    return '''
$usageHeader
  $nameOfExecutable generate id ${AFibD.config.appNamespace.toUpperCase()}{Kind}ID.yourWhatever

$descriptionHeader
  $description
  e.g. generate id ${AFibD.config.appNamespace.toUpperCase()}WidgetID.buttonSaveFile

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