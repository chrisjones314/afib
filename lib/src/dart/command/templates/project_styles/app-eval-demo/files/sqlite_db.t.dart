
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
  static ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB? instance;

  final sql.Database db;

  ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB({
    required this.db
  });

  static Future<sql.Database> accessDB() async {
    final result = await ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.access();
    return result.db;
  }

  static Map<String, dynamic> toColumnMap(sql.Row row) {
    final result = <String, dynamic>{};
    row.forEach((key, value) { result[key] = value; });
    return result;
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