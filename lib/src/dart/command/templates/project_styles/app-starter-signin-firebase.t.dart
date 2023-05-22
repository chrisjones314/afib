import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninFirebaseT extends AFProjectStyleSourceTemplate {

  StarterSigninFirebaseT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSigninFirebase,
  );

  String get template => '''
--override-templates +
  +core/files/main=project_styles/app-starter-signin-firebase/files/main
  +core/files/define_core=project_styles/app-starter-signin/files/define_core
  +core/snippets/fundamental_theme_init=project_styles/app-starter-signin/snippets/fundamental_theme_init
require "firebase_core, firebase_auth, cloud_firestore, meta, afib, afib_firebase_firestore, afib_signin"
integrate library --package-name afib_firebase_firestore --package-code affs
import project_styles/app-starter-signin-shared
generate ui StartupScreen --no-back-button --override-templates +
  +core/snippets/empty_screen_build_body_impl=core/snippets/snippet_startup_screen_complete_project_style
''';

}







