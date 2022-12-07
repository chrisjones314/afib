

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/start_here/files/query_example_start_here.t.dart';

class QueryReadReferencedUserT extends QueryExampleStartHereT {
  QueryReadReferencedUserT({
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
  }): super(
    templateFileId: "query_read_referenced_user",
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
  );

  factory QueryReadReferencedUserT.example() {
    return QueryReadReferencedUserT(
      insertExtraImports: '''
import 'dart:async';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
''',
      insertMemberVariables: 'final String userId;',
      insertConstructorParams: 'required this.userId,',
      insertStartImpl: '''
// See StartupQuery for an explanation of why you would never hard-code a test result
// in a real app.  This is an ideosyncracy of this example app.
Timer(const Duration(seconds: 1), () {
  context.onSuccess(ReferencedUser(
    id: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.referencedUserChris,
    firstName: "Chris",
    lastName: "Debug",
  email: 'chris.debug@nowhere.com',
  ));
});
''',
      insertFinishImpl: '''
// the user we loaded is the response.
final user = context.r;

// we are going to update our global state and add the referenced user.
final tdleState = context.accessComponentState<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>();

// The idea here is that our app might ultimately reference several users, and we want to
// store them all consistently.   When working with immutable data structures, you want to do
// 'late client side joins' on your data.   That is, you want to your data to reference ids, not pointer references
// to resolved objects.  Then, as you are rendering your UI, you 'join' to the actual user object in
// real time.   That way, when you update a user, you update it in a single place.  All the other data
// that references the user contains only the user id, and thus remains unchanged.
final refererencedUsers = tdleState.referencedUsers;

// the state is immutable, so to add this user to it, we need to revise it.
final revisedUsers = refererencedUsers.reviseUser(user);

// now, save our changes to our global state.
context.updateComponentRootStateOne<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>(revisedUsers);
''',
    );
  }



  
}