import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninT extends AFProjectStyleSourceTemplate {

  StarterSigninT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSignin,
  );

  String get template => '''
--override-templates +
  +core/snippets/fundamental_theme_init=project_styles/starter-signin/snippets/fundamental_theme_init
import project-style core/files/starter-signin-shared
generate ui StartupScreen --override-templates +
  +core/snippets/minimal_screen_build_body_impl=core/snippets/snippet_startup_screen_complete_project_style
secho --warning "You must now run 'dart bin/${insertAppNamespace}_afib.dart integrate project-style $insertProjectStyle' to complete setup.  Your project is not complete until you do so."
''';

}







