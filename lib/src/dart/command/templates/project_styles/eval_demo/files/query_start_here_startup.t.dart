

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/query_example_start_here.t.dart';

class QueryStartHereStartupT extends QueryExampleStartHereT {
  QueryStartHereStartupT({
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_startup",
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryStartHereStartupT.example() {
    return QueryStartHereStartupT(
      insertExtraImports: '''
import 'dart:async';
import 'package:afib/afib_flutter.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/check_signin_query.dart';
''',
      insertMemberVariables: AFSourceTemplate.empty,
      insertConstructorParams: AFSourceTemplate.empty,
      insertStartImpl: '''
final db = await ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.accessDB();

// see if the count table exists.
final result = db.select("SELECT name FROM sqlite_master WHERE type='table' AND name='\${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableUserCredential}';");
if(result.isEmpty) {
  // if it doesn't, then create the entire schema and populate it
  _establishSchema(db);
}

context.onSuccess(AFUnused.unused);
''',
      insertFinishImpl: '''
context.executeQuery(CheckSigninQuery());
''',
      insertAdditionalMethods: '''
  void _establishSchema(sql.Database db) {
db.execute(\'''CREATE TABLE IF NOT EXISTS \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableCountHistory} (
  \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colId} INTEGER PRIMARY KEY,
  \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colUserId} INTEGER NOT NULL,
  \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colCount} INTEGER NOT NULL
);\''');

db.execute(\'''CREATE TABLE IF NOT EXISTS \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableUsers} (
  \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colId} INTEGER PRIMARY KEY,
  \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colFirstName} TEXT NOT NULL,
  \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colLastName} TEXT NOT NULL,
  \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colEmail} TEXT NOT NULL
);\''');

db.select("INSERT INTO \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableUsers} (\${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colFirstName}, \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colLastName}, \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colEmail}) values (?, ?, ?)", [
  "Chris",
  "Sqlite",
  "chris@debugnowhere.com",
]);    

final userId = db.lastInsertRowId;
db.execute(\'''CREATE TABLE IF NOT EXISTS \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableUserCredential} (
  \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colId} INTEGER PRIMARY KEY,
  \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colActiveUserId} INTEGER NOT NULL
);\''');

db.select("INSERT INTO \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableUserCredential} (\${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colActiveUserId}) values (?)", [
  userId
]);    
}
'''
    );
  }



  
}