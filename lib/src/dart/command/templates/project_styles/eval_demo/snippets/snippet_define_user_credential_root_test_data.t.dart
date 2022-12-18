

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_test_data.dart';

class SnippetDefineUserCredentialRootTestDataT {

  static SnippetDefineTestDataT example() {
    return SnippetDefineTestDataT(
      templateFileId: "define_user_credential_root_test_data",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        SnippetDefineTestDataT.insertModelDeclaration: '''
final userCred = UserCredentialRoot(
  userId: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserChris,
  token: UserCredentialRoot.notSpecified,
  storedEmail: UserCredentialRoot.notSpecified,
);

// feel its a little less confusing if the example state test refers to a more natural ID.
context.define(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userCredentialChris, userCred);

''',
        SnippetDefineTestDataT.insertModelCall: "userCred"
      }

    ));
  }
}
