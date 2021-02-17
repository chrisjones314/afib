// @dart=2.9
import 'dart:async';

import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/id.dart';
import 'package:afib/src/flutter/ui/af_prototype_base.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//--------------------------------------------------------------------------------------
class AFPrototypeDrawerRouteParam extends AFRouteParam {
  static const viewTheme = 1;
  static const viewTest  = 2;
  static const viewResults = 3;
  final int view;
  final Map<String, bool> themeExpanded;

  AFPrototypeDrawerRouteParam({
    @required this.view, 
    @required this.themeExpanded
  });

  factory AFPrototypeDrawerRouteParam.createOncePerScreen(int view) {
    final themeExpanded = <String, bool>{};
    return AFPrototypeDrawerRouteParam(view: view, themeExpanded: themeExpanded);
  }

  bool isExpanded(String area) {
    final result = themeExpanded[area];
    return result ?? false;
  }

  AFPrototypeDrawerRouteParam reviseExpanded(String area, { bool expanded }) {
    final revised = Map<String, bool>.from(themeExpanded);
    revised[area] = expanded;
    return copyWith(themeExpanded: revised);
  }

  AFPrototypeDrawerRouteParam reviseView(int view) {
    return copyWith(view: view);
  }

  AFPrototypeDrawerRouteParam copyWith({
    int view,
    Map<String, bool> themeExpanded
  }) {
    return AFPrototypeDrawerRouteParam(
      view: view ?? this.view,
      themeExpanded: themeExpanded ?? this.themeExpanded
    );
  }
}

//--------------------------------------------------------------------------------------
class AFPrototypeDrawerStateView extends AFStateView3<AFScreenTestContextSimulator, AFSingleScreenTestState, AFScreenPrototype> {
  AFPrototypeDrawerStateView(AFScreenTestContextSimulator testContext, AFSingleScreenTestState testState, AFScreenPrototype test): 
    super(first: testContext, second: testState, third: test);

  AFScreenTestContextSimulator get testContext { return first; }
  AFSingleScreenTestState get testState { return second; }
  AFScreenPrototype get prototype { return third; }
}

//--------------------------------------------------------------------------------------
class AFPrototypeDrawer extends AFProtoConnectedDrawer<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> {
  static final timeFormat = DateFormat('Hms');

  //--------------------------------------------------------------------------------------
  AFPrototypeDrawer(): super(AFUIScreenID.screenTestDrawer);

  //--------------------------------------------------------------------------------------
  AFScreenID get primaryScreenId {
    return null;
  }

  //--------------------------------------------------------------------------------------
  @override
  AFPrototypeDrawerStateView createStateViewAF(AFState state, AFPrototypeDrawerRouteParam param, AFRouteParamWithChildren paramWithChildren) {
    final testState = state.testState;
    final test = AFibF.g.findScreenTestById(testState.activeTestId);
    return AFPrototypeDrawerStateView(testState.findContext(test.id), testState.findState(test.id), test);
  }

  //--------------------------------------------------------------------------------------
  AFPrototypeDrawerRouteParam createDefaultRouteParam(AFState state) {
    return AFPrototypeDrawerRouteParam.createOncePerScreen(AFPrototypeDrawerRouteParam.viewTest);
  }

  //--------------------------------------------------------------------------------------
  @override
  AFPrototypeDrawerStateView createStateView(AFAppStateArea state, AFPrototypeDrawerRouteParam param) {
    // this should never be called, because createDataAF replaces it.
    throw UnimplementedError();
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget buildWithContext(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context) {
    return _buildDrawer(context);
  }

  //--------------------------------------------------------------------------------------
  Widget _buildDrawer(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context) {
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
  Widget _buildHeader(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context) {
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
          context.s.prototype.id.toString(), 
          style: t.styleOnPrimary.bodyText2
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

  Widget _buildChoiceButton(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context,
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
  Widget _buildChoiceRow(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context) {
    final t = context.t;

    final cols = t.row();

    cols.add(_buildChoiceButton(context, "Theme", AFPrototypeDrawerRouteParam.viewTheme));
    cols.add(_buildChoiceButton(context, "Tests", AFPrototypeDrawerRouteParam.viewTest));
    cols.add(_buildChoiceButton(context, "Results", AFPrototypeDrawerRouteParam.viewResults));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: cols);
  }

  Widget _buildContent(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context) {
    var item;
    final view = context.p.view;
    if(view == AFPrototypeDrawerRouteParam.viewTheme) {
      item = _buildThemeContent(context);
    } else if(view == AFPrototypeDrawerRouteParam.viewTest) {
      item = _childTestLists(context);
    } else if(view == AFPrototypeDrawerRouteParam.viewResults) {
      item = _buildResultsContent(context);
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

  TableRow _createAttributeRow(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context, AFThemeID title, Widget Function() buildValue) {
    final t = context.t;    
    final cols = t.row();
    cols.add(t.testResultTableValue(context, title.toString(), TextAlign.right));
    cols.add(buildValue());
    return TableRow(children: cols);
  }

  Widget _buildEnumAttributeRowValue(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context, AFThemeID attr, dynamic attrValue) {
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

  void _overrideThemeValue({AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context, AFThemeID id, dynamic value}) {
      context.dispatch(AFOverrideThemeValueAction(
        id: id,
        value: value,
      ));     
      context.dispatch(AFRebuildFunctionalThemes());       
  }

  Widget _buildLocaleAttributeRowValue(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context, AFThemeID attr, dynamic attrValue) {
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

  Widget _buildThemeAreaBody(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context, String area) {
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

  Widget _buildThemeContent(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context) {
    
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

  void _onRun(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context, AFScreenTestID id) {
    final test = context.s.prototype;
    context.closeDrawer();
    Timer(Duration(seconds: 1), () async {            
      await test.onDrawerRun(context.d, context.s.testContext, context.s.testState, id, () {
        final revised = context.p.reviseView(AFPrototypeDrawerRouteParam.viewResults);
        updateRouteParam(context, revised);
        test.openTestDrawer(id);
      });
    });    
  }

  Widget _childTestList(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context,
    List<AFScreenTestDescription> tests,
    String title) {
    final t = context.t;
    final rows = t.column();
    
    for(final test in tests) {
      rows.add(ListTile(
        title: t.childText(test.id.codeId),
        subtitle: t.childText(test.description ?? ""),
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

  Widget _childTestLists(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context) {
    final t = context.t;
    final prototype = context.s.prototype;
    final rows = t.column();
    rows.add(_childTestList(context, prototype.smokeTests, "Smoke"));
    rows.add(_childTestList(context, prototype.reusableTests, "Resuable"));
    rows.add(_childTestList(context, prototype.regressionTests, "Regression"));

    //_buildTestReport(context, rows);
    final content = Column(
      children: rows
    );
    return content;
  }

  Widget _buildResultsContent(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context) {
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

  void _buildTestReport(AFProtoBuildContext<AFPrototypeDrawerStateView, AFPrototypeDrawerRouteParam> context, List<Widget> rows) {
    final t = context.t;
    final testContext = context.s.testContext;
    final testState = context.s.testState;
    
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
