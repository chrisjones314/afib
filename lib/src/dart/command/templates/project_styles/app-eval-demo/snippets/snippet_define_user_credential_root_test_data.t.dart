

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_test_data.dart';

class SnippetDefineUserCredentialRootTestDataT {

  static SnippetDefineTestDataT example() {
    return SnippetDefineTestDataT(
      templateFileId: "define_user_credential_root_test_data",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/user.dart';
''',
        SnippetDefineTestDataT.insertModelDeclaration: '''
// this was previously defined, so we can access it
final userWC = context.find<User>(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userWestCoast);
final userCredWC = UserCredentialRoot(
  userId: userWC.id,
  token: UserCredentialRoot.notSpecified,
  storedEmail: userWC.email,
);

final userEC = context.find<User>(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userEastCoast);
final userCredEC = UserCredentialRoot(
  userId: userEC.id,
  token: UserCredentialRoot.notSpecified,
  storedEmail: userEC.email,
);

// feel its a little less confusing if the example state test refers to a more natural ID.
context.define(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userCredentialWestCoast, userCredWC);
context.define(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userCredentialEastCoast, userCredEC);
''',
        SnippetDefineTestDataT.insertModelCall: "userCredWC"
      }

    ));
  }
}
