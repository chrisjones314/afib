
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
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/count_history_item.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/write_count_history_item_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/reset_history_query.dart';
''',
      })
    );
  }
}

class SnippetCounterManagementScreenRouteParamT {

  static SnippetStandardRouteParamT example() {
    return SnippetStandardRouteParamT(
      templateFileId: "counter_management_screen_route_param",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertCreateParamsInsertion: AFSourceTemplate.empty,
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
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        SnippetNavigatePushT.insertNavigatePushParamDecl: '{ int clickCount = 0, }',
        SnippetNavigatePushT.insertNavigatePushParamCall: 'clickCount: clickCount,',
      })
    );
  }
}

class SnippetCounterManagementScreenAdditionalMethodsT extends AFSnippetSourceTemplate {
  SnippetCounterManagementScreenAdditionalMethodsT(): super(
    templateFileId: "counter_management_screen_additional_methods",
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );
  
  @override
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
    text: spi.clickCountParam.toString(),
    wid: ${insertAppNamespaceUpper}WidgetID.textCountRouteParam,
    style: t.styleOnCard.displayMedium
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
      wid: ${insertAppNamespaceUpper}WidgetID.buttonSaveTransientCount,
      text: "Save Transient Count in History", 
      onPressed: spi.onPressedPersistTransientCount
    )
  ));

  rows.add(t.childSingleRowButton(
    button: t.childButtonPrimaryText(
      wid: ${insertAppNamespaceUpper}WidgetID.buttonResetHistory,
      text: "Reset History", 
      onPressed: spi.onPressedResetHistory,
    )
  ));


  rows.add(t.childCaptionSimulatedLatency());

  return _buildCard(spi, rows);
}

TableRow _buildHistoryEntry(CounterManagementScreenSPI spi, CountHistoryItem entry) {
  final t = spi.t;
  final cols = t.row();
  cols.add(t.childText(text: entry.id));
  cols.add(t.childText(text: entry.count.toString()));
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
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );
  
  @override
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
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );
  
  @override
  String get template => '''
final t = spi.t;
final body = _buildBody(spi);
return t.childScaffold(
  spi: spi,
  body: body,
  appBar: AppBar(
    title: t.childText(text: "${insertPackageName.spaces}"),
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
int get clickCountState => context.s.countHistoryItems.totalCount;

bool get showFullHistory => clickCountState > 0;

Iterable<CountHistoryItem> get historyEntries => context.s.countHistoryItems.findAll;


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

  context.executeWireframeEvent(${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.buttonSaveTransientCount, context.p, onSuccess: _onClearClickCount);

  final entry = CountHistoryItem.createNew(
    userId: context.s.userCredential.userId,
    count: context.p.clickCount
  );

  // execute the query which writes it to the history, and 
  context.executeQuery(WriteCountHistoryItemQuery(item: entry, onSuccess: (successCtx) {
    _onClearClickCount();
  }));

}

void onPressedResetHistory() {
  context.executeWireframeEvent(${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.buttonResetHistory, context.p);
  context.executeQuery(ResetHistoryQuery(userId: context.s.userCredential.userId));
}


void _onClearClickCount() {
  // then, clear the transient click count.
  final revisedClear = context.p.reviseClearClickCount();
  context.updateRouteParam(revisedClear);
}

'''
    });
    return SnippetDeclareSPIT(
      templateFileId: "counter_management_screen_spi",    
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: ei,
    );
  }
}


