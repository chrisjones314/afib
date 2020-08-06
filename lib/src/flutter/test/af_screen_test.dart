

import 'dart:async';

import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/core/afui.dart';
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


class AFWidgetTypeSelector extends AFWidgetSelector {
  Type widgetType;
  AFWidgetTypeSelector(this.widgetType);

  bool matches(Element elem) {
    return elem.widget.runtimeType == widgetType;
  }

  bool operator==(dynamic o) {
    return o is AFWidgetTypeSelector && o.widgetType == widgetType;
  }
}


class AFMultipleWidgetSelector extends AFWidgetSelector {
  final selectors = List<AFWidgetSelector>();
  AFMultipleWidgetSelector(List sel) {
    for(final item in sel) {
      selectors.add(AFScreenTestWidgetCollector.createSelector(null, item));
    }
  }

  bool matches(Element elem) {
    for(final sel in selectors) {
      if(sel.matches(elem)) {
        return true;
      }
    }
    return false;
  }

  bool operator==(dynamic o) {
    if(!(o is AFMultipleWidgetSelector)) {
      return false;
    }

    if(o.selectors.length != selectors.length) {
      return false;
    }

    for(int i = 0; i < selectors.length; i++) {
      final l = selectors[i];
      final r = o.selectors[i];
      if(l != r) {
        return false;
      }
    }
    return true;
  }
}

class AFRichTextGestureTapSpecifier extends AFWidgetSelector {
  final AFWidgetSelector selector;
  final String containsText;


  AFRichTextGestureTapSpecifier(this.selector, this.containsText);

  factory AFRichTextGestureTapSpecifier.create(dynamic selector, String containsText) {
    final sel = AFScreenTestWidgetCollector.createSelector(null, selector);
    return AFRichTextGestureTapSpecifier(sel, containsText);
  }

  bool matches(Element elem) {
    return selector.matches(elem);
  }

  bool operator==(dynamic o) {
    if(!(o is AFRichTextGestureTapSpecifier)) {
      return false;
    }

    if(o.selector != selector) {
      return false;
    }

    if(o.containsText != containsText) {
      return false;
    }
    return true;
  }
}


class AFSparsePathWidgetSelector extends AFWidgetSelector {
  final  List<AFWidgetSelector> pathSelectors;

  AFSparsePathWidgetSelector(this.pathSelectors);

  factory AFSparsePathWidgetSelector.createEmpty() {
    return AFSparsePathWidgetSelector(List<AFWidgetSelector>());
  }
  
  bool matchesPath(List<Element> path) {
    // first, make sure the final path element matches, we don't want 
    // extra stuff below the last selector.
    final lastSelector = pathSelectors.last;
    final lastPath = path.last;
    
    const testKey = Key("edit_dish_number");
    if(path.where((testElem) {
      return (testElem.widget.key == testKey);
    }).isNotEmpty) {
      int i = 0;
      i++;
    }

    if(!lastSelector.matches(lastPath)) {
      return false;
    }

    // if the last matches, then go up the path making sure that we can
    // find all the other path selectors.
    int curPath = path.length - 2;
    int curSel = pathSelectors.length - 2;
    while(curSel >= 0 && curPath >= 0) {
      final sel   = pathSelectors[curSel];
      final item  = path[curPath];
      if(sel.matches(item)) {
        if(curSel == 0) {
          return true;
        }
        curSel--;
      }
      curPath--;
    }

    return false;
  }

  AFSparsePathWidgetSelector copyAndAdd(AFWidgetSelector selector) {
    final revised = List<AFWidgetSelector>.of(pathSelectors);
    revised.add(selector);
    return AFSparsePathWidgetSelector(revised);
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
  final underPaths = List<AFSparsePathWidgetSelector>();
  Type popupScreenType;
  
  AFScreenTestExecute(this.test);

  Type get activeScreenType {
    if(popupScreenType != null) {
      return popupScreenType;
    }
    return test.screen.runtimeType;
  }


  @override
  AFTestID get testID => test.id;
  AFSparsePathWidgetSelector get activeSelectorPath {
    if(underPaths.isEmpty) {
      return null;
    }
    return underPaths.last;
  }


  void expectOneWidget(dynamic selector) {
    expectNWidgets(selector, 1, extraFrames: 1);
  }  

  void expectMissingWidget(dynamic selector) {
    expectNWidgets(selector, 0, extraFrames: 1);
  }

  /// Any operations applied within the [underHere] callback operate on 
  /// widgets which are nested under [selector].
  /// 
  /// In addition to passing a standard [selector], like a AFWidgetID, you can also
  /// pass in a list of selectors.  If you do so, then the operation takes place
  /// under a sparse-path containing all the items in the list.
  Future<void> underWidget(dynamic selector, Future<void> Function() underHere);
  void expectNWidgets(dynamic selector, int n, {int extraFrames = 0});
  void expectText(dynamic selector, String text) {
    expectWidgetValue(selector, ft.equals(text), extraFrames: 1);
  }



  /// Used to tap on an element that opens a popup of [popupScreenType].
  /// 
  /// You can operate on the controls in the popup from within [underHere]
  Future<void> tapWithPopup(dynamic selectorTap, final Type popupScreenType, Future<void> Function() underHere) async {
    int popupRenderCount = AFibF.testOnlyScreenUpdateCount(popupScreenType);
    await tap(selectorTap, expectRender: false);
    this.setPopupScreenType(popupScreenType);
    await pauseForRender(popupRenderCount, true);
    await underHere();
    this.setPopupScreenType(null);
    return null;
  }

  /// Used to tap on a control that closes a popup.
  /// 
  /// The standard tap waits for the popup to re-render, which
  /// it may not do.  This function does the tap but does not
  /// wait for a render.
  Future<void> tapClosePopup(dynamic selector) async {
    return tap(selector, expectRender: false);
  }

  void setPopupScreenType(final Type popupScreenType) {
    this.popupScreenType = popupScreenType;
  }

  /// Expect that a [Chip] is selected or not selected.
  /// 
  /// Note that in addition to the standard options, 
  /// the [selector] can be a list of other selectors.  With chips,
  /// it is very common to verify that several of them are on or off
  /// at the same time, and passing in a list is a concise way to do
  /// so.
  void expectChipSelected(dynamic selector, bool sel) {
    expectWidgetValue(selector, ft.equals(sel), extraFrames: 1);
  }

  void expectWidget(dynamic selector, Function(Element elem) onFound, { int extraFrames = 0 });
  void expectWidgets(dynamic selector, Function(List<Element>) onFound, { int extraFrames = 0 });

  void expectWidgetValue(dynamic selector, ft.Matcher matcher, { int extraFrames = 0 });

  /// Verifies that [element] has the expected [key], which can be
  /// either a [String] or an [AFWidgetID].
  void expectKey(Element element, dynamic key, { int extraFrames = 0 }) {
    var keyVal;
    if(key is AFWidgetID) {
      keyVal = key.code;
    } else if(key is String) {
      keyVal = key;
    } else {
      throw AFException("Unknown key type ${key.runtimeType}");
    }
    this.expect(element.widget.key, ft.equals(Key(keyVal)), extraFrames: extraFrames+1);
  }

  void expectKeys(List<Element> elements, List<dynamic> keys) {
    this.expect(elements.length, ft.equals(keys.length), extraFrames: 1);
    if(elements.length != keys.length) {
      return;
    }    

    for(int i = 0; i < elements.length; i++) {
      final elem = elements[i];
      final source = keys[i];
      this.expectKey(elem, source, extraFrames: 1);
    }
  }
  
  Future<void> applyWidgetValue(dynamic selector, dynamic value, String applyType, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 });
  Future<void> applyWidgetValueWithExpectedAction(dynamic selector, dynamic value, String applyType, AFActionWithKey actionSpecifier, Function(AFActionWithKey) checkAction, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 });
  Future<void> applyWidgetValueWithExpectedParam(dynamic selector, dynamic value, String applyType, Function(AFRouteParam) checkParam, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 });

  Future<void> enterText(dynamic selector, String text) {
    return applyWidgetValue(selector, text, AFApplyWidgetAction.applySetValue);
  }

  Future<void> tap(dynamic selector, { bool expectRender = true }) {
    return applyWidgetValue(selector, null, AFApplyWidgetAction.applyTap, expectRender: expectRender);
  }

  Future<void> tapWithExpectedAction(dynamic widgetSpecifier, AFActionWithKey actionSpecifier, Function(AFActionWithKey) checkQuery, { bool expectRender = true }) {
    return applyWidgetValueWithExpectedAction(widgetSpecifier, null, AFApplyWidgetAction.applyTap, actionSpecifier, checkQuery, extraFrames: 1, expectRender: expectRender);
  }

  Future<void> tapWithExpectedParam(dynamic specifier, Function(AFRouteParam) checkParam, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) {
    return applyWidgetValueWithExpectedParam(specifier, null, AFApplyWidgetAction.applyTap, checkParam, expectRender: expectRender, extraFrames: extraFrames, maxWidgets: maxWidgets);
  }

  Future<void> tapWithNavigatePop(dynamic specifier) {
    return tapWithActionType(specifier, AFNavigatePopAction());
  }

  Future<void> tapWithActionType(dynamic specifier, AFActionWithKey action, { bool expectRender = true }) {
    return applyWidgetValueWithExpectedAction(specifier, null, AFApplyWidgetAction.applyTap, action, (AFActionWithKey key) {}, expectRender: expectRender);
  }

  Future<void> keepSynchronous();
  Future<void> updateScreenData(dynamic data);

  void expectAction(AFActionWithKey specifier, Function(AFActionWithKey) checkAction, {int extraFrames = 0});

  Future<void> executeNamedSection(AFTestSectionID id, AFTestSectionParams params) {
    return this.test.body.executeNamedSection(id, this, params);
  }

  Future<void> pauseForRender(int previousCount, bool expectRender);
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

class AFScreenTestWidgetCollectorScreen {
  int previousUpdateCount;
  final Type screenType;
  final selectors = List<AFWidgetSelector>();

  AFScreenTestWidgetCollectorScreen(this.screenType, this.previousUpdateCount);

  void addSelector(AFWidgetSelector sel) {
    selectors.add(sel);
  }

  void clearAll() {
    for(final sel in selectors) {
      sel.clearWidgets();
    }
  }

  void resetForUpdate(int updateCount) {
    clearAll();
    previousUpdateCount = updateCount;
  }
}

/// This class is used to determine which widget selectors a tests uses to reference
/// widgets, and then to collect those widgets on the screen so that they can be referenced
/// during the test.
class AFScreenTestWidgetCollector extends AFScreenTestExecute {

  AFScreenTestWidgetCollector(AFScreenPrototypeTest test): super(test);

  final screens = Map<Type, AFScreenTestWidgetCollectorScreen>();

  AFScreenTestWidgetCollectorScreen _updateCache() {
    final info = AFibF.findTestScreen(activeScreenType);
    return _refresh(info);
  }

  List<Element> findWidgetsFor(dynamic selector) {
    final screenInfo = _updateCache();
    final sel = createSelector(activeSelectorPath, selector);
    for(final test in screenInfo.selectors) {
      if(test == sel) {
        return test.elements;
      }
    }
    return List<Element>();
  }

  ///
  Future<void> underWidget(dynamic selector, Future<void> Function() withinHere) async {
    var path = activeSelectorPath;
    if(path == null) {
      path = AFSparsePathWidgetSelector.createEmpty();
    }
    var next = path;
    if(selector is List) {
      for(final sel in selector) {
          next =  AFScreenTestWidgetCollector.createSelector(next, sel);
      }
    } else {
      next = AFScreenTestWidgetCollector.createSelector(next, selector);
    }
    underPaths.add(next);
    await withinHere();
    underPaths.removeLast();
    return null;
  }

  void expectWidget(dynamic selector, Function(Element) onFound, { int extraFrames = 0 }) {
    _addSelector(selector);
  }

  void expectWidgets(dynamic selector, Function(List<Element>) onFound, { int extraFrames = 0 }) {
    _addSelector(selector);
  }

  
  void expectNWidgets(dynamic selector, int n, {int extraFrames = 0}) {
    _addSelector(selector);
  }

  void expectWidgetValue(dynamic selector, ft.Matcher matcher, { int extraFrames = 0 }) {
    _addSelector(selector);
  }

  Future<void> applyWidgetValue(dynamic selector, dynamic value, String applyType, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) {
    _addSelector(selector);
    return null;
  }
  
  Future<void> applyWidgetValueWithExpectedAction(dynamic selector, dynamic value, String applyType, AFActionWithKey actionSpecifier, Function(AFActionWithKey) checkAction, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) {
    _addSelector(selector);
    return null;
  }
  
  Future<void> applyWidgetValueWithExpectedParam(dynamic selector, dynamic value, String applyType, Function(AFRouteParam) checkParam, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) {
    _addSelector(selector);
    return null;
  }


  void expectAction(AFActionWithKey specifier, Function(AFActionWithKey) checkAction, { int extraFrames = 0 }) {

  }

  Future<void> pauseForRender(int previousCount, bool expectRender) {
    return keepSynchronous();
  }

  Future<void> keepSynchronous() {
    return null;
  }

  Future<void> updateScreenData(dynamic data) {
    return null;
  }

  static AFWidgetSelector createSelector(AFSparsePathWidgetSelector path, dynamic sel) {
    AFWidgetSelector selector;
    if(sel is String) {
      selector = AFKeySelector(sel);
    } else if(sel is AFWidgetID) {
      selector = AFKeySelector(sel.code);
    } else if(sel is AFWidgetSelector) {
      selector = sel;
    } else if(sel is Type) {
      selector = AFWidgetTypeSelector(sel);
    } else {
      throw AFException("Unknown widget selector type: ${sel.runtimeType}");
    }

    if(path != null) {
      selector = path.copyAndAdd(selector);
    }
    return selector;
  }

  void _addSelector(dynamic sel) {
    final activePath = activeSelectorPath;
    final screenInfo = _findOrCreateScreenInfo(activeScreenType);
    screenInfo.addSelector(createSelector(activePath, sel));
  }

  /// Rebuild our internal cache of paths to elements with keys.
  AFScreenTestWidgetCollectorScreen _refresh(AFibTestOnlyScreenElement currentInfo) {
    final screenInfo = _findOrCreateScreenInfo(currentInfo.screenType);
    
    // nothing to do if the current root hasn't changed.
    if(currentInfo.updateCount == screenInfo.previousUpdateCount) {
      return screenInfo;
    }

    screenInfo.resetForUpdate(currentInfo.updateCount);

    final currentPath = List<Element>();
    _populateChildren(screenInfo, currentInfo.element, currentPath);
    return screenInfo;
  }

  AFScreenTestWidgetCollectorScreen _findOrCreateScreenInfo(Type screenType) {
    AFScreenTestWidgetCollectorScreen screenInfo = screens[screenType];
    if(screenInfo == null) {
      screenInfo = AFScreenTestWidgetCollectorScreen(screenType, -1);
      screens[screenType] = screenInfo;
    }
    return screenInfo;
  }

  // Go though all the children of [current], having the parent path [currentPath],
  // and add path entries for any widgets with keys.
  void _populateChildren(AFScreenTestWidgetCollectorScreen screenInfo, Element currentElem, List<Element> currentPath) {

    // add the current element.
    currentPath.add(currentElem);

    // go through all the selectors, and see if any of them match.
    for(final selector in screenInfo.selectors) {
      if(selector.matchesPath(currentPath)) {
        selector.add(currentPath.last);
      }
    } 

    // do this same process recursively on the childrne.
    currentElem.visitChildren((child) {
      _populateChildren(screenInfo, child, currentPath);
    });

    // maintain the path as we go back up.
    currentPath.removeLast();
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

  Future<void> underWidget(dynamic selector, void Function() withinHere) async {
    await elementCollector.underWidget(selector, withinHere);
    return null;
  }

  void expectWidget(dynamic selector, Function(Element elem) onFound, { int extraFrames = 0 }) {
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    this.expect(elems.length, ft.equals(1), extraFrames: extraFrames+1);
    if(elems.length > 0) {
      onFound(elems.first);
    }
  }

  void expectWidgets(dynamic selector, Function(List<Element>) onFound, { int extraFrames = 0 }) {
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    onFound(elems);
  }


  void setPopupScreenType(final Type popupScreenType) {
    super.setPopupScreenType(popupScreenType);
    elementCollector.setPopupScreenType(popupScreenType);
  }

  void expectNWidgets(dynamic selector, int n, {int extraFrames = 0}) {
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    this.expect(elems.length, ft.equals(n), extraFrames: extraFrames+1);
  }

  void expectWidgetValue(dynamic selectorDyn, ft.Matcher matcher, { String extractType = AFExtractWidgetAction.extractPrimary, int extraFrames = 0 }) {
    AFScreenTests testManager = _testManager;
    final selector = AFScreenTestWidgetCollector.createSelector(null, selectorDyn);
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    if(elems.isEmpty) {
      this.expect(elems, ft.isNotEmpty, extraFrames: extraFrames+1);
      return;
    }

    for(final elem in elems) {
      final selectable = testManager.findExtractor(extractType, elem);
      if(selectable == null) {
        throw AFException("No AFSelectedWidgetTest found for ${elem.widget.runtimeType}, you can register one using AFScreenTests.registerSelectable");
      }
      this.expect(selectable.extract(extractType, selector, elem), matcher, extraFrames: extraFrames+1);
    }
  }

  Future<void> applyWidgetValue(dynamic selectorDyn, dynamic value, String applyType, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) {
    final previous = AFibF.testOnlyScreenUpdateCount(activeScreenType);
    AFScreenTests testManager = _testManager;
    final selector = AFScreenTestWidgetCollector.createSelector(null, selectorDyn);
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    if(maxWidgets > 0 && maxWidgets < elems.length) {
      throw AFException("Expected at most $maxWidgets widget for selector $selector, found ${elems.length} widgets");
    }
    if(elems.isEmpty) {
      throw AFException("applyWidgetValue, no widget found with selector $selectorDyn");
    }

    Element elem = elems.first;
    final tapable = testManager.findApplicator(applyType, elem);
    if(tapable == null) {
      throw AFException("No AFApplyWidgetAction found for ${elem.widget.runtimeType}, you can register one using AFScreenTests.registerApplicator");
    }
    tapable.apply(applyType, selector, elem, value);    
    return pauseForRender(previous, expectRender);
  }
  
  Future<void> applyWidgetValueWithExpectedAction(dynamic selector, dynamic value, String applyType, AFActionWithKey actionSpecifier, Function(AFActionWithKey) checkAction, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) async {
    final previous = AFibF.testOnlyScreenUpdateCount(activeScreenType);
    await applyWidgetValue(selector, value, applyType, expectRender: expectRender, maxWidgets: maxWidgets);
    expectAction(actionSpecifier, checkAction, extraFrames: extraFrames+1);    
    return pauseForRender(previous, expectRender);
    //return null;
  }

  Future<void> applyWidgetValueWithExpectedParam(dynamic selector, dynamic value, String applyType, Function(AFRouteParam) checkParam,  { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) async {
    final previous = AFibF.testOnlyScreenUpdateCount(activeScreenType);
    await applyWidgetValueWithExpectedAction(selector, value, applyType, AFNavigateSetParamAction(), (dynamic action) {
      AFNavigateSetParamAction paramAction = action;
      checkParam(paramAction.param);
    }, extraFrames: 1);    
    
    return pauseForRender(previous, expectRender);
  }

  Future<void> keepSynchronous() {
    return null;
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
  Future<void> updateScreenData(dynamic data, {bool expectRender = true}) {
    final previous = AFibF.testOnlyScreenUpdateCount(activeScreenType);
    dispatcher.dispatch(AFUpdatePrototypeScreenTestDataAction(this.test.id, data));
    return pauseForRender(previous, expectRender);
  }

  @override
  Future<void> pauseForRender(int previousCount, bool expectRender) async {
    if(!expectRender) {
      AFibD.logInternal?.fine("Skipping pauseForRender because expectRender was false.");
      return null;
    }
    /// wait for the screen element to be rebuilt.
    final screenType = activeScreenType;
    var current = AFibF.testOnlyScreenUpdateCount(screenType);
    AFibD.logInternal?.fine("Starting _pauseForRender for $screenType with previous $previousCount and current $current");
    int n = 0;
    while(current == previousCount) {
      AFibD.logInternal?.fine("Starting pause");
      await Future<void>.delayed(Duration(milliseconds: 100), () {});
      current = AFibF.testOnlyScreenUpdateCount(screenType);
      AFibD.logInternal?.fine("Finished finished pause with update count $current");
      n++;
      if(n > 10) {
        throw new AFException("Timeout waiting for screen update.  You may need to pass noUpdate: true into one of the test manipulators if it does not produce an update.");
      }
    }
    AFibD.logInternal?.fine("Exiting _pauseForRender with count $current");
    return null;
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
  Future<void> pauseForRender(int previousCount, bool expectRender) async {
    await tester.pumpAndSettle(Duration(seconds: 1));
    return super.pauseForRender(previousCount, expectRender);
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
  AFConnectedScreenWithoutRoute screen;

  AFScreenPrototypeTest({
    @required this.id,
    @required this.data,
    @required this.param,
    @required this.screen,
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
  AFConnectedScreenWithoutRoute screen;
  List<AFScreenPrototypeTest> tests = List<AFScreenPrototypeTest>();

  AFScreenTestGroup({
    @required this.testMgr, 
    @required this.screen,
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
      screen: screen,
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
  final extractors = List<AFExtractWidgetAction>();
  final applicators = List<AFApplyWidgetAction>();

  AFScreenTests() {
    registerApplicator(AFFlatButtonAction());
    registerApplicator(AFRaisedButtonAction());
    registerApplicator(AFToggleChoiceChip());
    registerApplicator(AFApplyTextTextFieldAction());
    registerApplicator(AFApplyTextAFTextFieldAction());
    registerApplicator(AFRichTextGestureTapAction());
    registerApplicator(AFApplyCupertinoPicker());

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
    applicators.add(apply);
  }

  void registerExtractor(AFExtractWidgetAction extract) {
    extractors.add(extract);
  }


  AFExtractWidgetAction findExtractor(String actionType, Element elem) {
    for(final extractor in extractors) {
      if(extractor.matches(actionType, elem)) {
        return extractor;
      }
    }
    return null;
  }

  AFApplyWidgetAction findApplicator(String actionType, Element elem) {
    for(final apply in applicators) {
      if(apply.matches(actionType, elem)) {
        return apply;
      }
    }
    return null;
  }

  /// Add a screen widget, and then in the [addInstances] callback add one or more 
  /// data states to render with that screen.
  void addScreen(AFConnectedScreenWithoutRoute screen, Function(AFScreenTestGroup) addInstances) {
    AFScreenTestGroup group = AFScreenTestGroup(testMgr: this, screen: screen);
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