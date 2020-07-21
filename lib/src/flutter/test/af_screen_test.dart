

import 'dart:async';

import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/test/af_widget_actions.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

class AFTestSectionParamsFrame {
  final Map<String, dynamic> values;

  AFTestSectionParamsFrame(this.values);
  factory AFTestSectionParamsFrame.initial() {
    return AFTestSectionParamsFrame(Map<String, dynamic>());
  }


  void setString(String key, String value) { values[key] = value; }
  void setInt(String key, int value) { values[key] = value; }
  void setObj(String key, dynamic obj) { values[key] = obj; }
  void setWidget(String key, AFWidgetID wid) { values[key] = wid; }

  String string(String key) { return values[key]; }
  int integer(String key) { return values[key]; }
  dynamic obj(String key) { return values[key]; }
  AFWidgetID widget(String key) { return values[key]; }

  AFTestSectionParamsFrame clone() {
    return AFTestSectionParamsFrame(Map<String, dynamic>.from(this.values));
  }
}

/// [AFTestSectionParams] enables you to reuse sections of test code
/// by passing in different values as parameters.
class AFTestSectionParams {
  final frames = List<AFTestSectionParamsFrame>();

  AFTestSectionParams() {
    frames.add(AFTestSectionParamsFrame.initial());
  }


  AFTestSectionParamsFrame get _current { return frames.last; }

  String string(String key) { return _current.string(key); }
  int integer(String key) { return _current.integer(key); }
  dynamic obj(String key) { return _current.obj(key); }
  AFWidgetID widget(String key) { return _current.widget(key); }

  void setString(String key, String val) { _current.setString(key, val); }
  void setInteger(String key, int val) { _current.setInt(key, val); }
  void setObj(String key, dynamic val) { _current.setObj(key, val); }
  void setWidget(String key, AFWidgetID wid) { _current.setWidget(key, wid); }

  void pushFrame() {
    frames.add(frames.last.clone());
  }

  void popFrame() {
    frames.removeLast();
  }
}

/// A superclass that declares all the methods which select specific widgets.
/// This is used by [AFScreenWidgetSelectorCollector] to determine which widgets
/// it needs to track for each test.
abstract class AFScreenTestWidgetSelector extends AFBaseTestExecute {
  
}

/// A utility class used to pass 
abstract class AFWidgetSelector {
  final elements = List<Element>();
  void add(Element elem) {
    elements.add(elem);
  }

  void clearWidgets() {
    elements.clear();
  }

  bool matchesPath(List<Element> elem) {
    // by default, just match the leaf, but allow for more complicated
    // paths
    return matches(elem.last);
  }

  bool matches(Element elem);
}

class AFKeySelector extends AFWidgetSelector {
  Key key;
  AFKeySelector(String keyStr) {
    key = Key(keyStr);
  }

  bool matches(Element elem) {
    return elem.widget.key == key;
  }

  bool operator==(dynamic o) {
    return o is AFKeySelector && o.key == key;
  }
}

class AFSparsePathWidgetSelector extends AFWidgetSelector {
  final pathSelectors = List<AFWidgetSelector>();

  bool matchesPath(List<Element> path) {
    int curSel = 0;
    for(final item in path) {
      final selector = pathSelectors[curSel];
      if(selector.matches(item)) {
        curSel++;
        if(curSel >= pathSelectors.length) {
          break;
        }
      }
    }

    // this will be true only if we matched all the selectors somewhere along the path,
    // and the last element in the path matched the final selector.
    return curSel == path.length - 1;
  }

  bool matches(Element elem) {
    throw AFException("Do not attempt to add sparse path widget selectors recursively into each other.");
  }

  bool operator==(dynamic o) {
    if(o is AFSparsePathWidgetSelector) {
      if(o.pathSelectors.length != pathSelectors.length) {
        return false;
      }

      for(int i = 0; i < pathSelectors.length; i++) {
        final l = pathSelectors[i];
        final r = o.pathSelectors[i];
        if(l != r) {
          return false;
        }
      }

      return true;
    }
    return false;
  }
}



abstract class AFScreenTestExecute extends AFScreenTestWidgetSelector {
  AFScreenPrototypeTest test;
  AFScreenTestExecute(this.test);

  @override
  AFTestID get testID => test.id;

  void expectOneWidget(dynamic selector) {
    expectNWidgets(selector, 1, extraFrames: 1);
  }
  
  void expectMissingWidget(dynamic selector) {
    expectNWidgets(selector, 0, extraFrames: 1);
  }

  void expectNWidgets(dynamic selector, int n, {int extraFrames = 0});
  void expectText(dynamic selector, String text);
  void expectChipSelected(dynamic selector, bool sel);

  Future<void> enterText(dynamic selector, String text);
  Future<void> tap(dynamic selector);
  Future<void> tapWithExpectedAction(dynamic selector, AFActionWithKey specifier, Function(AFActionWithKey) checkQuery);
  Future<void> tapWithExpectedParam(dynamic selector, Function(AFRouteParam) checkParam);
  Future<void> tapWithActionType(dynamic selector, AFActionWithKey action);
  Future<void> keepSynchronous();
  Future<void> updateScreenData(dynamic data);

  void expectAction(AFActionWithKey specifier, Function(AFActionWithKey) checkAction, {int extraFrames = 0});

  Future<void> executeNamedSection(AFTestSectionID id, AFTestSectionParams params) {
    return this.test.body.executeNamedSection(id, this, params);
  }

  Future<void> pauseForRender(int previousCount);
  void addError(String error, int depth);
}

typedef Future<void> AFScreenTestBodyExecuteFunc(AFScreenTestExecute exec, AFTestSectionParams params);

class AFScreenTestBody {
  final AFScreenTestGroup group;
  final sections = List<dynamic>();

  AFScreenTestBody(this.group);

  bool get isNotEmpty { 
    return sections.isNotEmpty;
  }

  void execute(AFScreenTestBodyExecuteFunc func, {AFTestSectionID id}) {
    sections.add(func);
    if(id != null) {
      group.testMgr.addNamedTestSection(id, func);
    }
  }

  void _checkFutureExists(Future<void> test) {
    if(test == null) {
      throw AFException("Test section failed to return a future.  Make sure all test sections end with return AFScreenTestExecute.keepSynchronous()");
    }
  }

  Future<void> executeNamedSection(AFTestSectionID id, AFScreenTestExecute e, AFTestSectionParams params) async {
    final section = group.testMgr.findNamedTestSection(id);
    if(section == null) {
      throw new AFException("Attempt to executing undefined test section $id");
    }
    params.pushFrame();
    Future<void> fut = section(e, params);
    _checkFutureExists(fut);
    await fut;
    params.popFrame();
    return e.keepSynchronous();
  }


  Future<void> run(AFScreenTestContext context, AFTestSectionParams params, { Function onEnd }) async {
    int sectionGuard = 0;
    for(int i = 0; i < sections.length; i++) {
      final section = sections[i];
      sectionGuard++;
      if(sectionGuard > 1) {
        throw AFException("Test section $i is missing an await!");
      }
      // first, we run the section with the widget specifier collector so we know what kind of widgets we
      // are looking for.
      final fut0 = section(context.elementCollector, params);
      await fut0;

      final fut = section(context, params);
      _checkFutureExists(fut);
      await fut;
      sectionGuard--;
    }
    if(onEnd != null) {
      onEnd();
    }
  }

}

/// This class is used to determine which widget selectors a tests uses to reference
/// widgets, and then to collect those widgets on the screen so that they can be referenced
/// during the test.
class AFScreenTestWidgetCollector extends AFScreenTestExecute {

  AFScreenTestWidgetCollector(AFScreenPrototypeTest test): super(test);

  final selectors = List<AFWidgetSelector>();
  int previousUpdateCount;

  void _updateCache() {
    _refresh(AFibF.testOnlyScreenElement, AFibF.testOnlyScreenUpdateCount);
  }

  List<Element> findWidgetsFor(dynamic selector) {
    _updateCache();
    final sel = _convertSelector(selector);
    for(final test in selectors) {
      if(test == sel) {
        return test.elements;
      }
    }
    return List<Element>();
  }
  
  void expectNWidgets(dynamic selector, int n, {int extraFrames = 0}) {
    _addSelector(selector);
    return null;
  }

  void expectText(dynamic selector, String text) {
    _addSelector(selector);
    return null;
  }


  void expectChipSelected(dynamic selector, bool sel) {
    _addSelector(selector);
    return null;
  }

  Future<void> enterText(dynamic selector, String text) {
    _addSelector(selector);
    return null;
  }

  Future<void> tap(dynamic selector) {
    _addSelector(selector);
    return null;
  }

  Future<void> tapWithExpectedAction(dynamic selector, AFActionWithKey specifier, Function(AFActionWithKey) checkQuery) async {
    _addSelector(selector);
    return null;
  }

  Future<void> tapWithExpectedParam(dynamic selector, Function(AFRouteParam) checkParam) async {
    _addSelector(selector);
    return null;
  }

  Future<void> tapWithActionType(dynamic selector, AFActionWithKey action) {
    _addSelector(selector);
    return null;
  }

  void expectAction(AFActionWithKey specifier, Function(AFActionWithKey) checkAction, { int extraFrames = 0 }) {

  }

  Future<void> pauseForRender(int previousCount) {
    return keepSynchronous();
  }

  Future<void> keepSynchronous() {
    return null;
  }

  Future<void> updateScreenData(dynamic data) {
    return null;
  }

  AFWidgetSelector _convertSelector(dynamic sel) {
    if(sel is String) {
      return AFKeySelector(sel);
    } else if(sel is AFWidgetID) {
      return AFKeySelector(sel.code);
    } else if(sel is AFWidgetSelector) {
      return sel;
    } else {
      throw AFException("Unknown widget selector type: ${sel.runtimeType}");
    }
  }

  void _addSelector(dynamic sel) {
    selectors.add(_convertSelector(sel));
  }

  /// Rebuild our internal cache of paths to elements with keys.
  void _refresh(Element currentRoot, int currentUpdateCount) {
    // nothing to do if the current root hasn't changed.
    if(currentUpdateCount == previousUpdateCount) {
      return;
    }

    _clearAll();

    final currentPath = List<Element>();
    _populateChildren(currentRoot, currentPath);
  }

  // Go though all the children of [current], having the parent path [currentPath],
  // and add path entries for any widgets with keys.
  void _populateChildren(Element currentElem, List<Element> currentPath) {

    // add the current element.
    currentPath.add(currentElem);

    // go through all the selectors, and see if any of them match.
    for(final selector in selectors) {
      if(selector.matchesPath(currentPath)) {
        selector.add(currentPath.last);
      }
    } 

    // do this same process recursively on the childrne.
    currentElem.visitChildren((child) {
      _populateChildren(child, currentPath);
    });

    // maintain the path as we go back up.
    currentPath.removeLast();
  }

  void _clearAll() {
    for(final sel in selectors) {
      sel.clearWidgets();
    }
  }

}


abstract class AFScreenTestContext extends AFScreenTestExecute {
  AFScreenTestWidgetCollector elementCollector;
  final recentActions = Map<String, AFActionWithKey>();
  final AFDispatcher dispatcher;
  AFScreenTestContext(this.dispatcher, AFScreenPrototypeTest test): super(test) {
    elementCollector = AFScreenTestWidgetCollector(test);
  }
  AFTestID get testID { return this.test.id; }

  void expectNWidgets(dynamic selector, int n, {int extraFrames = 0}) {
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    this.expect(elems.length, ft.equals(n), extraFrames: extraFrames+1);
  }

  void expectText(dynamic selector, String text) {
    AFScreenTests testManager = _testManager;
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    if(elems.length != 1) {
      throw AFException("Expected to enter text for exactly one widget for selector $selector, found ${elems.length} widgets");
    }
    Element elem = elems.first;
    final widget = elem.widget;
    final extract = testManager.findExtractor(widget);
    if(extract == null) {
      throw AFException("No AFExtractTextWidgetAction found for ${elem.widget.runtimeType}, you can register one using AFScreenTests.registerExtractText");
    }
    final actualText = extract.extract(elem, widget);
    this.expect(actualText, ft.equals(text), extraFrames: 1);      
  }


  void expectChipSelected(dynamic selector, bool sel) {
    AFScreenTests testManager = _testManager;
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    if(elems.isEmpty) {
      this.expect(elems, ft.isNotEmpty, extraFrames: 1);
      return;
    }

    for(final elem in elems) {
      final widget = elem.widget;
      final selectable = testManager.findExtractor(widget);
      if(selectable == null) {
        throw AFException("No AFSelectedWidgetTest found for ${elem.widget.runtimeType}, you can register one using AFScreenTests.registerSelectable");
      }
      this.expect(selectable.extract(elem, widget), ft.equals(sel), extraFrames: 1);
    }
  }

  Future<void> enterText(dynamic selector, String text) {
    final previous = AFibF.testOnlyScreenUpdateCount;
    AFScreenTests testManager = _testManager;
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    if(elems.length != 1) {
      throw AFException("Expected to enter text for exactly one widget for selector $selector, found ${elems.length} widgets");
    }
    Element elem = elems.first;
    final widget = elem.widget;
    final apply = testManager.findApplicator(widget);
    if(apply == null) {
      throw AFException("No AFApplyTextWidgetAction found for ${elem.widget.runtimeType}, you can register one using AFScreenTests.registerApplyText");
    }
    apply.apply(widget, text);
    return pauseForRender(previous);

  }

  Future<void> tap(dynamic selector) {
    final previous = AFibF.testOnlyScreenUpdateCount;
    AFScreenTests testManager = _testManager;
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    if(elems.length != 1) {
      throw AFException("Expected a tap on exactly one widget for selector $selector, found ${elems.length} widgets");
    }
    Element elem = elems.first;
    final tapable = testManager.findApplicator(elem.widget);
    if(tapable == null) {
      throw AFException("No AFTapableWidgetAction found for ${elem.widget.runtimeType}, you can register one using AFScreenTests.registerTapable");
    }
    tapable.apply(elem.widget, null);    
    return pauseForRender(previous);
  }

  Future<void> tapWithExpectedAction(dynamic widgetSpecifier, AFActionWithKey actionSpecifier, Function(AFActionWithKey) checkQuery) async {
    final previous = AFibF.testOnlyScreenUpdateCount;
    await tap(widgetSpecifier);
    expectAction(actionSpecifier, checkQuery, extraFrames: 1);    
    return pauseForRender(previous);
  }

  Future<void> tapWithExpectedParam(dynamic specifier, Function(AFRouteParam) checkParam) async {
    final previous = AFibF.testOnlyScreenUpdateCount;
    await tap(specifier);
    expectAction(AFNavigateSetParamAction(), (dynamic action) {
      AFNavigateSetParamAction paramAction = action;
      checkParam(paramAction.param);
    }, extraFrames: 1);    
    
    return pauseForRender(previous);
  }

  Future<void> keepSynchronous() {
    return null;
  }

  Future<void> tapWithActionType(dynamic specifier, AFActionWithKey action) async {
    final previous = AFibF.testOnlyScreenUpdateCount;
    await tap(specifier);
    expectAction(action, (AFActionWithKey action) {

    }, extraFrames: 1);
    return pauseForRender(previous);
  }

  TExpected expectType<TExpected>(dynamic obj) {
    if(obj is TExpected) {
      return obj;
    }
    addError("Unexpected type ${obj.runtimeType}", 2);
    return null;
  }

  void registerAction(AFActionWithKey action) {
    final key = action.key;
    recentActions[key] = action;
  }

  void testText(Widget widget, String expect) {
    if(widget is Text) {
      this.expect(widget.data, ft.equals(expect));
    } else if(widget is TextField) {
      if(widget.controller != null) {
        this.expect(widget.controller.value.text, ft.equals(expect));
      } 
    } 

  }

  void testChipSelected(Widget widget, bool expect) {
    bool selected = false;
    if(widget is ChoiceChip) {
      selected = widget.selected;
    } else if(widget is InputChip) {
      selected = widget.selected;
    } else if(widget is FilterChip) {
      selected = widget.selected;
    }
    this.expect(selected, ft.equals(expect), extraFrames: 4);
  }

  @override
  void expectAction(AFActionWithKey specifier, Function(AFActionWithKey) checkAction, { int extraFrames = 0 }) {
    final key = specifier.key;
    final found = recentActions[key];
    this.expect(found, ft.isNotNull, extraFrames: extraFrames+1);
    if(found == null) {
      return;
    }
    
    checkAction(found);
  }

  AFScreenTests get _testManager {
    return test.body.group.testMgr;
  }

  
  @override
  Future<void> updateScreenData(dynamic data) {
    final previous = AFibF.testOnlyScreenUpdateCount;
    dispatcher.dispatch(AFUpdatePrototypeScreenTestDataAction(this.test.id, data));
    return pauseForRender(previous);
  }

  @override
  Future<void> pauseForRender(int previousCount) async {

    /// wait for the screen element to be rebuilt.
    AFibD.logInternal?.fine("Starting _pauseForRender with $previousCount");
    var current = AFibF.testOnlyScreenUpdateCount;
    int n = 0;
    while(current == previousCount) {
      AFibD.logInternal?.fine("Starting pause");
      await Future<void>.delayed(Duration(milliseconds: 100), () {});
      current = AFibF.testOnlyScreenUpdateCount;
      AFibD.logInternal?.fine("Starting finished pause with update count $current");
      n++;
      if(n > 10) {
        throw new AFException("Timeout waiting for screen update.  You may need to pass noUpdate: true into one of the test manipulators if it does not produce an update.");
      }
    }
    AFibD.logInternal?.fine("Exiting _pauseForRender with count $current");
  }

}

class AFScreenTestContextSimulator extends AFScreenTestContext {
  final int runNumber;
  final DateTime lastRun = DateTime.now();

  AFScreenTestContextSimulator(AFDispatcher dispatcher, AFScreenPrototypeTest test, this.runNumber): super(dispatcher, test);

  @override
  Future<void> keepSynchronous() {
    return Future<void>.delayed(Duration(milliseconds: 0), () {});
  }

  void addError(String desc, int depth) {
    String err = AFBaseTestExecute.composeError(desc, depth);
    dispatcher.dispatch(AFPrototypeScreenTestAddError(this.test.id, err));
    AFibD.debug(err);
  }

  bool addPassIf(bool test) {
    if(test) {
      dispatcher.dispatch(AFPrototypeScreenTestIncrementPassCount(this.test.id));
    }
    return test;
  }
}

class AFScreenTestContextWidgetTester extends AFScreenTestContext {
  final ft.WidgetTester tester;
  final AFApp app;

  AFScreenTestContextWidgetTester(this.tester, this.app, AFDispatcher dispatcher, AFScreenPrototypeTest test): super(dispatcher, test);

  @override
  Future<void> pauseForRender(int previousCount) async {
    await tester.pumpAndSettle(Duration(seconds: 1));
    return super.pauseForRender(previousCount);
  }

  Future<void> keepSynchronous() {
    return null;
  }
}

/// All the information necessary to render a single screen for
/// prototyping.
/// 
/// Each prototype can also have an optional test sequence associated
/// with it.
class AFScreenPrototypeTest {
  AFTestID id;
  dynamic data;
  dynamic param;
  String subtitle;
  AFScreenTestBody body;
  AFConnectedScreenWithoutRoute widget;

  AFScreenPrototypeTest({
    @required this.id,
    @required this.data,
    @required this.param,
    @required this.widget,
    @required this.body,
    this.subtitle
  });

  bool get hasBody {
    return body.isNotEmpty;
  }

  void run(AFScreenTestContext context, { Function onEnd}) {
    final params = AFTestSectionParams();
    body.run(context, params, onEnd: onEnd);
  }
}

/// All the screen tests/prototypes associated with a single screen.
class AFScreenTestGroup {
  final AFScreenTests testMgr;
  AFBuildableWidget widget;
  List<AFScreenPrototypeTest> tests = List<AFScreenPrototypeTest>();

  AFScreenTestGroup({
    @required this.testMgr, 
    @required this.widget,
  });

  /// Add a prototype of a particular screen with the specified [data]
  /// and [param].  
  /// 
  /// Returns an [AFScreenTestBody], which can be used to create a 
  /// test for the screen.
  AFScreenTestBody addSimplePrototype({
    @required AFTestID   id,
    @required dynamic data,
    @required dynamic param,
    String subtitle
  }) {
    AFScreenPrototypeTest instance = AFScreenPrototypeTest(
      id: id,
      data: data,
      param: param,
      widget: widget,
      subtitle: subtitle,
      body: AFScreenTestBody(this)
    );
    tests.add(instance);
    return instance.body;
  }
}

/// This class is used to create canned versions of screens and widget populated
/// with specific data for testing and prototyping purposes.
class AFScreenTests<TState> {
  
  final namedSections = Map<AFTestSectionID, AFScreenTestBodyExecuteFunc>();
  List<AFScreenTestGroup> groups = List<AFScreenTestGroup>();
  final extractors = Map<Type, AFExtractWidgetAction>();
  final applicators = Map<Type, AFApplyWidgetAction>();

  AFScreenTests() {
    registerApplicator(AFTapFlatButton());
    registerApplicator(AFToggleChoiceChip());
    registerApplicator(AFApplyTextTextFieldAction());
    registerApplicator(AFApplyTextAFTextFieldAction());

    registerExtractor(AFSelectableChoiceChip());
    registerExtractor(AFExtractTextTextAction());
    registerExtractor(AFExtractTextTextFieldAction());
    registerExtractor(AFExtractTextAFTextFieldAction());
  }

  /// Register a way to tap on a particular kind of widget.
  /// 
  /// The intent is to allow the testing framework to be extended for
  /// arbitrary widgets that might get tapped.
  void registerApplicator(AFApplyWidgetAction apply) {
    applicators[apply.appliesToType] = apply;
  }

  void registerExtractor(AFExtractWidgetAction extract) {
    extractors[extract.appliesTo] = extract;
  }


  AFExtractWidgetAction findExtractor(Widget widget) {
    return extractors[widget.runtimeType];
  }

  AFApplyWidgetAction findApplicator(Widget widget) {
    return applicators[widget.runtimeType];
  }

  /// Add a screen widget, and then in the [addInstances] callback add one or more 
  /// data states to render with that screen.
  void addScreen(AFBuildableWidget widget, Function(AFScreenTestGroup) addInstances) {
    AFScreenTestGroup group = AFScreenTestGroup(testMgr: this, widget: widget);
    addInstances(group);
    groups.add(group);
  }

  AFScreenPrototypeTest findById(AFTestID id) {
    for(var tests in groups) {
      for(var test in tests.tests) {
        if(test.id == id) {
          return test;
        }
      }
    }
    return null;
  }
  
  List<AFScreenTestGroup> get all { return groups; }

  void addNamedTestSection(AFTestSectionID id, AFScreenTestBodyExecuteFunc func) {
    if(namedSections.containsKey(id)) {
      throw new AFException("Attempt to register duplicate test section $id");
    }
    namedSections[id] = func;
  }

  AFScreenTestBodyExecuteFunc findNamedTestSection(AFTestSectionID id) {    
    return namedSections[id];
  }

  void registerData(dynamic id, dynamic data) {
    AFibF.testData.registerData(id, data);
  }

  dynamic findData(dynamic id) {
    return AFibF.testData.findData(id);
  }

  bool addPassIf(bool test) {
    if(test) {
      
    }
    return test;
  }

}