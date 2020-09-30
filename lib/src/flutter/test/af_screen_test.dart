

import 'dart:async';

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_prototype_single_screen_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_widget_screen.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_widget_actions.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

typedef void AFActionListenerDelegate(List<AFActionWithKey> actions);
typedef void AFParamListenerDelegate(AFRouteParam param);
typedef void AFAsyncQueryListenerDelegate(AFAsyncQueryCustomError query);

/// A superclass that declares all the methods which select specific widgets.
/// This is used by [AFScreenWidgetSelectorCollector] to determine which widgets
/// it needs to track for each test.
abstract class AFScreenTestWidgetSelector extends AFBaseTestExecute {
  
}

/// A utility class used to pass 
abstract class AFWidgetSelector {
  final elements = List<Element>();
  AFScreenTestWidgetCollectorScrollableSubpath parentScrollable;

  void add(Element elem) {
    elements.add(elem);
  }

  void clearWidgets() {
    elements.clear();
  }

  bool get isUnderScrollable {
    return parentScrollable != null;
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
    AFScreenPrototypeTest found = AFibF.screenTests.findById(this.testId);
    if(found == null) {
      found = AFibF.widgetTests.findById(this.testId);
    }
    return found;
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

  Future<void> expectOneWidget(dynamic selector) {
    return expectNWidgets(selector, 1, extraFrames: 1);
  }  

  Future<void> expectMissingWidget(dynamic selector) {
    expectNWidgets(selector, 0, extraFrames: 1, scrollIfMissing: false);
  }

  /// Any operations applied within the [underHere] callback operate on 
  /// widgets which are nested under [selector].
  /// 
  /// In addition to passing a standard [selector], like a AFWidgetID, you can also
  /// pass in a list of selectors.  If you do so, then the operation takes place
  /// under a sparse-path containing all the items in the list.
  Future<void> underWidget(dynamic selector, Future<void> Function() underHere);
  Future<void> expectNWidgets(dynamic selector, int n, {int extraFrames = 0, bool scrollIfMissing });

  Future<void> expectTextEquals(dynamic selector, String text) {
    return expectWidgetValue(selector, ft.equals(text), extraFrames: 1);
  }

  Future<void> expectText(dynamic selector, ft.Matcher matcher) {
    return expectWidgetValue(selector, matcher, extraFrames: 1);
  }

  Future<void> underScreen(AFScreenID screen, Function underHere) async {
    final shouldPush = true; //activeScreenIDs.isEmpty || activeScreenIDs.last != screen;
    if(shouldPush) {
      pushScreen(screen);
      await pauseForRender();
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
    await tap(selectorTap);
    await pauseForRender();
    verifyPopupScreenId(popupScreenId);
    await this.underScreen(popupScreenId, () async {
      await underHere();
      return keepSynchronous();
    });

    return null;
  }

  /// Used to tap on a control that closes a popup.
  /// 
  /// The standard tap waits for the popup to re-render, which
  /// it may not do.  This function does the tap but does not
  /// wait for a render.
  Future<void> tapClosePopup(dynamic selector) async {
    return tap(selector);
  }

  /// Expect that a [Chip] is selected or not selected.
  /// 
  /// Note that in addition to the standard options, 
  /// the [selector] can be a list of other selectors.  With chips,
  /// it is very common to verify that several of them are on or off
  /// at the same time, and passing in a list is a concise way to do
  /// so.
  Future<void> expectChipSelected(dynamic selector, bool sel) {
    return expectWidgetValue(selector, ft.equals(sel), extraFrames: 1);
  }

  Future<void> expectWidget(dynamic selector, Function(Element elem) onFound, { int extraFrames = 0 });
  Future<void> expectWidgets(dynamic selector, Function(List<Element>) onFound, { int extraFrames = 0 });

  Future<void> expectWidgetValue(dynamic selector, ft.Matcher matcher, { int extraFrames = 0 });

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
  
  Future<void> applyWidgetValue(dynamic selector, dynamic value, String applyType, { 
    AFActionListenerDelegate verifyActions, 
    AFParamListenerDelegate verifyParamUpdate,
    AFAsyncQueryListenerDelegate verifyQuery,
    int maxWidgets = 1, 
    int extraFrames = 0 
  });

  Future<void> tap(dynamic selector, { 
    int extraFrames = 0,
    AFActionListenerDelegate verifyActions, 
    AFParamListenerDelegate verifyParamUpdate,
    AFAsyncQueryListenerDelegate verifyQuery, 
  }) {
    return applyWidgetValue(selector, null, AFApplyWidgetAction.applyTap, extraFrames: extraFrames+1, verifyActions: verifyActions, verifyParamUpdate: verifyParamUpdate, verifyQuery: verifyQuery);
  }

  Future<void> swipeDismiss(dynamic selector, { 
    int maxWidgets = 1, 
    int extraFrames = 0, 
    AFActionListenerDelegate verifyActions, 
    AFParamListenerDelegate verifyParamUpdate,
    AFAsyncQueryListenerDelegate verifyQuery 
  }) {
    return applyWidgetValue(selector, null, AFApplyWidgetAction.applyDismiss, maxWidgets: maxWidgets, extraFrames: extraFrames+1, verifyActions: verifyActions, verifyParamUpdate: verifyParamUpdate, verifyQuery: verifyQuery);
  }

  Future<void> setValue(dynamic selector, dynamic value, { 
    int maxWidgets = 1, 
    int extraFrames = 0, 
    AFActionListenerDelegate verifyActions, 
    AFParamListenerDelegate verifyParamUpdate,
    AFAsyncQueryListenerDelegate verifyQuery,    
  }) {
    return applyWidgetValue(selector, value, AFApplyWidgetAction.applySetValue, maxWidgets:  maxWidgets, extraFrames: extraFrames+1, verifyActions: verifyActions, verifyParamUpdate: verifyParamUpdate, verifyQuery: verifyQuery);
  }

  Future<void> enterText(dynamic selector, dynamic value, { 
    int maxWidgets = 1, 
    int extraFrames = 0, 
    AFActionListenerDelegate verifyActions, 
    AFParamListenerDelegate verifyParamUpdate,
    AFAsyncQueryListenerDelegate verifyQuery,    
  }) {
    return applyWidgetValue(selector, value, AFApplyWidgetAction.applySetValue, maxWidgets:  maxWidgets, extraFrames: extraFrames+1, verifyActions: verifyActions, verifyParamUpdate: verifyParamUpdate, verifyQuery: verifyQuery);
  }


  Future<void> keepSynchronous();
  Future<void> get ks { return keepSynchronous(); }
  Future<void> updateScreenData(dynamic data);
  void verifyPopupScreenId(AFScreenID screenId);

  Future<void> executeNamedSection(AFTestSectionID id, dynamic params);

  Future<void> pauseForRender();
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


  Future<void> populateElementCollector() {
    return body(elementCollector, param); 
  }

  ScaffoldState findScaffoldState(AFScreenID screenId) {
    return elementCollector.findScaffoldState(screenId);
  }
}

class AFSingleScreenTestBody {
  final AFTestID testId;
  final sections = List<AFScreenTestBodyWithParam>();

  AFSingleScreenTestBody(this.testId);

  bool get isNotEmpty { 
    return sections.isNotEmpty;
  }

  void execute({AFScreenTestBodyExecuteFunc body, AFTestSectionID id, dynamic param}) async {
    final collector = AFScreenTestWidgetCollector(this.testId);
    // in the first section, always add a scaffold widget collector.
  
    sections.add(AFScreenTestBodyWithParam(id: id, body: body, param: param, elementCollector: collector));
    if(id != null) {
      AFibF.screenTests.defineNamedSection(id, body);
    }
  }

  Future<void> populateWidgetCollector() async {
    for(final section in sections) {
      await section.populateElementCollector();
    }
    return null;
  }

  void _checkFutureExists(Future<void> test) {
    if(test == null) {
      throw AFException("Test section failed to return a future.  Make sure all test sections end with return AFScreenTestExecute.keepSynchronous()");
    }
  }

  Future<void> executeNamedSection(AFTestSectionID id, AFScreenTestExecute e, dynamic params) async {
    return AFibF.screenTests.executeNamedSection(id, e, params);
  }

  void openTestDrawer() {
    final scaffoldState = sections.first.findScaffoldState(AFibF.testOnlyActiveScreenId);
    scaffoldState?.openEndDrawer();
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

class AFScreenTestWidgetCollectorScrollableSubpath {
  final List<Element> pathTo;

  AFScreenTestWidgetCollectorScrollableSubpath({this.pathTo});

  factory AFScreenTestWidgetCollectorScrollableSubpath.create(List<Element> pathTo) {
    return AFScreenTestWidgetCollectorScrollableSubpath(pathTo: List<Element>.of(pathTo));
  }
}


class AFScreenTestWidgetCollectorScreen {
  final AFScreenID screenId;
  final selectors = List<AFWidgetSelector>();
  final scrollables = List<AFScreenTestWidgetCollectorScrollableSubpath>();
  ScaffoldState scaffoldState;

  AFScreenTestWidgetCollectorScreen(this.screenId);

  void addSelector(AFWidgetSelector sel) {
    selectors.add(sel);
  }
  
  bool get hasScaffoldState {
    return scaffoldState != null;
  }

  void addScaffoldState(ScaffoldState state) {
    scaffoldState = state;
  }

  AFScreenTestWidgetCollectorScrollableSubpath addScrollableAt(List<Element> path) {
    final result = AFScreenTestWidgetCollectorScrollableSubpath.create(path);
    scrollables.add(result);
    return result;
  }

  void clearAll() {
    scaffoldState = null;
    scrollables.clear();
    for(final sel in selectors) {
      sel.clearWidgets();
    }
  }

  void resetForUpdate() {
    clearAll();
  }

  Future<List<Element>> findElementsForSelector(AFWidgetSelector selector, { bool scrollIfMissing }) async {

    // in many cases, the widgets are found as part of the normal screen rendering process.
    for(final test in selectors) {
      if(test == selector) {
        if(test.elements.isNotEmpty) {
          return test.elements;
        }
      }
    }

    if(!scrollIfMissing) {
      return List<Element>();
    }
    
    // if we didn't find the selector, and we are under a scrollable widget,
    // it might be that the widget is not in view, try systematically
    // scrolling the widget, and re-building our selectors under that point.
    return scrollUntilFound(selector, );
  }

  // Go though all the children of [current], having the parent path [currentPath],
  // and add path entries for any widgets with keys.
  void populateChildren(Element currentElem, List<Element> currentPath, bool underScaffold, AFScreenTestWidgetCollectorScrollableSubpath parentScrollable) {

    // add the current element.
    currentPath.add(currentElem);

    final widget = currentElem.widget;
    if(widget is Scrollable) {
      parentScrollable = addScrollableAt(currentPath);
    }

    if(underScaffold && !hasScaffoldState) {
      ScaffoldState scaffoldState = Scaffold.of(currentElem);
      if(scaffoldState != null) {
        addScaffoldState(scaffoldState);
      }
    }

    // go through all the selectors, and see if any of them match.
    for(final selector in selectors) {
      if(selector.matchesPath(currentPath)) {
        selector.add(currentPath.last);
        if(parentScrollable != null) {
          selector.parentScrollable = parentScrollable;
        }
      }
    } 

    // do this same process recursively on the childrne.
    currentElem.visitChildren((child) {
      final nowUnderScaffold = underScaffold || currentElem.widget is Scaffold;
      populateChildren(child, currentPath, nowUnderScaffold, parentScrollable);
    });

    // maintain the path as we go back up.
    currentPath.removeLast();
  }

  Future<List<Element>> scrollUntilFound(AFWidgetSelector selector) async {
    for(final scrollable in scrollables) {
      List<Element> found = await scrollOneUntilFound(scrollable, selector);
      if(found != null) {
        return found;
      }
    }
    return List<Element>();
  }

  Future<List<Element>> scrollOneUntilFound(AFScreenTestWidgetCollectorScrollableSubpath source, AFWidgetSelector selector) async {
    final pathTo = source.pathTo;
    final elemScrollable = pathTo.last;
    final Scrollable widgetScrollable = elemScrollable.widget;
    final controller = widgetScrollable.controller;

    double currentPosition = 0.0;
    final scrollIncrement = 200.0;

    while(true) {
      // animate to the current position.
      await controller.animateTo(currentPosition,
        curve: Curves.linear, 
        duration: Duration (milliseconds: 200)
      );

      // clear out all the child elements found under this scrollabe.
      _clearChildrenUnderScrollable(source);

      // rebuild with whatever is there now.
      populateChildren(elemScrollable, pathTo, true, source);
    
      // see if we found the widget at this position.
      List<Element> currentResults = await findElementsForSelector(selector, scrollIfMissing: false);
      if(currentResults.isNotEmpty) {
        return currentResults;
      }

      // if we got to a point where our current offset is less than our desired offset, we must have scrolled
      // all the way to the bottom, in that case just return the empty set.
      if(controller.offset < currentPosition) {
        return List<Element>();
      }

      // if we didn't then we need to scroll down about, and try again.
      currentPosition += scrollIncrement;
    }
  }

  void _clearChildrenUnderScrollable(AFScreenTestWidgetCollectorScrollableSubpath source) {
    for(final selector in selectors) {
      if(selector.parentScrollable == source) {
        selector.elements.clear();
      }
    }
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

  ScaffoldState findScaffoldState(AFScreenID screenId) {
    final screen = screens[screenId];
    return screen?.scaffoldState;
  }

  Future<List<Element>> findWidgetsFor(dynamic selector, { bool scrollIfMissing = true }) async {
    final screenInfo = _updateCache();
    final sel = createSelector(activeSelectorPath, selector);
    return screenInfo.findElementsForSelector(sel, scrollIfMissing: scrollIfMissing);
  }

  void verifyPopupScreenId(AFScreenID popupScreenId) {
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
    return keepSynchronous();
  }

  Future<void> expectWidget(dynamic selector, Function(Element) onFound, { int extraFrames = 0 }) {
    addSelector(selector);
  }

  Future<void> expectWidgets(dynamic selector, Function(List<Element>) onFound, { int extraFrames = 0 }) {
    addSelector(selector);
    return keepSynchronous();
  }

  
  Future<void> expectNWidgets(dynamic selector, int n, {int extraFrames = 0, bool scrollIfMissing}) {
    addSelector(selector);
    return keepSynchronous();
  }

  Future<void> expectWidgetValue(dynamic selector, ft.Matcher matcher, { int extraFrames = 0 }) {
    addSelector(selector);
  }

  Future<void> applyWidgetValue(dynamic selector, dynamic value, String applyType, { 
    AFActionListenerDelegate verifyActions, 
    AFParamListenerDelegate verifyParamUpdate,
    AFAsyncQueryListenerDelegate verifyQuery,
    int maxWidgets = 1, 
    int extraFrames = 0 
  }) {
    addSelector(selector);
    return null;
  }


  Future<void> pauseForRender() {
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
    
    screenInfo.resetForUpdate();

    final currentPath = List<Element>();
    screenInfo.populateChildren(currentInfo.element, currentPath, false, null);
    return screenInfo;
  }

  AFScreenTestWidgetCollectorScreen _findOrCreateScreenInfo(AFScreenID screenId) {
    AFScreenTestWidgetCollectorScreen screenInfo = screens[screenId];
    if(screenInfo == null) {
      screenInfo = AFScreenTestWidgetCollectorScreen(screenId);
      screens[screenId] = screenInfo;
    }
    return screenInfo;
  }

  static Scaffold findScaffoldUnder(Element currentElem) {
    if(currentElem.widget is Scaffold) {
      return currentElem.widget;
    }
    // do this same process recursively on the childrne.
    var result;
    currentElem.visitChildren((child) {
      final found = findScaffoldUnder(child);
      if(result != null) {
        result = found;
      }
    });

    return result;
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
    return keepSynchronous();
  }

  Future<void> expectWidget(dynamic selector, Function(Element elem) onFound, { int extraFrames = 0 }) async {
    List<Element> elems = await elementCollector.findWidgetsFor(selector);
    this.expect(elems.length, ft.equals(1), extraFrames: extraFrames+1);
    if(elems.length > 0) {
      onFound(elems.first);
    }
    return keepSynchronous();
  }

  Future<void> expectWidgets(dynamic selector, Function(List<Element>) onFound, { int extraFrames = 0 }) async {
    List<Element> elems = await elementCollector.findWidgetsFor(selector);
    onFound(elems);
    return keepSynchronous();
  }

  Future<void> expectNWidgets(dynamic selector, int n, {int extraFrames = 0, bool scrollIfMissing = true}) async {
    List<Element> elems = await elementCollector.findWidgetsFor(selector, scrollIfMissing: scrollIfMissing);
    this.expect(elems.length, ft.equals(n), extraFrames: extraFrames+1);
    return keepSynchronous();
  }

  Future<void> expectWidgetValue(dynamic selectorDyn, ft.Matcher matcher, { String extractType = AFExtractWidgetAction.extractPrimary, int extraFrames = 0 }) async {
    final selector = AFScreenTestWidgetCollector.createSelector(null, selectorDyn);
    List<Element> elems = await elementCollector.findWidgetsFor(selector);
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
    return keepSynchronous();
  }

  Future<void> applyWidgetValue(dynamic selectorDyn, dynamic value, String applyType, { 
      AFActionListenerDelegate verifyActions, 
      AFParamListenerDelegate verifyParamUpdate,
      AFAsyncQueryListenerDelegate verifyQuery,
      int maxWidgets = 1, 
      int extraFrames = 0 
    }) async {
    AFibF.testOnlyClearRecentActions();
    final selector = AFScreenTestWidgetCollector.createSelector(null, selectorDyn);
    List<Element> elems = await elementCollector.findWidgetsFor(selector);
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
    if(verifyActions != null) {
      verifyActions(AFibF.testOnlyRecentActions);
    } 
    if(verifyParamUpdate != null) {
      final AFNavigateSetParamAction setParam = AFibF.testOnlyRecentActions.firstWhere( (act) => (act is AFNavigateSetParamAction), orElse: () => null );
      if(setParam == null) {
        throw AFException("Passed in verifyUpdateParam, but there was not an AFNavigateSetParamAction dispatched by action");
      }
      var paramOuter = setParam.param;
      var paramInner = paramOuter;
      if(paramOuter is AFPrototypeSingleScreenRouteParam) {
        paramInner = paramOuter.param;
      }

      verifyParamUpdate(paramInner);
    }
    if(verifyQuery != null) {
      final AFAsyncQueryCustomError query = AFibF.testOnlyRecentActions.firstWhere( (act) => (act is AFAsyncQueryCustomError), orElse: () => null );
      if(query == null) {
        throw AFException("Passed in verifyQuery, but there was not an AFAsyncQueryCustomError dispatched by action");
      }
      verifyQuery(query);
      return keepSynchronous();
    }

    await pauseForRender();
    return keepSynchronous();
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
  Future<void> updateScreenData(dynamic data) {
    dispatcher.dispatch(AFUpdatePrototypeScreenTestDataAction(this.testId, data));
    return pauseForRender();
  }

  Future<void> yieldToRenderLoop() async {
    AFibD.logTest?.d("Starting yield to event loop");
    await Future<void>.delayed(Duration(milliseconds: 100), () {});
    return keepSynchronous();
  }

  @override
  Future<void> pauseForRender() async {
    await yieldToRenderLoop();
    return keepSynchronous();
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

  void verifyPopupScreenId(AFScreenID popupScreenId) {
    AFibF.testOnlyVerifyActiveScreen(popupScreenId, includePopups: true);
  }
}

class AFScreenTestContextWidgetTester extends AFScreenTestContext {
  final ft.WidgetTester tester;
  final AFApp app;

  AFScreenTestContextWidgetTester(this.tester, this.app, AFDispatcher dispatcher, AFTestID testId): super(dispatcher, testId);

  @override
  Future<void> pauseForRender() async {
    await tester.pumpAndSettle(Duration(seconds: 2));
    await super.pauseForRender();
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

  void verifyPopupScreenId(AFScreenID popupScreenId) {
    AFibF.testOnlyVerifyActiveScreen(popupScreenId, includePopups: true);
  }

}

abstract class AFScreenPrototypeTest {
  final AFTestID id;
  final String title;

  AFScreenPrototypeTest({
    @required this.id,
    this.title
  });

  bool get hasBody;
  AFScreenID get screenId;
  void startScreen(AFDispatcher dispatcher);
  Future<void> run(AFScreenTestContext context, dynamic params, { Function onEnd});
  void onDrawerReset(AFDispatcher dispatcher);
  Future<void> onDrawerRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext, AFSingleScreenTestState state, Function onEnd);
  void openTestDrawer();
  Future<void> populateWidgetCollector();


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
    String title
  }): super(id: id, title: title);

  bool get hasBody {
    return body.isNotEmpty;
  }

  Future<void> populateWidgetCollector() {
    return body?.populateWidgetCollector();
  }

  void startScreen(AFDispatcher dispatcher) {
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(this));
    dispatcher.dispatch(AFPrototypeSingleScreenScreen.navigatePush(this, id: this.id));    
  }

  Future<void> run(AFScreenTestExecute context, dynamic params, { Function onEnd, bool useParentCollector = false}) {
    return body.run(context, params, onEnd: onEnd, useParentCollector: useParentCollector);
  }

  void onDrawerReset(AFDispatcher dispatcher) {
    dispatcher.dispatch(AFUpdatePrototypeScreenTestDataAction(this.id, this.data));
  }

 
  Future<void> onDrawerRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext, AFSingleScreenTestState state, Function onEnd) async {
    //final screenUpdateCount = AFibF.testOnlyScreenUpdateCount(screenId);
    final testContext = prepareRun(dispatcher, prevContext);
    //await testContext.pauseForRender(screenUpdateCount, true);
    run(testContext, null, onEnd: onEnd);
    return null;
  }

  void openTestDrawer() {
    body.openTestDrawer();
  }
}

typedef AFConnectedWidgetWithParam AFCreateConnectedWidget(
  AFDispatcher dispatcher,
  AFFindParamDelegate findParamDelegate,
  AFUpdateParamDelegate updateParamDelegate,
);

class AFWidgetPrototypeTest extends AFScreenPrototypeTest {
  final dynamic data;
  final AFSingleScreenTestBody body;
  final AFCreateConnectedWidget createConnectedWidget;
  final AFCreateWidgetWrapperDelegate createWidgetWrapperDelegate;

  AFWidgetPrototypeTest({
    @required AFTestID id,
    @required this.body,
    @required this.data,
    @required this.createConnectedWidget,
    this.createWidgetWrapperDelegate,
    String title
  }): super(id: id, title: title);

  AFScreenID get screenId {
    return AFUIID.screenPrototypeWidget;
  }

  Future<void> populateWidgetCollector() {
    return body?.populateWidgetCollector();
  }

  bool get hasBody {
    return body != null && body.isNotEmpty;
  }

  void openTestDrawer() {
    body.openTestDrawer();
  }

  void startScreen(AFDispatcher dispatcher) {
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(this));
    dispatcher.dispatch(AFPrototypeWidgetScreen.navigatePush(this, id: this.id));    
  }
  
  Future<void> run(AFScreenTestExecute context, dynamic params, { Function onEnd, bool useParentCollector = false}) {
    return body.run(context, params, onEnd: onEnd, useParentCollector: useParentCollector);
  }

  void onDrawerReset(AFDispatcher dispatcher) {
    dispatcher.dispatch(AFUpdatePrototypeScreenTestDataAction(this.id, this.data));
  }

  Future<void> onDrawerRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext, AFSingleScreenTestState state, Function onEnd) async {
    //final screenUpdateCount = AFibF.testOnlyScreenUpdateCount(screenId);
    final testContext = prepareRun(dispatcher, prevContext);
    //await testContext.pauseForRender(screenUpdateCount, true);
    run(testContext, null, onEnd: onEnd);
    return null;
  }
}

 
/// All the information necessary to render a single screen for
/// prototyping and testing.
class AFConnectedWidgetPrototypeTest extends AFWidgetPrototypeTest {
  final AFRouteParam param;

  AFConnectedWidgetPrototypeTest({
    @required AFTestID id,
    @required dynamic data,
    @required this.param,
    @required AFCreateConnectedWidget createConnectedWidget,
    @required AFSingleScreenTestBody body,
    String title
  }): super(id: id, title: title, body: body, data: data, createConnectedWidget: createConnectedWidget);
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
    String title
  }): super(id: id, title: title);

  bool get hasBody {
    return body != null;
  }

  Future<void> populateWidgetCollector() {
    return body?.populateWidgetCollector();
  }

  void openTestDrawer() {
    body.openTestDrawer();
  }

  AFScreenID get screenId {
    return body.initialScreenId;
  }

  AFSingleScreenTests get screenTests {
    return AFibF.screenTests;
  }

  void startScreen(AFDispatcher dispatcher) {
    initializeMultiscreenPrototype(dispatcher, this);
  }

  static void initializeMultiscreenPrototype(AFDispatcher dispatcher, AFMultiScreenStatePrototypeTest test) {
    dispatcher.dispatch(AFResetToInitialStateAction());
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(test));

    // lookup the test.
    final testImpl = AFibF.stateTests.findById(test.stateTestId);
    
    // then, execute the desired state test to bring us to our desired state.
    final store = AFibF.testOnlyStore;
    final mainDispatcher = AFStoreDispatcher(store);    
    final stateDispatcher = AFStateScreenTestDispatcher(mainDispatcher);

    final stateTestContext = AFStateTestContext(testImpl, store, stateDispatcher, isTrueTestContext: false);
    testImpl.execute(stateTestContext);

    if(stateTestContext.errors.hasErrors) {
      // TODO: return.
    }

    // then, navigate into the desired path.
    for(final push in test.initialPath) {
      dispatcher.dispatch(push);
    }
  }


  Future<void> run(AFScreenTestContext context, dynamic params, { Function onEnd}) {
    return body.run(context, params, onEnd: onEnd);
  }

  void onDrawerReset(AFDispatcher dispatcher) {
    //throw UnimplementedError();
  }

  Future<void> onDrawerRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext, AFSingleScreenTestState state, Function onEnd) async {
    final testContext = prepareRun(dispatcher, prevContext);
    return run(testContext, null, onEnd: onEnd);
  }

}


/// Used to register connected or unconnected widget tests.
class AFWidgetTests<TState> {
  final _connectedTests = List<AFWidgetPrototypeTest>();
  
  AFSingleScreenTestBody addConnectedPrototype({
    @required AFTestID   id,
    @required AFCreateConnectedWidget createConnectedWidget,
    @required dynamic data,
    @required AFRouteParam param,
    String title
  }) {
    AFConnectedWidgetPrototypeTest instance = AFConnectedWidgetPrototypeTest(
      id: id,
      data: data,
      param: param,

      createConnectedWidget: createConnectedWidget,
      title: title,
      body: AFSingleScreenTestBody(id)
    );
    _connectedTests.add(instance);
    return instance.body;
  }

  AFWidgetPrototypeTest findById(AFTestID id) {
    return _connectedTests.firstWhere( (test) => test.id == id, orElse: () => null);
  }

  List<AFWidgetPrototypeTest> get all {
    return _connectedTests;
  }
}

/// This class is used to create canned versions of screens and widget populated
/// with specific data for testing and prototyping purposes.
class AFSingleScreenTests<TState> {
  
  final namedSections = Map<AFTestSectionID, AFScreenTestBodyExecuteFunc>();
  final _singleScreenTests = List<AFSingleScreenPrototypeTest>();
  final extractors = List<AFExtractWidgetAction>();
  final applicators = List<AFApplyWidgetAction>();

  AFSingleScreenTests() {
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
    registerApplicator(AFDismissibleSwipeAction());

    registerExtractor(AFSelectableChoiceChip());
    registerExtractor(AFExtractTextTextAction());
    registerExtractor(AFExtractTextTextFieldAction());
    registerExtractor(AFExtractTextAFTextFieldAction());
    registerExtractor(AFExtractRichTextAction());
  }

  List<AFSingleScreenPrototypeTest> get all {
    return _singleScreenTests;
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

  /// Add a prototype of a particular screen with the specified [data]
  /// and [param].  
  /// 
  /// Returns an [AFSingleScreenTestBody], which can be used to create a 
  /// test for the screen.
  AFSingleScreenTestBody addPrototype({
    @required AFScreenID screenId,
    @required AFTestID   id,
    @required dynamic data,
    @required dynamic param,
    String title
  }) {
    AFSingleScreenPrototypeTest instance = AFSingleScreenPrototypeTest(
      id: id,
      data: data,
      param: param,
      screenId: screenId,
      title: title,
      body: AFSingleScreenTestBody(id)
    );
    _singleScreenTests.add(instance);
    return instance.body;
  }


  /*
  /// Add a screen widget, and then in the [addInstances] callback add one or more 
  /// data states to render with that screen.
  void addScreen(AFScreenID screenId, Function(AFScreenTestGroup) addInstances) {
    AFScreenTestGroup group = AFScreenTestGroup(screenId: screenId);

    groups.add(group);

    addInstances(group);
  }
  */
  

  AFSingleScreenPrototypeTest findById(AFTestID id) {
    return _singleScreenTests.firstWhere((test) => test.id == id, orElse: () => null);
  }
  
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
    AFibF.testData.register(id, data);
  }

  dynamic findData(dynamic id) {
    return AFibF.testData.find(id);
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
    @required AFScreenID startScreen,
    AFScreenID endScreen,
    bool verifyScreen = true
  });

  Future<void> runScreenTest(AFTestID screenTestId, {
    AFScreenID terminalScreen, 
    dynamic params, 
    AFTestID queryResults});
  Future<void> runWidgetTest(AFTestID widgetTestId, AFScreenID originScreen, {AFScreenID terminalScreen, dynamic params, AFTestID queryResults});
  Future<void> onScreen({
    @required AFScreenID startScreen, 
    AFScreenID endScreen, 
    AFTestID queryResults, 
    Function(AFScreenTestExecute) body,
    bool verifyScreen = true });
  Future<void> keepSynchronous();
  Future<void> tapOpenDrawer({
    @required dynamic tap,
    @required AFScreenID startScreen,
    @required AFScreenID drawerId
  });
  Future<void> onDrawer({
    @required AFScreenID drawerId, 
    AFScreenID endScreen, 
    AFTestID queryResults, 
    Function(AFScreenTestExecute) body,
  });
  
}


class AFMultiScreenTestWidgetCollector extends AFMultiScreenTestExecute {
  final AFScreenTestWidgetCollector elementCollector;

  AFMultiScreenTestWidgetCollector(this.elementCollector);

  Future<void> tapNavigateFromTo({
    @required dynamic tap,
    @required AFScreenID startScreen,
    AFScreenID endScreen,
    bool verifyScreen = true
  }) async {
    await elementCollector.underScreen(startScreen, () {
      elementCollector.addSelector(tap);
    });
    return keepSynchronous();
  }

  Future<void> tapOpenDrawer({
    @required dynamic tap,
    @required AFScreenID startScreen,
    @required AFScreenID drawerId
  }) async {
    await elementCollector.underScreen(startScreen, () {
      elementCollector.addSelector(tap);    
    });
    return keepSynchronous();
  }


  Future<void> runScreenTest(AFTestID screenTestId, {AFScreenID terminalScreen, dynamic params, AFTestID queryResults}) async {
    final screenTest = AFibF.screenTests.findById(screenTestId);
    elementCollector.pushScreen(screenTest.screenId);
    await screenTest.run(elementCollector, params, useParentCollector: true);
    elementCollector.popScreen();
  }

  Future<void> runWidgetTest(AFTestID widgetTestId, AFScreenID originScreen, {AFScreenID terminalScreen, dynamic params, AFTestID queryResults, }) async {
    final widgetTest = AFibF.widgetTests.findById(widgetTestId);
    elementCollector.pushScreen(originScreen);
    await widgetTest.run(elementCollector, params, useParentCollector: true);
    elementCollector.popScreen();
  }

  Future<void> onScreen({
    @required AFScreenID startScreen, 
    AFScreenID endScreen, 
    AFTestID queryResults, 
    Function(AFScreenTestExecute) body, 
    bool verifyScreen = true
  }) async {
    await elementCollector.underScreen(startScreen, () async {
      await body(elementCollector);
      return elementCollector.keepSynchronous();
    });
    return keepSynchronous();
  }

  Future<void> onDrawer({
    @required AFScreenID drawerId, 
    AFScreenID endScreen, 
    AFTestID queryResults, 
    Function(AFScreenTestExecute) body,
  }) {
    return onScreen(
      startScreen: drawerId,
      endScreen: endScreen,
      queryResults: queryResults,
      body: body,
      verifyScreen: false
    );
  }

  Future<void> keepSynchronous() {
    return null;
  }
}


class AFMultiScreenTestContext extends AFMultiScreenTestExecute {
  final AFScreenTestContext screenContext;

  AFMultiScreenTestContext(this.screenContext);  

  /// Execute the specified screen tests, with query-responses provided by the specified state test.
  Future<void> runScreenTest(AFTestID screenTestId,  {AFScreenID terminalScreen, dynamic params, AFTestID queryResults}) async {
    _installQueryResults(queryResults);
    final screenTest = AFibF.screenTests.findById(screenTestId);
    final originalScreenID = screenTest.screenId;
    screenContext.pushScreen(originalScreenID);
    await screenTest.run(screenContext, params, useParentCollector: true);  
    screenContext.popScreen();    
    if(terminalScreen != null && originalScreenID != terminalScreen) {
      await screenContext.pauseForRender();
    } 
    return keepSynchronous();  
  }

  Future<void> runWidgetTest(AFTestID widgetTestId, AFScreenID originScreen, {AFScreenID terminalScreen, dynamic params, AFTestID queryResults}) async {
    _installQueryResults(queryResults);
    final widgetTest = AFibF.widgetTests.findById(widgetTestId);
    screenContext.pushScreen(originScreen);
    await widgetTest.run(screenContext, params, useParentCollector: true);  
    screenContext.popScreen();    
  }

  Future<void> tapNavigateFromTo({
    @required dynamic tap,
    @required AFScreenID startScreen,
    AFScreenID endScreen,
    bool verifyScreen = true
  }) {
      return onScreen(startScreen: startScreen, endScreen: endScreen, verifyScreen: verifyScreen, body: (AFScreenTestExecute ste) async {
        await ste.tap(tap);

        return ste.keepSynchronous();
      });
  }

  Future<void> tapOpenDrawer({
    @required dynamic tap,
    @required AFScreenID startScreen,
    @required AFScreenID drawerId
  }) {
    return tapNavigateFromTo(tap: tap, startScreen: startScreen, endScreen: drawerId, verifyScreen: false);
  }

  Future<void> onDrawer({
    @required AFScreenID drawerId, 
    AFScreenID endScreen, 
    AFTestID queryResults, 
    Function(AFScreenTestExecute) body,
  }) {
    return onScreen(
      startScreen: drawerId,
      endScreen: endScreen,
      queryResults: queryResults,
      body: body,
      verifyScreen: false
    );
  }

  Future<void> onScreen({
    @required AFScreenID startScreen, 
    AFScreenID endScreen, 
    AFTestID queryResults, 
    Function(AFScreenTestExecute) body,
    bool verifyScreen = true
  }) async {
    if(verifyScreen) {
      AFibF.testOnlyVerifyActiveScreen(startScreen);
    }
    if(endScreen == null) {
      endScreen = startScreen;
    }

    _installQueryResults(queryResults);
    await screenContext.underScreen(startScreen, () async {
      AFibD.logTest?.d("Starting underScreen");

      final fut = body(screenContext);
      await fut;
      return screenContext.keepSynchronous();
    });
    AFibD.logTest?.d("Finished underscreen");

    await screenContext.pauseForRender();
    if(verifyScreen) {
      AFibF.testOnlyVerifyActiveScreen(endScreen);
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

  Future<void> populateElementCollector(AFScreenTestWidgetCollector elementCollector) {
    return body(AFMultiScreenTestWidgetCollector(elementCollector), param);
  }
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

  void execute({ AFMultiScreenTestBodyExecuteFunc body, AFTestSectionID id, dynamic param}) async {
    sections.add(AFMultiScreenStateTestBodyWithParam(id: id, body: body, param: param));
  }  

  Future<void> populateWidgetCollector() async {
    for(final section in sections) {
      await section.populateElementCollector(elementCollector);
    }
    return null;
  }

  void openTestDrawer() {
    final scaffold = elementCollector.findScaffoldState(AFibF.testOnlyActiveScreenId);
    scaffold?.openEndDrawer();
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
    String title,
    @required List<AFNavigatePushAction> initialPath,
    @required AFTestID stateTestId,
  }) {
    AFMultiScreenStatePrototypeTest instance = AFMultiScreenStatePrototypeTest(
      id: id,
      title: title,
      initialPath: initialPath,
      stateTestId: stateTestId,
      body: AFMultiScreenStateTestBody.create(this, initialPath.last.screen, id)
    );
    stateTests.add(instance);
    return instance.body;
  }

  List<AFMultiScreenStatePrototypeTest> get all {
    return stateTests;
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
