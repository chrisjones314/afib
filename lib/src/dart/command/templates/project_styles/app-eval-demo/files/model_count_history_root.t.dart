import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_example_start_here.t.dart';

class ModelCountHistoryRootT extends ModelExampleStartHereT {
  
  ModelCountHistoryRootT({
    List<String>? templatePath,
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: "model_count_history_items_root",
    embeddedInsertions: embeddedInsertions,
  );  

  factory ModelCountHistoryRootT.example() {
    return ModelCountHistoryRootT(embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/count_history_item.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
''',
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
int get totalCount {
  int result = 0;
  for(final entry in findAll) {
    result += entry.count;
  }
  return result;
}

static CountHistoryItemsRoot fromDB(sql.ResultSet results) {
  final history = <String, CountHistoryItem>{};

  for(final row in results) {
    final entries = row.toTableColumnMap();
    if(entries == null) {
      throw AFException("No table column map?");
    }
    final values = entries[CountHistoryItem.tableName];
    if(values == null) {
      throw AFException("No users table?");
    }

    final entry = CountHistoryItem.serializeFromMap(values);
    history[entry.id] = entry;
  }

  return CountHistoryItemsRoot(items: history);
}


''',
    }));
  }
}