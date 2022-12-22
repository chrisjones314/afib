

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/query_example_start_here.t.dart';

class QueryCheckSigninT extends QueryExampleStartHereT {
  QueryCheckSigninT({
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_check_signin",
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryCheckSigninT.example() {
    return QueryCheckSigninT(
      insertExtraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/count_history_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/read_count_history_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/read_referenced_user_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/screens/home_page_screen.dart';

''',
      insertMemberVariables: AFSourceTemplate.empty,
      insertConstructorParams: AFSourceTemplate.empty,
      insertStartImpl: '''
final db = await ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.accessDB();

final signedIn = db.select("SELECT * from \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableUserCredential}");
if(signedIn.isEmpty) {
  context.onError(AFQueryError(message: "Error: No signed in user?"));
} else {
  final row = signedIn.first;
  final entries = row.toTableColumnMap();
  if(entries == null) {
    throw AFException("No table column map?");
  }
  final values = entries[${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableUserCredential];
  if(values == null) {
    throw AFException("No users table?");
  }
  final id = values[${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colActiveUserId].toString();

  context.onSuccess(UserCredentialRoot(
    userId: id.toString(),
    token:  UserCredentialRoot.notSpecified,
    storedEmail: UserCredentialRoot.notSpecified,
  ));
}
''',
      insertFinishImpl: '''
final cred = context.response;

// save the user credential to our state.
context.updateComponentRootStateOne<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>(cred);

if(cred.isSignedIn) {
  // load in the user record for this user.
  final startupLoad = AFCompositeQuery.createList();
  startupLoad.add(ReadReferencedUserQuery(userId: cred.userId));
  startupLoad.add(ReadCountHistoryQuery(userId: cred.userId));
  
  context.executeQuery(AFCompositeQuery.createFrom(
    queries: startupLoad, onSuccess: (successCtx) {
      // Now that we have our state established, navigate to the home screen.   Note that AFib in no way requires a 
      // 'load all your state on startup' model, but it is a simple place to start in this example.
      context.navigateReplaceAll(HomePageScreen.navigatePush().castToReplaceAll());
    }));
} else {
  // do nothing, we will just stay on the startup screen.  Later, when we integrate
  // afib signin, we will transition the startup screen from a 'loading' state to a 
  // 'show the signin ui' state here.   In this example we haven't yet added a way 
  // to sign in.
}
''',
      insertAdditionalMethods: AFSourceTemplate.empty,
    );
  }



  
}