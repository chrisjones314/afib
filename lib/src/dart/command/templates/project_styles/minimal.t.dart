import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class MinimalT extends AFProjectStyleSourceTemplate {

  MinimalT(): super(
    templateFileId: AFCreateAppCommand.projectStyleMinimal,
  );

  String get template => '''
''';

}







