import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StateLibStarterMinimalT extends AFProjectStyleSourceTemplate {

  StateLibStarterMinimalT(): super(
    templateFileId: AFCreateAppCommand.projectStyleStateLibStarterMinimal,
  );

  String get template => '''
require meta
''';

}







