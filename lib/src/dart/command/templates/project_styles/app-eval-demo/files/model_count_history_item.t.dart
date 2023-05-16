import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_example_start_here.t.dart';

class ModelCountHistoryItemT extends ModelExampleStartHereT {
  
  ModelCountHistoryItemT({
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: "model_count_history_item",
    embeddedInsertions: embeddedInsertions,
  );  

  factory ModelCountHistoryItemT.example() {
    return ModelCountHistoryItemT(embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:afib/afib_command.dart';
''',
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
factory CountHistoryItem.createNew({
  required int count,
  required String userId,
  String? idPrefix,
}) {
  return CountHistoryItem(
    // this just creates a flag value that we can tell is not a valid persistent id.
    id: AFDocumentIDGenerator.createNewId(idPrefix ?? "count_entry"),
    userId: userId,
    count: count
  );
}
''',
    }));
  }
}