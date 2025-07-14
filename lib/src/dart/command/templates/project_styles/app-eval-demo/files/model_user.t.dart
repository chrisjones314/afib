
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';

class ModelUserT extends ModelT {
  
  ModelUserT({
    required super.templateFileId,
    required super.templateFolder,
    super.embeddedInsertions,
  });  

  factory ModelUserT.custom({
    required List<String> templateFolder,
    required Object extraImports,
    required Object additionalMethods, 
  }) {
    return ModelUserT(
      templateFileId: "model_user",
      templateFolder: templateFolder,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: extraImports,
      AFSourceTemplate.insertAdditionalMethodsInsertion: additionalMethods
    }));

  }

  factory ModelUserT.example() {
    return ModelUserT.custom(
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoFiles,
      extraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
''', 
      additionalMethods: '''
static User fromDB(sql.Row row) {
  final entries = ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.toColumnMap(row);
  return User.serializeFromMap(entries);
}
''',
    );
  }
}