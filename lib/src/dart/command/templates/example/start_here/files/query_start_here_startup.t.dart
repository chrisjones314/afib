

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/example/start_here/files/query_example_start_here.t.dart';

class QueryStartHereStartupT extends QueryExampleStartHereT {
  QueryStartHereStartupT({
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
  }): super(
    templateFileId: "query_startup",
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
  );

  factory QueryStartHereStartupT.example() {
    return QueryStartHereStartupT(
      insertExtraImports: '''
import 'dart:async';
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/read_count_in_state_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/read_referenced_user_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/screens/startup_screen.dart';
''',
      insertMemberVariables: AFSourceTemplate.empty,
      insertConstructorParams: AFSourceTemplate.empty,
      insertStartImpl: '''
// Note: You would be much, must more likely to throw an unimplemented
// exception here initially (use throwUnimplemented(), which has a nice error message built in), 
// and then implement actual asynchronous calls to an external API or store here eventually.   If you want to pass test data
// as a result in development, the state-test is the correct mechanism to do so.
// In this example, I _neither_ want to commit to a particular storage model (e.g. sqllite, firebase),
// nor do I want the sample app to fail in debug mode, so I have hard-coded a result here.

// do a delay here so you can see the startup screen briefly.
Timer(const Duration(milliseconds: 100), () {
  context.onSuccess(UserCredentialRoot(
    userId: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserChris,
    token:  ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserChris,
  ));
});
''',
      insertFinishImpl: '''
final cred = context.response;

// save the user credential to our state.
context.updateComponentRootStateOne<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>(cred);

if(cred.isSignedIn) {
  // load in the user record for this user.
  final startupLoad = AFCompositeQuery.createList();
  startupLoad.add(ReadReferencedUserQuery(userId: cred.userId));
  startupLoad.add(ReadCountInStateQuery(userId: cred.userId));
  
  context.executeQuery(AFCompositeQuery.createFrom(
    queries: startupLoad, onSuccess: (successCtx) {
      // Now that we have our state established, navigate to the home screen.   Note that AFib in no way requires a 
      // 'load all your state on startup' model, but it is a simple place to start in this example.
      context.navigateReplaceAll(StartupScreen.navigatePush().castToReplaceAll());
    }));
} else {
  // do nothing, we will just stay on the startup screen.  Later, when we integrate
  // afib signin, we will transition the startup screen from a 'loading' state to a 
  // 'show the signin ui' state here.   In this example we haven't yet added a way 
  // to sign in.
}
''',
    );
  }



  
}