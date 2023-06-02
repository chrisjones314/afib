import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterTestIntentionalFailCreateT extends AFProjectStyleSourceTemplate {

  StarterTestIntentionalFailCreateT(): super(
    templateFileId: AFCreateAppCommand.projectStyleTestIntentionalFailCreate,
  );

  String get template => '''
require "afib, meta"
''';

}







