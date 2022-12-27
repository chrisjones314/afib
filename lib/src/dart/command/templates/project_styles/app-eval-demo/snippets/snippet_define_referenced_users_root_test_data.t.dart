

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_test_data.dart';

class SnippetDefineReferencedUsersRootTestDataT extends SnippetDefineTestDataT {
  
  SnippetDefineReferencedUsersRootTestDataT(): super(
      templateFileId: "define_referenced_users_root_test_data",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        SnippetDefineTestDataT.insertModelDeclaration: '''
  final userWC = context.define<ReferencedUser>(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserWestCoast, ReferencedUser(
    id: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserWestCoast, 
    firstName: "Westy", 
    lastName: "Test", 
    email: "westy.test@nowhere.com",
    zipCode: "98105",
  ));

  context.define<ReferencedUser>(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserEastCoast, ReferencedUser(
    id: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserEastCoast, 
    firstName: "Easty", 
    lastName: "Test", 
    email: "easty.test@nowhere.com",
    zipCode: "10005",
  ));

  context.define<ReferencedUser>(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserMidwest, ReferencedUser(
    id: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserMidwest, 
    firstName: "Middy", 
    lastName: "Test", 
    email: "middy.test@nowhere.com",
    zipCode: "63117",
  ));



  final users = <String, ReferencedUser>{
    ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserWestCoast: userWC
  };
  final referencedUsersWestCoast = ReferencedUsersRoot(
    users: users
  );
  context.define(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUsersWestCoast, referencedUsersWestCoast);
''',
        SnippetDefineTestDataT.insertModelCall: "referencedUsersWestCoast"
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
