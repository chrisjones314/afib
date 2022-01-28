
import 'dart:async';

import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/queries/af_time_update_listener_query.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/redux/state/models/afui_proto_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_prototype_state_view.dart';
import 'package:afib/src/flutter/utils/af_param_ui_state_holder.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//--------------------------------------------------------------------------------------
class AFUIPrototypeDrawerRouteParam extends AFRouteParam {
  static const viewTime = 0;
  static const viewTheme = 1;
  static const viewTest  = 2;
  static const viewResults = 3;
  final int view;
  final Map<String, bool> themeExpanded;
  final String timeText;
  final String timeAdjustText;
  final AFTextEditingControllersHolder textControllers;

  AFUIPrototypeDrawerRouteParam({
    required this.view, 
    required this.themeExpanded,
    required this.timeText,
    required this.timeAdjustText,
    required this.textControllers,
  }): super(id: AFUIScreenID.screenTestDrawer);

  factory AFUIPrototypeDrawerRouteParam.createOncePerScreen(int view) {
    final themeExpanded = <String, bool>{};
    final textControllers = AFTextEditingControllersHolder.createN({
      AFUIWidgetID.textTime: "",
      AFUIWidgetID.textTimeAdjust: "",
    });

    return AFUIPrototypeDrawerRouteParam(view: view, themeExpanded: themeExpanded, textControllers: textControllers, timeText: "", timeAdjustText: "");
  }

  bool isExpanded(String area) {
    final result = themeExpanded[area];
    return result ?? false;
  }

  AFUIPrototypeDrawerRouteParam reviseExpanded(String area, { required bool expanded }) {
    final revised = Map<String, bool>.from(themeExpanded);
    revised[area] = expanded;
    return copyWith(themeExpanded: revised);
  }

  AFUIPrototypeDrawerRouteParam reviseView(int view) {
    return copyWith(view: view);
  }

  AFUIPrototypeDrawerRouteParam reviseTimeText(String timeText) {
    return copyWith(timeText: timeText);
  }

  AFUIPrototypeDrawerRouteParam reviseTimeAdjust(String timeText) {
    return copyWith(timeAdjustText: timeText);
  }


  AFUIPrototypeDrawerRouteParam copyWith({
    int? view,
    Map<String, bool>? themeExpanded,
    String? timeText,
    String ? timeAdjustText,
  }) {
    return AFUIPrototypeDrawerRouteParam(
      view: view ?? this.view,
      themeExpanded: themeExpanded ?? this.themeExpanded,
      textControllers: this.textControllers,
      timeText: timeText ?? this.timeText,
      timeAdjustText: timeAdjustText ?? this.timeAdjustText

    );
  }
}

class AFUIPrototypeDrawerSPI extends AFUIScreenDefaultSPI<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> {
  AFUIPrototypeDrawerSPI(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context, AFConnectedUIBase screen): super(context, screen);
  factory AFUIPrototypeDrawerSPI.create(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context, AFConnectedUIBase screen) {
    return AFUIPrototypeDrawerSPI(context, screen);
  }
}

//--------------------------------------------------------------------------------------
class AFUIPrototypeDrawer extends AFUIConnectedDrawer<AFUIPrototypeDrawerSPI, AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> {
  static final timeFormat = DateFormat('Hms');

  //--------------------------------------------------------------------------------------
  AFUIPrototypeDrawer(): super(AFUIScreenID.screenTestDrawer, AFUIPrototypeStateView.creator, AFUIPrototypeDrawerSPI.create);

  //--------------------------------------------------------------------------------------
  AFScreenID? get primaryScreenId {
    return null;
  }

  //--------------------------------------------------------------------------------------
   @override
  AFUIStateView<AFUIPrototypeStateView> createStateView(AFBuildStateViewContext<AFUIPrototypeState, AFUIPrototypeDrawerRouteParam> context) {
    final testState = context.private.testState;
    final test = AFibF.g.findScreenTestById(testState.activeTestId!);
    if(test == null) throw AFException("Missing test for ${testState.activeTestId}");
    final testContext = testState.findContext(test.id);
    final testSubState = testState.findState(test.id);
    if(testSubState == null) throw AFException("unexpected null context or state for ${test.id}");
    return AFUIStateView<AFUIPrototypeStateView>(
      models: [
        AFWrapModelWithCustomID(AFUIPrototypeState.prototypeModel, test),
        testSubState,
        testContext,
        context.statePublic.time,
        context.statePublic.queries.findListenerQueryById(AFUIQueryID.time.toString())
      ]
    );
  }

  //--------------------------------------------------------------------------------------
  AFUIPrototypeDrawerRouteParam createDefaultRouteParam(AFState state) {
    return AFUIPrototypeDrawerRouteParam.createOncePerScreen(AFUIPrototypeDrawerRouteParam.viewTest);
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget buildWithContext(AFUIPrototypeDrawerSPI spi) {
    return _buildDrawer(spi.context);
  }

  //--------------------------------------------------------------------------------------
  Widget _buildDrawer(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context) {
    final rows = context.t.column();
    
    rows.add(_buildHeader(context));
    rows.add(_buildChoiceRow(context));
    rows.add(_buildContent(context));

    return Drawer(      
        child: Column(
          children: rows,
        )
    );
  }

  //--------------------------------------------------------------------------------------
  Widget _buildHeader(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context) {
    final t = context.t;
    final rows = t.column();
    final test = context.s.prototype;

    rows.add(Container(
      margin: t.margin.v.s3,
      child: t.childText(
        "AFib Prototype",
        style: t.styleOnPrimary.headline6
      )
    ));

    rows.add(Container(
      margin: t.margin.v.s3,
      child: t.childText(
          context.s.prototype?.id.toString(), 
          style: t.styleOnPrimary.bodyText2
      )
    ));

    final buttonStyle = OutlinedButton.styleFrom(
      primary: t.colorOnPrimary,
      textStyle: TextStyle(color: t.colorSecondary),
      side: BorderSide(width: 1, color: t.colorOnPrimary),
    );

    final cols = t.row();
    cols.add(TextButton(
      child: t.childText('Exit'),
      style: buttonStyle,
      onPressed: () {
          context.closeDrawer();
          context.dispatch(AFNavigateExitTestAction());
      }
    ));

    cols.add(
      Container(
        margin: t.margin.l.s3,
        child: OutlinedButton(
          style: buttonStyle,
          child: Text('Reset'),
          onPressed: () {
              context.closeDrawer();
              test?.onDrawerReset(context.d);
          }
        )
      )
    );

    rows.add(Row(children: cols));


    return DrawerHeader(
      decoration: BoxDecoration(
        color: t.colorSecondary
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: rows
      ),
    );
  }

  Widget _buildChoiceButton(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context,
    String title,
    IconData icon,
    int view
  ) {
    final t = context.t;
    final isActive = view == context.p.view;
    final color = isActive ? t.colorSecondary : Colors.grey[400] ?? Colors.grey;
      
    final button = IconButton(
      padding: t.paddingNone,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon),
      onPressed: () {
        updateRouteParam(context, context.p.copyWith(view: view));
      },
    );

    return Container(
      padding: t.paddingNone,
      margin: t.margin.b.s3,
      child: button,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: color))
      )
    );
  }

  //--------------------------------------------------------------------------------------
  Widget _buildChoiceRow(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context) {
    final t = context.t;

    final cols = t.row();
    cols.add(_buildChoiceButton(context, "Time", Icons.access_time, AFUIPrototypeDrawerRouteParam.viewTime));
    cols.add(_buildChoiceButton(context, "Theme", Icons.brush, AFUIPrototypeDrawerRouteParam.viewTheme));
    cols.add(_buildChoiceButton(context, "Tests", Icons.run_circle, AFUIPrototypeDrawerRouteParam.viewTest));
    cols.add(_buildChoiceButton(context, "Results", Icons.checklist, AFUIPrototypeDrawerRouteParam.viewResults));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: cols);
  }

  Widget _buildContent(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context) {
    var item;
    final view = context.p.view;
    if(view == AFUIPrototypeDrawerRouteParam.viewTheme) {
      item = _buildThemeContent(context);
    } else if(view == AFUIPrototypeDrawerRouteParam.viewTest) {
      item = _childTestLists(context);
    } else if(view == AFUIPrototypeDrawerRouteParam.viewResults) {
      item = _buildResultsContent(context);
    } else if(view == AFUIPrototypeDrawerRouteParam.viewTime) {
      item = _buildTimeContent(context);
    }

    return Expanded(
      child: MediaQuery.removePadding(
        context: context.contextNullCheck, 
        removeTop: true,
        child: ListView(
          children: [Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [item]
          )]
        )
    ));
  }

  TableRow _createAttributeRow(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context, AFThemeID title, Widget Function() buildValue) {
    final t = context.t;    
    final cols = t.row();
    cols.add(t.testResultTableValue(context, title.toString(), TextAlign.right));
    cols.add(buildValue());
    return TableRow(children: cols);
  }

  Widget _buildEnumAttributeRowValue(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context, AFThemeID attr, dynamic attrValue) {
    final t = context.t;
    final rows = t.column();

    final values = t.fundamentals.optionsForType(attr);
    if(values == null) {
      rows.add(t.childText(attrValue.toString()));
    } else {
      for(final value in values) {
        var text = value.toString();
        final idxOfDot = text.indexOf(".");
        if(idxOfDot > 0) {
          text = text.substring(idxOfDot+1);
        }
        final isSel = value == attrValue;
        rows.add(ChoiceChip(
          selected: isSel,
          label: t.childText(text, textColor: t.colorOnPrimary),
          selectedColor: t.colorPrimary,
          onSelected: (val) {
            if(val) {
              _overrideThemeValue(
                context: context,
                id: attr,
                value: value,
              );            
            }
          }
        ));
      }
    }
    
    return Column(
      children: rows
    );
  }

  void _overrideThemeValue({
    required AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context, 
    required AFThemeID id, 
    dynamic value
  }) {
      context.dispatch(AFOverrideThemeValueAction(
        id: id,
        value: value,
      ));     
      context.dispatch(AFRebuildFunctionalThemes());       
  }

  Widget _buildLocaleAttributeRowValue(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context, AFThemeID attr, dynamic attrValue) {
    final t = context.t;
    final rows = t.column();

    final values = t.fundamentals.supportedLocales;

    rows.add(t.childChoiceChip(
      selected: t.fundamentals.showTranslationIds,
      label: t.childText("Identifiers", textColor: t.colorOnPrimary),
      selectedColor: t.colorPrimary,
      onSelected: (val) {
        _overrideThemeValue(
          context: context,
          id: AFUIThemeID.showTranslationsIDs,
          value: true
        );            
      } 
    ));    

    for(final value in values) {
      var text = value.toString();
      final isSel = value == attrValue;
      rows.add(t.childChoiceChip(
        selected: isSel,
        label: t.childText(text, textColor: t.colorOnPrimary),
        selectedColor: t.colorPrimary,
        onSelected: (val) {
          if(val) {
            _overrideThemeValue(
              context: context,
              id: AFUIThemeID.showTranslationsIDs,
              value: false
            );            
            _overrideThemeValue(
              context: context,
              id: attr,
              value: value,
            );            
          }
        }
      ));
    }
    
    return Column(
      children: rows
    );
  }

  bool _isEnum(dynamic attrVal) {
   final split = attrVal.toString().split('.');
   return split.length > 1 && split[0] == attrVal.runtimeType.toString();
  }

  Widget _buildThemeAreaBody(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context, String area) {
    final t = context.t;    
    // build a table that has different values, like 
    final headerCols = t.row();
    headerCols.add(t.testResultTableHeader(context, "Attr", TextAlign.right));
    headerCols.add(t.testResultTableHeader(context, "Value", TextAlign.left));
    final tableRows = t.childrenTable();
    tableRows.add(TableRow(children: headerCols));       

    for(final attr in t.fundamentals.attrsForArea(area)) {
      tableRows.add(_createAttributeRow(context, attr, () {
          var attrVal = t.fundamentals.findValue(attr);
          if(attr == AFUIThemeID.formFactor) {
            attrVal = t.deviceFormFactor;
          } else if(attr == AFUIThemeID.formOrientation) {
            attrVal = t.deviceOrientation;
          }
          if(attrVal is IconData) {
            return Icon(attrVal);
          }
          if(attrVal is bool) {
            return Row(children: [Switch(          
              value: attrVal,
              onChanged: (attrValNow) {
                _overrideThemeValue(
                  context: context,
                  id: attr,
                  value: attrValNow,
                );            
              }
            )]);
          }
          if(_isEnum(attrVal)) {
            return _buildEnumAttributeRowValue(context, attr, attrVal);
          }
          if(attrVal is Locale) {
            return _buildLocaleAttributeRowValue(context, attr, attrVal);
          }

          return t.childText(attrVal.toString());        
      }));
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: tableRows
    );

  }

  Widget _buildThemeContent(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context) {
    
    final t = context.t;
    final panels = t.childrenExpansionList();
    final areaList = t.fundamentals.areaList;

    for(final area in areaList) {
      panels.add(ExpansionPanel(

        isExpanded: context.p.isExpanded(area),
        headerBuilder: (context, isExpanded) {
          return ListTile(
            title: t.childText("Area: $area" ),
            dense: true,
          );
        },
        body: _buildThemeAreaBody(context, area)
      ));
    }

    final content = ExpansionPanelList(
      expansionCallback: (index, isExpanded) {
        final area = areaList[index];
        updateRouteParam(context, context.p.reviseExpanded(area, expanded: !isExpanded));
      },
      children: panels,
    );

    return Container(
      margin: t.marginStandard,
      child: content
    );
  }

  void _onRun(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context, AFScreenTestID id) {
    final test = context.s.prototype;
    context.closeDrawer();
    Timer(Duration(seconds: 1), () async {         
      final prevContext = context.s.testContext as AFScreenTestContextSimulator?;
      final testState = context.s.singleScreenTestState;
      await test?.onDrawerRun(context.d, prevContext, testState, id, () {
        final revised = context.p.reviseView(AFUIPrototypeDrawerRouteParam.viewResults);
        updateRouteParam(context, revised);
        test.openTestDrawer(id);
      });
    });    
  }

  Widget _childTestList(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context,
    List<AFScreenTestDescription> tests,
    String title) {
    final t = context.t;
    final rows = t.column();
    
    for(final test in tests) {
      var description = test.description;
      var descColor;
      if(test.disabled != null) {
        description = "Disabled: ${test.disabled}";
        descColor = t.colorDisabled;
      }

      rows.add(ListTile(
        title: t.childText(test.id.codeId),
        subtitle: t.childText(description, textColor: descColor),
        trailing: Icon(Icons.run_circle),
        dense: true,
        onTap: () {
          _onRun(context, test.id);
        }
      ));     
    }
    if(tests.isEmpty) {
      rows.add(t.childPadding(
        padding: t.paddingStandard,
        child: t.childText("No tests defined.")
      ));
    }
    

    return t.childCardHeader(context, null, title, rows);
  }

  Widget _childTestLists(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context) {
    final t = context.t;
    final prototype = context.s.prototype;
    final rows = t.column();
    if(prototype == null) throw AFException("Prototype should not be null");
    rows.add(_childTestList(context, prototype.smokeTests, "Smoke"));
    rows.add(_childTestList(context, prototype.reusableTests, "Resuable"));
    rows.add(_childTestList(context, prototype.regressionTests, "Regression"));

    //_buildTestReport(context, rows);
    final content = Column(
      children: rows
    );
    return content;
  }

  Widget _buildResultsContent(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context) {
    final t = context.t;
    final rows = t.column();
    _buildTestReport(context, rows);
    return t.childCard(
      child: t.childPadding(
        padding: t.paddingStandard,
        child: Column(children: rows, crossAxisAlignment: CrossAxisAlignment.stretch)
      )
    );
  }

  TableRow _buildAbsoluteRow(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context, String title, int abs) {
    final t = context.t;
    final cols = t.row();
    cols.add(t.childMargin(
      margin: t.margin.r.s3,
      child: Text(title, textAlign: TextAlign.right)
    ));
    cols.add(Text(abs.toString()));
    return TableRow(children: cols);
  }

  TableRow _createTimeRow(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context, String title, AFTimeState value) {
    final t = context.t;
    final cols = t.column();
    cols.add(t.childMargin(
      margin: t.margin.r.s3,
      child: Text("$title:", textAlign: TextAlign.right)
    ));
    cols.add(Text(value.toString()));
    return TableRow(children: cols);
  }

  Widget _buildTimeContent(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context) {
    final t = context.t;
    final time = context.s.time;
    final timeUTC = time.reviseToUTC();
    final rowsCurrent = t.column();

    final trsCurrent = t.childrenTable();
    trsCurrent.add(_createTimeRow(context, "Local", time));
    trsCurrent.add(_createTimeRow(context, "UTC", timeUTC));

    final columnWidths = <int, TableColumnWidth>{};
    columnWidths[0] = FixedColumnWidth(50);
    columnWidths[1] = FlexColumnWidth();

    rowsCurrent.add(Table(
      children: trsCurrent,
      columnWidths: columnWidths,
    ));
    final timeQuery = context.s.timeQuery;
    if(timeQuery == null) {
      return t.childMargin(
        margin: t.marginStandard,
        child: Text("A AFTimeUpdateListenerQuery is not running.  Either start one in a workflow test, or pass in runTime: true in a screen or widget test.")
      );
    }

    final colsPlayPause = t.row();
    colsPlayPause.add(OutlinedButton(
      child: Icon(Icons.play_arrow),
      onPressed: () {
        final revisedBase = timeQuery.baseTime.reviseForPlay();
        context.dispatchQuery(AFTimeUpdateListenerQuery(baseTime: revisedBase));
      }
    ));

    colsPlayPause.add(OutlinedButton(
      child: Icon(Icons.pause),
      onPressed: () {
        final revisedBase = timeQuery.baseTime.reviseForPause();
        context.dispatchQuery(AFTimeUpdateListenerQuery(baseTime: revisedBase));
      }
    ));

    rowsCurrent.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: colsPlayPause
    ));

    final rowsAdjust = t.column();
    rowsAdjust.add(t.childTextField(
      wid: AFUIWidgetID.textTimeAdjust,
      controllers: context.p.textControllers,
      text: context.p.timeAdjustText,
      obscureText: false,
      autofocus: false,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Adjustment"
      ),
      onChanged: (val) {
        context.updateRouteParam(this, context.p.reviseTimeAdjust(val));
      },       
    ));


    rowsAdjust.add(Container(
      margin: t.marginStandard,
      child: Text("space separated with suffix, eg 1d 2h 3m 4s 5ms", style: t.styleHint())
    ));

    final colsAdd = t.row();
    colsAdd.add(OutlinedButton(
      child: Text("Add"),
      onPressed: () {
        final duration = AFTimeState.parseDuration(context.p.timeAdjustText);
        if(duration == null) {
          return;
        }
        final revisedBase = timeQuery.baseTime.reviseAdjustOffset(duration);
        context.dispatchQuery(AFTimeUpdateListenerQuery(baseTime: revisedBase));
      }
    ));

    colsAdd.add(OutlinedButton(
      child: Text("Subtract"),
      onPressed: () {
        final duration = AFTimeState.parseDuration(context.p.timeAdjustText);
        if(duration == null) {
          context.showDialogErrorText(
            themeOrId: context.t,
            title: "Could not parse duration",
            body: "Please specify duration as a space separated set of tokens, each starting with a number and ending with a suffix, like 2d 1h 3m 4s 5ms"
            
          );
          return;
        }
        final revisedBase = timeQuery.baseTime.reviseAdjustOffset(-duration);
        context.dispatchQuery(AFTimeUpdateListenerQuery(baseTime: revisedBase));
      }
    ));

    rowsAdjust.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: colsAdd));
    
    final rowsSet = t.column();
    rowsSet.add(t.childTextField(
      wid: AFUIWidgetID.textTime,
      controllers: context.p.textControllers,
      text: context.p.timeText,
      obscureText: false,
      autofocus: false,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Enter Time"
      ),
      onChanged: (val) {
        context.updateRouteParam(this, context.p.reviseTimeText(val));
      },        

    ));

    final colsActions = t.row();
    colsActions.add(OutlinedButton(
      child: Row(children: [
        Text("Get"),
        Icon(Icons.arrow_downward)
      ]),
      onPressed: () {
        final timeStr = time.toString();
        context.p.textControllers.reviseOne(AFUIWidgetID.textTime, timeStr);
        context.updateRouteParam(this, context.p.reviseTimeText(timeStr));
      }
    ));

    colsActions.add(OutlinedButton(
      child: Row(children: [
        Text("Set"),
        Icon(Icons.arrow_upward)
      ]),
      onPressed: () {
        final textVal = context.p.textControllers.textFor(AFUIWidgetID.textTime);
        final revised = DateTime.tryParse(textVal);
        if(revised == null) {
          // TODO: handle error case
          return;
        }
        final revisedBase = timeQuery.baseTime.reviseForDesiredNow(DateTime.now(), revised);
        context.dispatchQuery(AFTimeUpdateListenerQuery(baseTime: revisedBase));
      }
    ));


    rowsSet.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: colsActions));



    final rowsOverall = t.column();
    rowsOverall.add(t.childCardHeader(context, null, "Current Time", rowsCurrent));

    rowsOverall.add(t.childCardHeader(context, null, "Adjust Time", [
      t.childMargin(
        margin: t.marginStandard,
        child: Column(children: rowsAdjust)
      )
    ]));

    rowsOverall.add(t.childCardHeader(context, null, "Set Local Time", [
      t.childMargin(
        margin: t.marginStandard,
        child: Column(children: rowsSet)
      )
    ]));

    rowsOverall.add(_buildAbsoluteTimes(context, "Absolute Time", time));
    rowsOverall.add(_buildAbsoluteTimes(context, "Absolute Time - UTC", timeUTC));

    return Column(children: rowsOverall);
  }

  Widget _buildAbsoluteTimes(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context, String title, AFTimeState time) {
    final t = context.t;
    final rowsAbsolute = t.column();
    
    final childrenAbsolute = t.childrenTable();
    childrenAbsolute.add(_buildAbsoluteRow(context, "Second", time.absoluteSecond));
    childrenAbsolute.add(_buildAbsoluteRow(context, "Minute", time.absoluteMinute));
    childrenAbsolute.add(_buildAbsoluteRow(context, "Hour", time.absoluteHour));
    childrenAbsolute.add(_buildAbsoluteRow(context, "Day", time.absoluteDay));
    childrenAbsolute.add(_buildAbsoluteRow(context, "Month", time.absoluteMonth));
    childrenAbsolute.add(_buildAbsoluteRow(context, "Year", time.absoluteYear));
    rowsAbsolute.add(t.childMargin(
      margin: t.marginStandard,
      child: Table(children: childrenAbsolute)
    ));

    return t.childCardHeader(context, null, title, rowsAbsolute);
  }

  void _buildTestReport(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeDrawerRouteParam> context, List<Widget> rows) {
    final t = context.t;
    final testContext = context.s.testContext;
    final testState = context.s.singleScreenTestState;
    
    if(testContext == null) {
      return;
    }

    rows.add(t.buildErrorsSection(context, testState.errors));

    final headerCols = t.row();
    headerCols.add(t.testResultTableHeader(context, "Test", TextAlign.right));
    headerCols.add(t.testResultTableHeader(context, "Pass", TextAlign.right));
    headerCols.add(t.testResultTableHeader(context, "Fail", TextAlign.right));

    final resultCols = t.row();
    resultCols.add(t.testResultTableValue(context, testState.testId.code, TextAlign.left));
    resultCols.add(t.testResultTableValue(context, testState.pass.toString(), TextAlign.right));
    resultCols.add(t.testResultTableValue(context, testState.errors.length.toString(), TextAlign.right, showError: (testState.errors.isNotEmpty)));
    
    final tableRows = t.childrenTable();
    tableRows.add(TableRow(children: headerCols));
    tableRows.add(TableRow(children: resultCols));

    final columnWidths = {
      1: FlexColumnWidth(),
      2: FixedColumnWidth(t.resultColumnWidth),
      3: FixedColumnWidth(t.resultColumnWidth),
    };

    rows.add(Container(
      margin: t.margin.t.s4,
      child: Table(children: tableRows, columnWidths: columnWidths)
    ));
  }
}
