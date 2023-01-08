

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryReadUserSigninStarterT extends SimpleQueryT {
  QueryReadUserSigninStarterT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_read_user",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryReadUserSigninStarterT.example() {
    return QueryReadUserSigninStarterT(
      insertExtraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/user.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/signin_query.dart';
import 'package:afib_signin/afsi_flutter.dart';
''',
      insertStartImpl: '''
// TODO: Actually read the user from your data store using on credential.userId.
context.onSuccess(User(
  id: credential.userId,
  email: 'test@nowwhere.com',
  firstName: "Test",
  lastName: "Nowhere",
  zipCode: "98105",
));
''',
      insertFinishImpl: '''
onUpdateUser(context);
''',
      insertAdditionalMethods: '''
static void onUpdateUser(AFFinishQuerySuccessContext<User> context) {
  final result = context.r;
  final ${AFSourceTemplate.insertAppNamespaceInsertion}State = context.accessComponentState<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>();
  final users = ${AFSourceTemplate.insertAppNamespaceInsertion}State.users;
  final revised = users.reviseUser(result);
  context.updateComponentRootStateOne<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>(revised);    
}
'''
    );
  }



  
}