
import 'dart:async';

import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/queries/af_time_update_listener_query.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/utils/af_param_ui_state_holder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//--------------------------------------------------------------------------------------
class AFUIPrototypeDrawerRouteParam extends AFDrawerRouteParam {
  static const viewTime = 0;
  static const viewTheme = 1;
  static const viewTest  = 2;
  static const viewResults = 3;
  final int view;
  final Map<String, bool> themeExpanded;
  final String timeText;
  final String timeAdjustText;
  final AFTextEditingControllers textControllers;

  AFUIPrototypeDrawerRouteParam({
    required this.view, 
    required this.themeExpanded,
    required this.timeText,
    required this.timeAdjustText,
    required this.textControllers,
  }): super(screenId: AFUIScreenID.drawerPrototype);

  factory AFUIPrototypeDrawerRouteParam.createOncePerScreen(int view) {
    final themeExpanded = <String, bool>{};
    final textControllers = AFTextEditingControllers.createN({
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

  AFUIPrototypeDrawerRouteParam reviseLatencyAdjust(String timeText) {
    return copyWith(latencyAdjustText: timeText);
  }

  AFUIPrototypeDrawerRouteParam copyWith({
    int? view,
    Map<String, bool>? themeExpanded,
    String? timeText,
    String? timeAdjustText,
    String? latencyAdjustText,
  }) {
    return AFUIPrototypeDrawerRouteParam(
      view: view ?? this.view,
      themeExpanded: themeExpanded ?? this.themeExpanded,
      textControllers: this.textControllers,
      timeText: timeText ?? this.timeText,
      timeAdjustText: timeAdjustText ?? this.timeAdjustText,
    );
  }
}

class AFUIPrototypeDrawerSPI extends AFUIDrawerSPI<AFUIDefaultStateView, AFUIPrototypeDrawerRouteParam> {

  const AFUIPrototypeDrawerSPI(super.context, super.standard);
  
  factory AFUIPrototypeDrawerSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeDrawerRouteParam> context, AFStandardSPIData standard) {
    return AFUIPrototypeDrawerSPI(context, standard);
  }

  void onTapAddDuration() {
    _onTapDuration(1);
  }

  //--------------------------------------------------------------------------------------
  void onTapSubtractDuration() {
    _onTapDuration(-1);
  }

  //--------------------------------------------------------------------------------------
  void onPressedViewButton(int view) {
     context.updateRouteParam(context.p.copyWith(view: view));
  }

  //--------------------------------------------------------------------------------------
  void onExpandArea(String area, { required bool expanded }) {
    context.updateRouteParam(context.p.reviseExpanded(area, expanded: expanded));
  }

  //--------------------------------------------------------------------------------------
  void onChangedTimeAdjust(String val) {
    context.updateRouteParam(context.p.reviseTimeAdjust(val));
  }

  //--------------------------------------------------------------------------------------
  void onChangedLatencyAdjust(String val) {
    context.updateRouteParam(context.p.reviseLatencyAdjust(val));
  }

  //--------------------------------------------------------------------------------------
  void onChangedTimeText(String val) {
    context.updateRouteParam(context.p.reviseTimeText(val));
  }

  //--------------------------------------------------------------------------------------
  void onPressedGetTime(String timeStr) {
    context.p.textControllers.reviseOne(AFUIWidgetID.textTime, timeStr);
    context.updateRouteParam(context.p.reviseTimeText(timeStr));
  }

  //--------------------------------------------------------------------------------------
  void onPressedPlayTime(AFTimeUpdateListenerQuery timeQuery) {
    final revisedBase = timeQuery.baseTime.reviseForPlay();
    context.executeQuery(AFTimeUpdateListenerQuery(baseTime: revisedBase));
  }

  //--------------------------------------------------------------------------------------
  void onPressedPauseTime(AFTimeUpdateListenerQuery timeQuery) {
    final revisedBase = timeQuery.baseTime.reviseForPause();
    context.executeQuery(AFTimeUpdateListenerQuery(baseTime: revisedBase));
  }

  //--------------------------------------------------------------------------------------
  void onTapSetTime() {
    final timeQuery = context.s.timeQuery;
    if(timeQuery == null) {
      return;
    }
    final textVal = context.p.textControllers.textFor(AFUIWidgetID.textTime);
    DateTime revised;
    try {
      revised = DateTime.parse(textVal);
    } on FormatException {
      context.showDialogErrorText(
        themeOrId: t,
        title: "Could not parse time",
        body: "Could not parse the time during DateTime.parse.  Note that days and hours must be two digits (e.g. 05, not 5)",        
      );
      return;
    }
    final revisedBase = timeQuery.baseTime.reviseForDesiredNow(DateTime.now(), revised);
    context.executeQuery(AFTimeUpdateListenerQuery(baseTime: revisedBase));

  }

  //--------------------------------------------------------------------------------------
  void _onTapDuration(int multiple) {
    final timeQuery = context.s.timeQuery;
    if(timeQuery == null) {
      return;
    }
    Duration duration;
    try {
      duration = AFTimeState.parseDuration(context.p.timeAdjustText);
    } on FormatException {
      context.showDialogErrorText(
        themeOrId: t,
        title: "Could not parse duration",
        body: "Please specify duration as a space separated set of tokens, each starting with a number and ending with a suffix, like 2d 1h 3m 4s 5ms"        
      );
      return;
    }
    final revisedBase = timeQuery.baseTime.reviseAdjustOffset(duration*multiple);
    context.executeQuery(AFTimeUpdateListenerQuery(baseTime: revisedBase));
  }
}

//--------------------------------------------------------------------------------------
class AFUIPrototypeDrawer extends AFUIConnectedDrawer<AFUIPrototypeDrawerSPI, AFUIDefaultStateView, AFUIPrototypeDrawerRouteParam> {
  static final timeFormat = DateFormat('Hms');
  static final config = AFUIDefaultDrawerConfig<AFUIPrototypeDrawerSPI, AFUIPrototypeDrawerRouteParam> (
    spiCreator: AFUIPrototypeDrawerSPI.create,
    createDefaultRouteParam: (source, pubState) => AFUIPrototypeDrawerRouteParam.createOncePerScreen(AFUIPrototypeDrawerRouteParam.viewTest)
  );

  //--------------------------------------------------------------------------------------
  AFUIPrototypeDrawer(): super(screenId: AFUIScreenID.drawerPrototype, config: config);

  //--------------------------------------------------------------------------------------
  @override
  AFScreenID? get primaryScreenId {
    return null;
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget buildWithSPI(AFUIPrototypeDrawerSPI spi) {
    return _buildDrawer(spi);
  }

  //--------------------------------------------------------------------------------------
  Widget _buildDrawer(AFUIPrototypeDrawerSPI spi) {
    final rows = spi.t.column();
    
    rows.add(_buildHeader(spi));
    rows.add(_buildChoiceRow(spi));
    rows.add(_buildContent(spi));

    return Drawer(      
        child: Column(
          children: rows,
        )
    );
  }

  //--------------------------------------------------------------------------------------
  Widget _buildHeader(AFUIPrototypeDrawerSPI spi) {
    final t = spi.t;
    final context = spi.context;
    final rows = t.column();
    final test = context.s.prototype;

    rows.add(Container(
      margin: t.margin.v.s3,
      child: t.childText(
        text: "AFib Prototype",
        style: t.styleOnPrimary.titleLarge
      )
    ));

    rows.add(Container(
      margin: t.margin.v.s3,
      child: t.childText(
          text: context.s.prototype?.id.toString(), 
          style: t.styleOnPrimary.bodyMedium,
          overflow: TextOverflow.ellipsis,
      )
    ));

    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: t.colorOnPrimary,
      textStyle: TextStyle(color: t.colorSecondary),
      side: BorderSide(width: 1, color: t.colorOnPrimary),
    );

    final cols = t.row();
    cols.add(TextButton(
      style: buttonStyle,
      onPressed: () {
          context.closeDrawer();
          context.dispatch(AFNavigateExitTestAction());
      },
      child: t.childText(text: 'Exit')
    ));

    cols.add(
      Container(
        margin: t.margin.l.s3,
        child: OutlinedButton(
          style: buttonStyle,
          child: const Text('Reset'),
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

  Widget _buildChoiceButton(AFUIPrototypeDrawerSPI spi,
    String title,
    IconData icon,
    int view
  ) {
    final t = spi.t;
    final context = spi.context;
    final isActive = view == context.p.view;
    final color = isActive ? t.colorSecondary : Colors.grey[400] ?? Colors.grey;
      
    final button = IconButton(
      padding: t.padding.none,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon),
      onPressed: () {
        spi.onPressedViewButton(view);
      },
    );

    return Container(
      padding: t.padding.none,
      margin: t.margin.b.s3,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: color))
      ),
      child: button
    );
  }

  //--------------------------------------------------------------------------------------
  Widget _buildChoiceRow(AFUIPrototypeDrawerSPI spi) {
    final t = spi.t;

    final cols = t.row();
    cols.add(_buildChoiceButton(spi, "Time", Icons.access_time, AFUIPrototypeDrawerRouteParam.viewTime));
    cols.add(_buildChoiceButton(spi, "Theme", Icons.brush, AFUIPrototypeDrawerRouteParam.viewTheme));
    cols.add(_buildChoiceButton(spi, "Tests", Icons.run_circle, AFUIPrototypeDrawerRouteParam.viewTest));
    cols.add(_buildChoiceButton(spi, "Results", Icons.checklist, AFUIPrototypeDrawerRouteParam.viewResults));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: cols);
  }

  Widget _buildContent(AFUIPrototypeDrawerSPI spi) {
    final context = spi.context;
    var item;
    final view = context.p.view;
    if(view == AFUIPrototypeDrawerRouteParam.viewTheme) {
      item = _buildThemeContent(spi);
    } else if(view == AFUIPrototypeDrawerRouteParam.viewTest) {
      item = _childTestLists(spi);
    } else if(view == AFUIPrototypeDrawerRouteParam.viewResults) {
      item = _buildResultsContent(spi);
    } else if(view == AFUIPrototypeDrawerRouteParam.viewTime) {
      item = _buildTimeContent(spi);
    }

    return Expanded(
      child: MediaQuery.removePadding(
        context: spi.context.contextNullCheck, 
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

  TableRow _createAttributeRow(AFUIPrototypeDrawerSPI spi, AFThemeID title, Widget Function() buildValue) {
    final t = spi.t;    
    final cols = t.row();
    cols.add(t.testResultTableValue(title.toString(), TextAlign.right));
    cols.add(buildValue());
    return TableRow(children: cols);
  }

  Widget _buildEnumAttributeRowValue(AFUIPrototypeDrawerSPI spi, AFThemeID attr, dynamic attrValue) {
    final t = spi.t;
    final rows = t.column();

    final values = t.fundamentals.optionsForType(attr);
    if(values == null) {
      rows.add(t.childText(text: attrValue.toString()));
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
          label: t.childText(text: text, textColor: t.colorOnPrimary),
          selectedColor: t.colorPrimary,
          onSelected: (val) {
            if(val) {
              _overrideThemeValue(
                spi: spi,
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
    required AFUIPrototypeDrawerSPI spi, 
    required AFThemeID id, 
    dynamic value
  }) {
      spi.context.dispatch(AFOverrideThemeValueAction(
        id: id,
        value: value,
      ));     
  }

  Widget _buildLocaleAttributeRowValue(AFUIPrototypeDrawerSPI spi, AFThemeID attr, dynamic attrValue) {
    final t = spi.t;
    final rows = t.column();

    final values = t.fundamentals.supportedLocales;

    rows.add(t.childChoiceChip(
      selected: t.fundamentals.showTranslationIds,
      label: t.childText(text: "Identifiers", textColor: t.colorOnPrimary),
      selectedColor: t.colorPrimary,
      onSelected: (val) {
        _overrideThemeValue(
          spi: spi,
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
        label: t.childText(text: text, textColor: t.colorOnPrimary),
        selectedColor: t.colorPrimary,
        onSelected: (val) {
          if(val) {
            _overrideThemeValue(
              spi: spi,
              id: AFUIThemeID.showTranslationsIDs,
              value: false
            );            
            _overrideThemeValue(
              spi: spi,
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

  Widget _buildThemeAreaBody(AFUIPrototypeDrawerSPI spi, String area) {
    final t = spi.t;    
    // build a table that has different values, like 
    final headerCols = t.row();
    headerCols.add(t.testResultTableHeader("Attr", TextAlign.right));
    headerCols.add(t.testResultTableHeader("Value", TextAlign.left));
    final tableRows = t.childrenTable();
    tableRows.add(TableRow(children: headerCols));       

    for(final attr in t.fundamentals.attrsForArea(area)) {
      tableRows.add(_createAttributeRow(spi, attr, () {
          var attrVal = t.fundamentals.findValue(attr);
          if(attr == AFUIThemeID.formFactor) {
            attrVal = t.deviceFormFactor;
          } else if(attr == AFUIThemeID.formOrientation) {
            attrVal = t.deviceOrientation;
          }
          if(attrVal is IconData) {
            return Icon(attrVal);
          }
          if(attrVal is Color) {
            return Row(
              children: [
                Container(
                  margin: t.margin.r.standard,
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: attrVal,
                    border: Border.all(color: Colors.black),
                  )
                ),
                Text(attrVal.value.toRadixString(16)),
              ]
            
            );
          }
          if(attrVal is bool) {
            return Row(children: [Switch(          
              value: attrVal,
              onChanged: (attrValNow) {
                _overrideThemeValue(
                  spi: spi,
                  id: attr,
                  value: attrValNow,
                );            
              }
            )]);
          }
          if(_isEnum(attrVal)) {
            return _buildEnumAttributeRowValue(spi, attr, attrVal);
          }
          if(attrVal is Locale) {
            return _buildLocaleAttributeRowValue(spi, attr, attrVal);
          }

          return t.childText(text: attrVal.toString());        
      }));
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: tableRows
    );

  }

  Widget _buildThemeContent(AFUIPrototypeDrawerSPI spi) {    
    final t = spi.t;
    final context = spi.context;

    final panels = t.childrenExpansionList();
    final areaList = t.fundamentals.areaList;

    for(final area in areaList) {
      panels.add(ExpansionPanel(

        isExpanded: context.p.isExpanded(area),
        headerBuilder: (spi, isExpanded) {
          return ListTile(
            title: t.childText(text: "Area: $area" ),
            dense: true,
          );
        },
        body: _buildThemeAreaBody(spi, area)
      ));
    }

    final content = ExpansionPanelList(
      expansionCallback: (index, isExpanded) {
        final area = areaList[index];
        spi.onExpandArea(area, expanded: !isExpanded);
      },
      children: panels,
    );

    return Container(
      margin: t.margin.standard,
      child: content
    );
  }

  void _onRun(AFUIPrototypeDrawerSPI spi, AFScreenTestID id) {
    final context = spi.context;
    final test = context.s.prototype;
    context.closeDrawer();
    Timer(const Duration(seconds: 1), () async {         
      final prevContext = context.s.testContext as AFScreenTestContextSimulator?;
      final testState = context.s.singleScreenTestState;
      await test?.onDrawerRun(context, prevContext, testState, id, () {
        spi.onPressedViewButton(AFUIPrototypeDrawerRouteParam.viewResults);
        test.openTestDrawer(id);
      });
    });    
  }



  Widget _childTestList(AFUIPrototypeDrawerSPI spi,
    List<AFScreenTestDescription> tests,
    String title) {
    final t = spi.t;
    final context = spi.context;
    final rows = t.column();
    
    for(final test in tests) {
      var description = test.description;
      var descColor;
      if(test.disabled != null) {
        description = "Disabled: ${test.disabled}";
        descColor = t.colorDisabled;
      }

      rows.add(ListTile(
        title: t.childText(text: test.id.codeId),
        subtitle: t.childText(text: description, textColor: descColor),
        trailing: const Icon(Icons.run_circle),
        dense: true,
        onTap: () {
          final testId = test.id;
          if(testId is AFScreenTestID) {
            _onRun(spi, testId);
          } 
        }
      ));     
    }
    if(tests.isEmpty) {
      rows.add(t.childPadding(
        padding: t.padding.standard,
        child: t.childText(text: "No tests defined.")
      ));
    }
    

    return t.childCardHeader(context, null, title, rows);
  }

  Widget _childTestLists(AFUIPrototypeDrawerSPI spi) {
    final t = spi.t;
    final context = spi.context;
    final prototype = context.s.prototype;
    final rows = t.column();
    if(prototype == null) throw AFException("Prototype should not be null");
    rows.add(_childTestList(spi, prototype.smokeTests, "Smoke"));
    rows.add(_childTestList(spi, prototype.reusableTests, "Resuable"));
    rows.add(_childTestList(spi, prototype.regressionTests, "Regression"));

    //_buildTestReport(spi, rows);
    final content = Column(
      children: rows
    );
    return content;
  }

  Widget _buildResultsContent(AFUIPrototypeDrawerSPI spi) {
    final t = spi.t;
    final rows = t.column();
    _buildTestReport(spi, rows);
    return t.childCard(
      child: t.childPadding(
        padding: t.padding.standard,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows)
      )
    );
  }

  TableRow _buildAbsoluteRow(AFUIPrototypeDrawerSPI spi, String title, int abs) {
    final t = spi.t;
    final cols = t.row();
    cols.add(t.childMargin(
      margin: t.margin.r.s3,
      child: Text(title, textAlign: TextAlign.right)
    ));
    cols.add(Text(abs.toString()));
    return TableRow(children: cols);
  }

  TableRow _createTimeRow(AFUIPrototypeDrawerSPI spi, String title, AFTimeState value) {
    final t = spi.t;
    final cols = t.column();
    cols.add(t.childMargin(
      margin: t.margin.r.s3,
      child: Text("$title:", textAlign: TextAlign.right)
    ));
    cols.add(Text(value.toString()));
    return TableRow(children: cols);
  }

  Widget _buildTimeContent(AFUIPrototypeDrawerSPI spi) {
    final context = spi.context;
    final t = spi.t;
    final timeQuery = context.s.timeQuery;
    final rowsOverall = t.column();

    if(timeQuery == null)  {
      rowsOverall.add(Container(
        padding: t.padding.standard,
        margin: t.margin.standard,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: t.borderRadius.standard,
        ),
        child: t.childText(text: "An AFTimeUpdateListenerQuery is not running.  Either start one in a workflow test, or pass in runTime: true in a screen or widget test."
      )));      
    } else {
      _buildTimeControls(spi, rows: rowsOverall);
    }

    return Column(children: rowsOverall);
  }

  void _buildTimeControls(AFUIPrototypeDrawerSPI spi, { required List<Widget> rows }) {
    final context = spi.context;
    final t = spi.t;
    final time = context.s.time;
    final timeUTC = time.reviseToUTC();
    final rowsCurrent = t.column();

    final trsCurrent = t.childrenTable();
    trsCurrent.add(_createTimeRow(spi, "Local", time));
    trsCurrent.add(_createTimeRow(spi, "UTC", timeUTC));

    final columnWidths = <int, TableColumnWidth>{};
    columnWidths[0] = const FixedColumnWidth(50);
    columnWidths[1] = const FlexColumnWidth();

    rowsCurrent.add(Table(
      children: trsCurrent,
      columnWidths: columnWidths,
    ));
    final timeQuery = context.s.timeQuery;
    if(timeQuery == null) {
      return;
    }

    final colsPlayPause = t.row();
    colsPlayPause.add(OutlinedButton(
      child: const Icon(Icons.play_arrow),
      onPressed: () => spi.onPressedPlayTime(timeQuery)

    ));

    colsPlayPause.add(OutlinedButton(
      child: const Icon(Icons.pause),
      onPressed: () => spi.onPressedPauseTime(timeQuery)
    ));

    rowsCurrent.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: colsPlayPause
    ));

    final rowsAdjust = t.column();
    rowsAdjust.add(t.childTextField(
      screenId: screenId,
      wid: AFUIWidgetID.textTimeAdjust,
      controllers: context.p.textControllers,
      expectedText: context.p.timeAdjustText,
      obscureText: false,
      autofocus: false,
      textAlign: TextAlign.left,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Adjustment"
      ),
      onChanged: spi.onChangedTimeAdjust
    ));


    rowsAdjust.add(Container(
      margin: t.margin.standard,
      child: Text("space separated with suffix, eg 1d 2h 3m 4s 5ms", style: t.styleHint())
    ));

    final colsAdd = t.row();
    colsAdd.add(OutlinedButton(
      child: const Text("Add"),
      onPressed: () {
        spi.onTapAddDuration();
      }
    ));

    colsAdd.add(OutlinedButton(
      child: const Text("Subtract"),
      onPressed: () {
        spi.onTapSubtractDuration();
      }
    ));

    rowsAdjust.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: colsAdd));
    
    final rowsSet = t.column();
    rowsSet.add(t.childTextField(
      wid: AFUIWidgetID.textTime,
      screenId: screenId,
      controllers: context.p.textControllers,
      expectedText: context.p.timeText,
      obscureText: false,
      autofocus: false,
      textAlign: TextAlign.left,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Enter Time"
      ),
      onChanged: spi.onChangedTimeText

    ));

    final colsActions = t.row();
    colsActions.add(OutlinedButton(
      child: const Row(children: [
        Text("Get"),
        Icon(Icons.arrow_downward)
      ]),
      onPressed: () {
        final timeStr = time.toString();
        spi.onPressedGetTime(timeStr);
      }
    ));

    colsActions.add(OutlinedButton(
      child: const Row(children: [
        Text("Set"),
        Icon(Icons.arrow_upward)
      ]),
      onPressed: () {
        spi.onTapSetTime();
      }
    ));


    rowsSet.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: colsActions));



    rows.add(t.childCardHeader(context, null, "Current Time", rowsCurrent));

    rows.add(t.childCardHeader(context, null, "Adjust Time", [
      t.childMargin(
        margin: t.margin.standard,
        child: Column(children: rowsAdjust)
      )
    ]));

    rows.add(t.childCardHeader(context, null, "Set Local Time", [
      t.childMargin(
        margin: t.margin.standard,
        child: Column(children: rowsSet)
      )
    ]));

    rows.add(_buildAbsoluteTimes(spi, "Absolute Time", time));
    rows.add(_buildAbsoluteTimes(spi, "Absolute Time - UTC", timeUTC));
  }

  Widget _buildAbsoluteTimes(AFUIPrototypeDrawerSPI spi, String title, AFTimeState time) {
    final t = spi.t;
    final context = spi.context;
    final rowsAbsolute = t.column();
    
    final childrenAbsolute = t.childrenTable();
    childrenAbsolute.add(_buildAbsoluteRow(spi, "Second", time.absoluteSecond));
    childrenAbsolute.add(_buildAbsoluteRow(spi, "Minute", time.absoluteMinute));
    childrenAbsolute.add(_buildAbsoluteRow(spi, "Hour", time.absoluteHour));
    childrenAbsolute.add(_buildAbsoluteRow(spi, "Day", time.absoluteDay));
    childrenAbsolute.add(_buildAbsoluteRow(spi, "Month", time.absoluteMonth));
    childrenAbsolute.add(_buildAbsoluteRow(spi, "Year", time.absoluteYear));
    rowsAbsolute.add(t.childMargin(
      margin: t.margin.standard,
      child: Table(children: childrenAbsolute)
    ));

    return t.childCardHeader(context, null, title, rowsAbsolute);
  }

  void _buildTestReport(AFUIPrototypeDrawerSPI spi, List<Widget> rows) {
    final t = spi.t;
    final context = spi.context;
    final testContext = context.s.testContext;
    final testState = context.s.singleScreenTestState;
    
    if(testContext == null) {
      return;
    }

    rows.add(t.buildErrorsSection(testState.errors));

    final headerCols = t.row();
    headerCols.add(t.testResultTableHeader("Test", TextAlign.right));
    headerCols.add(t.testResultTableHeader("Pass", TextAlign.right));
    headerCols.add(t.testResultTableHeader("Fail", TextAlign.right));

    final resultCols = t.row();
    resultCols.add(t.testResultTableValue(testState.testId.code, TextAlign.left));
    resultCols.add(t.testResultTableValue(testState.pass.toString(), TextAlign.right));
    resultCols.add(t.testResultTableValue(testState.errors.length.toString(), TextAlign.right, showError: (testState.errors.isNotEmpty)));
    
    final tableRows = t.childrenTable();
    tableRows.add(TableRow(children: headerCols));
    tableRows.add(TableRow(children: resultCols));

    final columnWidths = {
      1: const FlexColumnWidth(),
      2: FixedColumnWidth(t.resultColumnWidth),
      3: FixedColumnWidth(t.resultColumnWidth),
    };

    rows.add(Container(
      margin: t.margin.t.s4,
      child: Table(children: tableRows, columnWidths: columnWidths)
    ));
  }
}
