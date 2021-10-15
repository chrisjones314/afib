import 'package:afib/afib_flutter.dart';
import 'package:afib/id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/af_prototype_base.dart';
import 'package:afib/src/flutter/ui/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:stack_trace/stack_trace.dart';

/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFExceptionScreenRouteParam extends AFRouteParam {
  final Exception exception;
  final StackTrace stack;

  AFExceptionScreenRouteParam({
    required this.exception,
    required this.stack
  }): super(id: AFUIScreenID.screenException);
}

/// Data used to render the screen
class AFExceptionScreenStateView extends AFStateView1<AFPublicState?> {
  AFExceptionScreenStateView(AFPublicState? pub): 
    super(first: pub);
  
  AFPublicState? get publicState { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFExceptionScreen extends AFUIConnectedScreen<AFExceptionScreenStateView, AFExceptionScreenRouteParam>{
  static const runWidgetTestsId = "run_widget_tests";
  static const runScreenTestsId = "run_screen_tests";
  static const runWorkflowTestsId = "run_workflow_tests";
  AFExceptionScreen(): super(AFUIScreenID.screenException);

  @override
  AFExceptionScreenStateView createStateViewPublic(AFPublicState state, AFExceptionScreenRouteParam param, AFRouteSegmentChildren? children) {
    return AFExceptionScreenStateView(state);
  }

  @override
  AFExceptionScreenStateView createStateView(AFAppStateArea? state, AFExceptionScreenRouteParam param) {
    // this should never be called, because createDataAF replaces it.
    throw UnimplementedError();
  }

  @override
  Widget buildWithContext(AFUIBuildContext<AFExceptionScreenStateView, AFExceptionScreenRouteParam> context) {
    return _buildErrorPage(context);
  }

  /// 
  Widget _buildErrorPage(AFUIBuildContext<AFExceptionScreenStateView, AFExceptionScreenRouteParam> context) {
    final uiTheme = context.findTheme(AFUIThemeID.conceptualUI) as AFUITheme;
    final body = buildBody(context);
    return uiTheme.childScaffold<AFUIBuildContext<AFExceptionScreenStateView, AFExceptionScreenRouteParam>>(
      context: context, 
      appBar: _childStandardAppBar(context, screenId, "Internal Error"),
      body: body,
      contextSource: this,
    );
  }

  AppBar _childStandardAppBar(AFBuildContext context, AFScreenID screenId, String title) {
    final uiTheme = context.findTheme(AFUIThemeID.conceptualUI) as AFUITheme;
    return AppBar(
        leading: uiTheme.childButtonStandardBack(context, 
          screen: screenId,
          worksInSingleScreenTest: true,
        ),
        title: Text(title),
    );
  }

  Widget buildBody(AFUIBuildContext<AFExceptionScreenStateView, AFExceptionScreenRouteParam> context) {
    if(AFibD.config.isProduction) {
      return buildBodyProduction(context);
    } else {
      return buildBodyDebug(context);
    }
  }

  Widget buildBodyProduction(AFUIBuildContext<AFExceptionScreenStateView, AFExceptionScreenRouteParam> context) {
    return Center(child: Text("An internal error occcured, please report it to the developer"));
  }

  Frame? _findKeyFrame(List<Frame> frames) {
    final frame = frames.firstWhereOrNull((f) => !f.isCore);
    return frame;
  }

  TableRow createStackRow(AFUIBuildContext<AFExceptionScreenStateView, AFExceptionScreenRouteParam> context, Frame frame, int row, TextStyle? bold) {
    final t = context.t;
    final cols = t.column();
    cols.add(TableCell(
      child: Container(
        child: Text("#$row")
      )
    ));

    final rows = t.column();
    rows.add(Text(frame.member ?? "", style: bold));
    rows.add(Text(simpleLocation(frame)));
    cols.add(Container(
      margin: t.margin.b.s4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows
      )
    ));

    return TableRow(children: cols);
  }

  String simpleLocation(Frame frame) {
    final location = frame.location;
    var idxSlash = location.lastIndexOf('/');
    if(idxSlash < 0) {
      idxSlash = location.lastIndexOf('\\');
    }
    var result = location;
    if(idxSlash > 0) {
      result = location.substring(idxSlash+1);
    }
    return result;
  }

  Widget buildBodyDebug(AFUIBuildContext<AFExceptionScreenStateView, AFExceptionScreenRouteParam> context) {
    final t = context.t;
    final p = context.p;
    final rows = t.column();

    final headerRows = t.column();
    headerRows.add(Text(p.exception.toString(), style: t.styleOnCard.headline5));
    final trace = Trace.from(p.stack);
    final frames = trace.frames;

    final bodyBold = t.styleOnCard.bodyText2?.copyWith(fontWeight: FontWeight.bold);
 
    // highlight the first stack frame:
    final firstFrame = _findKeyFrame(frames);
    if(firstFrame != null) {
      headerRows.add(Divider(color: Colors.white));
      headerRows.add(Container(
        margin: t.margin.v.s3,
        child: Text("${firstFrame.member}", style: bodyBold)
      ));

      headerRows.add(Divider(color: Colors.white));
      headerRows.add(Container(
        margin: t.margin.t.s3,
        child: Text("${simpleLocation(firstFrame)}", style: t.styleOnCard.bodyText2)
      ));
    }

    // add the header.
    rows.add(Container(
      padding: t.paddingStandard,
      decoration: BoxDecoration(
        borderRadius: t.borderRadiusStandard,
        color: Colors.red[400],
      ),
      child: Column(children: headerRows)
    ));


    // now, add the stack traces in a table.
    final stackRows = t.childrenTable();
    for(var i = 0; i < frames.length; i++) {
      final frame = frames[i];
      stackRows.add(createStackRow(context, frame, i, bodyBold));
    }


    final columnWidths = <int, TableColumnWidth>{};
    columnWidths[0] = FixedColumnWidth(50.0);
    columnWidths[1] = FlexColumnWidth();

    rows.add(Container(
      margin: t.margin.t.s3,
      padding: t.paddingStandard,
      decoration: BoxDecoration(
        borderRadius: t.borderRadiusStandard,
        color: Colors.grey[300],
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        columnWidths: columnWidths,
        children: stackRows
      )
    ));


    return ListView(
      children: [Container(
        margin: t.marginStandard,
        child: Column(
          children: rows
        )
      )]
    );    
  }

}