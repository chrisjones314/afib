

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/query_example_start_here.t.dart';

class QueryStartHereStartupT extends QueryExampleStartHereT {
  QueryStartHereStartupT({
    required super.insertExtraImports,
    required super.insertStartImpl,
    required super.insertFinishImpl,
    required super.insertAdditionalMethods,
  }): super(
    templateFileId: "query_startup",
  );

  factory QueryStartHereStartupT.example() {
    return QueryStartHereStartupT(
      insertExtraImports: '''
import 'dart:async';
import 'package:afib/afib_flutter.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/check_signin_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/count_history_item.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/user.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
''',
      insertStartImpl: '''
final db = await ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.accessDB();

// see if the count table exists.
final result = db.select("SELECT name FROM sqlite_master WHERE type='table' AND name='\${UserCredentialRoot.tableName}';");
if(result.isEmpty) {
  // if it doesn't, then create the entire schema and populate it
  _establishSchema(db);
}

context.onSuccess(AFUnused.unused);
''',
      insertFinishImpl: '''

context.executeStandardAFibStartup(
  updateFrequency: const Duration(seconds: 1),
  defaultUpdateSpecificity: AFTimeStateUpdateSpecificity.day,
);

context.executeQuery(CheckSigninQuery());
''',
      insertAdditionalMethods: '''
  void _establishSchema(sql.Database db) {
db.execute(\'''CREATE TABLE IF NOT EXISTS \${CountHistoryItem.tableName} (
  \${CountHistoryItem.colId} INTEGER PRIMARY KEY,
  \${CountHistoryItem.colUserId} INTEGER NOT NULL,
  \${CountHistoryItem.colCount} INTEGER NOT NULL
);\''');

db.execute(\'''CREATE TABLE IF NOT EXISTS \${User.tableName} (
  \${User.colId} INTEGER PRIMARY KEY,
  \${User.colFirstName} TEXT NOT NULL,
  \${User.colLastName} TEXT NOT NULL,
  \${User.colEmail} TEXT NOT NULL,
  \${User.colZipCode} TEXT NOT NULL
);\''');

db.select("INSERT INTO \${User.tableName} (\${User.colFirstName}, \${User.colLastName}, \${User.colEmail}, \${User.colZipCode}) values (?, ?, ?, ?)", [
  "Chris",
  "Sqlite",
  "chris@afibframework.io",
  "10001",
]);    

final userId = db.lastInsertRowId;
db.execute(\'''CREATE TABLE IF NOT EXISTS \${UserCredentialRoot.tableName} (
  id INTEGER PRIMARY KEY,
  \${UserCredentialRoot.colUserId} INTEGER NOT NULL
);\''');

db.select("INSERT INTO \${UserCredentialRoot.tableName} (\${UserCredentialRoot.colUserId}) values (?)", [
  userId
]);    
}
'''
    );
  }



  
}