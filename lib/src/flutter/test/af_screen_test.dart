

import 'dart:async';

import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
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

  factory AFSparsePathWidgetSelector.createFrom(List<dynamic> selectors) {
    final sels = List<AFWidgetSelector>();
    for(final selector in selectors) {
      sels.add(AFScreenTestWidgetCollector.createSelector(null, selector));
    }
    return AFSparsePathWidgetSelector(sels);
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
  AFTestID testId;
  final underPaths = List<AFSparsePathWidgetSelector>();
  final activeScreenIDs = List<AFScreenID>();
  
  AFScreenTestExecute(this.testId);

  AFScreenPrototypeTest get test {
    return AFibF.screenTests.findById(this.testId);
  }

  AFScreenID get activeScreenId;

  @override
  AFTestID get testID => testId;
  AFSparsePathWidgetSelector get activeSelectorPath {
    if(underPaths.isEmpty) {
      return null;
    }
    return underPaths.last;
  }

  void setCollector(AFScreenTestWidgetCollector collector) {
    //throw UnimplementedError();
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

  Future<void> underScreen(AFScreenID screen, Function underHere, { bool expectRender = true }) async {
    final shouldPush = true; //activeScreenIDs.isEmpty || activeScreenIDs.last != screen;
    if(shouldPush) {
      int screenRenderCount = AFibF.testOnlyScreenUpdateCount(screen);
      pushScreen(screen);
      await pauseForRender(screenRenderCount, expectRender);
    }
    await underHere();

    if(shouldPush) {
      popScreen();
    }
    return keepSynchronous();
  }

  void pushScreen(AFScreenID screen) {
    activeScreenIDs.add(screen);
  }

  void popScreen() {
    activeScreenIDs.removeLast();
  }

  /// Used to tap on an element that opens a popup of [popupScreenType].
  /// 
  /// You can operate on the controls in the popup from within [underHere]
  Future<void> tapWithPopup(dynamic selectorTap, final AFScreenID popupScreenId, Future<void> Function() underHere) async {
    int popupRenderCount = AFibF.testOnlyScreenUpdateCount(popupScreenId);
    await tap(selectorTap, expectRender: false);
    await this.underScreen(popupScreenId, () async {
      await pauseForRender(popupRenderCount, true);
      await underHere();
      return keepSynchronous();
    }, expectRender: false);

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

  void expectActionOnce(AFActionWithKey specifier, Function(AFActionWithKey) checkAction, {int extraFrames = 0});

  Future<void> executeNamedSection(AFTestSectionID id, dynamic params);

  Future<void> pauseForRender(int previousCount, bool expectRender);
  void addError(String error, int depth);
}

abstract class AFSingleScreenTestExecute extends AFScreenTestExecute {
  AFSingleScreenTestExecute(AFTestID testId): super(testId);

  AFScreenID get activeScreenId {
    if(activeScreenIDs.isNotEmpty) {
      return activeScreenIDs.last;
    }

    AFScreenPrototypeTest screenTest = test;
    return screenTest.screenId;
  }

  Future<void> executeNamedSection(AFTestSectionID id, dynamic params) {
    return AFibF.screenTests.executeNamedSection(id, this, params);
  }
}

typedef Future<void> AFScreenTestBodyExecuteFunc(AFScreenTestExecute exec, dynamic params);

class AFScreenTestBodyWithParam {
  final AFScreenTestBodyExecuteFunc body;
  final dynamic param;
  final AFTestSectionID id;
  final AFScreenTestWidgetCollector elementCollector;
  AFScreenTestBodyWithParam({this.id, this.body, this.param, this.elementCollector});
}


class AFSingleScreenTestBody {
  final AFTestID testId;
  final AFScreenTestGroup group;
  final sections = List<AFScreenTestBodyWithParam>();

  AFSingleScreenTestBody(this.testId, this.group);

  bool get isNotEmpty { 
    return sections.isNotEmpty;
  }

  void execute({AFScreenTestBodyExecuteFunc body, AFTestSectionID id, dynamic param}) {
    final collector = AFScreenTestWidgetCollector(this.testId);
    
    body(collector, param);

    sections.add(AFScreenTestBodyWithParam(id: id, body: body, param: param, elementCollector: collector));
    if(id != null) {
      AFibF.screenTests.defineNamedSection(id, body);
    }
  }

  void _checkFutureExists(Future<void> test) {
    if(test == null) {
      throw AFException("Test section failed to return a future.  Make sure all test sections end with return AFScreenTestExecute.keepSynchronous()");
    }
  }

  Future<void> executeNamedSection(AFTestSectionID id, AFScreenTestExecute e, dynamic params) async {
    return AFibF.screenTests.executeNamedSection(id, e, params);
  }

  Future<void> run(AFScreenTestExecute context, dynamic params, { Function onEnd, bool useParentCollector = false }) async {
    int sectionGuard = 0;
    for(int i = 0; i < sections.length; i++) {
      final section = sections[i];
      sectionGuard++;
      if(sectionGuard > 1) {
        throw AFException("Test section $i is missing an await!");
      }
      var actualParams = params;
      if(actualParams == null) {
        actualParams = section.param;
      }

      if(!useParentCollector) {
        context.setCollector(section.elementCollector);
      }

      final fut = section.body(context, actualParams);
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
  final AFScreenID screenId;
  final selectors = List<AFWidgetSelector>();

  AFScreenTestWidgetCollectorScreen(this.screenId, this.previousUpdateCount);

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
class AFScreenTestWidgetCollector extends AFSingleScreenTestExecute {

  AFScreenTestWidgetCollector(AFTestID testId): super(testId);

  final screens = Map<AFScreenID, AFScreenTestWidgetCollectorScreen>();


  AFScreenTestWidgetCollectorScreen _updateCache() {
    final info = AFibF.findTestScreen(activeScreenId);
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
    addSelector(selector);
  }

  void expectWidgets(dynamic selector, Function(List<Element>) onFound, { int extraFrames = 0 }) {
    addSelector(selector);
  }

  
  void expectNWidgets(dynamic selector, int n, {int extraFrames = 0}) {
    addSelector(selector);
  }

  void expectWidgetValue(dynamic selector, ft.Matcher matcher, { int extraFrames = 0 }) {
    addSelector(selector);
  }

  Future<void> applyWidgetValue(dynamic selector, dynamic value, String applyType, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) {
    addSelector(selector);
    return null;
  }
  
  Future<void> applyWidgetValueWithExpectedAction(dynamic selector, dynamic value, String applyType, AFActionWithKey actionSpecifier, Function(AFActionWithKey) checkAction, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) {
    addSelector(selector);
    return null;
  }
  
  Future<void> applyWidgetValueWithExpectedParam(dynamic selector, dynamic value, String applyType, Function(AFRouteParam) checkParam, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) {
    addSelector(selector);
    return null;
  }


  void expectActionOnce(AFActionWithKey specifier, Function(AFActionWithKey) checkAction, { int extraFrames = 0 }) {

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

  void addSelector(dynamic sel) {
    final activePath = activeSelectorPath;
    final screenInfo = _findOrCreateScreenInfo(activeScreenId);
    screenInfo.addSelector(createSelector(activePath, sel));
  }

  /// Rebuild our internal cache of paths to elements with keys.
  AFScreenTestWidgetCollectorScreen _refresh(AFibTestOnlyScreenElement currentInfo) {
    final screenInfo = _findOrCreateScreenInfo(currentInfo.screenId);
    
    // nothing to do if the current root hasn't changed.
    if(currentInfo.updateCount == screenInfo.previousUpdateCount) {
      return screenInfo;
    }

    screenInfo.resetForUpdate(currentInfo.updateCount);

    final currentPath = List<Element>();
    _populateChildren(screenInfo, currentInfo.element, currentPath);
    return screenInfo;
  }

  AFScreenTestWidgetCollectorScreen _findOrCreateScreenInfo(AFScreenID screenId) {
    AFScreenTestWidgetCollectorScreen screenInfo = screens[screenId];
    if(screenInfo == null) {
      screenInfo = AFScreenTestWidgetCollectorScreen(screenId, -1);
      screens[screenId] = screenInfo;
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


abstract class AFScreenTestContext extends AFSingleScreenTestExecute {
  AFScreenTestWidgetCollector elementCollector;
  final AFDispatcher dispatcher;
  AFScreenTestContext(this.dispatcher, AFTestID testId): super(testId);
  AFTestID get testID { return this.testId; }
  void setCollector(AFScreenTestWidgetCollector collector) { elementCollector = collector; }

  void pushScreen(AFScreenID screen) {
    elementCollector.pushScreen(screen);
    super.pushScreen(screen);
  }

  void popScreen() {
    super.popScreen();
    elementCollector.popScreen();
  }

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

  void expectNWidgets(dynamic selector, int n, {int extraFrames = 0}) {
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    this.expect(elems.length, ft.equals(n), extraFrames: extraFrames+1);
  }

  void expectWidgetValue(dynamic selectorDyn, ft.Matcher matcher, { String extractType = AFExtractWidgetAction.extractPrimary, int extraFrames = 0 }) {
    final selector = AFScreenTestWidgetCollector.createSelector(null, selectorDyn);
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    if(elems.isEmpty) {
      this.expect(elems, ft.isNotEmpty, extraFrames: extraFrames+1);
      return;
    }

    for(final elem in elems) {
      final selectable = AFibF.screenTests.findExtractor(extractType, elem);
      if(selectable == null) {
        throw AFException("No AFSelectedWidgetTest found for ${elem.widget.runtimeType}, you can register one using AFScreenTests.registerSelectable");
      }
      this.expect(selectable.extract(extractType, selector, elem), matcher, extraFrames: extraFrames+1);
    }
  }

  Future<void> applyWidgetValue(dynamic selectorDyn, dynamic value, String applyType, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) async {
    final previous = AFibF.testOnlyScreenUpdateCount(activeScreenId);
    final selector = AFScreenTestWidgetCollector.createSelector(null, selectorDyn);
    List<Element> elems = elementCollector.findWidgetsFor(selector);
    if(maxWidgets > 0 && maxWidgets < elems.length) {
      throw AFException("Expected at most $maxWidgets widget for selector $selector, found ${elems.length} widgets");
    }
    if(elems.isEmpty) {
      throw AFException("applyWidgetValue, no widget found with selector $selectorDyn");
    }

    Element elem = elems.first;
    final tapable = AFibF.screenTests.findApplicator(applyType, elem);
    if(tapable == null) {
      throw AFException("No AFApplyWidgetAction found for ${elem.widget.runtimeType}, you can register one using AFScreenTests.registerApplicator");
    }
    tapable.apply(applyType, selector, elem, value);    
    await pauseForRender(previous, expectRender);
    return keepSynchronous();
  }
  
  Future<void> applyWidgetValueWithExpectedAction(dynamic selector, dynamic value, String applyType, AFActionWithKey actionSpecifier, Function(AFActionWithKey) checkAction, { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) async {
    final previous = AFibF.testOnlyScreenUpdateCount(activeScreenId);
    await applyWidgetValue(selector, value, applyType, expectRender: expectRender, maxWidgets: maxWidgets);
    expectActionOnce(actionSpecifier, checkAction, extraFrames: extraFrames+1);    
    return pauseForRender(previous, expectRender);
    //return null;
  }

  Future<void> applyWidgetValueWithExpectedParam(dynamic selector, dynamic value, String applyType, Function(AFRouteParam) checkParam,  { bool expectRender = true, int maxWidgets = 1, int extraFrames = 0 }) async {
    final previous = AFibF.testOnlyScreenUpdateCount(activeScreenId);
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
  void expectActionOnce(AFActionWithKey specifier, Function(AFActionWithKey) checkAction, { int extraFrames = 0 }) {
    final key = specifier.key;
    final found = AFibF.testOnlyRecentActionWithKey(key);
    this.expect(found, ft.isNotNull, extraFrames: extraFrames+1);
    if(found == null) {
      return;
    }
    
    checkAction(found);
    AFibF.testOnlyRemoveRecentActionByKey(key);
  }
  
  @override
  Future<void> updateScreenData(dynamic data, {bool expectRender = true}) {
    final previous = AFibF.testOnlyScreenUpdateCount(activeScreenId);
    dispatcher.dispatch(AFUpdatePrototypeScreenTestDataAction(this.testId, data));
    return pauseForRender(previous, expectRender);
  }

  Future<void> yieldToRenderLoop() async {
    AFibD.logTest?.d("Starting yield to event loop");
    await Future<void>.delayed(Duration(milliseconds: 100), () {});
    return keepSynchronous();
  }

  @override
  Future<void> pauseForRender(int previousCount, bool expectRender, { AFScreenID screenId }) async {
    if(!expectRender) {
      AFibD.logTest?.d("Skipping pauseForRender because expectRender was false.");
      return null;
    }
    /// wait for the screen element to be rebuilt.
    final screenType = screenId ?? activeScreenId;
    var current = AFibF.testOnlyScreenUpdateCount(screenType);
    AFibD.logTest?.d("Starting _pauseForRender for $screenType with previous $previousCount and current $current");
    int n = 0;
    while(current == previousCount) {
      await yieldToRenderLoop();
      current = AFibF.testOnlyScreenUpdateCount(screenType);
      AFibD.logTest?.d("Finished finished pause for $screenType with update count $current");
      n++;
      if(n > 10) {
        throw new AFException("Timeout waiting for screen update.  You may need to pass noUpdate: true into one of the test manipulators if it does not produce an update.");
      }
    }
    AFibD.logTest?.d("Exiting _pauseForRender with count $current");
    return null;
  }
}

class AFScreenTestContextSimulator extends AFScreenTestContext {
  final int runNumber;
  final DateTime lastRun = DateTime.now();

  AFScreenTestContextSimulator(AFDispatcher dispatcher, AFTestID testId, this.runNumber): super(dispatcher, testId);

  @override
  Future<void> keepSynchronous() {
    return Future<void>.delayed(Duration(milliseconds: 0), () {});
  }

  void addError(String desc, int depth) {
    String err = AFBaseTestExecute.composeError(desc, depth);
    dispatcher.dispatch(AFPrototypeScreenTestAddError(this.testId, err));
    AFibD.log?.e(err);
  }

  bool addPassIf(bool test) {
    if(test) {
      dispatcher.dispatch(AFPrototypeScreenTestIncrementPassCount(this.testId));
    }
    return test;
  }
}

class AFScreenTestContextWidgetTester extends AFScreenTestContext {
  final ft.WidgetTester tester;
  final AFApp app;

  AFScreenTestContextWidgetTester(this.tester, this.app, AFDispatcher dispatcher, AFTestID testId): super(dispatcher, testId);

  @override
  Future<void> pauseForRender(int previousCount, bool expectRender, { AFScreenID screenId }) async {
    await tester.pumpAndSettle(Duration(seconds: 2));
    await super.pauseForRender(previousCount, expectRender, screenId: screenId);
    return keepSynchronous();
  }

  Future<void> yieldToRenderLoop() async {
    AFibD.logTest?.d("yielding to pump");
    await tester.pumpAndSettle(Duration(seconds: 2));
    return keepSynchronous();
  }

  Future<void> keepSynchronous() {
    return null;
  }
}

abstract class AFScreenPrototypeTest {
  final AFTestID id;
  final String subtitle;

  AFScreenPrototypeTest({
    @required this.id,
    this.subtitle
  });

  bool get hasBody;
  AFScreenID get screenId;
  void run(AFScreenTestContext context, { Function onEnd});
  void onDrawerReset(AFDispatcher dispatcher);
  Future<void> onDrawerRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext, AFSingleScreenTestState state, Function onEnd);

  AFScreenTestContextSimulator prepareRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext) {
    onDrawerReset(dispatcher);
    var runNumber = 1;
    if(prevContext != null && prevContext.runNumber != null) {
      runNumber = prevContext.runNumber + 1;
    }

    final testContext = AFScreenTestContextSimulator(dispatcher, this.id, runNumber);
    dispatcher.dispatch(AFStartPrototypeScreenTestContextAction(testContext));
    return testContext;
  }

}

/// All the information necessary to render a single screen for
/// prototyping and testing.
class AFSingleScreenPrototypeTest extends AFScreenPrototypeTest {
  dynamic data;
  dynamic param;
  final AFSingleScreenTestBody body;
  //final AFConnectedScreenWithoutRoute screen;
  final AFScreenID screenId;

  AFSingleScreenPrototypeTest({
    @required AFTestID id,
    @required this.data,
    @required this.param,
    @required this.screenId,
    @required this.body,
    String subtitle
  }): super(id: id, subtitle: subtitle);

  bool get hasBody {
    return body.isNotEmpty;
  }

  Future<void> run(AFScreenTestExecute context, { dynamic params, Function onEnd, bool useParentCollector = false}) {
    return body.run(context, params, onEnd: onEnd, useParentCollector: useParentCollector);
  }

  void onDrawerReset(AFDispatcher dispatcher) {
    dispatcher.dispatch(AFUpdatePrototypeScreenTestDataAction(this.id, this.data));
  }

 
  Future<void> onDrawerRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext, AFSingleScreenTestState state, Function onEnd) async {
    //final screenUpdateCount = AFibF.testOnlyScreenUpdateCount(screenId);
    final testContext = prepareRun(dispatcher, prevContext);
    //await testContext.pauseForRender(screenUpdateCount, true);
    run(testContext, onEnd: onEnd);
    return null;
  }
}

/// The information necessary to start a test with a baseline state
/// (determined by a state test) and an initial screen/route.
class AFMultiScreenStatePrototypeTest extends AFScreenPrototypeTest {
  final List<AFNavigatePushAction> initialPath;
  final AFTestID stateTestId;
  final AFMultiScreenStateTestBody body;

  AFMultiScreenStatePrototypeTest({
    @required AFTestID id,
    @required this.initialPath,
    @required this.stateTestId,
    @required this.body,
    String subtitle
  }): super(id: id, subtitle: subtitle);

  bool get hasBody {
    return body != null;
  }

  AFScreenID get screenId {
    return body.initialScreenId;
  }

  AFScreenTests get screenTests {
    return AFibF.screenTests;
  }

  void run(AFScreenTestContext context, { Function onEnd}) {
    body.run(context, null, onEnd: onEnd);
  }

  void onDrawerReset(AFDispatcher dispatcher) {
    //throw UnimplementedError();
  }

  Future<void> onDrawerRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext, AFSingleScreenTestState state, Function onEnd) async {
    final testContext = prepareRun(dispatcher, prevContext);
    run(testContext, onEnd: onEnd);
  }

}

/// All the screen tests/prototypes associated with a single screen.
class AFScreenTestGroup {
  AFScreenID screenId;
  final simpleTests = List<AFSingleScreenPrototypeTest>();

  AFScreenTestGroup({
    @required this.screenId,
  });

  List<AFScreenPrototypeTest> get allTests {
    final result = List<AFScreenPrototypeTest>.of(simpleTests);
    result.sort( (left, right) {
      return left.id.compareTo(right.id);
    });
    return result;
  }

  /// Add a prototype of a particular screen with the specified [data]
  /// and [param].  
  /// 
  /// Returns an [AFSingleScreenTestBody], which can be used to create a 
  /// test for the screen.
  AFSingleScreenTestBody addPrototype({
    @required AFTestID   id,
    @required dynamic data,
    @required dynamic param,
    String subtitle
  }) {
    AFSingleScreenPrototypeTest instance = AFSingleScreenPrototypeTest(
      id: id,
      data: data,
      param: param,
      screenId: screenId,
      subtitle: subtitle,
      body: AFSingleScreenTestBody(id, this)
    );
    simpleTests.add(instance);
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
    registerApplicator(AFIconButtonAction());
    registerApplicator(AFListTileTapAction());
    registerApplicator(AFGestureDetectorTapAction());

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
  void addScreen(AFScreenID screenId, Function(AFScreenTestGroup) addInstances) {
    AFScreenTestGroup group = AFScreenTestGroup(screenId: screenId);

    groups.add(group);

    addInstances(group);
  }

  AFSingleScreenPrototypeTest findById(AFTestID id) {
    for(var tests in groups) {
      for(var test in tests.simpleTests) {
        if(test.id == id) {
          return test;
        }
      }
    }
    return null;
  }
  
  List<AFScreenTestGroup> get all { return groups; }

  void defineNamedSection(AFTestSectionID id, AFScreenTestBodyExecuteFunc func) {
    _addNamedTestSection(id, func);
  }

  void _addNamedTestSection(AFTestSectionID id, AFScreenTestBodyExecuteFunc func) {
    if(namedSections.containsKey(id)) {
      throw new AFException("Attempt to register duplicate test section $id");
    }
    namedSections[id] = func;
  }

  Future<void> executeNamedSection(AFTestSectionID id, AFScreenTestExecute e, dynamic params) async {
    final section = findNamedTestSection(id);
    if(section == null) {
      throw new AFException("Attempt to executing undefined test section $id");
    }
    Future<void> fut = section(e, params);
    await fut;
    return e.keepSynchronous();
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

abstract class AFMultiScreenTestExecute {
  Future<void> tapNavigateFromTo({
    @required dynamic tap,
    @required AFScreenID from,
    @required AFScreenID to
  });

  Future<void> runScreenTest(AFTestID screenTestId, AFScreenID terminalScreen, {dynamic params, AFTestID queryResults, bool expectRender = true});
  Future<void> onScreen(AFScreenID screenId, AFScreenID terminalScreen, {AFTestID queryResults, Function(AFScreenTestExecute) body, expectRender = true});
  Future<void> keepSynchronous();
  
}

class AFMultiScreenTestWidgetCollector extends AFMultiScreenTestExecute {
  final AFScreenTestWidgetCollector elementCollector;

  AFMultiScreenTestWidgetCollector(this.elementCollector);

  Future<void> tapNavigateFromTo({
    @required dynamic tap,
    @required AFScreenID from,
    @required AFScreenID to
  }) {
    elementCollector.underScreen(from, () {
      elementCollector.addSelector(tap);
    });
    return keepSynchronous();
  }

  Future<void> runScreenTest(AFTestID screenTestId, AFScreenID terminalScreen, {dynamic params, AFTestID queryResults, bool expectRender = true}) async {
    final screenTest = AFibF.screenTests.findById(screenTestId);
    elementCollector.pushScreen(screenTest.screenId);
    await screenTest.run(elementCollector, params: params);
    elementCollector.popScreen();
  }


  Future<void> onScreen(AFScreenID screenId, AFScreenID terminalScreen, {AFTestID queryResults, Function(AFScreenTestExecute) body, expectRender = true}) async {
    await elementCollector.underScreen(screenId, () async {
      await body(elementCollector);
    });
    return keepSynchronous();
  }

  Future<void> keepSynchronous() {
    return null;
  }
}


class AFMultiScreenTestContext extends AFMultiScreenTestExecute {
  final AFScreenTestContext screenContext;

  AFMultiScreenTestContext(this.screenContext);  

  /// Execute the specified screen tests, with query-responses provided by the specified state test.
  Future<void> runScreenTest(AFTestID screenTestId, AFScreenID terminalScreen, {dynamic params, AFTestID queryResults, bool expectRender = true}) async {
    int prevRenderCount = AFibF.testOnlyScreenUpdateCount(terminalScreen);
    _installQueryResults(queryResults);
    final screenTest = AFibF.screenTests.findById(screenTestId);
    final originalScreenID = screenTest.screenId;
    screenContext.pushScreen(originalScreenID);
    await screenTest.run(screenContext, params: params, useParentCollector: true);  
    screenContext.popScreen();    
    if(originalScreenID != terminalScreen) {
      await screenContext.pauseForRender(prevRenderCount, expectRender, screenId: terminalScreen);
    } 
    return keepSynchronous();  
  }

  Future<void> tapNavigateFromTo({
    @required dynamic tap,
    @required AFScreenID from,
    @required AFScreenID to
  }) {
      return onScreen(from, to, body: (AFScreenTestExecute ste) async {
        await ste.tap(tap, expectRender: false);
        return ste.keepSynchronous();
      });
  }

  Future<void> onScreen(AFScreenID screenId, AFScreenID terminalScreen, {AFTestID queryResults, Function(AFScreenTestExecute) body, expectRender = true}) async {
    _installQueryResults(queryResults);
    final prevRenderCount = AFibF.testOnlyScreenUpdateCount(terminalScreen);
    await screenContext.underScreen(screenId, () async {
      AFibD.logTest?.d("Starting underScreen");
      // first, populate the element collector.
      final fut0 = body(screenContext.elementCollector);
      await fut0;

      final fut = body(screenContext);
      await fut;
      return screenContext.keepSynchronous();
    }, expectRender: false);
    AFibD.logTest?.d("Finished underscreen");

    if(screenId != terminalScreen) {
      return screenContext.pauseForRender(prevRenderCount, true, screenId: terminalScreen);
    } else {
      return keepSynchronous();
    }
  }

  void _installQueryResults(AFTestID queryResults) {
    if(queryResults == null) {
      return;
    }
    final stateTest = AFibF.stateTests.findById(queryResults);
    final store = AFibF.testOnlyStore;
    final dispatcher = AFStoreDispatcher(store);

    // This causes the query middleware to return results specified in the state test.
    final stateTestContext = AFStateTestContext(stateTest, store, dispatcher, isTrueTestContext: false);
    AFStateTestContext.setCurrentTest(stateTestContext);    
  }

  Future<void> keepSynchronous() {
    return null;
  }

}

typedef Future<void> AFMultiScreenTestBodyExecuteFunc(AFMultiScreenTestExecute exec, dynamic params);

class AFMultiScreenStateTestBodyWithParam {
  final AFMultiScreenTestBodyExecuteFunc body;
  final AFTestSectionID id;
  final dynamic param;
  AFMultiScreenStateTestBodyWithParam({this.body, this.id, this.param});


}

class AFMultiScreenStateTestBody {
  final AFMultiScreenStateTests tests;
  final AFScreenTestWidgetCollector elementCollector;
  final AFScreenID initialScreenId;
  final sections = List<AFMultiScreenStateTestBodyWithParam>();

  AFMultiScreenStateTestBody(this.tests, this.initialScreenId, this.elementCollector);

  factory AFMultiScreenStateTestBody.create(AFMultiScreenStateTests tests, AFScreenID initialScreenId, AFTestID testId) {
    return AFMultiScreenStateTestBody(tests, initialScreenId, AFScreenTestWidgetCollector(testId));
  }

  void execute({ AFMultiScreenTestBodyExecuteFunc body, AFTestSectionID id, dynamic param}) {
    body(AFMultiScreenTestWidgetCollector(elementCollector), param);

    sections.add(AFMultiScreenStateTestBodyWithParam(id: id, body: body, param: param));
  }  

  Future<void> run(AFScreenTestContext context, dynamic params, { Function onEnd }) async {
    context.setCollector(elementCollector);
    final e = AFMultiScreenTestContext(context);
    for(final section in sections) {
      var actualParams = params;
      if(actualParams == null) {
        actualParams = section.param;
      }

      await section.body(e, actualParams);
    }

    // TODO: this doesn't work because we are on a different screen at the end.
    if(onEnd != null) {
      onEnd();
    }
  }
}


/// Used for tests which have a real redux state/store, and navigate across multiple 
/// screens.
/// 
/// These tests by combine an initial state from an [AFStateTest] with a series
/// of screen manipulations from an [AFScreenTest]
class AFMultiScreenStateTests {
  final stateTests = List<AFMultiScreenStatePrototypeTest>();

  AFMultiScreenStateTestBody addPrototype({
    @required AFTestID   id,
    String subtitle,
    @required List<AFNavigatePushAction> initialPath,
    @required AFTestID stateTestId,
  }) {
    AFMultiScreenStatePrototypeTest instance = AFMultiScreenStatePrototypeTest(
      id: id,
      subtitle: subtitle,
      initialPath: initialPath,
      stateTestId: stateTestId,
      body: AFMultiScreenStateTestBody.create(this, initialPath.last.screen, id)
    );
    stateTests.add(instance);
    return instance.body;
  }

  AFMultiScreenStatePrototypeTest findById(AFTestID id) {
    for(final test in stateTests) {
      if(test.id == id) {
        return test;
      }
    }
    return null;
  }

  

}
