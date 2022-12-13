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
''',
      AFSourceTemplate.insertMemberVariablesInsertion: '''
final String id;
final int count;
''',
      AFSourceTemplate.insertConstructorParamsInsertion: '''{
required this.id,
required this.count,
}''',
      AFSourceTemplate.insertCopyWithParamsInsertion: '''{
String? id,
int? count,
}''',
    AFSourceTemplate.insertCopyWithCallInsertion: '''      
id: id ?? this.id,
count: count ?? this.count,
''',
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
factory CountHistoryEntry.createNew({
  required int count,
  String idPrefix = "count_entry",
}) {
  return CountHistoryEntry(
    // this just creates a flag value that we can tell is not a valid persistent id.
    id: AFDocumentIDGenerator.createNewId(idPrefix),
    count: count
  );
}

CountHistoryEntry reviseId(String id) {
  return copyWith(id: id);
}
''',
    }));
  }
}