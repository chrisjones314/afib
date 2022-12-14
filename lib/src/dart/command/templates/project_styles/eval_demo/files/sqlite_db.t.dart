
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/custom.t.dart';

class SqliteDBT {
  static CustomT example() {
    return CustomT(
      templateFileId: "sqlite_db",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoFiles,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
''',
        AFSourceTemplate.insertAdditionalMethodsInsertion: '''
class ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB {
  // Note: I am not suggesting this is how you should handle DB/serialization code, 
  // I am trying to keep it trivial because this code is not the point.
  static const tableCountHistory = "count_history";
  static const tableUsers = "users";
  static const tableUserCredential = "user_credential";
  static const colId = "id";
  static const colUserId = "user_id";
  static const colFirstName = "first_name";
  static const colLastName = "last_name";
  static const colEmail = "email";
  static const colCount = "count";
  static const colActiveUserId = "active_user_id";
  static ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB? instance;

  final sql.Database db;

  ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB({
    required this.db
  });

  static Future<sql.Database> accessDB() async {
    final result = await ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.access();
    return result.db;
  }

  static Future<${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB> access() async {

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = "\${dir.path}/test.db";
    ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB? inst = instance;
    if(inst == null) {
      final db = sql.sqlite3.open(dbPath);
      //final db = sql.sqlite3.openInMemory();
      inst = ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB(db: db);
      instance = inst;
    }
    return inst;
  }
}
''',
      })
    );
  }
}