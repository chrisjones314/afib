import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninFirebaseT extends AFProjectStyleSourceTemplate {

  StarterSigninFirebaseT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSigninFirebase,
  );

  String get template => '''
--override-templates +
  +core/files/main=project_styles/starter-signin-firebase/files/main
  +core/snippets/fundamental_theme_init=project_styles/starter-signin/snippets/fundamental_theme_init
import project_styles/starter-signin-shared
''';

}







