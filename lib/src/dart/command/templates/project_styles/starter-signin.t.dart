import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninT extends AFProjectStyleSourceTemplate {

  StarterSigninT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSignin,
  );

  String get template => '''
--override-templates +
  +core/snippets/fundamental_theme_init=project_styles/starter-signin/snippets/fundamental_theme_init
integrate library --package-name afib_signin --package-code afsi
generate id ${insertAppNamespaceUpper}WidgetID.textFirstName
generate id ${insertAppNamespaceUpper}WidgetID.textLastName
generate id ${insertAppNamespaceUpper}WidgetID.textZipCode
generate id ${insertAppNamespaceUpper}WidgetID.widgetRegistrationDetails
generate id ${insertAppNamespaceUpper}TestDataID.referencedUserWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.referencedUsersWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.userCredentialWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.referencedUserEastCoast
generate id ${insertAppNamespaceUpper}TestDataID.userCredentialEastCoast
generate id ${insertAppNamespaceUpper}TestDataID.referencedUserMidwest
generate ui StartupScreen --override-templates +
  +core/snippets/minimal_screen_build_body_impl=core/snippets/snippet_startup_screen_complete_project_style
generate state UserCredentialRoot --override-templates +
  +core/files/model=project_styles/eval_demo/files/model_user_credential_root
  +core/snippets/define_test_data=project_styles/eval_demo/snippets/define_user_credential_root_test_data
generate state ReferencedUser --override-templates "core/files/model=project_styles/starter-signin/files/model_referenced_user"
generate state ReferencedUsersRoot --override-templates +
  +core/files/model=project_styles/eval_demo/files/model_referenced_users_root
  +core/snippets/define_test_data=project_styles/eval_demo/snippets/define_referenced_users_root_test_data
echo --warning "You must now run 'dart bin/${insertAppNamespace}_afib.dart integrate project-style $insertProjectStyle' to complete setup.  Your project is not complete until you do so."
''';

}







