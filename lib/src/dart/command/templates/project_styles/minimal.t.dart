import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class MinimalT extends AFFileSourceTemplate {

  MinimalT(): super(
    templatePath: const <String>[AFProjectPaths.folderProjectStyles, AFCreateAppCommand.projectStyleMinimal],
  );

  String get template => '''
''';

}







