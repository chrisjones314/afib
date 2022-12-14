

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_test_data.dart';

class SnippetDefineReferencedUsersRootTestDataT extends SnippetDefineTestDataT {
  
  SnippetDefineReferencedUsersRootTestDataT(): super(
      templateFileId: "define_referenced_users_root_test_data",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        SnippetDefineTestDataT.insertModelDeclaration: '''
  final userCJ = context.define<ReferencedUser>(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserChris, ReferencedUser(
    id: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserChris, 
    firstName: "Chris", 
    lastName: "Test", 
    email: "chris.test@nowhere.com"
  ));

  final users = <String, ReferencedUser>{
    ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserChris: userCJ
  };
  final referencedUsersChris = ReferencedUsersRoot(
    users: users
  );
  context.define(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUsersChris, referencedUsersChris);
''',
        SnippetDefineTestDataT.insertModelCall: "referencedUsersChris"
      })
  );

  @override 
  List<String> get extraImports {
    return [
      "import 'package:$insertPackagePath/state/models/referenced_user.dart';"
    ];
  }

  static SnippetDefineTestDataT example() {
    return SnippetDefineReferencedUsersRootTestDataT();
  }
}
