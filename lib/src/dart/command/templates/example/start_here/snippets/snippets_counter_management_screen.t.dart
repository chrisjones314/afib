
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_navigate_push.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_standard_route_param.t.dart';


class SnippetCounterManagementScreenExtraImportsT {
  static SnippetExtraImportsT example() {
    return SnippetExtraImportsT(
      templateFileId: "counter_management_screen_extra_imports",    
      templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/count_history_entry.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/write_count_history_entry_query.dart';
''',
      })
    );
  }
}

class SnippetCounterManagementScreenRouteParamT {

  static SnippetStandardRouteParamT example() {
    return SnippetStandardRouteParamT(
      templateFileId: "counter_management_screen_route_param",
      templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertMemberVariablesInsertion: '''
final int clickCount;
''',
        AFSourceTemplate.insertConstructorParamsInsertion: '{ required this.clickCount, }',
        AFSourceTemplate.insertCreateParamsInsertion: "{ required int clickCount }",
        AFSourceTemplate.insertCreateParamsCallInsertion: "clickCount: clickCount",
        AFSourceTemplate.insertCopyWithParamsInsertion: "{  int? clickCount }",
        AFSourceTemplate.insertCopyWithCallInsertion: "clickCount: clickCount ?? this.clickCount,",
        AFSourceTemplate.insertAdditionalMethodsInsertion: '''
CounterManagementScreenRouteParam reviseIncrementClickCount() => copyWith(clickCount: clickCount+1);
CounterManagementScreenRouteParam reviseClearClickCount() => copyWith(clickCount: 0);
'''
      })
    );
  }

}

class SnippetCounterManagementScreenNavigatePushT {

  static SnippetNavigatePushT example() {
    return SnippetNavigatePushT(
      templateFileId: "counter_management_screen_navigate_push",
      templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        SnippetNavigatePushT.insertParamDecl: '{ int clickCount = 0, }',
        SnippetNavigatePushT.insertParamCall: 'clickCount: clickCount,',
      })
    );
  }
}

class SnippetCounterManagementScreenAdditionalMethodsT extends AFSnippetSourceTemplate {
  SnippetCounterManagementScreenAdditionalMethodsT(): super(
    templateFileId: "counter_management_screen_additional_methods",
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
  );
  
  String get template => '''
/// This method creates the UI card which displays the route parameter
/// count.
/// 
/// In online examples, you will frequently see flutter UI declared
/// in large, inline static data structures.   I prefer decomposing
/// the UI build into subprocedures.   The SPI makes this easier, as
/// it is a single value you can pass down that contains everything you
/// need to render the UI.
Widget _buildIncrementParamCard(CounterManagementScreenSPI spi) {
  final t = spi.t;
  final rows = t.column();
  t.buildCardHeader(rows: rows, title: "Transient Count", subtitle: "(route parameter)");
  rows.add(t.childText(
    spi.clickCountParam.toString(),
    wid: ${insertAppNamespaceUpper}WidgetID.textCountRouteParam,
    style: t.styleOnCard.headline2
  ));

  rows.add(t.childSingleRowButton(
    button: t.childButtonPrimaryText(
      wid: ${insertAppNamespaceUpper}WidgetID.buttonIncrementRouteParam,
      text: "Increment Transient Count", 
      onPressed: spi.onPressedIncrementTransientCount
    )
  ));

  return _buildCard(spi, rows);
}

Widget _buildCard(CounterManagementScreenSPI spi, List<Widget> rows) {
  final t = spi.t;
  return Card(
    child: t.childMargin(
      margin: t.margin.standard,
      child: Column(children: rows)
    )
  );    

}

/// This method creates the UI card that displays the state count.
///
/// This method could have been been consolidated with the method above using a few parameters,
/// but I left them separate to make debugging the example easier and clearer.
Widget _buildIncrementStateCard(CounterManagementScreenSPI spi) {
  final t = spi.t;
  final rows = t.column();
  t.buildStateCount(rows: rows, clickCount: spi.clickCountState);

  rows.add(t.childSingleRowButton(
    button: t.childButtonPrimaryText(
      text: "Save Transient Count in History", 
      onPressed: spi.onPressedPersistTransientCount
    )
  ));

  rows.add(t.childCaptionSimulatedLatency());

  return _buildCard(spi, rows);
}

TableRow _buildHistoryEntry(CounterManagementScreenSPI spi, CountHistoryEntry entry) {
  final t = spi.t;
  final cols = t.row();
  cols.add(t.childText(entry.id));
  cols.add(t.childText(entry.count.toString()));
  return TableRow(children: cols);
}

Widget _buildFullHistoryCard(CounterManagementScreenSPI spi) {
  final t = spi.t;
  final rows = t.column();

  t.buildCardHeader(rows: rows, title: "Full Persistent History");

  final tableRows = t.childrenTable();
  for(final entry in spi.historyEntries) {
      tableRows.add(_buildHistoryEntry(spi, entry));
  }
  
  rows.add(t.childMarginStandard(
    child: Table(
      children: tableRows,
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
        1: FixedColumnWidth(60.0),
      },
    )
  ));

  return _buildCard(spi, rows);
}
''';
}

class SnippetCounterManagementScreenBuildBodyT extends AFSnippetSourceTemplate {
  SnippetCounterManagementScreenBuildBodyT(): super(
    templateFileId: "counter_management_screen_build_body",
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
  );
  
  String get template => '''
final t = spi.t;
final rows = t.column();
rows.add(_buildIncrementParamCard(spi));
rows.add(_buildIncrementStateCard(spi));
if(spi.showFullHistory) {
  rows.add(_buildFullHistoryCard(spi));
}

return ListView(
  children: rows
);
''';
}

class SnippetCounterManagementScreenBuildWithSPIImplT extends AFSnippetSourceTemplate {
  SnippetCounterManagementScreenBuildWithSPIImplT(): super(
    templateFileId: "counter_management_screen_build_with_spi",
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
  );
  
  String get template => '''
final t = spi.t;
final body = _buildBody(spi);
return t.childScaffold(
  spi: spi,
  body: body,
  appBar: AppBar(
    title: t.childText("${insertPackageName.spaces}"),
    leading: t.childButtonStandardBack(spi, screen: screenId, shouldContinueCheck: () async {
      return AFShouldContinue.yesContinue; 
    })
  ),
);
''';
}

class SnippetCounterManagementScreenSPIT {

  static SnippetDeclareSPIT example() {
    final ei = AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
/// One of the main roles of this SPI is to present a simplified view of your 
/// business data to the UI, moving filtering and other business logic out of 
/// the UI code, and into a class which will be easily accessible from state tests
/// without actually building the UI.
/// 
/// Note that you can do this in accessors, like this, or by adding final variables
/// and initializing them in the factory method above.
int get clickCountParam => context.p.clickCount;

/// The difference between
int get clickCountState => context.s.countHistory.totalCount;

bool get showFullHistory => clickCountState > 0;

Iterable<CountHistoryEntry> get historyEntries => context.s.countHistory.history.values;


/// The second main role is to move event handling logic out of the UI and into 
/// a business logic object.   This SPI will be accessible from state tests, so you can
/// manipulate the state from 'almost' the UI level in your tests, without actually building
/// your UI.
void onPressedIncrementTransientCount() {
  /// Note that the route parameter is immutable, so we must make a copy of it when we 
  /// change it.  Although this is a trivial example, I like to add revise... methods 
  /// to the route parameter which achieve specific conceptual goals.  It makes it easy to find
  /// the existing revise methods when I pick up the code later.
  final revised = context.p.reviseIncrementClickCount();
  context.updateRouteParam(revised);
}

void onPressedPersistTransientCount() {

  // execute the query which writes it to the history, and 
  context.executeQuery(WriteCountHistoryEntryQuery(entry: CountHistoryEntry.createNew(count: context.p.clickCount), onSuccess: (successCtx) {
    
    // then, clear the transient click count.
    final revisedClear = context.p.reviseClearClickCount();
    context.updateRouteParam(revisedClear);

  }));

}
'''
    });
    return SnippetDeclareSPIT(
      templateFileId: "counter_management_screen_spi",    
      templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
      embeddedInsertions: ei,
    );
  }
}


