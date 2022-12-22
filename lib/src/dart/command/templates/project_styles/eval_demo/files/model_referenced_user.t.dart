
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';

class ModelReferencedUserT extends ModelT {
  
  ModelReferencedUserT({
    required String templateFileId,
    required List<String> templateFolder,
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );  

  factory ModelReferencedUserT.custom({
    required String templateFileId,
    required List<String> templateFolder,
    required Object extraImports,
    required Object additionalMethods, 
  }) {
    return ModelReferencedUserT(
      templateFileId: templateFileId,
      templateFolder: templateFolder,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: extraImports,
      AFSourceTemplate.insertMemberVariablesInsertion: '''
// Note: even if have integer ID values on the server, you should
// convert them to String ids within AFib.   Doing so allows you to
// use String test ids, which are vastly clearer in debugging contexts.
final String id;
final String firstName;
final String lastName;
final String email;
final String zipCode;
''',
      AFSourceTemplate.insertConstructorParamsInsertion: '''{
required this.id,
required this.firstName,
required this.lastName,
required this.email,
required this.zipCode,
}''',
      AFSourceTemplate.insertCopyWithParamsInsertion: '''{
String? id,
String? firstName,
String? lastName,
String? email,
String? zipCode,
}''',
    AFSourceTemplate.insertCopyWithCallInsertion: '''      
id: id ?? this.id,
firstName: firstName ?? this.firstName,
lastName: lastName ?? this.lastName,
email: email ?? this.email,
zipCode: zipCode ?? this.zipCode,
''',
      AFSourceTemplate.insertAdditionalMethodsInsertion: additionalMethods
    }));

  }

  factory ModelReferencedUserT.example() {
    return ModelReferencedUserT.custom(
      templateFileId: "model_referenced_user",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoFiles,
      extraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
''', 
      additionalMethods: '''
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
    email: email,
    zipCode: '00000',
  );
}
''',
    );
  }
}