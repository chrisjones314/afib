

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_test_data.dart';

class SnippetDefineUsersRootTestDataT extends SnippetDefineTestDataT {
  
  SnippetDefineUsersRootTestDataT(): super(
      templateFileId: "define_referenced_users_root_test_data",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        SnippetDefineTestDataT.insertModelDeclaration: '''
  final userWC = context.define<User>(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userWestCoast, User(
    id: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userWestCoast, 
    firstName: "Westy", 
    lastName: "Test", 
    email: "westy.test@afibframework.io",
    zipCode: "98105",
  ));

  context.define<User>(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userEastCoast, User(
    id: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userEastCoast, 
    firstName: "Easty", 
    lastName: "Test", 
    email: "easty.test@afibframework.io",
    zipCode: "10005",
  ));

  context.define<User>(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userMidwest, User(
    id: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userMidwest, 
    firstName: "Middy", 
    lastName: "Test", 
    email: "middy.test@afibframework.io",
    zipCode: "63117",
  ));



  final users = <String, User>{
    ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userWestCoast: userWC
  };
  final usersWestCoast = UsersRoot(
    items: users
  );
  context.define(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.usersWestCoast, usersWestCoast);
''',
        SnippetDefineTestDataT.insertModelCall: "usersWestCoast"
      })
  );

  @override 
  List<String> get extraImports {
    return [
      "import 'package:$insertPackagePath/state/models/user.dart';"
    ];
  }

  static SnippetDefineTestDataT example() {
    return SnippetDefineUsersRootTestDataT();
  }
}
