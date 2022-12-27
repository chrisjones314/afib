import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_example_start_here.t.dart';

class ModelCountHistoryRootT extends ModelExampleStartHereT {
  
  ModelCountHistoryRootT({
    List<String>? templatePath,
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: "model_count_history_root",
    embeddedInsertions: embeddedInsertions,
  );  

  factory ModelCountHistoryRootT.example() {
    return ModelCountHistoryRootT(embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/count_history_entry.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
''',
      AFSourceTemplate.insertMemberVariablesInsertion: '''
  final Map<String, CountHistoryEntry> history;
''',
      AFSourceTemplate.insertConstructorParamsInsertion: '''{
required this.history,        
}''',
      AFSourceTemplate.insertCopyWithParamsInsertion: '''{
Map<String, CountHistoryEntry>? history,
}''',
      AFSourceTemplate.insertCopyWithCallInsertion: '''      
history: history ?? this.history,
''',
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
int get totalCount {
  int result = 0;
  for(final entry in history.values) {
    result += entry.count;
  }
  return result;
}

static CountHistoryRoot fromDB(sql.ResultSet results) {
  final history = <String, CountHistoryEntry>{};

  for(final row in results) {
    final entries = row.toTableColumnMap();
    if(entries == null) {
      throw AFException("No table column map?");
    }
    final values = entries[${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableCountHistory];
    if(values == null) {
      throw AFException("No users table?");
    }

    final entry = CountHistoryEntry.fromDB(values);
    history[entry.id] = entry;
  }

  return CountHistoryRoot(history: history);
}

factory CountHistoryRoot.initialState() {
  return CountHistoryRoot(history: const <String, CountHistoryEntry>{});
}

factory CountHistoryRoot.fromList(List<CountHistoryEntry> source) {
  final result = <String, CountHistoryEntry>{};
  for(final entry in source) {
    result[entry.id] = entry;
  }
  return CountHistoryRoot(history: result);
}

CountHistoryRoot reviseAddEntry(CountHistoryEntry entry) {
  final revised = Map<String, CountHistoryEntry>.from(history);
  revised[entry.id] = entry;
  return copyWith(history: revised);
}
''',
    }));
  }
}