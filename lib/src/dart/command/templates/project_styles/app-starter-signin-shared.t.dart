import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninSharedT extends AFProjectStyleSourceTemplate {

  StarterSigninSharedT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSigninShared,
  );

  String get template => '''
integrate library --package-name afib_signin --package-code afsi
generate id ${insertAppNamespaceUpper}WidgetID.textFirstName
generate id ${insertAppNamespaceUpper}WidgetID.textLastName
generate id ${insertAppNamespaceUpper}WidgetID.textZipCode
generate id ${insertAppNamespaceUpper}WidgetID.widgetRegistrationDetails
generate id ${insertAppNamespaceUpper}TestDataID.userWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.usersWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.userCredentialWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.userEastCoast
generate id ${insertAppNamespaceUpper}TestDataID.userCredentialEastCoast
generate id ${insertAppNamespaceUpper}TestDataID.userMidwest
generate id ${insertAppNamespaceUpper}WidgetID.navBarBottom
generate state UserCredentialRoot --member-variables "String token; String storedEmail" --resolve-variables "User user;" --override-templates +
  +core/files/model_root=project_styles/app-eval-demo/files/model_user_credential_root
  +core/snippets/define_test_data=project_styles/app-eval-demo/snippets/define_user_credential_root_test_data
  +core/snippets/declare_root_accessor=project_styles/app-starter-signin/snippets/declare_root_accessor
generate state User --add-standard-root --member-variables "String id;String firstName;String lastName; String email;String zipCode" --override-templates +
  +core/files/model=project_styles/app-starter-signin/files/model_user
  +core/snippets/define_test_data=project_styles/app-eval-demo/snippets/define_referenced_users_root_test_data
generate query StartupQuery --result-type AFUnused --override-templates "core/files/query_simple=core/files/query_startup_empty"
echo --warning "You must now run 'dart bin/${insertAppNamespace}_afib.dart integrate project-style $insertProjectStyle' to complete setup.  Your project is not complete until you do so."
''';

}







