

import 'dart:async';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:quiver/core.dart';
import 'package:meta/meta.dart';

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_prototype_widget_screen.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_widget_actions.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

typedef AFTestScreenExecuteDelegate = Future<void> Function(AFScreenTestExecute ste);
typedef AFVerifyReturnValueDelegate = void Function(dynamic value);

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

  String toString() {
    return "AFKeySelector($key)";
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
      selectors.add(AFWidgetSelector.createSelector(null, item));
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
    final sel = AFWidgetSelector.createSelector(null, selector);
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
      sels.add(AFWidgetSelector.createSelector(null, selector));
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

abstract class AFScreenTestExecute extends AFBaseTestExecute {
  AFTestID testId;
  final underPaths = <AFSparsePathWidgetSelector>[];
  final activeScreenIDs = <AFScreenID>[];
  int slowOnScreenMillis = 0;
  
  AFScreenTestExecute(this.testId);

  AFScreenPrototypeTest get test {
    AFScreenPrototypeTest found = AFibF.g.screenTests.findById(this.testId);
    if(found == null) {
      found = AFibF.g.widgetTests.findById(this.testId);
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
  Future<void> underWidget(dynamic selector, Future<void> Function() withinHere) async {
    var path = activeSelectorPath;
    if(path == null) {
      path = AFSparsePathWidgetSelector.createEmpty();
    }
    var next = path;
    if(selector is List) {
      for(final sel in selector) {
          next =  AFWidgetSelector.createSelector(next, sel);
      }
    } else {
      next = AFWidgetSelector.createSelector(next, selector);
    }
    underPaths.add(next);
    await withinHere();
    underPaths.removeLast();
    return keepSynchronous();
  }

  Future<void> visitNWidgets(dynamic selector, int n, {int extraFrames = 0, bool scrollIfMissing });

  Future<void> matchTextEquals(dynamic selector, String text) {
    return matchWidgetValue(selector, ft.equals(text), extraFrames: 1);
  }

  Future<void> matchText(dynamic selector, ft.Matcher matcher) {
    return matchWidgetValue(selector, matcher, extraFrames: 1);
  }

  Future<void> matchSwitch(dynamic selector, { @required bool enabled }) {
    return matchWidgetValue(selector, ft.equals(enabled), extraFrames: 1);
  }

  Future<void> setSwitch(dynamic selector, { @required bool enabled }) {
    return setValue(selector, enabled, extraFrames: 1);
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

  /// Tap on the specified widget, then expect a dialog which you can interact with via the onDialog parameter.
  Future<void> tapExpectDialog(dynamic selectorTap, final AFScreenID dialogScreenId, AFTestScreenExecuteDelegate onDialog, {
    AFVerifyReturnValueDelegate verifyReturn
  }) async {
    await tap(selectorTap);
    await pauseForRender();
    
    await this.underScreen(dialogScreenId, () async {
      await onDialog(this);
      return keepSynchronous();
    });

    final result = AFibF.g.testOnlyDialogReturn[dialogScreenId];
    if(verifyReturn != null) {
      verifyReturn(result);
    }
    
    return null;

  }

  /// Tap on the specified widget, then expect a dialog which you can interact with via the onSheet parameter.
  Future<void> tapExpectModalBottomSheet(dynamic selectorTap, final AFScreenID dialogScreenId, AFTestScreenExecuteDelegate onSheet, {
    AFVerifyReturnValueDelegate verifyReturn
  }) async {
    await tap(selectorTap);
    await pauseForRender();
    
    await this.underScreen(dialogScreenId, () async {
      await onSheet(this);
      return keepSynchronous();
    });

    final result = AFibF.g.testOnlyBottomSheetReturn[dialogScreenId];
    if(verifyReturn != null) {
      verifyReturn(result);
    }
    
    return null;

  }

  /// Expect that a [Chip] is selected or not selected.
  /// 
  /// Note that in addition to the standard options, 
  /// the [selector] can be a list of other selectors.  With chips,
  /// it is very common to verify that several of them are on or off
  /// at the same time, and passing in a list is a concise way to do
  /// so.
  Future<void> matchChipSelected(dynamic selector, {@required bool selected}) {
    return matchWidgetValue(selector, ft.equals(selected), extraFrames: 1);
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

  Future<List<Element>> findWidgetsFor(dynamic selector, { bool scrollIfMissing = true}) async {
    if(slowOnScreenMillis > 0 && !AFibD.config.isWidgetTesterContext) {
      await Future<void>.delayed(Duration(milliseconds: slowOnScreenMillis));
    }
    final sel = AFWidgetSelector.createSelector(activeSelectorPath, selector);
    final info = AFibF.g.findTestScreen(activeScreenId);
    final currentPath = <Element>[];
    _populateChildrenDirect(info.element, currentPath, sel, null, underScaffold: false);
    return sel.elements;
  }

  /// A debugging utility which slows down every widget lookup in a test under the function [f].
  /// 
  /// This only works when debugging on-screen.   It can be used to make it easier to see what the test
  /// is doing.   This function is not intended to help resolve subtle timing issues.   If you are experiencing
  /// subtle timing issues, please review your code, and if the problem appears AFib-related, submit a bug.
  Future<void> debugSlowOnScreen(Future<void> Function() f, { int delayMillis = 500 }) async {
    slowOnScreenMillis = delayMillis;
    await f();
    slowOnScreenMillis = 0;
  }


  Future<void> keepSynchronous();
  Future<void> get ks { return keepSynchronous(); }
  Future<void> updateScreenData(dynamic data);
  void verifyPopupScreenId(AFScreenID screenId);

  Future<void> pauseForRender();
  void addError(String error, int depth);

  // Go though all the children of [current], having the parent path [currentPath],
  // and add path entries for any widgets with keys.
  void _populateChildrenDirect(Element currentElem, List<Element> currentPath, AFWidgetSelector selector, AFScreenTestWidgetCollectorScrollableSubpath parentScrollable, { bool underScaffold }) {

    // add the current element.
    currentPath.add(currentElem);

    /*
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
    */

    if(selector.matchesPath(currentPath)) {
      final activeElement = selector.activeElementForPath(currentPath);
      if(!selector.contains(activeElement)) {
        selector.add(activeElement);
      }
    
      if(parentScrollable != null) {
        selector.parentScrollable = parentScrollable;
      }
    }

    // do this same process recursively on the childrne.
    currentElem.visitChildren((child) {
      final nowUnderScaffold = underScaffold || currentElem.widget is Scaffold;
      _populateChildrenDirect(child, currentPath, selector, parentScrollable, underScaffold: nowUnderScaffold);
    });

    // maintain the path as we go back up.
    currentPath.removeLast();
  }

  /*
  AFScreenTestWidgetCollectorScrollableSubpath addScrollableAt(List<Element> path) {
    final result = AFScreenTestWidgetCollectorScrollableSubpath.create(path);
    scrollables.add(result);
    return result;
  }
  */

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
  final AFReusableScreenTestBodyExecuteDelegate3 body;
  final AFSingleScreenReusableBody bodyReusable;
  final String disabled;
  final dynamic param1;
  final dynamic param2;
  final dynamic param3;
  
  
  AFScreenTestBody({
    @required this.body, 
    @required this.bodyReusable,
    @required this.param1,
    @required this.param2,
    @required this.param3,
    @required this.disabled,
  });

  bool get isReusable {
    return bodyReusable != null;
  }

  AFID get sectionId {
    if(bodyReusable != null) {
      return bodyReusable.id;
    }
    return AFUITestID.smokeTest;
  }
}

class AFSingleScreenPrototype {
  final AFTestID testId;
  final AFScreenID screenId;
  final sections = <AFReusableTestID, AFScreenTestBody>{};

  AFSingleScreenPrototype(this.testId,  { this.screenId });

  factory AFSingleScreenPrototype.createReusable(AFReusableTestID reusableId, AFReusableScreenTestBodyExecuteDelegate3 body, {
    String disabled,
    dynamic param1,
    dynamic param2,
    dynamic param3 
  }) {
    final bodyTest = AFScreenTestBody(disabled: disabled, param1: param1, param2: param2, param3: param3, bodyReusable: null, body: body);
    final proto = AFSingleScreenPrototype(null);
    proto.addReusable(reusableId, bodyTest);
    return proto;
  }
  
  List<AFReusableTestID> get sectionIds {
    return sections.keys.toList();
  }

  bool get isNotEmpty { 
    return sections.isNotEmpty;
  }

  void addSmokeTest(AFScreenTestBody body) {
    if(sections.containsKey(AFReusableTestID.smokeTestId)) {
      throw AFException("You can only define a single smoke test for each prototype");
    }
    sections[AFReusableTestID.smokeTestId] = body;
  }

  void addReusable(AFReusableTestID reusableId, AFScreenTestBody body) {
    if(sections.containsKey(reusableId)) {
      throw AFException("Duplicate definition of reusable test $reusableId");
    }
    sections[reusableId] = body;
  }

  void defineSmokeTest(AFScreenTestBodyExecuteDelegate body, { String disabled }) async {
    // in the first section, always add a scaffold widget collector.
  
    addSmokeTest(AFScreenTestBody(disabled: disabled, param1: null, param2: null, param3: null, bodyReusable: null, body: (sse, p1, p2, p3) async {
      await body(sse);
    }));
  }

  bool get hasReusable {
    for(final section in sections.values) {
      if(section.isReusable) {
        return true;
      }
    }
    return false;
  }

  List<String> paramDescriptions(AFReusableTestID idSection) {
    final body = sections[idSection];
    if(body?.bodyReusable == null) {
      return  <String>[];
    }
    return body.bodyReusable.paramDescriptions;
  }

  void executeReusable(AFSingleScreenTests tests, AFReusableTestID bodyId, {
    dynamic param1,
    dynamic param2,
    dynamic param3
  }) {
    final body = tests.findReusable(bodyId);
    if(body == null) {
      throw AFException("The reusable test $bodyId must be defined using tests.defineReusable");
    }
    final bodyTest = AFScreenTestBody(disabled: null, body: body.body, bodyReusable: body, param1: param1, param2: param2, param3: param3);;
    addReusable(bodyId, bodyTest);
  }

  void _checkFutureExists(Future<void> test) {
    if(test == null) {
      throw AFException("Test section failed to return a future.  You might be missing an async or await");
    }
  }

  void openTestDrawer(AFReusableTestID id) {
    final info = AFibF.g.testOnlyMostRecentScreen;
    final scaffoldState = findScaffoldState(info.element, underScaffold: false);
    scaffoldState?.openEndDrawer();
  }

  static ScaffoldState findScaffoldState(Element elem, { bool underScaffold }) {
    var result;
    elem.visitChildren((child) {
      if(result == null && underScaffold) {
        result = Scaffold.of(child);
      }
      if(result == null) {
        final underScaffoldNow = underScaffold || child.widget is Scaffold;
        result = findScaffoldState(child, underScaffold: underScaffoldNow);
      }
    });
    return result;
  }

  Future<void> run(AFScreenTestExecute context, { dynamic param1, dynamic param2, dynamic param3, Function onEnd}) async {
    var sectionGuard = 0;
    var sectionPrev;
    for(final section in sections.values) {
      if(section.disabled != null) {
        context.markDisabled(section);
        continue; 
      }

      sectionGuard++;
      if(sectionGuard > 1) {
        throw AFException("Test section ${sectionPrev.id} is missing an await!");
      }
      sectionPrev = section;


      if(param1 == null) {
        param1 = section.param1;
        param2 = section.param2;
        param3 = section.param3;
      }

      context.startSection(section);
      final fut = section.body(context, param1, param2, param3);
      _checkFutureExists(fut);
      await fut;
      context.endSection(section);
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

abstract class AFScreenTestContext extends AFSingleScreenTestExecute {
  final AFDispatcher dispatcher;
  AFScreenTestContext(this.dispatcher, AFTestID testId): super(testId);
  AFTestID get testID { return this.testId; }

  Future<void> visitWidget(dynamic selector, Function(Element elem) onFound, { int extraFrames = 0 }) async {
    final elems = await findWidgetsFor(selector);
    this.expect(elems.length, ft.equals(1), extraFrames: extraFrames+1);
    if(elems.length > 0) {
      onFound(elems.first);
    }
    return keepSynchronous();
  }

  Future<void> visitWidgets(dynamic selector, Function(List<Element>) onFound, { int extraFrames = 0 }) async {
    final elems = await findWidgetsFor(selector);
    onFound(elems);
    return keepSynchronous();
  }

  Future<void> visitNWidgets(dynamic selector, int n, {int extraFrames = 0, bool scrollIfMissing = true}) async {
    final elems = await findWidgetsFor(selector, scrollIfMissing: scrollIfMissing);
    this.expect(elems.length, ft.equals(n), extraFrames: extraFrames+1);
    return keepSynchronous();
  }

  

  Future<void> matchWidgetValue(dynamic selectorDyn, ft.Matcher matcher, { String extractType = AFExtractWidgetAction.extractPrimary, int extraFrames = 0 }) async {
    final selector = AFWidgetSelector.createSelector(null, selectorDyn);
    final elems = await findWidgetsFor(selector);
    if(elems.isEmpty) {
      this.expect(elems, ft.isNotEmpty, extraFrames: extraFrames+1);
      return;
    }

    for(final elem in elems) {
      final selectable = AFibF.g.screenTests.findExtractor(extractType, elem);
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
    AFibF.g.testOnlyClearRecentActions();
    final selector = AFWidgetSelector.createSelector(null, selectorDyn);
    final elems = await findWidgetsFor(selector);
    if(maxWidgets > 0 && maxWidgets < elems.length) {
      throw AFException("Expected at most $maxWidgets widget for selector $selector, found ${elems.length} widgets");
    }
    if(elems.isEmpty) {
      throw AFException("applyWidgetValue, no widget found with selector $selectorDyn");
    }

    final elem = elems.first;
    final tapable = AFibF.g.screenTests.findApplicator(applyType, elem);
    if(tapable == null) {
      throw AFException("No AFApplyWidgetAction found for ${elem.widget.runtimeType}, you can register one using AFScreenTests.registerApplicator");
    }
    tapable.apply(applyType, selector, elem, value);    
    if(verifyActions != null) {
      verifyActions(AFibF.g.testOnlyRecentActions);
    } 
    if(verifyParamUpdate != null) {
      final AFNavigateSetParamAction setParam = AFibF.g.testOnlyRecentActions.firstWhere( (act) => (act is AFNavigateSetParamAction), orElse: () => null );
      var paramInner;
      if(setParam != null) {
        paramInner = setParam.param;
      } else {
        final AFNavigateSetChildParamAction setParamChild = AFibF.g.testOnlyRecentActions.firstWhere( (act) => (act is AFNavigateSetChildParamAction), orElse: () => null );
        paramInner = setParamChild.param;
      }

      verifyParamUpdate(paramInner);
    }
    if(verifyQuery != null) {
      final AFAsyncQuery query = AFibF.g.testOnlyRecentActions.firstWhere( (act) => (act is AFAsyncQuery), orElse: () => null );
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
    //AFibD.log?.e(err);
  }

  bool addPassIf({bool test}) {
    if(test) {
      dispatcher.dispatch(AFPrototypeScreenTestIncrementPassCount(this.testId));
    }
    return test;
  }

  void verifyPopupScreenId(AFScreenID popupScreenId) {
    AFibF.g.testOnlyVerifyActiveScreen(popupScreenId, includePopups: true);
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
    AFibF.g.testOnlyVerifyActiveScreen(popupScreenId, includePopups: true);
  }

}

abstract class AFScreenPrototypeTest {
  static const testDrawerSideEnd = 1;
  static const testDrawerSideBegin = 2;

  final AFTestID id;
  final int testDrawerSide;

  AFScreenPrototypeTest({
    @required this.id,
    this.testDrawerSide = testDrawerSideEnd
  });

  bool get hasBody;
  AFScreenID get screenId;
  bool get hasReusable { return false; }
  List<String> paramDescriptions(AFReusableTestID id) { return <String>[]; }
  List<AFReusableTestID> get sectionIds { return <AFReusableTestID>[]; }
  void startScreen(AFDispatcher dispatcher);
  Future<void> run(AFScreenTestContext context, { Function onEnd});
  void onDrawerReset(AFDispatcher dispatcher);
  Future<void> onDrawerRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext, AFSingleScreenTestState state, AFReusableTestID testId, Function onEnd);
  void openTestDrawer(AFReusableTestID id);
  dynamic get routeParam { return null; }
  dynamic get stateView { return null; }
  bool get isTestDrawerEnd { return testDrawerSide == testDrawerSideEnd; }
  bool get isTestDrawerBegin { return testDrawerSide == testDrawerSideBegin; }


  AFScreenTestContextSimulator prepareRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext) {
    onDrawerReset(dispatcher);
    var runNumber = 1;
    if(prevContext != null && prevContext.runNumber != null) {
      runNumber = prevContext.runNumber + 1;
    }

    final testContext = AFScreenTestContextSimulator(dispatcher, this.id, runNumber);
    dispatcher.dispatch(AFStartPrototypeScreenTestContextAction(testContext, param: this.routeParam, stateView: this.stateView, screen: this.screenId));
    return testContext;
  }

}

/// All the information necessary to render a single screen for
/// prototyping and testing.
class AFSingleScreenPrototypeTest extends AFScreenPrototypeTest {
  dynamic data;
  dynamic param;
  final AFSingleScreenPrototype body;
  //final AFConnectedScreenWithoutRoute screen;
  final AFScreenID screenId;

  AFSingleScreenPrototypeTest({
    @required AFSingleScreenTestID id,
    @required this.data,
    @required this.param,
    @required this.screenId,
    @required this.body,
  }): super(id: id);

  bool get hasBody {
    return body.isNotEmpty;
  }

  @override
  bool get hasReusable {
    return body.hasReusable;
  }

  @override
  dynamic get routeParam { 
    return param;
  }

  @override
  dynamic get stateView { 
    return data;
  }

  @override
  List<AFReusableTestID> get sectionIds {
    return body.sectionIds;
  }

  @override
  List<String> paramDescriptions(AFReusableTestID id) {
    return body.paramDescriptions(id);
  }

  void startScreen(AFDispatcher dispatcher) {
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(this, param: param, stateView: data, screen: screenId));
    dispatcher.dispatch(AFNavigatePushAction(
      screen: this.screenId,
      param: this.param
    ));
  }

  Future<void> run(AFScreenTestExecute context, { dynamic param1, dynamic param2, dynamic param3, Function onEnd}) {
    return body.run(context, onEnd: onEnd, param1: param1, param2: param2, param3: param3);
  }

  static void resetTestParam(AFDispatcher dispatcher, AFTestID testId, AFScreenID screenId, dynamic param) {
    final d = AFSingleScreenTestDispatcher(testId, dispatcher, null);
    d.dispatch(AFNavigateSetParamAction(
      param: param,
      screen: screenId,
      route: AFNavigateRoute.routeHierarchy
    ));
  }

  void onDrawerReset(AFDispatcher dispatcher) {
    AFSingleScreenPrototypeTest.resetTestParam(dispatcher, this.id, this.screenId, this.param);
    dispatcher.dispatch(AFUpdatePrototypeScreenTestDataAction(this.id, this.data));
  }

  @override
  Future<void> onDrawerRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext, AFSingleScreenTestState state, AFReusableTestID id, Function onEnd) async {
    final testContext = prepareRun(dispatcher, prevContext);
    return run(testContext, onEnd: onEnd);
  }

  void openTestDrawer(AFReusableTestID id) {
    body.openTestDrawer(id);
  }
}


abstract class AFWidgetPrototypeTest extends AFScreenPrototypeTest {
  final dynamic data;
  final AFSingleScreenPrototype body;
  final AFRenderConnectedChildDelegate render;
  final AFCreateWidgetWrapperDelegate createWidgetWrapperDelegate;

  AFWidgetPrototypeTest({
    @required AFTestID id,
    @required this.body,
    @required this.data,
    @required this.render,
    this.createWidgetWrapperDelegate,
    String title
  }): super(id: id);

  AFScreenID get screenId {
    return AFUIScreenID.screenPrototypeWidget;
  }

  bool get hasBody {
    return body != null && body.isNotEmpty;
  }

  void openTestDrawer(AFReusableTestID id) {
    body.openTestDrawer(id);
  }

  void startScreen(AFDispatcher dispatcher) {
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(this, stateView: data, screen: AFUIScreenID.screenPrototypeWidget, param: this.routeParam));
    dispatcher.dispatch(AFPrototypeWidgetScreen.navigatePush(this, id: this.id));    
  }
  
  Future<void> run(AFScreenTestExecute context, { Function onEnd }) {
    return body.run(context, onEnd: onEnd);
  }

  @override
  Future<void> onDrawerRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext, AFSingleScreenTestState state, AFReusableTestID id, Function onEnd) async {
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
    @required dynamic stateView,
    @required this.param,
    @required AFRenderConnectedChildDelegate render,
    @required AFSingleScreenPrototype body,
  }): super(id: id, body: body, data: stateView, render: render);

  @override
  List<AFReusableTestID> get sectionIds {
    return body.sectionIds;
  }

  void onDrawerReset(AFDispatcher dispatcher) {
    dispatcher.dispatch(AFNavigateSetParamAction(
      screen: this.screenId,
      param: AFPrototypeWidgetRouteParam(test: this, param: this.param),
      route: AFNavigateRoute.routeHierarchy
    ));
    dispatcher.dispatch(AFUpdatePrototypeScreenTestDataAction(this.id, this.data));
  }

}


/// The information necessary to start a test with a baseline state
/// (determined by a state test) and an initial screen/route.
class AFWorkflowStatePrototypeTest<TState extends AFAppStateArea> extends AFScreenPrototypeTest {
  final dynamic subpath;
  final AFStateTestID stateTestId;
  final AFWorkflowStateTestPrototype body;

  AFWorkflowStatePrototypeTest({
    @required AFWorkflowTestID id,
    @required this.subpath,
    @required this.stateTestId,
    @required this.body,
  }): super(id: id);

  bool get hasBody {
    return body != null;
  }

  @override
  List<AFReusableTestID> get sectionIds {
    return [AFReusableTestID.workflowTestId];
  }

  void openTestDrawer(AFReusableTestID id) {
    body.openTestDrawer(id);
  }

  AFScreenID get screenId {
    return body.initialScreenId;
  }

  AFSingleScreenTests get screenTests {
    return AFibF.g.screenTests;
  }

  void startScreen(AFDispatcher dispatcher) {
    initializeMultiscreenPrototype<TState>(dispatcher, this);
  }

  static void initializeMultiscreenPrototype<TState extends AFAppStateArea>(AFDispatcher dispatcher, AFWorkflowStatePrototypeTest test) {
    dispatcher.dispatch(AFResetToInitialStateAction());
    final screenMap = AFibF.g.screenMap;
    dispatcher.dispatch(AFNavigatePushAction(
      screen: screenMap.trueAppStartupScreenId,
      param: screenMap.trueCreateStartupScreenParam()
    ));
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(test, screen: test.screenId));

    // lookup the test.
    final testImpl = AFibF.g.stateTests.findById(test.stateTestId);
    
    // then, execute the desired state test to bring us to our desired state.
    final store = AFibF.g.storeInternalOnly;
    final mainDispatcher = AFStoreDispatcher(store);    
    final stateDispatcher = AFStateScreenTestDispatcher(mainDispatcher);

    final stateTestContext = AFStateTestContext<TState>(testImpl, store, stateDispatcher, isTrueTestContext: false);
    testImpl.execute(stateTestContext);


    if(stateTestContext.errors.hasErrors) {
    }

    // then, navigate into the desired path.
    final subpath = test.subpath;
    if(subpath is AFNavigatePushAction) {
      dispatcher.dispatch(subpath);
    } else if(subpath is List) {
      for(final push in subpath) {
        if(push is AFNavigatePushAction) {
          dispatcher.dispatch(push);
        }
      }
    }
  }


  Future<void> run(AFScreenTestContext context, { Function onEnd}) {
    return body.run(context, onEnd: onEnd);
  }

  void onDrawerReset(AFDispatcher dispatcher) {
    dispatcher.dispatch(AFNavigateExitTestAction());
    initializeMultiscreenPrototype<TState>(dispatcher, this);
  }

  @override
  Future<void> onDrawerRun(AFDispatcher dispatcher, AFScreenTestContextSimulator prevContext, AFSingleScreenTestState state, AFReusableTestID id, Function onEnd) async {
    final testContext = prepareRun(dispatcher, prevContext);
    return run(testContext, onEnd: onEnd);
  }

}


/// Used to register connected or unconnected widget tests.
class AFWidgetTests<TState> {
  final _connectedTests = <AFWidgetPrototypeTest>[];
  
  AFSingleScreenPrototype addConnectedPrototype({
    @required AFTestID   id,
    @required AFRenderConnectedChildDelegate render,
    dynamic data,
    AFRouteParam param,
    AFNavigatePushAction navigate,
  }) {
    final instance = AFConnectedWidgetPrototypeTest(
      id: id,
      stateView: data,
      param: param,
      render: render,
      body: AFSingleScreenPrototype(id)
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
  final AFReusableTestID id;
  final AFSingleScreenPrototype prototype;
  final AFReusableScreenTestBodyExecuteDelegate3 body;
  final String describeParam1;
  final String describeParam2;
  final String describeParam3;

  AFSingleScreenReusableBody({
    @required this.id,
    @required this.prototype, 
    @required this.body,
    @required this.describeParam1,
    @required this.describeParam2,
    @required this.describeParam3,
  });

  List<String> get paramDescriptions {
    final result = <String>[];
    _addOptional(result, describeParam1);
    _addOptional(result, describeParam2);
    _addOptional(result, describeParam3);
    return result;
  }
  
  void _addOptional(List<String> dest, String p) {
    if(p != null) {
      dest.add(p);
    }
  }
}

/// This class is used to create canned versions of screens and widget populated
/// with specific data for testing and prototyping purposes.
class AFSingleScreenTests<TState> {
  
  final _singleScreenTests = <AFSingleScreenPrototypeTest>[];
  final reusable = <AFReusableTestID, AFSingleScreenReusableBody>{};

  AFSingleScreenTests();

  List<AFSingleScreenPrototypeTest> get all {
    return _singleScreenTests;
  }

  void defineReusableTest1({
    @required AFReusableTestID id, 
    @required AFSingleScreenPrototype prototype, 
    @required String describeParam1,
    @required AFReusableScreenTestBodyExecuteDelegate1 body}) {
    if(reusable.containsKey(id)) {
      throw AFException("Duplicate definition for $id");
    }

    
    reusable[id] = AFSingleScreenReusableBody(
      id: id,
      prototype: prototype,
      describeParam1: describeParam1,
      describeParam2: null,
      describeParam3: null,
      body: (sse, p1, p2, p3) async {
      await body(sse, p1);
    });
  }

  void defineReusableTest2({
    @required AFReusableTestID id, 
    @required AFSingleScreenPrototype prototype, 
    @required AFReusableScreenTestBodyExecuteDelegate2 body,
    @required String describeParam1,
    @required String describeParam2,
  }) {
    if(reusable.containsKey(id)) {
      throw AFException("Duplicate definition for $id");
    }

    reusable[id] = AFSingleScreenReusableBody(
      id: id,
      prototype: prototype,
      describeParam1: describeParam1,
      describeParam2: describeParam2,
      describeParam3: null,
      body: (sse, p1, p2, p3) async {
        await body(sse, p1, p2);
      }
    );
  }

  void defineReusableTest3({
    @required AFReusableTestID id, 
    @required AFSingleScreenPrototype prototype, 
    @required AFReusableScreenTestBodyExecuteDelegate3 body,
    @required String describeParam1,
    @required String describeParam2,
    @required String describeParam3
  }) {
    if(reusable.containsKey(id)) {
      throw AFException("Duplicate definition for $id");
    }

    reusable[id] = AFSingleScreenReusableBody(
      id: id,
      prototype: prototype,
      describeParam1: describeParam1,
      describeParam2: describeParam2,
      describeParam3: describeParam3,
      body: (sse, p1, p2, p3) async {
        await body(sse, p1, p2, p3);
      }
    );
  }

  AFSingleScreenReusableBody findReusable(AFReusableTestID id) {
    return reusable[id];
  }

  AFExtractWidgetAction findExtractor(String actionType, Element elem) {
    for(final extractor in AFibF.g.testExtractors) {
      if(extractor.matches(actionType, elem)) {
        return extractor;
      }
    }
    return null;
  }

  AFApplyWidgetAction findApplicator(String actionType, Element elem) {
    for(final apply in AFibF.g.testApplicators) {
      if(apply.matches(actionType, elem)) {
        return apply;
      }
    }
    return null;
  }

  /// Add a prototype of a particular screen with the specified [data]
  /// and [param].  
  /// 
  /// Returns an [AFSingleScreenPrototype], which can be used to create a 
  /// test for the screen.
  AFSingleScreenPrototype addPrototype({
    @required AFSingleScreenTestID   id,
    @required dynamic data,
    dynamic param,
    AFScreenID screenId,
    AFNavigatePushAction navigate
  }) {
    final hasNav    = (navigate != null);
    final hasParam  = (screenId != null || param != null);
    if(hasNav && hasParam) {
      throw AFException("Please specify either the navigate parameter, or the screenId and param parameters, but not both (they are redundant)");
    }
    if(!hasNav && !hasParam) {
      throw AFException("You must specify a screenId and param, either via those parameters, or via the single navigate parameter");
    }

    if(hasNav) {
      screenId = navigate.screen;
      param = navigate.param;
    }

    final instance = AFSingleScreenPrototypeTest(
      id: id,
      data: data,
      param: param,
      screenId: screenId,
      body: AFSingleScreenPrototype(id, screenId: screenId)
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
    AFibF.g.testData.register(id, data);
  }

  dynamic findData(dynamic id) {
    return AFibF.g.testData.find(id);
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

  Future<void> withState<TState extends AFAppStateArea>( Future<void> Function(TState, AFRouteState) withState) async {
    final public = AFibF.g.storeInternalOnly.state.public;
    return withState(public.areaStateFor(TState), public.route);
  }

  Future<void> runScreenTest(AFReusableTestID screenTestId, {
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



class AFWorkflowTestContext extends AFWorkflowTestExecute {
  final AFScreenTestContext screenContext;

  AFWorkflowTestContext(this.screenContext);  

  /// Execute the specified screen tests, with query-responses provided by the specified state test.
  Future<void> runScreenTest(AFTestID screenTestId,  {AFScreenID terminalScreen, dynamic param1, dynamic param2, dynamic param3, AFTestID queryResults}) async {
    _installQueryResults(queryResults);
    
    final originalScreenId = await internalRunScreenTest(screenTestId, screenContext, param1, param2, param3);

    if(terminalScreen != null && originalScreenId != terminalScreen) {
      await screenContext.pauseForRender();
    } 

    return keepSynchronous();  
  }

  static Future<AFScreenID> internalRunScreenTest(AFReusableTestID screenTestId, AFSingleScreenTestExecute sse, dynamic param1, dynamic param2, dynamic param3 ) async {
    final screenTest = AFibF.g.screenTests.findById(screenTestId);
    var screenId;
    var body;
    if(screenTest != null) {
      screenId = screenTest.screenId;
      body = screenTest.body;
    } else {
      // this might be a re-usable screen test.
      final reusable = AFibF.g.screenTests.findReusable(screenTestId);
      if(reusable == null) {
        throw AFException("Screen test $screenTestId is not defined");
      }
      screenId = reusable.prototype.screenId;
      body = AFSingleScreenPrototype.createReusable(screenTestId, reusable.body);
    }

    sse.pushScreen(screenId);
    await body.run(sse, param1: param1, param2: param2, param3: param3);
    sse.popScreen();
    return screenId;
  }


  Future<void> runWidgetTest(AFTestID widgetTestId, AFScreenID originScreen, {AFScreenID terminalScreen, AFTestID queryResults}) async {
    _installQueryResults(queryResults);
    final widgetTest = AFibF.g.widgetTests.findById(widgetTestId);
    screenContext.pushScreen(originScreen);
    await widgetTest.run(screenContext);  
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
      AFibF.g.testOnlyVerifyActiveScreen(startScreen);
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
      AFibF.g.testOnlyVerifyActiveScreen(endScreen);
    }
  }

  void _installQueryResults(AFTestID queryResults) {
    if(queryResults == null) {
      return;
    }
    final stateTest = AFibF.g.stateTests.findById(queryResults);
    final store = AFibF.g.storeInternalOnly;
    final dispatcher = AFibF.g.storeDispatcherInternalOnly;

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

}

class AFWorkflowStateTestPrototype {
  final AFWorkflowStateTests tests;
  final AFScreenID initialScreenId;
  final sections = <AFWorkflowStateTestBodyWithParam>[];

  AFWorkflowStateTestPrototype(this.tests, this.initialScreenId);

  factory AFWorkflowStateTestPrototype.create(AFWorkflowStateTests tests, AFScreenID initialScreenId, AFTestID testId) {
    return AFWorkflowStateTestPrototype(tests, initialScreenId);
  }

  void execute(AFWorkflowTestBodyExecuteDelegate body) async {
    sections.add(AFWorkflowStateTestBodyWithParam(body));
  }  

  void openTestDrawer(AFReusableTestID id) {
    final info = AFibF.g.testOnlyMostRecentScreen;
    final scaffoldState = AFSingleScreenPrototype.findScaffoldState(info.element, underScaffold: false);
    scaffoldState?.openEndDrawer();
  }

  Future<void> run(AFScreenTestContext context, { Function onEnd }) async {
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
class AFWorkflowStateTests<TState extends AFAppStateArea> {
  final stateTests = <AFWorkflowStatePrototypeTest>[];

  AFWorkflowStateTestPrototype addPrototype({
    @required AFWorkflowTestID id,
    @required dynamic subpath,
    @required AFTestID stateTestId,
  }) {
    final screenId = _initialScreenIdFromSubpath(subpath);
    final instance = AFWorkflowStatePrototypeTest<TState>(
      id: id,
      subpath: subpath,
      stateTestId: stateTestId,
      body: AFWorkflowStateTestPrototype.create(this, screenId, id)
    );
    stateTests.add(instance);
    return instance.body;
  }

  AFScreenID _initialScreenIdFromSubpath(dynamic subpath) {
    if(subpath is AFScreenID) {
      return subpath;
    }
    if(subpath is AFNavigatePushAction) {
      return subpath.screen;
    }
    if(subpath is List) {
      final last = subpath.last;
      if(last is AFScreenID) {
        return last;
      }
      if(last is AFNavigatePushAction) {
        return last.screen;
      }
    }

    throw AFException("Unexpected type ${subpath.runtimeType} specified as subpath");
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


/// Base test definition wrapper, with access to test data.
/// 
class AFBaseTestDefinitionContext {
  final AFTestDataRegistry registry;
  AFBaseTestDefinitionContext(this.registry);

  /// Looks up the test data defined in your test_data.dart file for a particular
  /// test data id.
  dynamic td(dynamic testDataId) {
    return registry.find(testDataId);
  }

  /// Looks up the test data defined in your test_data.dart file for a particular
  /// test data id.
  dynamic testData(dynamic testDataId) {
    return registry.find(testDataId);
  }

}

class AFUnitTestDefinitionContext extends AFBaseTestDefinitionContext {
  final AFUnitTests tests;

  AFUnitTestDefinitionContext({
    this.tests,
    AFTestDataRegistry testData
  }): super(testData);

  void addTest(AFTestID id, AFUnitTestBodyExecuteDelegate fnTest) {
    tests.addTest(id, fnTest);
  }
}

/// A context wrapper for defining a state test.
/// 
/// This class is intended to provide a quick start for the most common
/// methods in defining state tests, and to enable extensions
/// later without changing the test definition function profile.
class AFStateTestDefinitionContext extends AFBaseTestDefinitionContext {
  final AFStateTests tests;

  AFStateTestDefinitionContext({
    this.tests,
    AFTestDataRegistry testData
  }): super(testData);

  /// Define a state test. 
  /// 
  /// The state test should define one or more query results, and then
  /// execute a query.  Note that state tests are usually built in a 
  /// kind of tree, with a cumulative state being build from
  /// a series of query/response cycles across multiple tests.
  void addTest(AFStateTestID id, AFProcessTestDelegate handler) {
    tests.addTest(id, handler);
  }

  /// Specify a response for a particular query.
  /// 
  /// When the query 'executes', its [AFAsyncQuery.startAsync] method will be skipped
  /// and its [AFAsyncQuery.finishAsyncWithResponse] method will be called with the 
  /// test data with the specified [idData] in the test data registry.
  void specifyFixedResponse(AFStateTest test, dynamic querySpecifier, dynamic idData) {
    test.specifyResponse(querySpecifier, this, idData);
  }

  /// Create a response dynamically for a particular query.
  /// 
  /// This method is useful when you have query methods which 'write' data, where often
  /// the data doesn't change at all when it is writen, or the changes are simple (like 
  /// a new identifier is returned, or the update-timestamp for the data is created by the server).
  /// Using this method, in many cases you can cause 'workflow' prototypes to behave very much
  /// like they have a back end server, despite the fact that they do not.
  /// 
  /// When the query 'executes', its [AFAsyncQuery.startAsync] method will be skipped
  /// and its [AFAsyncQuery.finishAsyncWithResponse] method will be called with the 
  /// test data that is created by [delegate].
  void specifyDynamicResponse(AFStateTest test, dynamic querySpecifier, AFCreateQueryResultDelegate delegate) {
    test.createResponse(querySpecifier, delegate);
  }

  /// Use this method to execute a query and validate the state change which it causes.
  void executeQuery(AFStateTest test, AFAsyncQuery query, {
    AFProcessVerifyDifferenceDelegate verify
  }) {
    test.executeQuery(query, verifyState: verify);
  }

}

/// A context wrapper for definining a widget test
/// 
/// This class is intended to provide a quick start for the most common
/// methods in defining widget tests, and to enable extensions
/// later without changing the test definition function profile.
class AFWidgetTestDefinitionContext extends AFBaseTestDefinitionContext {

  final AFWidgetTests tests;
  AFWidgetTestDefinitionContext({
    this.tests,
    AFTestDataRegistry testData
  }): super(testData);

  AFSingleScreenPrototype definePrototype({
    @required AFTestID   id,
    @required AFRenderConnectedChildDelegate render,
    @required dynamic data,
    @required AFRouteParam param,
  }) {
    return tests.addConnectedPrototype(
      id: id,
      render: render,
      data: data,
      param: param,
    );
  }

  void defineSmokeTest(AFSingleScreenPrototype prototype, AFScreenTestBodyExecuteDelegate body) {
    prototype.defineSmokeTest(body);
  }
}

/// A context wrapper for defining single screen test. 
/// 
/// This class is intended to provide a quick start for the most common
/// methods in defining single screen tests, and to enable extensions
/// later without changing the test definition function profile.
class AFSingleScreenTestDefinitionContext extends AFBaseTestDefinitionContext {
  final AFSingleScreenTests tests; 

  AFSingleScreenTestDefinitionContext({
    this.tests,
    AFTestDataRegistry testData
  }): super(testData);


  /// Define a prototype which shows a  single screen in a particular 
  /// screen view state/route param state.
  /// 
  /// As a short cut, rather than passing in routeParam/screenId, you can pass
  /// in a navigate action, which has both of those values within it.
  AFSingleScreenPrototype definePrototype({
    @required AFSingleScreenTestID   id,
    @required dynamic viewState,
    dynamic routeParam,
    AFScreenID screenId,
    AFNavigatePushAction navigate,
    String title,
  }) {
    final dataActual = testData(viewState);
    final paramActual = testData(routeParam);
    
    return tests.addPrototype(
      id: id,
      data: dataActual,
      param: paramActual,
      screenId: screenId,
      navigate: navigate,
    );
  }

  /// Create a smoke test for the [prototype]
  /// 
  /// A smoke test manipulates the screen thoroughly and validates 
  /// it in various states, it is not intended to be reused.
  void defineSmokeTest(AFSingleScreenPrototype prototype, AFScreenTestBodyExecuteDelegate body, {
    String disabled
  }) {
    prototype.defineSmokeTest(body, disabled: disabled);
  }

  /// Used to define a reusable test which takes a single parameter.
  /// 
  /// The test author should write it so that it automatically executes a test
  /// appropriate for its parameterized values.   The prototype mode UI will show
  /// the test with a 'reusable' tag.   The intent is that when building multiple
  /// screen 'workflow' tests, it is useful to be able to assemble several single screen
  /// tests which were designed to be parameterized into a composite workflow.  This 
  /// feature is intended to make reusable tests discoverable.
  /// 
  /// Defining a reusable test does not execute it, use [executeReusableTest] to do that.
  void defineReusableTest1({
    @required AFReusableTestID id, 
    @required AFSingleScreenPrototype prototype,
    @required String describeParam1,
    @required dynamic param1,
    @required AFReusableScreenTestBodyExecuteDelegate1 body
  }) {
    tests.defineReusableTest1(
      id: id, 
      describeParam1: describeParam1,
      prototype: prototype,
      body: body
    );

    executeReusableTest(prototype, id, param1: param1);
  }

  /// Used to define a reusable test which takes a two parameters.
  /// 
  /// See [defineReusableTest1] for more.
  void defineReusableTest2({
    @required AFReusableTestID id, 
    @required AFSingleScreenPrototype prototype, 
    @required AFReusableScreenTestBodyExecuteDelegate2 body,
    @required String describeParam1,
    @required String describeParam2,
    @required dynamic param1,
    @required dynamic param2,
  }) {
    tests.defineReusableTest2(
      id: id, 
      prototype: prototype,
      body: body,
      describeParam1: describeParam1,
      describeParam2: describeParam2,
    );

    executeReusableTest(prototype, id, param1: param1, param2: param2);
  }

  /// Used to define a reusable test which takes three parameters.
  /// 
  /// See [defineReusableTest1] for more.
  void defineReusableTest3({
    @required AFReusableTestID id, 
    @required AFSingleScreenPrototype prototype, 
    @required AFReusableScreenTestBodyExecuteDelegate3 body,
    @required String describeParam1,
    @required String describeParam2,
    @required String describeParam3,
    @required dynamic param1,
    @required dynamic param2,
    @required dynamic param3
  }) {
    tests.defineReusableTest3(
      id: id, 
      prototype: prototype,
      body: body,
      describeParam1: describeParam1,
      describeParam2: describeParam2,
      describeParam3: describeParam3,
    );

    executeReusableTest(prototype, id, param1: param1, param2: param2, param3: param3);
  }

  /// Executes a test defined with [defineResuable1] or one of its variants, allowing
  /// you to provide values from the 1-3 parameters required by the test.
  void executeReusableTest(AFSingleScreenPrototype body, AFReusableTestID bodyId, {
    dynamic param1,
    dynamic param2,
    dynamic param3
  }) {
    final p1 = td(param1);
    final p2 = td(param2);
    final p3 = td(param3);
    body.executeReusable(tests, bodyId, param1: p1, param2: p2, param3: p3);
  }
}

class AFWorkflowTestDefinitionContext extends AFBaseTestDefinitionContext {
  final AFWorkflowStateTests tests;

  AFWorkflowTestDefinitionContext({
    this.tests,
    AFTestDataRegistry testData
  }): super(testData);

  AFWorkflowStateTestPrototype definePrototype({
    @required AFWorkflowTestID id,
    String title,
    @required dynamic subpath,
    @required AFTestID stateTestId,
  }) {
    return tests.addPrototype(
      id: id,
      subpath: subpath,
      stateTestId: stateTestId
    );
  }
  
  void defineWorkflow(AFWorkflowStateTestPrototype prototype, AFWorkflowTestBodyExecuteDelegate body) {
    prototype.execute(body);
  }
}

