import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterMinimalT extends AFProjectStyleSourceTemplate {

  StarterMinimalT(): super(
    templateFileId: AFCreateAppCommand.projectStyleStarterMinimal,
  );

  String get template => '''
--override-templates +
  +core/snippets/state_test_impl=core/snippets/state_test_impl_minimal
  +core/files/query_simple=project_styles/app-starter-minimal/files/query_startup
  +core/snippets/empty_screen_build_body_impl=project_styles/app-starter-minimal/snippets/minimal_startup_screen_build_body_impl
require "meta, afib"
''';

}







