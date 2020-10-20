

import 'dart:async';
import 'package:quiver/core.dart';

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
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

/// A superclass that declares all the methods which select specific widgets.
/// This is used by [AFScreenWidgetSelectorCollector] to determine which widgets
/// it needs to track for each test.
abstract class AFScreenTestWidgetSelector extends AFBaseTestExecute {
  
}

/// A utility class used to pass 
abstract class AFWidgetSelector {
  final elements = <Element>[];
  AFScreenTestWidgetCollectorScrollableSubpath parentScrollable;

  void add(Element elem) {
    elements.add(elem);
  }

  bool contains(Element elem) {
    return elements.contains(elem);
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

  Element activeElementForPath(List<Element> elems) {
    return elems.last;
  }

  bool matches(Element elem);
}

class AFKeySelector extends AFWidgetSelector {
  Key key;
  AFKeySelector(String keyStr) {
    key = Key(keyStr);
  }

  factory AFKeySelector.fromWidget(AFWidgetID wid) {
    return AFKeySelector(wid.code);
  }

  bool matches(Element elem) {
    return elem.widget.key == key;
  }

  bool operator==(dynamic o) {
    return o is AFKeySelector && o.key == key;
  }

  int get hashCode {
    return key.hashCode;
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

  int get hashCode {
    return widgetType.hashCode;
  }
}

class AFIconDataSelector extends AFWidgetSelector {
  IconData data;
  AFIconDataSelector(this.data);

  bool matches(Element elem) {
    final widget = elem.widget;
    if(widget is Icon) {
      return widget.icon == data;
    }
    return false;
  }

  bool operator==(dynamic o) {
    return o is AFIconDataSelector && o.data == this.data;
  }

  int get hashCode {
    return data.hashCode;
  }
}



class AFMultipleWidgetSelector extends AFWidgetSelector {
  final selectors = <AFWidgetSelector>[];
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

    for(var i = 0; i < selectors.length; i++) {
      final l = selectors[i];
      final r = o.selectors[i];
      if(l != r) {
        return false;
      }
    }
    return true;
  }

  int get hashCode {
    return selectors.hashCode;
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

  int get hashCode {
    return hash2(selector.hashCode, containsText.hashCode);
  }
}


class AFSparsePathWidgetSelector extends AFWidgetSelector {
  final  List<AFWidgetSelector> pathSelectors;

  /// By default, 0 selects the element matched by the final selector to operate on.
  /// However, if you want to operate on the element matched by an earlier selector,
  /// specific a positive number (e.g. 1 is the next to last selector/element, etc)
  final int selectorsFromLast;

  AFSparsePathWidgetSelector(this.pathSelectors, { this.selectorsFromLast = 0 });

  factory AFSparsePathWidgetSelector.createEmpty() {
    return AFSparsePathWidgetSelector(<AFWidgetSelector>[]);
  }

  factory AFSparsePathWidgetSelector.createFrom(List<dynamic> selectors) {
    final sels = <AFWidgetSelector>[];
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

    if(!lastSelector.matches(lastPath)) {
      return false;
    }

    // if the last matches, then go up the path making sure that we can
    // find all the other path selectors.
    var curPath = path.length - 2;
    var curSel = pathSelectors.length - 2;
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

  Element activeElementForPath(List<Element> elems) {
    var matchedSels = 0;
    for(var i = elems.length-1; i >= 0; i--) {
      var curSel = pathSelectors.length - 1 - matchedSels;
      final elem = elems[i];
      final sel = pathSelectors[curSel];
      if(sel.matches(elem)) {
        if(this.selectorsFromLast == matchedSels) {
          return elem;
        }
        matchedSels++;
      }
    }
    return null;
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

      for(var i = 0; i < pathSelectors.length; i++) {
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

  int get hashCode {
    return pathSelectors.hashCode;
  }
}

abstract class AFScreenTestExecute extends AFScreenTestWidgetSelector {
  AFTestID testId;
  final underPaths = <AFSparsePathWidgetSelector>[];
  final activeScreenIDs = <AFScreenID>[];
  
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

  Future<void> matchOneWidget(dynamic selector) {
    return visitNWidgets(selector, 1, extraFrames: 1);
  }  

  Future<void> matchMissingWidget(dynamic selector) {
    return visitNWidgets(selector, 0, extraFrames: 1, scrollIfMissing: false);
  }

  /// Any operations applied within the [underHere] callback operate on 
  /// widgets which are nested under [selector].
  /// 
  /// In addition to passing a standard [selector], like a AFWidgetID, you can also
  /// pass in a list of selectors.  If you do so, then the operation takes place
  /// under a sparse-path containing all the items in the list.
  Future<void> underWidget(dynamic selector, Future<void> Function() underHere);
  Future<void> visitNWidgets(dynamic selector, int n, {int extraFrames = 0, bool scrollIfMissing });

  Future<void> matchTextEquals(dynamic selector, String text) {
    return matchWidgetValue(selector, ft.equals(text), extraFrames: 1);
  }

  Future<void> matchText(dynamic selector, ft.Matcher matcher) {
    return matchWidgetValue(selector, matcher, extraFrames: 1);
  }

  Future<void> underScreen(AFScreenID screen, Function underHere) async {
    final shouldPush = true; //activeScreenIDs.isEmpty || activeScreenIDs.last != screen;
    if(shouldPush) {
      pushScreen(screen);
      await pauseForRender();
    }
    
    // the situation here is something like:
    // e.underWidget(WidgetID.myWidgetID) {
    //   e.tapWithPopup(..., () {
    //      // here, we aren't under myWidgetID any more.
    //   })
    // })
    await underHere();

    if(shouldPush) {
      popScreen();
    }
    return keepSynchronous();
  }

  void pushScreen(AFScreenID screen) {
    activeScreenIDs.add(screen);
    underPaths.add(null);
  }

  void popScreen() {
    activeScreenIDs.removeLast();
    underPaths.removeLast();
  }

  /// Used to tap on an element that opens a popup of [popupScreenType].
  /// 
  /// You can operate on the controls in the popup from within [underHere]
  Future<void> tapOpenPopup(dynamic selectorTap, final AFScreenID popupScreenId, Future<void> Function() underHere) async {
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
  Future<void> matchChipSelected(dynamic selector, {bool isSel}) {
    return matchWidgetValue(selector, ft.equals(isSel), extraFrames: 1);
  }

  Future<void> visitWidget(dynamic selector, Function(Element elem) onFound, { int extraFrames = 0 });
  Future<void> visitWidgets(dynamic selector, Function(List<Element>) onFound, { int extraFrames = 0 });

  Future<void> matchWidgetValue(dynamic selector, ft.Matcher matcher, { int extraFrames = 0 });

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

    for(var i = 0; i < elements.length; i++) {
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

  Future<void> pauseForRender();
  void addError(String error, int depth);
}

abstract class AFSingleScreenTestExecute extends AFScreenTestExecute {
  AFSingleScreenTestExecute(AFTestID testId): super(testId);

  AFScreenID get activeScreenId {
    if(activeScreenIDs.isNotEmpty) {
      return activeScreenIDs.last;
    }

    return test.screenId;
  }
}

class AFScreenTestBody {
  final AFReusableScreenTestBodyExecuteDelegate3<dynamic, dynamic, dynamic> body;
  final AFScreenTestWidgetCollector elementCollector;
  final dynamic param1;
  final dynamic param2;
  final dynamic param3;
  
  AFScreenTestBody({
    @required this.body, 
    @required this.elementCollector, 
    @required this.param1,
    @required this.param2,
    @required this.param3,
  });

  bool get isReusable {
    return param1 != null;
  }

  Future<void> populateElementCollector() {
    return body(elementCollector, param1, param2, param3); 
  }

  ScaffoldState findScaffoldState(AFScreenID screenId) {
    return elementCollector.findScaffoldState(screenId);
  }
}

class AFSingleScreenTestBody {
  final AFTestID testId;
  final List<AFScreenTestBody> sections;

  AFSingleScreenTestBody(this.testId, { this.sections });

  factory AFSingleScreenTestBody.createReusable(AFSingleScreenTestExecute elementCollector, AFReusableScreenTestBodyExecuteDelegate3<dynamic, dynamic, dynamic> body, {
    dynamic param1,
    dynamic param2,
    dynamic param3 }) {
    final sections = <AFScreenTestBody>[];
    sections.add(AFScreenTestBody(elementCollector: elementCollector, param1: param1, param2: param2, param3: param3, body: body));
    return AFSingleScreenTestBody(null, sections: sections);
  }

  bool get isNotEmpty { 
    return sections.isNotEmpty;
  }

  void execute(AFScreenTestBodyExecuteDelegate body) async {
    final collector = AFScreenTestWidgetCollector(this.testId);
    // in the first section, always add a scaffold widget collector.
  
    sections.add(AFScreenTestBody(elementCollector: collector, param1: null, param2: null, param3: null, body: (sse, p1, p2, p3) async {
      await body(sse);
    }));
  }

  bool get isReusable {
    for(final section in sections) {
      if(section.isReusable) {
        return true;
      }
    }
    return false;
  }

  void executeReusable(AFSingleScreenTests tests, AFSingleScreenTestID bodyId, {
    dynamic param1,
    dynamic param2,
    dynamic param3
  }) {
    final collector = AFScreenTestWidgetCollector(this.testId);
    final body = tests.findReusable(bodyId);
    if(body == null) {
      throw AFException("The reusable test $bodyId must be defined using tests.defineReusable");
    }

    sections.add(AFScreenTestBody(elementCollector: collector, body: body.body, param1: param1, param2: param2, param3: param3));    
  }


  Future<void> populateWidgetCollector() async {
    for(final section in sections) {
      await section.populateElementCollector();
    }
    return null;
  }

  void _checkFutureExists(Future<void> test) {
    if(test == null) {
      throw AFException("Test section failed to return a future.  You might be missing an async or await");
    }
  }

  void openTestDrawer() {
    final scaffoldState = sections.first.findScaffoldState(AFibF.testOnlyActiveScreenId);
    scaffoldState?.openEndDrawer();
  }

  Future<void> run(AFScreenTestExecute context, { dynamic param1, dynamic param2, dynamic param3, Function onEnd, bool useParentCollector = false }) async {
    var sectionGuard = 0;
    for(var i = 0; i < sections.length; i++) {
      final section = sections[i];
      sectionGuard++;
      if(sectionGuard > 1) {
        throw AFException("Test section $i is missing an await!");
      }
      if(!useParentCollector) {
        context.setCollector(section.elementCollector);
      }
      if(param1 == null) {
        param1 = section.param1;
        param2 = section.param2;
        param3 = section.param3;
      }

      final fut = section.body(context, param1, param2, param3);
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
  final selectors = <AFWidgetSelector>[];
  final scrollables = <AFScreenTestWidgetCollectorScrollableSubpath>[];
  ScaffoldState scaffoldState;

  AFScreenTestWidgetCollectorScreen(this.screenId);

  void addSelector(AFWidgetSelector sel) {
    selectors.add(sel);
  }
  
  bool get hasScaffoldState {
    return scaffoldState != null;
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
      return <Element>[];
    }
    
    // if we didn't find the selector, and we are under a scrollable widget,
    // it might be that the widget is not in view, try systematically
    // scrolling the widget, and re-building our selectors under that point.
    return scrollUntilFound(selector, );
  }

  // Go though all the children of [current], having the parent path [currentPath],
  // and add path entries for any widgets with keys.
  void populateChildren(Element currentElem, List<Element> currentPath, AFScreenTestWidgetCollectorScrollableSubpath parentScrollable, { bool underScaffold }) {

    // add the current element.
    currentPath.add(currentElem);

    final widget = currentElem.widget;
    if(widget is Scrollable) {
      parentScrollable = addScrollableAt(currentPath);
    }

    if(underScaffold && !hasScaffoldState) {
      final scaffoldState = Scaffold.of(currentElem);
      if(scaffoldState != null) {
        this.scaffoldState = scaffoldState;
      }
    }

    // go through all the selectors, and see if any of them match.
    for(final selector in selectors) {
      if(selector.matchesPath(currentPath)) {
        final activeElement = selector.activeElementForPath(currentPath);
        if(!selector.contains(activeElement)) {
          selector.add(activeElement);
        }
      
        if(parentScrollable != null) {
          selector.parentScrollable = parentScrollable;
        }
      }
    } 

    // do this same process recursively on the childrne.
    currentElem.visitChildren((child) {
      final nowUnderScaffold = underScaffold || currentElem.widget is Scaffold;
      populateChildren(child, currentPath, parentScrollable, underScaffold: nowUnderScaffold);
    });

    // maintain the path as we go back up.
    currentPath.removeLast();
  }

  Future<List<Element>> scrollUntilFound(AFWidgetSelector selector) async {
    for(final scrollable in scrollables) {
      final found = await scrollOneUntilFound(scrollable, selector);
      if(found != null) {
        return found;
      }
    }
    return <Element>[];
  }

  Future<List<Element>> scrollOneUntilFound(AFScreenTestWidgetCollectorScrollableSubpath source, AFWidgetSelector selector) async {
    final pathTo = source.pathTo;
    final elemScrollable = pathTo.last;
    final Scrollable widgetScrollable = elemScrollable.widget;
    final controller = widgetScrollable.controller;

    var currentPosition = 0.0;
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
      populateChildren(elemScrollable, pathTo, source, underScaffold: true);
    
      // see if we found the widget at this position.
      final currentResults = await findElementsForSelector(selector, scrollIfMissing: false);
      if(currentResults.isNotEmpty) {
        return currentResults;
      }

      // if we got to a point where our current offset is less than our desired offset, we must have scrolled
      // all the way to the bottom, in that case just return the empty set.
      if(controller.offset <= currentPosition) {
        return <Element>[];
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

  final screens = <AFScreenID, AFScreenTestWidgetCollectorScreen>{};


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

  Future<void> visitWidget(dynamic selector, Function(Element) onFound, { int extraFrames = 0 }) {
    addSelector(selector);
    return null;
  }

  Future<void> visitWidgets(dynamic selector, Function(List<Element>) onFound, { int extraFrames = 0 }) {
    addSelector(selector);
    return ks;
  }

  
  Future<void> visitNWidgets(dynamic selector, int n, {int extraFrames = 0, bool scrollIfMissing}) {
    addSelector(selector);
    return keepSynchronous();
  }

  Future<void> matchWidgetValue(dynamic selector, ft.Matcher matcher, { int extraFrames = 0 }) {
    addSelector(selector);
    return keepSynchronous();
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

    final currentPath = <Element>[];
    screenInfo.populateChildren(currentInfo.element, currentPath, null, underScaffold: false);
    return screenInfo;
  }

  AFScreenTestWidgetCollectorScreen _findOrCreateScreenInfo(AFScreenID screenId) {
    var screenInfo = screens[screenId];
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

  Future<void> visitWidget(dynamic selector, Function(Element elem) onFound, { int extraFrames = 0 }) async {
    final elems = await elementCollector.findWidgetsFor(selector);
    this.expect(elems.length, ft.equals(1), extraFrames: extraFrames+1);
    if(elems.length > 0) {
      onFound(elems.first);
    }
    return keepSynchronous();
  }

  Future<void> visitWidgets(dynamic selector, Function(List<Element>) onFound, { int extraFrames = 0 }) async {
    final elems = await elementCollector.findWidgetsFor(selector);
    onFound(elems);
    return keepSynchronous();
  }

  Future<void> visitNWidgets(dynamic selector, int n, {int extraFrames = 0, bool scrollIfMissing = true}) async {
    final elems = await elementCollector.findWidgetsFor(selector, scrollIfMissing: scrollIfMissing);
    this.expect(elems.length, ft.equals(n), extraFrames: extraFrames+1);
    return keepSynchronous();
  }

  Future<void> matchWidgetValue(dynamic selectorDyn, ft.Matcher matcher, { String extractType = AFExtractWidgetAction.extractPrimary, int extraFrames = 0 }) async {
    final selector = AFScreenTestWidgetCollector.createSelector(null, selectorDyn);
    final elems = await elementCollector.findWidgetsFor(selector);
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
    final elems = await elementCollector.findWidgetsFor(selector);
    if(maxWidgets > 0 && maxWidgets < elems.length) {
      throw AFException("Expected at most $maxWidgets widget for selector $selector, found ${elems.length} widgets");
    }
    if(elems.isEmpty) {
      throw AFException("applyWidgetValue, no widget found with selector $selectorDyn");
    }

    final elem = elems.first;
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
      final AFAsyncQuery query = AFibF.testOnlyRecentActions.firstWhere( (act) => (act is AFAsyncQuery), orElse: () => null );
      if(query == null) {
        throw AFException("Passed in verifyQuery, but there was not an AFAsyncQuery dispatched by action");
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
    return null;
  }

  void addError(String desc, int depth) {
    final err = AFBaseTestExecute.composeError(desc, depth);
    dispatcher.dispatch(AFPrototypeScreenTestAddError(this.testId, err));
    AFibD.log?.e(err);
  }

  bool addPassIf({bool test}) {
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
  bool get isReusable { return false; }
  void startScreen(AFDispatcher dispatcher);
  Future<void> run(AFScreenTestContext context, { Function onEnd});
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
    @required AFSingleScreenTestID id,
    @required this.data,
    @required this.param,
    @required this.screenId,
    @required this.body,
    String title
  }): super(id: id, title: title);

  bool get hasBody {
    return body.isNotEmpty;
  }

  bool get isReusable {
    return body.isReusable;
  }

  Future<void> populateWidgetCollector() {
    return body?.populateWidgetCollector();
  }

  void startScreen(AFDispatcher dispatcher) {
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(this));
    dispatcher.dispatch(AFPrototypeSingleScreenScreen.navigatePush(this, id: this.id));    
  }

  Future<void> run(AFScreenTestExecute context, { dynamic param1, dynamic param2, dynamic param3, Function onEnd, bool useParentCollector = false}) {
    return body.run(context, onEnd: onEnd, useParentCollector: useParentCollector, param1: param1, param2: param2, param3: param3);
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

  void openTestDrawer() {
    body.openTestDrawer();
  }
}


class AFWidgetPrototypeTest extends AFScreenPrototypeTest {
  final dynamic data;
  final AFSingleScreenTestBody body;
  final AFCreateConnectedWidgetDelegate createConnectedWidget;
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
  
  Future<void> run(AFScreenTestExecute context, { Function onEnd, bool useParentCollector = false}) {
    return body.run(context, onEnd: onEnd, useParentCollector: useParentCollector);
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

 
/// All the information necessary to render a single screen for
/// prototyping and testing.
class AFConnectedWidgetPrototypeTest extends AFWidgetPrototypeTest {
  final AFRouteParam param;

  AFConnectedWidgetPrototypeTest({
    @required AFTestID id,
    @required dynamic data,
    @required this.param,
    @required AFCreateConnectedWidgetDelegate createConnectedWidget,
    @required AFSingleScreenTestBody body,
    String title
  }): super(id: id, title: title, body: body, data: data, createConnectedWidget: createConnectedWidget);
}


/// The information necessary to start a test with a baseline state
/// (determined by a state test) and an initial screen/route.
class AFWorkflowStatePrototypeTest extends AFScreenPrototypeTest {
  final List<AFNavigatePushAction> initialPath;
  final AFStateTestID stateTestId;
  final AFWorkflowStateTestBody body;

  AFWorkflowStatePrototypeTest({
    @required AFWorkflowTestID id,
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

  static void initializeMultiscreenPrototype(AFDispatcher dispatcher, AFWorkflowStatePrototypeTest test) {
    dispatcher.dispatch(AFResetToInitialStateAction());
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(test));

    // lookup the test.
    final testImpl = AFibF.stateTests.findById(test.stateTestId);
    
    // then, execute the desired state test to bring us to our desired state.
    final store = AFibF.testOnlyStore;
    final mainDispatcher = AFStoreDispatcher(store);    
    final stateDispatcher = AFStateScreenTestDispatcher(mainDispatcher);

    final stateTestContext = AFStateTestContext(testImpl, store, stateDispatcher, isTrueTestContext: false);
    AFibF.testOnlyShouldSuppressNavigation = true;
    testImpl.execute(stateTestContext);
    AFibF.testOnlyShouldSuppressNavigation = false;


    if(stateTestContext.errors.hasErrors) {
    }

    // then, navigate into the desired path.
    for(final push in test.initialPath) {
      dispatcher.dispatch(push);
    }
  }


  Future<void> run(AFScreenTestContext context, { Function onEnd}) {
    return body.run(context, onEnd: onEnd);
  }

  void onDrawerReset(AFDispatcher dispatcher) {
    //throw UnimplementedError();
  }

  Future<void> onDrawerRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext, AFSingleScreenTestState state, Function onEnd) async {
    final testContext = prepareRun(dispatcher, prevContext);
    return run(testContext, onEnd: onEnd);
  }

}


/// Used to register connected or unconnected widget tests.
class AFWidgetTests<TState> {
  final _connectedTests = <AFWidgetPrototypeTest>[];
  
  AFSingleScreenTestBody addConnectedPrototype({
    @required AFTestID   id,
    @required AFCreateConnectedWidgetDelegate createConnectedWidget,
    @required dynamic data,
    @required AFRouteParam param,
    String title
  }) {
    final instance = AFConnectedWidgetPrototypeTest(
      id: id,
      data: data,
      param: param,

      createConnectedWidget: createConnectedWidget,
      title: title,
      body: AFSingleScreenTestBody(id, sections: <AFScreenTestBody>[])
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

@immutable
class AFSingleScreenReusableBody {
  final AFScreenID screen;
  final AFReusableScreenTestBodyExecuteDelegate3<dynamic, dynamic, dynamic> body;

  AFSingleScreenReusableBody(this.screen, this.body);
}

/// This class is used to create canned versions of screens and widget populated
/// with specific data for testing and prototyping purposes.
class AFSingleScreenTests<TState> {
  
  final _singleScreenTests = <AFSingleScreenPrototypeTest>[];
  final extractors = <AFExtractWidgetAction>[];
  final applicators = <AFApplyWidgetAction>[];
  final reusable = <AFSingleScreenTestID, AFSingleScreenReusableBody>{};

  AFSingleScreenTests() {
    registerApplicator(AFFlatButtonAction());
    registerApplicator(AFRaisedButtonAction());
    registerApplicator(AFTapChoiceChip());
    registerApplicator(AFSetChoiceChip());
    registerApplicator(AFApplyTextTextFieldAction());
    registerApplicator(AFApplyTextAFTextFieldAction());
    registerApplicator(AFRichTextGestureTapAction());
    registerApplicator(AFApplyCupertinoPicker());
    registerApplicator(AFIconButtonAction());
    registerApplicator(AFListTileTapAction());
    registerApplicator(AFGestureDetectorTapAction());
    registerApplicator(AFDismissibleSwipeAction());
    registerApplicator(AFSwitchTapAction());

    registerExtractor(AFSelectableChoiceChip());
    registerExtractor(AFExtractTextTextAction());
    registerExtractor(AFExtractTextTextFieldAction());
    registerExtractor(AFExtractTextAFTextFieldAction());
    registerExtractor(AFExtractRichTextAction());
    
  }

  List<AFSingleScreenPrototypeTest> get all {
    return _singleScreenTests;
  }

  void defineReusable1<TP1>(AFSingleScreenTestID id, AFScreenID screen, AFReusableScreenTestBodyExecuteDelegate1<TP1> body) {
    if(reusable.containsKey(id)) {
      throw AFException("Duplicate definition for $id");
    }

    reusable[id] = AFSingleScreenReusableBody(screen, (sse, p1, p2, p3) async {
      TP1 tp1 = p1;
      await body(sse, tp1);
    });
  }

  void defineReusable2<TP1, TP2>(AFSingleScreenTestID id, AFScreenID screen, AFReusableScreenTestBodyExecuteDelegate2<TP1, TP2> body) {
    if(reusable.containsKey(id)) {
      throw AFException("Duplicate definition for $id");
    }

    reusable[id] = AFSingleScreenReusableBody(screen, (sse, p1, p2, p3) async {
      TP1 tp1 = p1;
      TP2 tp2 = p2;
      await body(sse, tp1, tp2);
    });
  }

  void defineReusable3<TP1, TP2, TP3>(AFSingleScreenTestID id, AFScreenID screen, AFReusableScreenTestBodyExecuteDelegate3<TP1, TP2, TP3> body) {
    if(reusable.containsKey(id)) {
      throw AFException("Duplicate definition for $id");
    }

    reusable[id] = AFSingleScreenReusableBody(screen, (sse, p1, p2, p3) async {
      TP1 tp1 = p1;
      TP2 tp2 = p2;
      TP3 tp3 = p3;
      await body(sse, tp1, tp2, tp3);
    });
  }

  AFSingleScreenReusableBody findReusable(AFSingleScreenTestID id) {
    return reusable[id];
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
    @required AFSingleScreenTestID   id,
    @required dynamic data,
    @required dynamic param,
    String title
  }) {
    final instance = AFSingleScreenPrototypeTest(
      id: id,
      data: data,
      param: param,
      screenId: screenId,
      title: title,
      body: AFSingleScreenTestBody(id, sections: <AFScreenTestBody>[])
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



  void registerData(dynamic id, dynamic data) {
    AFibF.testData.register(id, data);
  }

  dynamic findData(dynamic id) {
    return AFibF.testData.find(id);
  }

  bool addPassIf({bool test}) {
    if(test) {
      
    }
    return test;
  }
}

abstract class AFWorkflowTestExecute {
  Future<void> tapNavigateFromTo({
    @required dynamic tap,
    @required AFScreenID startScreen,
    AFScreenID endScreen,
    bool verifyScreen = true
  });

  Future<void> runScreenTest(AFSingleScreenTestID screenTestId, {
    dynamic param1,
    dynamic param2,
    dynamic param3,
    AFScreenID terminalScreen, 
    AFStateTestID queryResults});
  Future<void> runWidgetTest(AFTestID widgetTestId, AFScreenID originScreen, {AFScreenID terminalScreen, AFTestID queryResults});
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


class AFWorkflowTestWidgetCollector extends AFWorkflowTestExecute {
  final AFScreenTestWidgetCollector elementCollector;

  AFWorkflowTestWidgetCollector(this.elementCollector);

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


  Future<void> runScreenTest(AFSingleScreenTestID screenTestId, {AFScreenID terminalScreen, AFTestID queryResults, dynamic param1, dynamic param2, dynamic param3}) async {
    await internalRunScreenTest(screenTestId, elementCollector, elementCollector, param1, param2, param3);
  }

  static Future<AFScreenID> internalRunScreenTest(AFSingleScreenTestID screenTestId, AFSingleScreenTestExecute sse, AFScreenTestWidgetCollector elementCollector, dynamic param1, dynamic param2, dynamic param3 ) async {
    final screenTest = AFibF.screenTests.findById(screenTestId);
    var screenId;
    var body;
    if(screenTest != null) {
      screenId = screenTest.screenId;
      body = screenTest.body;
    } else {
      // this might be a re-usable screen test.
      final reusable = AFibF.screenTests.findReusable(screenTestId);
      if(reusable == null) {
        throw AFException("Screen test $screenTestId is not defined");
      }
      screenId = reusable.screen;
      body = AFSingleScreenTestBody.createReusable(elementCollector, reusable.body);
    }

    sse.pushScreen(screenId);
    await body.run(sse, useParentCollector: true, param1: param1, param2: param2, param3: param3);
    sse.popScreen();
    return screenId;
  }

  Future<void> runWidgetTest(AFTestID widgetTestId, AFScreenID originScreen, {AFScreenID terminalScreen, AFTestID queryResults, }) async {
    final widgetTest = AFibF.widgetTests.findById(widgetTestId);
    elementCollector.pushScreen(originScreen);
    await widgetTest.run(elementCollector, useParentCollector: true);
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


class AFWorkflowTestContext extends AFWorkflowTestExecute {
  final AFScreenTestContext screenContext;

  AFWorkflowTestContext(this.screenContext);  

  /// Execute the specified screen tests, with query-responses provided by the specified state test.
  Future<void> runScreenTest(AFTestID screenTestId,  {AFScreenID terminalScreen, dynamic param1, dynamic param2, dynamic param3, AFTestID queryResults}) async {
    _installQueryResults(queryResults);
    
    final originalScreenId = await AFWorkflowTestWidgetCollector.internalRunScreenTest(screenTestId, screenContext, screenContext.elementCollector, param1, param2, param3);


    /*
    final screenTest = AFibF.screenTests.findById(screenTestId);
    final originalScreenID = screenTest.screenId;
    screenContext.pushScreen(originalScreenID);
    await screenTest.run(screenContext, useParentCollector: true, param: param);  
    screenContext.popScreen();    

    */

    if(terminalScreen != null && originalScreenId != terminalScreen) {
      await screenContext.pauseForRender();
    } 
    return keepSynchronous();  
  }

  Future<void> runWidgetTest(AFTestID widgetTestId, AFScreenID originScreen, {AFScreenID terminalScreen, AFTestID queryResults}) async {
    _installQueryResults(queryResults);
    final widgetTest = AFibF.widgetTests.findById(widgetTestId);
    screenContext.pushScreen(originScreen);
    await widgetTest.run(screenContext, useParentCollector: true);  
    screenContext.popScreen();    
  }

  Future<void> tapNavigateFromTo({
    @required dynamic tap,
    @required AFScreenID startScreen,
    AFScreenID endScreen,
    bool verifyScreen = true
  }) {
      return onScreen(startScreen: startScreen, endScreen: endScreen, verifyScreen: verifyScreen, body: (ste) async {
        await ste.tap(tap);
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
    AFStateTestContext.currentTest = stateTestContext;    
  }

  Future<void> keepSynchronous() {
    return null;
  }

}

class AFWorkflowStateTestBodyWithParam {
  final AFWorkflowTestBodyExecuteDelegate body;
  AFWorkflowStateTestBodyWithParam(this.body);

  Future<void> populateElementCollector(AFScreenTestWidgetCollector elementCollector) {
    return body(AFWorkflowTestWidgetCollector(elementCollector));
  }
}

class AFWorkflowStateTestBody {
  final AFWorkflowStateTests tests;
  final AFScreenTestWidgetCollector elementCollector;
  final AFScreenID initialScreenId;
  final sections = <AFWorkflowStateTestBodyWithParam>[];

  AFWorkflowStateTestBody(this.tests, this.initialScreenId, this.elementCollector);

  factory AFWorkflowStateTestBody.create(AFWorkflowStateTests tests, AFScreenID initialScreenId, AFTestID testId) {
    return AFWorkflowStateTestBody(tests, initialScreenId, AFScreenTestWidgetCollector(testId));
  }

  void execute(AFWorkflowTestBodyExecuteDelegate body) async {
    sections.add(AFWorkflowStateTestBodyWithParam(body));
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

  Future<void> run(AFScreenTestContext context, { Function onEnd }) async {
    context.setCollector(elementCollector);
    final e = AFWorkflowTestContext(context);
    for(final section in sections) {
      await section.body(e);
    }

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
class AFWorkflowStateTests {
  final stateTests = <AFWorkflowStatePrototypeTest>[];

  AFWorkflowStateTestBody addPrototype({
    @required AFWorkflowTestID id,
    String title,
    @required List<AFNavigatePushAction> initialPath,
    @required AFTestID stateTestId,
  }) {
    final instance = AFWorkflowStatePrototypeTest(
      id: id,
      title: title,
      initialPath: initialPath,
      stateTestId: stateTestId,
      body: AFWorkflowStateTestBody.create(this, initialPath.last.screen, id)
    );
    stateTests.add(instance);
    return instance.body;
  }

  List<AFWorkflowStatePrototypeTest> get all {
    return stateTests;
  }

  AFWorkflowStatePrototypeTest findById(AFTestID id) {
    for(final test in stateTests) {
      if(test.id == id) {
        return test;
      }
    }
    return null;
  }

  

}
