

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/start_here/files/query_example_start_here.t.dart';

class QueryWriteCountHistoryEntryT extends QueryExampleStartHereT {
  QueryWriteCountHistoryEntryT({
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
  }): super(
    templateFileId: "query_write_count_history_entry",
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
  );

  factory QueryWriteCountHistoryEntryT.example() {
    return QueryWriteCountHistoryEntryT(
      insertExtraImports: '''
import 'dart:async';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
''',
      insertMemberVariables: '''
static int simulatedStaticId = 10;
final CountHistoryEntry entry;
''',
      insertConstructorParams: 'required this.entry,',
      insertStartImpl: '''
// see StartupQuery for why you would never hard code test data into startAsync in a 
// real app.  This is an ideosyncracy of this particular example app.
Timer(const Duration(milliseconds: 500), () {
  // we need to artificially create an id.
  if(AFDocumentIDGenerator.isNewId(entry.id)) {
    final revisedEntry = entry.reviseId("_from_startAsync_\$simulatedStaticId");
    simulatedStaticId++;
    context.onSuccess(revisedEntry);
  }
});    
''',
      insertFinishImpl: '''
final entry = context.r;
final tdleState = context.accessComponentState<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>();
final history = tdleState.countHistory;
final revised = history.reviseAddEntry(entry);
context.updateComponentRootStateOne<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>(revised);
''',
    );
  }



  
}