

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/query_example_start_here.t.dart';

class QueryReadReferencedUserT extends QueryExampleStartHereT {
  QueryReadReferencedUserT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
  }): super(
    templateFileId: "query_read_referenced_user",
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: AFSourceTemplate.empty,
  );

  factory QueryReadReferencedUserT.example() {
    return QueryReadReferencedUserT(
      insertExtraImports: '''
import 'dart:async';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
''',
      insertStartImpl: '''
final db = await ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.accessDB();
final userIdInt = int.tryParse(userId);
final dbResults = db.select("SELECT * from \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableUsers} where id = ?", [userIdInt]);
if(dbResults.isEmpty) {
  context.onError(AFQueryError(message: "Internal error: No user with id \$userId in database?"));
} else {
  final firstResult = dbResults.first;
  final user = ReferencedUser.fromDB(firstResult);
  context.onSuccess(user);
}
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