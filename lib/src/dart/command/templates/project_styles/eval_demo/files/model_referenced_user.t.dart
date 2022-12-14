
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/model_example_start_here.t.dart';

class ModelReferencedUserT extends ModelExampleStartHereT {
  
  ModelReferencedUserT({
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: "model_referenced_user",
    embeddedInsertions: embeddedInsertions,
  );  

  factory ModelReferencedUserT.example() {
    return ModelReferencedUserT(embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:afib/afib_flutter.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
''',
      AFSourceTemplate.insertMemberVariablesInsertion: '''
// Note: even if have integer ID values on the server, you should
// convert them to String ids within AFib.   Doing so allows you to
// use String test ids, which are vastly clearer in debugging contexts.
final String id;
final String firstName;
final String lastName;
final String email;
''',
      AFSourceTemplate.insertConstructorParamsInsertion: '''{
required this.id,
required this.firstName,
required this.lastName,
required this.email,
}''',
      AFSourceTemplate.insertCopyWithParamsInsertion: '''{
String? id,
String? firstName,
String? lastName,
String? email,
}''',
    AFSourceTemplate.insertCopyWithCallInsertion: '''      
id: id ?? this.id,
firstName: firstName ?? this.firstName,
lastName: lastName ?? this.lastName,
email: email ?? this.email,
''',
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
static ReferencedUser fromDB(sql.Row row) {
  final entries = row.toTableColumnMap();
  if(entries == null) {
    throw AFException("No table column map?");
  }
  final values = entries[${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableUsers];
  if(values == null) {
    throw AFException("No users table?");
  }

  final id = values[${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colId].toString();
  final first = values[${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colFirstName];
  final last = values[${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colLastName];
  final email = values[${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colEmail];
    
  return ReferencedUser(
    id: id,
    firstName: first,
    lastName: last,
    email: email
  );
}
''',
    }));
  }
}