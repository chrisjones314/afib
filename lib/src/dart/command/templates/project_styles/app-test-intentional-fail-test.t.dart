import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterTestIntentionalFailTestT extends AFProjectStyleSourceTemplate {

  StarterTestIntentionalFailTestT(): super(
    templateFileId: AFCreateAppCommand.projectStyleTestIntentionalFailTest,
  );

  String get template => '''
require "afib, meta"
generate test FailingUnitTest --override-templates +
  +core/files/unit_test=project_styles/app-test-intentional-fail-test/files/unit_test_intentional_fail
''';

}







