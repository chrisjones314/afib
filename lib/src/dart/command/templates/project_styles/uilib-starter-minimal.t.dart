import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class UILibStarterMinimalT extends AFProjectStyleSourceTemplate {

  UILibStarterMinimalT(): super(
    templateFileId: AFCreateAppCommand.projectStyleUILibStarterMinimal,
  );

  @override
  String get template => '''
require meta
''';

}







