
import 'dart:async';

import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/id.dart';
import 'package:afib/src/flutter/ui/af_prototype_base.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//--------------------------------------------------------------------------------------
class AFTestDrawerRouteParam extends AFRouteParam {
  static const viewTheme = 1;
  static const viewTest  = 2;
  static const viewReuse = 3;
  final int view;
  final Map<String, bool> themeExpanded;

  AFTestDrawerRouteParam({
    @required this.view, 
    @required this.themeExpanded
  });

  factory AFTestDrawerRouteParam.createOncePerScreen(int view) {
    final themeExpanded = <String, bool>{};
    return AFTestDrawerRouteParam(view: view, themeExpanded: themeExpanded);
  }

  bool isExpanded(String area) {
    final result = themeExpanded[area];
    return result ?? false;
  }

  AFTestDrawerRouteParam reviseExpanded(String area, { bool expanded }) {
    final revised = Map<String, bool>.from(themeExpanded);
    revised[area] = expanded;
    return copyWith(themeExpanded: revised);
  }

  AFTestDrawerRouteParam copyWith({
    int view,
    Map<String, bool> themeExpanded
  }) {
    return AFTestDrawerRouteParam(
      view: view ?? this.view,
      themeExpanded: themeExpanded ?? this.themeExpanded
    );
  }
}

//--------------------------------------------------------------------------------------
class AFTestDrawerData extends AFStateView3<AFScreenTestContextSimulator, AFSingleScreenTestState, AFScreenPrototypeTest> {
  AFTestDrawerData(AFScreenTestContextSimulator testContext, AFSingleScreenTestState testState, AFScreenPrototypeTest test): 
    super(first: testContext, second: testState, third: test);

  AFScreenTestContextSimulator get testContext { return first; }
  AFSingleScreenTestState get testState { return second; }
  AFScreenPrototypeTest get test { return third; }
}

//--------------------------------------------------------------------------------------
class AFTestDrawer extends AFProtoConnectedDrawer<AFTestDrawerData, AFTestDrawerRouteParam> {
  static final timeFormat = DateFormat('Hms');

  //--------------------------------------------------------------------------------------
  AFTestDrawer(): super(AFUIScreenID.screenTestDrawer);

  //--------------------------------------------------------------------------------------
  AFScreenID get primaryScreenId {
    return null;
  }

  //--------------------------------------------------------------------------------------
  @override
  AFTestDrawerData createStateViewAF(AFState state, AFTestDrawerRouteParam param, AFRouteParamWithChildren paramWithChildren) {
    final testState = state.testState;
    final test = AFibF.g.findScreenTestById(testState.activeTestId);
    return AFTestDrawerData(testState.findContext(test.id), testState.findState(test.id), test);
  }

  //--------------------------------------------------------------------------------------
  AFTestDrawerRouteParam createDefaultRouteParam(AFState state) {
    return AFTestDrawerRouteParam.createOncePerScreen(AFTestDrawerRouteParam.viewTest);
  }

  //--------------------------------------------------------------------------------------
  @override
  AFTestDrawerData createStateView(AFAppStateArea state, AFTestDrawerRouteParam param) {
    // this should never be called, because createDataAF replaces it.
    throw UnimplementedError();
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget buildWithContext(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context) {
    return _buildDrawer(context);
  }

  //--------------------------------------------------------------------------------------
  Widget _buildDrawer(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context) {
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
  Widget _buildHeader(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context) {
    final t = context.t;
    final rows = t.column();
    final test = context.s.test;

    rows.add(Container(
      margin: t.margin.v.s3,
      child: t.childText(
        "AFib Test Drawer",
        style: t.styleOnPrimary.headline2
      )
    ));

    rows.add(Container(
      margin: t.margin.v.s3,
      child: t.childText(
          context.s.test.id.toString(), 
          style: t.styleOnPrimary.headline6
      )
    ));

    final cols = t.row();
    cols.add(FlatButton(
      child: t.childText('Exit'),
      color: t.colorOnPrimary,
      textColor: t.colorSecondary,
      onPressed: () {
          context.closeDrawer();
          context.dispatch(AFNavigateExitTestAction());
      }
    ));

    cols.add(
      Container(
        margin: t.margin.l.s3,
        child: FlatButton(
        child: Text('Reset'),
        color: t.colorOnPrimary,
        textColor: t.colorSecondary,
        onPressed: () {
            context.closeDrawer();
            test.onDrawerReset(context.d);
        }
      )
    ));

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

  Widget _buildChoiceButton(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context,
    String title,
    int view
  ) {
    final t = context.t;
    final isActive = view == context.p.view;
    final color = isActive ? t.colorSecondary : Colors.grey[400];
    final colorText = isActive ? t.colorOnPrimary : t.colorOnBackground;

    return FlatButton(
      child: t.childText(title),
      color: color,
      textColor: colorText,
      shape: RoundedRectangleBorder(),
      onPressed: () {
        updateRouteParam(context, context.p.copyWith(view: view));
      },
    );
  }

  //--------------------------------------------------------------------------------------
  Widget _buildChoiceRow(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context) {
    final t = context.t;

    final cols = t.row();

    cols.add(_buildChoiceButton(context, "Theme", AFTestDrawerRouteParam.viewTheme));
    cols.add(_buildChoiceButton(context, "Test", AFTestDrawerRouteParam.viewTest));
    cols.add(_buildChoiceButton(context, "Reuse", AFTestDrawerRouteParam.viewReuse));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: cols);
  }

  Widget _buildContent(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context) {
    var item;
    final view = context.p.view;
    if(view == AFTestDrawerRouteParam.viewTheme) {
      item = _buildThemeContent(context);
    } else if(view == AFTestDrawerRouteParam.viewTest) {
      item = _buildTestContent(context);
    } else if(view == AFTestDrawerRouteParam.viewReuse) {
      item = _buildReuseContent(context);
    }

    return Expanded(
      child: MediaQuery.removePadding(
        context: context.c, 
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

  TableRow _createAttributeRow(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context, AFThemeID title, Widget Function() buildValue) {
    final t = context.t;    
    final cols = t.row();
    cols.add(t.testResultTableValue(context, title.toString(), TextAlign.right));
    cols.add(buildValue());
    return TableRow(children: cols);
  }

  Widget _buildEnumAttributeRowValue(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context, AFThemeID attr, dynamic attrValue) {
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
              context.dispatch(AFOverrideThemeValueAction(
                id: attr,
                value: value,
              ));            
            }
          }
        ));
      }
    }
    
    return Column(
      children: rows
    );
  }


  bool _isEnum(dynamic attrVal) {
   final split = attrVal.toString().split('.');
   return split.length > 1 && split[0] == attrVal.runtimeType.toString();
  }

  Widget _buildThemeAreaBody(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context, String area) {
    final t = context.t;    
    // build a table that has different values, like 
    final headerCols = t.row();
    headerCols.add(t.testResultTableHeader(context, "Attr", TextAlign.right));
    headerCols.add(t.testResultTableHeader(context, "Value", TextAlign.left));
    final tableRows = t.childrenTable();
    tableRows.add(TableRow(children: headerCols));       

    for(final attr in t.fundamentals.attrsForArea(area)) {
      tableRows.add(_createAttributeRow(context, attr, () {
          final attrVal = t.fundamentals.findValue(attr);
          if(attrVal is IconData) {
            return Icon(attrVal);
          }
          if(attrVal is bool) {
            return Row(children: [Switch(          
              value: attrVal,
              onChanged: (attrValNow) {
                context.dispatch(AFOverrideThemeValueAction(
                  id: attr,
                  value: attrValNow,
                ));
              }
            )]);
          }
          if(_isEnum(attrVal)) {
            return _buildEnumAttributeRowValue(context, attr, attrVal);
          }

          return t.childText(attrVal.toString());        
      }));
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: tableRows
    );

  }

  Widget _buildThemeContent(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context) {
    
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

  void _onRun(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context, AFReusableTestID id) {
    final test = context.s.test;
    context.closeDrawer();
    Timer(Duration(seconds: 1), () async {            
      await test.onDrawerRun(context.d, context.s.testContext, context.s.testState, id, () {
        test.openTestDrawer(id);
      });
    });    
  }

  Widget _buildRunButton(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context) {
    final t = context.t;
    final test = context.s.test;
    final sectionIds = test.sectionIds;

    final cols = t.row();

    final hasMultiple = sectionIds.length > 1;
    final firstId = sectionIds.first;
    var defaultRunId = firstId;
    var rowAlign = MainAxisAlignment.start;
    if(hasMultiple) {
      defaultRunId = AFReusableTestID.allTestId;
      rowAlign = MainAxisAlignment.spaceBetween;
    }

    cols.add(t.childText('Run $defaultRunId test'));

    if(hasMultiple) {
      cols.add(PopupMenuButton<AFReusableTestID>(
        onSelected: (id) { 
          _onRun(context, id);
        },
        itemBuilder: (context) {
          final result = <PopupMenuEntry<AFReusableTestID>>[];
          for(final id in sectionIds) {
            result.add(PopupMenuItem<AFReusableTestID>(
              value: id,
              child: t.childText(id.toString())
            ));
          }

          return result;
        }
      ));
    }

    final buttonContent = Row(
      mainAxisAlignment: rowAlign,
      children: cols,
    );

    return FlatButton(
      child: buttonContent,
      color: t.colorSecondary,
      textColor: t.colorOnSecondary,
      onPressed: ()  {
        _onRun(context, defaultRunId);
      }
    );


    
      
    
  }

  Widget _buildTestContent(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context) {
    final t = context.t;
    var content;
    if(context.s.test.hasBody) {
      final rows = t.column();
      rows.add(_buildRunButton(context));
      _buildTestReport(context, rows);
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows
      );
    } else {
      content = t.testExplanationText("This test does not have a test body.  To add one, see definitions.addSmokeTest or definitions.addReusableTest1...");
    }

    return _areaContentCard(context, content);
  }

  Widget _areaContentCard(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context, Widget child) {
    return Card(child: Container(
      margin: context.t.marginStandard,
      child: child
    ));
  }

  Widget _buildReuseContent(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context) {
    final t = context.t;
    final test = context.s.test;
    var content;
    if(test.hasReusable) {

      for(final reusableId in test.sectionIds) {
        final rows = t.column();
        if(reusableId == AFReusableTestID.smokeTestId) {
          continue;
        }

        if(reusableId != null) {
          rows.add(Container(
            margin: t.margin.b.s5,
            child: t.childText('Reusable: ${reusableId.toString()}', textAlign: TextAlign.left)
          ));
        }
        final params = test.paramDescriptions(reusableId);

        final tableRows = t.childrenTable();
        final headerCols = t.row();
        headerCols.add(t.testResultTableHeader(context, "#", TextAlign.left));
        headerCols.add(t.testResultTableHeader(context, "Param Description", TextAlign.left));
        tableRows.add(TableRow(children: headerCols));
        
        for(var i = 0; i < params.length; i++) {
          final param = params[i];
          final resultCols = t.row();
          resultCols.add(t.testResultTableValue(context, (i+1).toString(), TextAlign.right));
          resultCols.add(t.testResultTableValue(context, param, TextAlign.left));
          tableRows.add(TableRow(children: resultCols));
        }

        rows.add(Table(children: tableRows, columnWidths: AFPrototypeTheme.columnWidthsForNumValueTable));
        content = Container(
          margin: t.margin.t.s3,
          child: Column(
            children: rows
          )
        );
      }
    } else {
      content = t.testExplanationText("This test has no reusable sections.  To add on, see definitions.defineReusable1...");
    }
    return _areaContentCard(context, content);
  }

  void _buildTestReport(AFProtoBuildContext<AFTestDrawerData, AFTestDrawerRouteParam> context, List<Widget> rows) {
    final t = context.t;
    final testContext = context.s.testContext;
    final testState = context.s.testState;
    
    if(testContext == null) {
      return;
    }

    rows.add(t.buildErrorsSection(context, testState.errors));

    final headerCols = t.row();
    headerCols.add(t.testResultTableHeader(context, "Run", TextAlign.right));
    headerCols.add(t.testResultTableHeader(context, "At", TextAlign.left));
    headerCols.add(t.testResultTableHeader(context, "Pass", TextAlign.right));
    headerCols.add(t.testResultTableHeader(context, "Fail", TextAlign.right));

    final resultCols = t.row();
    resultCols.add(t.testResultTableValue(context, testContext.runNumber.toString(), TextAlign.right));
    resultCols.add(t.testResultTableValue(context, timeFormat.format(testContext.lastRun), TextAlign.left));
    resultCols.add(t.testResultTableValue(context, testState.pass.toString(), TextAlign.right));
    resultCols.add(t.testResultTableValue(context, testState.errors.length.toString(), TextAlign.right, showError: (testState.errors.isNotEmpty)));
    
    final tableRows = t.childrenTable();
    tableRows.add(TableRow(children: headerCols));
    tableRows.add(TableRow(children: resultCols));

    final columnWidths = {
      0: FixedColumnWidth(t.resultColumnWidth),
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