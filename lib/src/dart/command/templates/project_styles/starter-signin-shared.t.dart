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
generate id ${insertAppNamespaceUpper}TestDataID.referencedUserWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.referencedUsersWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.userCredentialWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.referencedUserEastCoast
generate id ${insertAppNamespaceUpper}TestDataID.userCredentialEastCoast
generate id ${insertAppNamespaceUpper}TestDataID.referencedUserMidwest
generate state UserCredentialRoot --member-variables "String userId; String token; String storedEmail" --override-templates +
  +core/files/model=project_styles/eval_demo/files/model_user_credential_root
  +core/snippets/define_test_data=project_styles/eval_demo/snippets/define_user_credential_root_test_data
generate state ReferencedUser --member-variables "String id;String firstName;String lastName; String email;String zipCode" --serial --override-templates "core/files/model=project_styles/starter-signin/files/model_referenced_user"
generate state ReferencedUsersRoot --member-variables "Map<String, ReferencedUser> users" --override-templates +
  +core/files/model=project_styles/eval_demo/files/model_referenced_users_root
  +core/snippets/define_test_data=project_styles/eval_demo/snippets/define_referenced_users_root_test_data
echo --warning "You must now run 'dart bin/${insertAppNamespace}_afib.dart integrate project-style $insertProjectStyle' to complete setup.  Your project is not complete until you do so."
''';

}







