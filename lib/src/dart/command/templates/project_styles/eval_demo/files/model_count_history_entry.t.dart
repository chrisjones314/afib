import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/model_example_start_here.t.dart';

class ModelCountHistoryEntryT extends ModelExampleStartHereT {
  
  ModelCountHistoryEntryT({
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: "model_count_history_entry",
    embeddedInsertions: embeddedInsertions,
  );  

  factory ModelCountHistoryEntryT.example() {
    return ModelCountHistoryEntryT(embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:afib/afib_command.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}_example/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
''',
      AFSourceTemplate.insertMemberVariablesInsertion: '''
final String id;
final String userId;
final int count;
''',
      AFSourceTemplate.insertConstructorParamsInsertion: '''{
required this.id,
required this.userId,
required this.count,
}''',
      AFSourceTemplate.insertCopyWithParamsInsertion: '''{
String? id,
String? userId,
int? count,
}''',
    AFSourceTemplate.insertCopyWithCallInsertion: '''      
id: id ?? this.id,
userId: userId ?? this.userId,
count: count ?? this.count,
''',
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
factory CountHistoryEntry.createNew({
  required int count,
  required String userId,
  String? idPrefix,
}) {
  return CountHistoryEntry(
    // this just creates a flag value that we can tell is not a valid persistent id.
    id: AFDocumentIDGenerator.createNewId(idPrefix ?? "count_entry"),
    userId: userId,
    count: count
  );
}

factory CountHistoryEntry.fromDB(Map<String, dynamic> cols) {
  final id = cols[TDLESqliteDB.colId].toString();
  final userId = cols[TDLESqliteDB.colUserId];
  final count = cols[TDLESqliteDB.colCount];
  return CountHistoryEntry(id: id, userId: userId.toString(), count: count);
}

CountHistoryEntry reviseId(String id) {
  return copyWith(id: id);
}
''',
    }));
  }
}