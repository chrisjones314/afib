import 'dart:async';

import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/redux/state/models/af_test_state.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_bottomsheet_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_dialog_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_drawer_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_widget_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_unimplemented_screen.dart';
import 'package:afib/src/flutter/utils/af_api_mixins.dart';
import 'package:collection/collection.dart';
import 'package:colorize/colorize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:logger/logger.dart';
import 'package:quiver/core.dart';

enum AFTestTimeHandling {
  running,
  paused
}

typedef AFCreateWidgetLaunchParamDelegate = AFRouteParam Function(AFScreenID screenId, AFWidgetID wid, AFRouteLocation routeLocation);
typedef AFTestScreenExecuteDelegate = Future<void> Function(AFScreenTestExecute ste);
typedef AFVerifyReturnValueDelegate = void Function(Object? value);

/// A utility class used to pass 
abstract class AFWidgetSelector {
  final elements = <Element>[];
  //AFScreenTestWidgetCollectorScrollableSubpath parentScrollable;
  final scrollables = <AFScrollTracker>[];

  void add(Element elem) {
    elements.add(elem);
  }

  bool contains(Element elem) {
    return elements.contains(elem);
  }

  void clearWidgets() {
    elements.clear();
  }

  bool matchesPath(List<Element> elem) {
    // by default, just match the leaf, but allow for more complicated
    // paths
    return matches(elem.last);
  }

  Element? activeElementForPath(List<Element> elems) {
    return elems.last;
  }

  bool canScrollMore() {
    if(AFibD.config.isWidgetTesterContext) {
      return false;
    }
    if(scrollables.isEmpty) {
      return false;
    }    
    final scrollable = scrollables.first;
    return scrollable.canScrollMore();
  }

  Future<void> scrollMore() async {
    if(scrollables.isEmpty) {
      return;
    }    
    final scrollable = scrollables.first;
    return scrollable.scrollMore();    
  }

  bool matches(Element elem);

  static AFWidgetSelector createSelector(AFSparsePathWidgetSelector? path, dynamic sel) {
    AFWidgetSelector selector;
    if(sel is String) {
      selector = AFKeySelector(sel);
    } else if(sel is AFWidgetID) {
      selector = AFKeySelector(sel.code);
    } else if(sel is AFWidgetSelector) {
      selector = sel;
    } else if(sel is Type) {
      selector = AFWidgetTypeSelector(sel);
    } else if(sel is List) {
      final selectors = <AFWidgetSelector>[];
      for(final selItem in sel) {
        selectors.add(createSelector(null, selItem));
      }
      return AFSparsePathWidgetSelector(selectors);
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
  Key? key;
  AFKeySelector(String keyStr) {
    key = Key(keyStr);
  }

  factory AFKeySelector.fromWidget(AFWidgetID wid) {
    return AFKeySelector(wid.code);
  }

  @override
  bool matches(Element elem) {
    return elem.widget.key == key;
  }

  @override
  bool operator==(Object other) {
    return other is AFKeySelector && other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }

  @override
  String toString() {
    return "$key";
  }

  
}


class AFWidgetTypeSelector extends AFWidgetSelector {
  Type widgetType;
  AFWidgetTypeSelector(this.widgetType);

@override
  bool matches(Element elem) {
    return elem.widget.runtimeType == widgetType;
  }

  @override
  bool operator==(Object other) {
    return other is AFWidgetTypeSelector && other.widgetType == widgetType;
  }

  @override
  int get hashCode {
    return widgetType.hashCode;
  }

  @override
  String toString() {
    return widgetType.toString();
  }
}

class AFIconDataSelector extends AFWidgetSelector {
  IconData data;
  AFIconDataSelector(this.data);

  @override
  bool matches(Element elem) {
    final widget = elem.widget;
    if(widget is Icon) {
      return widget.icon == data;
    }
    return false;
  }

  @override
  bool operator==(Object other) {
    return other is AFIconDataSelector && other.data == this.data;
  }

  @override
  int get hashCode {
    return data.hashCode;
  }

  @override
  String toString() {
    return data.toString();
  }
}



class AFMultipleWidgetSelector extends AFWidgetSelector {
  final selectors = <AFWidgetSelector>[];
  AFMultipleWidgetSelector(List sel) {
    for(final item in sel) {
      selectors.add(AFWidgetSelector.createSelector(null, item));
    }
  }

  @override
  bool matches(Element elem) {
    for(final sel in selectors) {
      if(sel.matches(elem)) {
        return true;
      }
    }
    return false;
  }

  @override
  bool operator==(Object other) {
    if(other is! AFMultipleWidgetSelector) {
      return false;
    }

    if(other.selectors.length != selectors.length) {
      return false;
    }

    for(var i = 0; i < selectors.length; i++) {
      final l = selectors[i];
      final r = other.selectors[i];
      if(l != r) {
        return false;
      }
    }
    return true;
  }

  @override
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

  @override
  bool matches(Element elem) {
    return selector.matches(elem);
  }

  @override
  bool operator==(Object other) {
    if(other is! AFRichTextGestureTapSpecifier) {
      return false;
    }

    if(other.selector != selector) {
      return false;
    }

    if(other.containsText != containsText) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return hash2(selector.hashCode, containsText.hashCode);
  }

  @override
  String toString() {
    final result = StringBuffer();
    result.write(selector.toString());
    result.write(":");
    result.write(containsText);
    return result.toString();
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


  
  @override
  bool matchesPath(List<Element> elem) {
    // first, make sure the final path element matches, we don't want 
    // extra stuff below the last selector.
    final lastSelector = pathSelectors.last;
    final lastPath = elem.last;

    if(!lastSelector.matches(lastPath)) {
      return false;
    }

    // if the last matches, then go up the path making sure that we can
    // find all the other path selectors.
    var curPath = elem.length - 2;
    var curSel = pathSelectors.length - 2;
    while(curSel >= 0 && curPath >= 0) {
      final sel   = pathSelectors[curSel];
      final item  = elem[curPath];
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

  @override
  Element? activeElementForPath(List<Element> elems) {
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

  @override
  bool matches(Element elem) {
    throw AFException("Do not attempt to add sparse path widget selectors recursively into each other.");
  }

  @override
  bool operator==(Object other) {
    if(other is AFSparsePathWidgetSelector) {
      if(other.pathSelectors.length != pathSelectors.length) {
        return false;
      }

      for(var i = 0; i < pathSelectors.length; i++) {
        final l = pathSelectors[i];
        final r = other.pathSelectors[i];
        if(l != r) {
          return false;
        }
      }

      return true;
    }
    return false;
  }

  @override
  int get hashCode {
    return pathSelectors.hashCode;
  }

  @override
  String toString() {
    final result = StringBuffer();
    for(final sel in pathSelectors) {
      if(result.isNotEmpty) {
        result.write("/.../");
      }
      result.write(sel.toString());
    }
    return result.toString();
  }

}

class AFTestParams {
  final List<Object?> params;
  AFTestParams(this.params);


  Iterable<Object?> get values {
    return params;
  }

  T getParam<T extends Object>(int idx) {
    final result = getParamOrNull<T>(idx);
    if(result == null) {
      throw AFException("Expected test parameter at $idx to be non-null, if it can be null use getParamOrNull instead");
    }
    return result;
  }

  T? getParamOrNull<T extends Object>(int idx) {
    if(idx < 0 || idx >= params.length) {
      throw AFException("Attempting to access test parameter at $idx but there are only ${params.length} params");
    }

    final obj = params[idx];
    if(obj == null) {
      return null;
    }
    if(obj is! T?) {
      throw AFException("Expected test parameter at $idx to have type ${T.toString()}, but it is a ${obj.runtimeType.toString()}");
    }
    return obj as T?;
  }
}

@immutable
class AFUIVerifyContext {
  final List<AFActionWithKey> actions;
  final Map<AFScreenID, dynamic> showResults;
  final AFScreenID activeScreenId;

  const AFUIVerifyContext({
    required this.actions,
    required this.activeScreenId,
    required this.showResults,
  });

  TAction accessOneAction<TAction extends AFActionWithKey>() {
    final found = actions.whereType<TAction>();
    if(found.isEmpty) {
      throw AFException("Failed to find action of type $TAction");
    }

    if(found.length > 1) {
      throw AFException("Found more than one action of type $TAction");
    }

    return found.first;
  }

  TResult accessShowResult<TResult>(AFScreenID screenId) {
    final result = showResults[screenId];
    if(result == null) {
      throw AFException("No result for screen $screenId");
    }
    return result;
  }

  TResult accessActiveScreenShowResult<TResult>() {
    return accessShowResult(activeScreenId);
  }

  TQuery accessOneQuery<TQuery extends AFAsyncQuery>() {
    final queries = accessQueries<TQuery>();
    if(queries.isEmpty) {
      throw AFException("Found no queries with type $TQuery");
    }
    if(queries.length > 1) {
      throw AFException("Found multiple queries of type $TQuery, use accessQueries");
    }
    return queries.first;
  }

  List<TQuery> accessQueries<TQuery extends AFAsyncQuery>() {
    final queries = actions.whereType<TQuery>();
    return queries.toList();
  }
    


  List<TRouteParam> accessRouteParamUpdates<TRouteParam extends AFRouteParam>() {
    final candidates = actions.whereType<AFNavigateSetParamAction>();
    final correctTypes = candidates.where((act) { 
      return act.param is TRouteParam;
    });

    
    final result = correctTypes.map((x) => x.param as TRouteParam ).toList();
    return result;
  }

  TRouteParam accessRouteParamUpdate<TRouteParam extends AFRouteParam>() {
    final correctTypes = accessRouteParamUpdates<TRouteParam>();

    if(correctTypes.isEmpty) {
      throw AFException("Found no AFNavigateSetParam actions for param type $TRouteParam");
    }

    if(correctTypes.length > 1) {
      throw AFException("Error, found ${correctTypes.length} updated to route param $TRouteParam, use accessRouteParamUpdates");
    }

    final correctType = correctTypes.first;
    return correctType;
  }
}

abstract class AFScreenTestExecute extends AFBaseTestExecute with AFDeviceFormFactorMixin {
  AFBaseTestID testId;
  final underPaths = <AFSparsePathWidgetSelector?>[];
  final activeScreenIDs = <AFScreenID>[];
  int slowOnScreenMillis = 0;
  
  AFScreenTestExecute(this.testId);

  AFScreenPrototype? get test {
    var found = AFibF.g.findScreenTestById(this.testId);
    found ??= AFibF.g.widgetTests.findById(this.testId);
    return found;
  }

  AFScreenID get activeScreenId;
  bool isEnabled(AFBaseTestID id) { return true; }

  AFTimeState get currentTime {
    final state = AFibF.g.internalOnlyActiveStore.state;
    final testState = state.private.testState.findState(testId);
    if(testState == null) {
      throw AFException("No test state for test $testId");
    }
    final models = testState.models;
    var timeState;
    if(models == null) {
      // this is a workflow test.
      timeState = state.public.time;
    } else {
      timeState = testState.models!["AFTimeState"] as AFTimeState?;
    }

    if(timeState == null) {
      throw AFException("You called currentTime in a test, but you don't have an AFTimeState in the models for the test");
    }
    return timeState;
  }

   void expectWidgetIds(List<Widget> widgets, List<AFWidgetID?> ids, { AFWidgetMapperDelegate? mapper } ) {
    return expect(widgets, hasWidgetIdsWith(ids, mapper: mapper));
  }
 

  @override
  AFBaseTestID get testID => testId;
  AFSparsePathWidgetSelector? get activeSelectorPath {
    if(underPaths.isEmpty) {
      return null;
    }
    return underPaths.last;
  }

  /// Verifies the specified widget is not present.  
  Future<void> matchMissingWidget(dynamic selector, { bool ignoreUnderWidget = false }) async {
    await matchWidgets(selector, expectedCount: 0, extraFrames: 1, scrollIfMissing: false, ignoreUnderWidget: ignoreUnderWidget);
  }

  /// Any operations applied within the [underHere] callback operate on 
  /// widgets which are nested under [selector].
  /// 
  /// In addition to passing a standard [selector], like a AFWidgetID, you can also
  /// pass in a list of selectors.  If you do so, then the operation takes place
  /// under a sparse-path containing all the items in the list.
  Future<void> underWidget(dynamic selector, Future<void> Function() underHere) async {
    var path = activeSelectorPath;
    path ??= AFSparsePathWidgetSelector.createEmpty();
    var next = path;
    if(selector is List) {
      for(final sel in selector) {
          next =  AFWidgetSelector.createSelector(next, sel) as AFSparsePathWidgetSelector;
      }
    } else {
      next = AFWidgetSelector.createSelector(next, selector) as AFSparsePathWidgetSelector;
    }
    underPaths.add(next);
    await underHere();
    underPaths.removeLast();
  }

  Future<Widget> matchTextEquals(dynamic selector, String text) {
    return matchWidgetValue(selector, ft.equals(text), extraFrames: 1);
  }

  Future<Widget> matchText(dynamic selector, ft.Matcher matcher) {
    return matchWidgetValue(selector, matcher, extraFrames: 1);
  }

  Future<Switch> matchSwitch(dynamic selector, { required bool enabled }) async {
    final swi = await matchWidgetValue(selector, ft.equals(enabled), extraFrames: 1) as Switch;
    return swi;
  }

  Future<void> applySetSwitch(dynamic selector, { required bool enabled }) {
    return setValue(selector, enabled, extraFrames: 1);
  }

  Future<void> underScreen(AFScreenID screen, Function underHere) async {
    const shouldPush = true; //activeScreenIDs.isEmpty || activeScreenIDs.last != screen;
    if(shouldPush) {
      pushScreen(screen);
      await pauseForRender();
    }
    
    await underHere();

    if(shouldPush) {
      popScreen();
    }
  }

  void pushScreen(AFScreenID screen) {
    activeScreenIDs.add(screen);
    underPaths.add(null);
  }

  void popScreen() {
    activeScreenIDs.removeLast();
    underPaths.removeLast();
  }

  @override
  bool deviceHasFormFactor({
    AFFormFactor? atLeast,
    AFFormFactor? atMost,
    Orientation? withOrientation
  }) {
    final themes = AFibF.g.internalOnlyActiveStore.state.public.themes;
    final functional = themes.fundamentals;
    return functional.deviceHasFormFactor(
      atLeast: atLeast,
      atMost: atMost,
      withOrientation: withOrientation,
    );
  }

  /// Tap on the specified widget, then expect a dialog which you can interact with via the onDialog parameter.
  Future<void> applyTapExpectDialog(dynamic selectorTap, final AFScreenID dialogScreenId, AFTestScreenExecuteDelegate onDialog) async {
    await applyTap(selectorTap);
    await pauseForRender();
    
    await this.underScreen(dialogScreenId, () async {
      await onDialog(this);
    });
  }

  /// Tap on the specified widget, then expect a dialog which you can interact with via the onSheet parameter.
  Future<void> applyTapExpectModalBottomSheet(dynamic selectorTap, final AFScreenID dialogScreenId, AFTestScreenExecuteDelegate onSheet) async {
    await applyTap(selectorTap);
    await pauseForRender();
    
    await this.underScreen(dialogScreenId, () async {
      await onSheet(this);
    });
  }

  Future<void> matchChipsSelected(List<dynamic> selectors, { required bool selected }) async {
    for(final sel in selectors) {
      await matchChipSelected(sel, selected: selected);
    }
  }

  /// Expect that a [Chip] is selected or not selected.
  /// 
  /// Note that in addition to the standard options, 
  /// the [selector] can be a list of other selectors.  With chips,
  /// it is very common to verify that several of them are on or off
  /// at the same time, and passing in a list is a concise way to do
  /// so.
  Future<Widget> matchChipSelected(dynamic selector, {required bool selected}) async {
    return matchWidgetValue(selector, ft.equals(selected), extraFrames: 1);
  }

  Future<Widget> matchWidgetValue(dynamic selectorDyn, ft.Matcher matcher, { bool scrollIfMissing = true, bool ignoreUnderWidget = false, String extractType = AFExtractWidgetAction.extractPrimary, int extraFrames = 0 }) async {
    final elems = await findElementsFor(selectorDyn, ignoreUnderWidget: ignoreUnderWidget, shouldScroll: scrollIfMissing);
    if(elems.length != 1) {
      throw AFException("matchWidgetValue expects $selectorDyn to match exactly one widget, found ${elems.length}");
    }

    final elem = elems.first;
    final selectable = AFibF.g.screenTests.findExtractor(extractType, elem);
    if(selectable == null) {
      throw AFException("No AFSelectedWidgetTest found for ${elem.widget.runtimeType}, you can register one using AFScreenTests.registerSelectable");
    }
    
    final selector = AFWidgetSelector.createSelector(activeSelectorPath, selectorDyn);
    final value = selectable.extract(extractType, selector, elem);
    this.expect(value, matcher, extraFrames: extraFrames+1);
    return elem.widget;
  }
  
  Future<void> applyWidgetValue(dynamic selector, dynamic value, String applyType, { 
    AFUIVerifyDelegate? verify,
    int maxWidgets = 1, 
    int extraFrames = 0,
    bool ignoreUnderWidget = false, 
  });

  Future<void> applyTap(dynamic selector, { 
    int extraFrames = 0,
    dynamic tapData,
    AFUIVerifyDelegate? verify,
    bool ignoreUnderWidget = false,
  }) {
    return applyWidgetValue(selector, tapData, AFApplyWidgetAction.applyTap, 
      ignoreUnderWidget: ignoreUnderWidget, 
      extraFrames: extraFrames+1, 
      verify: verify, 
    );
  }

  Future<void> applySwipeDismiss(dynamic selector, { 
    int maxWidgets = 1, 
    int extraFrames = 0, 
    AFUIVerifyDelegate? verify,
    bool ignoreUnderWidget = false, 
  }) {
    return applyWidgetValue(selector, null, AFApplyWidgetAction.applyDismiss, 
      ignoreUnderWidget: ignoreUnderWidget, 
      maxWidgets: maxWidgets, 
      extraFrames: extraFrames+1, 
      verify: verify, 
    );
  }

  Future<void> setValue(dynamic selector, dynamic value, { 
    int maxWidgets = 1, 
    int extraFrames = 0, 
    AFUIVerifyDelegate? verify,
    bool ignoreUnderWidget = false,
  }) {
    return applyWidgetValue(selector, value, AFApplyWidgetAction.applySetValue, 
      ignoreUnderWidget: ignoreUnderWidget, 
      maxWidgets:  maxWidgets, 
      extraFrames: extraFrames+1, 
      verify: verify, 
    );
  }

  Future<void> applyEnterText(dynamic selector, dynamic value, { 
    int maxWidgets = 1, 
    int extraFrames = 0, 
    AFUIVerifyDelegate? verify,
    bool ignoreUnderWidget = false
  }) {
    return applyWidgetValue(selector, value, AFApplyWidgetAction.applySetValue, 
      ignoreUnderWidget: ignoreUnderWidget, 
      maxWidgets:  maxWidgets, 
      extraFrames: extraFrames+1, 
      verify: verify,
    );
  }

  Future<List<Element>> findElementsFor(dynamic selector, { required bool shouldScroll, required bool ignoreUnderWidget }) async {
    if(slowOnScreenMillis > 0 && !AFibD.config.isWidgetTesterContext) {
      await Future<void>.delayed(Duration(milliseconds: slowOnScreenMillis));
    }
    final activeSel = ignoreUnderWidget ? null : activeSelectorPath;
    final sel = AFWidgetSelector.createSelector(activeSel, selector);
    final info = AFibF.g.internalOnlyFindScreen(activeScreenId);

    final currentPath = <Element>[];
    final elem = info?.element as Element;
    _populateChildrenDirect(elem, currentPath, sel, null, underScaffold: false, collectScrollable: true);
    while(sel.elements.isEmpty && shouldScroll && sel.canScrollMore()) {
      await sel.scrollMore();
      _populateChildrenDirect(elem, currentPath, sel, null, underScaffold: false, collectScrollable: false);
    }

    return sel.elements;
  }

  Future<TWidget?> matchWidget<TWidget extends Widget>(dynamic selector, { bool shouldScroll = true, bool ignoreUnderWidget = false }) async {
    final widgets = await matchWidgets(selector, expectedCount: 1, scrollIfMissing: shouldScroll, extraFrames: 1, ignoreUnderWidget: ignoreUnderWidget);
    if(widgets.isEmpty) {
      return null;
    }
    return widgets.first as TWidget;
  }

  Future<List<Widget>> matchWidgets(dynamic selector, { int? expectedCount, bool scrollIfMissing = true, bool ignoreUnderWidget = false, int extraFrames = 0 }) async {
    final elems = await findElementsFor(selector, ignoreUnderWidget: ignoreUnderWidget, shouldScroll: scrollIfMissing);
    if(expectedCount != null) {
      expect(elems, ft.hasLength(expectedCount), extraFrames: extraFrames+1);
    }
    return elems.map( (e) => e.widget ).toList();
  }

  Future<List<Widget>> matchDirectChildrenOf(dynamic selector, { List<AFWidgetID?>? expectedIds, bool shouldScroll = true, 
    bool ignoreUnderWidget = false, AFFilterWidgetDelegate? filterWidgets }) async {
    final elems = await findElementsFor(selector, ignoreUnderWidget: ignoreUnderWidget, shouldScroll: shouldScroll);
    if(elems.isEmpty) {
      throw AFException("Could not find element $selector");
    }
    if(elems.length > 1) {
      throw AFException("matchDirectChildrenOf should refer to exactly one widget.");
    }

    final sel = AFWidgetSelector.createSelector(activeSelectorPath, selector);
    final elem = elems.first;
    final extractor = AFibF.g.screenTests.findExtractor(AFExtractWidgetAction.extractChildren, elem);
    if(extractor == null) {
      throw AFException("No children extractor for element $selector with widget type ${elem.widget.runtimeType}");
    }
    dynamic resultDyn = extractor.extract(AFExtractWidgetAction.extractChildren, sel, elem);
    if(resultDyn is! List<Widget>) {
      throw AFException("The extractor ${extractor.runtimeType} did not return a list of widget children");
    }

    var result = resultDyn;

    if(filterWidgets != null) {
      result = result.where((e) => filterWidgets(e) ).toList();
    }

    if(expectedIds != null) {
      expectWidgetIds(result, expectedIds);
    }
    return result;
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

  Future<void> updateStateViews(dynamic data);

  Future<void> pauseForRender();
  @override
  void addError(String desc, int depth);

  // Go though all the children of [current], having the parent path [currentPath],
  // and add path entries for any widgets with keys.
  void _populateChildrenDirect(Element currentElem, List<Element> currentPath, AFWidgetSelector selector, AFScreenTestWidgetCollectorScrollableSubpath? parentScrollable, { required bool underScaffold, required bool collectScrollable }) {

    // add the current element.
    currentPath.add(currentElem);

    if(collectScrollable) {
      final scroller = AFibF.g.screenTests.findScroller(currentElem);
      if(scroller != null) {
        selector.scrollables.add(scroller.createScrollTracker(selector, currentElem));
      }
    }

    final key = currentPath.last.widget.key;
    if(key != null) {
      AFibD.logUIAF?.d("Found key $key");
    }

    if(selector.matchesPath(currentPath)) {
      final activeElement = selector.activeElementForPath(currentPath);
      if(activeElement != null) {
        if(!selector.contains(activeElement)) {
          selector.add(activeElement);
        }
      }
    }

    // do this same process recursively on the childrne.
    currentElem.visitChildren((child) {
      final nowUnderScaffold = underScaffold || currentElem.widget is Scaffold;
      _populateChildrenDirect(child, currentPath, selector, parentScrollable, underScaffold: nowUnderScaffold, collectScrollable: collectScrollable);
    });

    // maintain the path as we go back up.
    currentPath.removeLast();
  }

}

abstract class AFSingleScreenTestExecute extends AFScreenTestExecute {
  AFSingleScreenTestExecute(super.testId);
  @override
  bool isEnabled(AFBaseTestID id) { return true; }

  @override
  AFScreenID get activeScreenId {
    if(activeScreenIDs.isNotEmpty) {
      return activeScreenIDs.last;
    }

    return test!.createNavigatePush().screenId;
  }
}

class AFScreenTestDescription {
  final AFBaseTestID id;
  final String? description;
  final String? disabled;
  AFScreenTestDescription(this.id, this.description, this.disabled);
}


class AFScreenTestBody extends AFScreenTestDescription {
  final AFReusableScreenTestBodyExecuteDelegate body;
  final AFSingleScreenReusableBody? bodyReusable;
  final List<Object?> params;
  
  
  AFScreenTestBody({
    required AFScreenTestID id,
    required String? description,
    required this.body, 
    this.bodyReusable,
    required this.params,
    required String? disabled,
  }): super(id, description, disabled);

  bool get isReusable {
    return bodyReusable != null;
  }

  AFID get sectionId {
    final br = bodyReusable;
    if(br != null) {
      return br.id;
    }
    return AFUIScreenTestID.smoke;
  }
}

typedef AFCreateScreenIDDelegate = AFScreenID Function ();

class AFSingleScreenPrototypeBody {
  final AFPrototypeID? testId;
  final AFCreateScreenIDDelegate? screenIdCreator;
  final smokeTests = <AFScreenTestBody>[];
  final reusableTests = <AFScreenTestBody>[];
  final regressionTests = <AFScreenTestBody>[];

  AFSingleScreenPrototypeBody(this.testId,  { this.screenIdCreator });

  factory AFSingleScreenPrototypeBody.createReusable(AFScreenTestID id, {
    String? disabled,
    required List<Object?> params,
    String? description,
    required AFReusableScreenTestBodyExecuteDelegate body
  }) {
    final bodyTest = AFScreenTestBody(id: id, description: description, disabled: disabled, params: params, bodyReusable: null, body: body);
    final proto = AFSingleScreenPrototypeBody(null);
    proto.addReusable(bodyTest);
    return proto;
  }
  
  void addSmokeTest(AFScreenTestBody body) {
    _checkDuplicateTestId(body.id);
    smokeTests.add(body);
  }

  void _checkDuplicateTestId(AFID id) {
    if( _listContainsTestId(smokeTests, id) ||
      _listContainsTestId(reusableTests, id) ||
      _listContainsTestId(regressionTests, id) 
    ) {
      throw AFException("Test id $id was defined twice in $testId");
    }
  }

  bool _listContainsTestId(List<AFScreenTestBody> tests, AFID id) {
    return tests.where((t) => t.id == id).isNotEmpty;
  }

  void addReusable(AFScreenTestBody body) {
    _checkDuplicateTestId(body.id);
    reusableTests.add(body);
  }

  void defineSmokeTest({ AFScreenTestID id = AFUIScreenTestID.smoke, required AFScreenTestBodyExecuteDelegate body, String? description, String? disabled }) async {
    // in the first section, always add a scaffold widget collector.

    addSmokeTest(AFScreenTestBody(id: id, description: description, disabled: disabled, params: [], bodyReusable: null, body: (sse, params) async {
      await body(sse);
    }));
  }

  bool get hasReusable {
    return reusableTests.isNotEmpty;
  }

  void executeReusable(AFSingleScreenTests tests, AFScreenTestID bodyId, {
    String? description,
    String? disabled,
    required List<Object?> params,
  }) {
    final body = tests.findReusable(bodyId);
    if(body == null) {
      throw AFException("The reusable test $bodyId must be defined using tests.defineReusable");
    }
    final bodyTest = AFScreenTestBody(id: bodyId, description: description, disabled: disabled, body: body.body, bodyReusable: body, params: params);
    addReusable(bodyTest);
  }

  void _checkFutureExists(Future<void>? test) {
    if(test == null) {
      throw AFException("Test section failed to return a future.  You might be missing an async or await");
    }
  }

  void openTestDrawer(AFScreenTestID id) {
    final info = AFibF.g.testOnlyMostRecentScreen;
    final scaffoldState = findScaffoldState(info?.element as Element, underScaffold: false);
    scaffoldState?.openEndDrawer();
  }

  static ScaffoldState? findScaffoldState(Element elem, { required bool underScaffold }) {
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

  Future<void> _runTests(AFScreenTestExecute context, List<AFScreenTestBody> sections, { List<Object?>? params }) async {
    var sectionGuard = 0;
    var sectionPrev;
    for(final section in sections) {
      if(!context.isEnabled(section.sectionId as AFBaseTestID)) {
        continue;
      }

      context.printStartTest(section.id);

      final disabled = section.disabled;
      if(disabled != null) {
        context.markDisabled(section);
        context.printFinishTestDisabled(section.id, disabled);
        continue; 
      }

      sectionGuard++;
      if(sectionGuard > 1) {
        throw AFException("Test section ${sectionPrev.screenId} is missing an await!");
      }
      sectionPrev = section;


      params ??= section.params;

      context.startSection(section.id, resetSection: true);
      final paramsFull = AFTestParams(params);
      final fut = section.body(context, paramsFull);
      _checkFutureExists(fut);
      await fut;
      context.endSection();

      context.printFinishTest(section.id);
      sectionGuard--;
    }
  }

  Future<void> run(AFScreenTestExecute context, { List<Object?>? params, Function? onEnd}) async {
    await _runTests(context, smokeTests, params: params);
    await _runTests(context, reusableTests, params: params);
    await _runTests(context, regressionTests, params: params);
    if(onEnd != null) {
      onEnd();
    }
  }
}

class AFScreenTestWidgetCollectorScrollableSubpath {
  final List<Element> pathTo;

  AFScreenTestWidgetCollectorScrollableSubpath({required this.pathTo});

  factory AFScreenTestWidgetCollectorScrollableSubpath.create(List<Element> pathTo) {
    return AFScreenTestWidgetCollectorScrollableSubpath(pathTo: List<Element>.of(pathTo));
  }
}

abstract class AFScreenTestContext extends AFSingleScreenTestExecute {
  final AFDispatcher dispatcher;
  AFScreenTestContext(this.dispatcher, AFBaseTestID testId): super(testId);
  @override
  AFBaseTestID get testID { return this.testId; }

  @override
  Future<void> applyWidgetValue(dynamic selectorDyn, dynamic value, String applyType, { 
      AFUIVerifyDelegate? verify,
      int maxWidgets = 1, 
      int extraFrames = 0,
      bool ignoreUnderWidget = false, 
    }) async {
    AFibF.g.testOnlyClearRecentActions();
    final selector = AFWidgetSelector.createSelector(null, selectorDyn);
    final elems = await findElementsFor(selector, ignoreUnderWidget: ignoreUnderWidget, shouldScroll: true);
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

    final verifyUIContext = AFUIVerifyContext(
      actions: AFibF.g.testOnlyRecentActions,
      activeScreenId: activeScreenId,
      showResults: Map<AFScreenID, dynamic>.from(AFibF.g.testOnlyShowUIReturn),
    );

    if(verify != null) {
      verify(verifyUIContext);
    }

    await pauseForRender();
  }

  TExpected? expectType<TExpected>(dynamic obj) {
    if(obj is TExpected) {
      return obj;
    }
    addError("Unexpected type ${obj.runtimeType}", 2);
    return null;
  }
  
  @override
  Future<void> updateStateViews(dynamic stateViews) {
    final sv = AFibF.g.testData.resolveStateViewModels(stateViews);
    dispatcher.dispatch(AFUpdatePrototypeScreenTestModelsAction(this.testId, sv));
    return pauseForRender();
  }

  Future<void> yieldToRenderLoop() async {
    AFibD.logUIAF?.d("Starting yield to event loop");
    await Future<void>.delayed(const Duration(milliseconds: 100), () {});
  }

  @override
  Future<void> pauseForRender() async {
    return yieldToRenderLoop();
  }
}

class AFScreenTestContextSimulator extends AFScreenTestContext {
  final int runNumber;
  final DateTime lastRun = DateTime.now();
  final AFBaseTestID? selectedTest;

  AFScreenTestContextSimulator(super.dispatcher, super.testId, this.runNumber, this.selectedTest);

  @override
  bool isEnabled(AFBaseTestID id) { return selectedTest == null || selectedTest == id; }

  @override
  void addError(String desc, int depth) {
    final err = AFBaseTestExecute.composeError(desc, depth);
    dispatcher.dispatch(AFPrototypeScreenTestAddError(this.testId, err));
    //AFibD.log?.e(err);
  }

  @override
  bool addPassIf({required bool test}) {
    if(test) {
      dispatcher.dispatch(AFPrototypeScreenTestIncrementPassCount(this.testId));
    }
    return test;
  }
}

class AFScreenTestContextWidgetTester extends AFScreenTestContext {
  final ft.WidgetTester tester;
  final AFApp app;
  final AFCommandOutput output;
  final AFTestStats stats;

  AFScreenTestContextWidgetTester(this.tester, this.app, AFDispatcher dispatcher, AFBaseTestID testId, this.output, this.stats): super(dispatcher, testId);

  @override
  Future<void> pauseForRender() async {
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await super.pauseForRender();
  }

  @override
  Future<void> yieldToRenderLoop() async {
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  @override
  void indentOutput() { output.indent(); }

  @override 
  void outdentOutput() { output.outdent(); }

  @override
  void printTestTitle(AFID id) {
    AFBaseTestExecute.printTitleColumn(output, id.codeId);    
    output.endLine();
  }

  @override
  void printStartTest(AFID id) {
    var title = id.codeId;
    if(id is AFScreenID) {
      title = "onScreen: ${id.codeId}";
    }
    AFBaseTestExecute.printTitleColumn(output, title, fill: ".");    
  }

  @override
  void printFinishTestDisabled(AFID id, String disabled) {
    AFBaseTestExecute.printResultColumn(output, suffix: disabled, color: Styles.YELLOW);
    output.endLine();
    stats.addDisabled(1);
  }

  @override
  void printFinishTest(AFID id) {
    final errors = sectionErrors[id];
    if(errors == null) throw AFException("No errors for $id");
    AFBaseTestExecute.printResultColumn(output, count: errors.pass, suffix: " passed", color: Styles.GREEN);
    output.endLine();
    stats.addPasses(errors.pass);
    final errorCount = errors.errorCount;
    if(errorCount > 0) {
      stats.addErrors(errors);
      AFBaseTestExecute.printErrors(output, errors.errors);
    } 

  }


}

abstract class AFScreenPrototype {
  static const testDrawerSideEnd = 1;
  static const testDrawerSideBegin = 2;

  final AFUIType uiType;
  final AFPrototypeID id;
  final int testDrawerSide;

  AFScreenPrototype({
    required this.uiType,
    required this.id,
    this.testDrawerSide = testDrawerSideEnd
  });

  AFID get displayId;
  List<AFScreenTestDescription> get smokeTests;
  List<AFScreenTestDescription> get reusableTests;
  List<AFScreenTestDescription> get regressionTests;
  AFTestTimeHandling get timeHandling;
  AFSingleScreenPrototypeBody get singleScreenBody;

  bool get hasTests { 
    return (smokeTests.isNotEmpty ||
            reusableTests.isNotEmpty || 
            regressionTests.isNotEmpty);
  }  

  bool get hasReusable {
    return reusableTests.isNotEmpty;
  }

  AFNavigatePushAction? get navigate;
  AFNavigateWithOnEventContextDelegate? get navigateWithEventContext;

  List<String> paramDescriptions(AFScreenTestID id) { return <String>[]; }
  List<AFScreenTestID> get sectionIds { return <AFScreenTestID>[]; }
  void startScreen(AFDispatcher dispatcher, BuildContext? flutterContext, AFDefineTestDataContext registry, { AFRouteParam? routeParam, List<Object>? stateView });
  Future<void> run(AFScreenTestContext context, { Function onEnd});
  void onDrawerReset(AFDispatcher dispatcher);
  Future<void> onDrawerRun(AFBuildContext context, AFScreenTestContextSimulator? prevContext, AFSingleScreenTestState state, AFScreenTestID testId, Function onEnd);
  void openTestDrawer(AFScreenTestID id);
  dynamic get stateView;
  bool get isTestDrawerEnd { return testDrawerSide == testDrawerSideEnd; }
  bool get isTestDrawerBegin { return testDrawerSide == testDrawerSideBegin; }

  AFNavigatePushAction createNavigatePush() {
    return AFScreenPrototype.createNavigatePushStatic(
      navigate: navigate,
      navigateWithEventContext: navigateWithEventContext,
      stateView: stateView,
    );
  }

  static AFNavigatePushAction createNavigatePushStatic({
    required AFNavigatePushAction? navigate,
    required AFNavigateWithOnEventContextDelegate? navigateWithEventContext,
    required dynamic stateView
  }) {
    if(navigate != null) {
      return navigate;
    }

    if(navigateWithEventContext == null) {
      const msg = "You must specify either navigate or navigateWithEventContext";
      assert(false, msg);
      return AFUIUnimplementedScreen.navigatePush(msg);
    }

    if(stateView == null) {
      const msg = "You must specify a state view with navigateWithEventContext";
      assert(false, msg);
      return AFUIUnimplementedScreen.navigatePush(msg);
    }



    final eventContext = AFTestOnEventContext(
      dispatcher: AFibF.g.internalOnlyActiveDispatcher,
      stateView: stateView
    );

    return navigateWithEventContext(eventContext);
  }


  AFScreenTestContextSimulator prepareRun(AFDispatcher dispatcher, AFScreenTestContextSimulator? prevContext, AFScreenTestID idSelected) {
    onDrawerReset(dispatcher);
    var runNumber = 1;
    final rN = prevContext?.runNumber;
    if(rN != null) {
      runNumber = rN + 1;
    }

    final testContext = AFScreenTestContextSimulator(dispatcher, this.id, runNumber, idSelected);
    dispatcher.dispatch(AFStartPrototypeScreenTestContextAction(testContext, navigate: createNavigatePush(), models: this.stateView, timeHandling: this.timeHandling));
    return testContext;
  }
}

abstract class AFScreenLikePrototype extends AFScreenPrototype {
  @override
  dynamic stateView;
  final AFSingleScreenPrototypeBody body;
  //final AFConnectedScreenWithoutRoute screen;
  @override
  final AFNavigatePushAction? navigate;
  @override
  final AFTestTimeHandling timeHandling;

  @override
  AFNavigateWithOnEventContextDelegate? navigateWithEventContext;

  AFScreenLikePrototype({
    required super.id,
    required this.stateView,
    required this.navigate,
    required this.navigateWithEventContext,
    required this.body,
    required this.timeHandling,
    required super.uiType,
  });

  @override
  AFID get displayId {
    return id;
  }

  @override
  void openTestDrawer(AFScreenTestID id) {
    body.openTestDrawer(id);
  }

  @override
  AFSingleScreenPrototypeBody get singleScreenBody {
    return body;
  }

  @override
  List<AFScreenTestDescription> get smokeTests { return List<AFScreenTestDescription>.from(body.smokeTests); }
  @override
  List<AFScreenTestDescription> get reusableTests { return  List<AFScreenTestDescription>.from(body.reusableTests); }
  @override
  List<AFScreenTestDescription> get regressionTests { return  List<AFScreenTestDescription>.from(body.regressionTests); }
  
  @override
  Future<void> run(AFScreenTestExecute context, { List<Object?>? params, Function? onEnd}) {
    return body.run(context, onEnd: onEnd, params: params);
  }

  @override
  Future<void> onDrawerRun(AFBuildContext context, AFScreenTestContextSimulator? prevContext, AFSingleScreenTestState state, AFScreenTestID id, Function onEnd) async {
    final dispatcher = context.d;
    final testContext = prepareRun(dispatcher, prevContext, id);
    return run(testContext, onEnd: onEnd);
  }

}

/// All the information necessary to render a single screen for
/// prototyping and testing.
class AFSingleScreenPrototype extends AFScreenLikePrototype {

  AFSingleScreenPrototype({
    required super.id,
    required super.stateView,
    super.navigate,
    super.navigateWithEventContext,
    required super.body,
    required super.timeHandling,
  }): super(
    uiType: AFUIType.screen
  );


  @override
  void startScreen(AFDispatcher dispatcher, BuildContext? flutterContext, AFDefineTestDataContext registry, { AFRouteParam? routeParam, List<Object>? stateView }) {
    final ms = stateView ?? this.stateView;
    final rvp = routeParam ?? this.createNavigatePush().param;
    final actualModels = registry.resolveStateViewModels(ms);
    final rp = registry.find(rvp);
    

    if(timeHandling == AFTestTimeHandling.running) {
      final baseTime = actualModels["AFTimeState"] as AFTimeState?;
      if(baseTime == null) {
        throw AFException("If you specify runTine for a screen or widget test, you must include an AFTimeState instance in your models.");
      }
      dispatcher.dispatch(AFTimeUpdateListenerQuery(baseTime: baseTime));
    }

    final navigate = this.createNavigatePush();
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(
      this, 
      navigate: navigate,
      models: actualModels, 
    ));
    dispatcher.dispatch(AFNavigatePushAction(
      launchParam: rp,
      children: navigate.children,
      createDefaultChildParam: navigate.createDefaultChildParam,
    ));

  }


  static void resetTestParam(AFDispatcher dispatcher, AFBaseTestID testId, AFNavigatePushAction navigate) {
    final d = AFSingleScreenTestDispatcher(testId, dispatcher, null);
    d.dispatch(AFNavigateSetParamAction(
      param: navigate.param,
      children: navigate.children
    ));
  }

  @override
  void onDrawerReset(AFDispatcher dispatcher) {
    AFSingleScreenPrototype.resetTestParam(dispatcher, this.id, this.createNavigatePush());
    final sv = AFibF.g.testData.resolveStateViewModels(this.stateView);
    dispatcher.dispatch(AFUpdatePrototypeScreenTestModelsAction(this.id, sv));
  }

}


abstract class AFWidgetPrototype extends AFScreenPrototype {
  @override
  final dynamic stateView;
  final AFSingleScreenPrototypeBody body;
  final AFRenderConnectedChildDelegate render;
  final AFCreateWidgetWrapperDelegate? createWidgetWrapperDelegate;

  AFWidgetPrototype({
    required super.id,
    required this.body,
    required this.stateView,
    required this.render,
    this.createWidgetWrapperDelegate,
    String? title
  }): super(uiType: AFUIType.widget);

  @override
  AFID get displayId {
    return id;
  }
  
  AFScreenID get screenId {
    return AFUIScreenID.screenPrototypeWidget;
  }

  @override
  void openTestDrawer(AFScreenTestID id) {
    body.openTestDrawer(id);
  }

  @override
  AFSingleScreenPrototypeBody get singleScreenBody {
    return body;
  }

  @override
  void startScreen(AFDispatcher dispatcher,  BuildContext? flutterContext, AFDefineTestDataContext registry, { AFRouteParam? routeParam, List<Object>? stateView }) {
    final ms = stateView ?? this.stateView;
    final rpp = routeParam ?? this.createNavigatePush().param;

    final actualModels = registry.find(ms);
    final rp = registry.find(rpp);
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(this, 
      models: actualModels, 
      navigate: AFNavigatePushAction(launchParam: AFRouteParamWrapper(screenId: AFUIScreenID.screenPrototypeWidget, original: rp)),
    ));
    dispatcher.dispatch(AFUIPrototypeWidgetScreen.navigatePush(this, id: this.id));    
  }
  
  @override
  Future<void> run(AFScreenTestExecute context, { Function? onEnd }) {
    return body.run(context, onEnd: onEnd);
  }

  @override
  Future<void> onDrawerRun(AFBuildContext context, AFScreenTestContextSimulator? prevContext, AFSingleScreenTestState state, AFScreenTestID selectedTestId, Function onEnd) async {
    //final screenUpdateCount = AFibF.testOnlyScreenUpdateCount(screenId);
    final testContext = prepareRun(context.dispatcher, prevContext, selectedTestId);
    //await testContext.pauseForRender(screenUpdateCount, true);
    run(testContext, onEnd: onEnd);
    return;
  }
}

 
/// All the information necessary to render a single screen for
/// prototyping and testing.
class AFConnectedWidgetPrototype extends AFWidgetPrototype {
  final AFRouteParam routeParam;
  final List<AFRouteParam>? children;
  @override
  final AFTestTimeHandling timeHandling;

  AFConnectedWidgetPrototype({
    required super.id,
    required dynamic models,
    required this.routeParam,
    this.children,
    required super.render,
    required super.body,
    required this.timeHandling,
  }): super(stateView: models);

  @override
  List<AFScreenTestDescription> get smokeTests { return List<AFScreenTestDescription>.from(body.smokeTests); }
  @override
  List<AFScreenTestDescription> get reusableTests { return  List<AFScreenTestDescription>.from(body.reusableTests); }
  @override
  List<AFScreenTestDescription> get regressionTests { return  List<AFScreenTestDescription>.from(body.regressionTests); }
  @override
  AFNavigatePushAction get navigate { 
    return AFNavigatePushAction(launchParam: AFRouteParamWrapper(original: routeParam, screenId: AFUIScreenID.screenPrototypeWidget));
  }

  /// This is not relevant, [navigate] is always used in this case.
  @override
  AFNavigateWithOnEventContextDelegate? get navigateWithEventContext { return null; }


  @override
  void onDrawerReset(AFDispatcher dispatcher) {
    assert(false);
    /*
    dispatcher.dispatch(AFNavigateSetParamAction(
      param: AFUIPrototypeWidgetRouteParam(test: this, routeParam: this.routeParam),
    ));
    final sv = AFibF.g.testData.resolveStateViewModels(this.models);
    dispatcher.dispatch(AFUpdatePrototypeScreenTestModelsAction(this.id, sv));
    */
  }

}


class AFDialogPrototype extends AFScreenLikePrototype {

  AFDialogPrototype({
    required super.id,
    required dynamic models,
    super.navigate,
    super.navigateWithEventContext,
    required super.body,
    required super.timeHandling,
  }): super(
    stateView: models, uiType: AFUIType.dialog);

  AFScreenID get screenId {
    return AFUIScreenID.screenPrototypeDialog;
  }

  @override
  void startScreen(AFDispatcher dispatcher, BuildContext? flutterContext, AFDefineTestDataContext registry, { AFRouteParam? routeParam, List<Object>? stateView }) {
    final ms = stateView ?? this.stateView;
    final rpp = routeParam ?? this.createNavigatePush().param;

    final actualModels = registry.find(ms);
    final rp = registry.find(rpp);
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(this, 
      models: actualModels, 
      navigate: AFNavigatePushAction(launchParam: AFRouteParamWrapper(screenId: AFUIScreenID.screenPrototypeWidget, original: rp)),
    ));
    dispatcher.dispatch(AFUIPrototypeDialogScreen.navigatePush(this, id: this.id));    
  }

  @override
  void onDrawerReset(AFDispatcher dispatcher) {
  }

  
  @override
  Future<void> onDrawerRun(AFBuildContext context, AFScreenTestContextSimulator? prevContext, AFSingleScreenTestState state, AFScreenTestID selectedTestId, Function onEnd) async {
    final dispatcher = context.d;
    //final screenUpdateCount = AFibF.testOnlyScreenUpdateCount(screenId);
    final testContext = prepareRun(dispatcher, prevContext, selectedTestId);

    final buildContext = AFibF.g.testOnlyShowBuildContext(AFUIType.drawer);
    assert(buildContext != null);

    // show the dialog, but don't wait it, because it won't return until the dialog is closed.
    AFContextShowMixin.showDialogStatic(
        dispatch: dispatcher.dispatch,
        navigate: createNavigatePush(),
        flutterContext: buildContext,
        executeBefore: null,
        executeDuring: null,
    );
   
    // instead, wait for the dialog to be displayed, then run the test.
    Future.delayed(const Duration(milliseconds: 500), () {
      run(testContext, onEnd: onEnd);
    });
  }
}

class AFBottomSheetPrototype extends AFScreenLikePrototype {

  AFBottomSheetPrototype({
    required super.id,
    required dynamic models,
    super.navigate,
    super.navigateWithEventContext,
    required super.body,
    required super.timeHandling,
  }): super(
    stateView: models,
    uiType: AFUIType.bottomSheet
  );

  AFScreenID get screenId {
    return AFUIScreenID.screenPrototypeBottomSheet;
  }

  @override
  void startScreen(AFDispatcher dispatcher, BuildContext? flutterContext, AFDefineTestDataContext registry, { AFRouteParam? routeParam, List<Object>? stateView }) {
    final ms = stateView ?? this.stateView;
    final rpp = routeParam ?? this.createNavigatePush().param;

    final actualModels = registry.find(ms);
    final rp = registry.find(rpp);
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(this, 
      models: actualModels, 
      navigate: AFNavigatePushAction(launchParam: AFRouteParamWrapper(screenId: AFUIScreenID.screenPrototypeWidget, original: rp)),
    ));
    dispatcher.dispatch(AFUIPrototypeBottomSheetScreen.navigatePush(this, id: this.id));    
  }

  @override
  void onDrawerReset(AFDispatcher dispatcher) {
  }

  @override
  Future<void> onDrawerRun(AFBuildContext context, AFScreenTestContextSimulator? prevContext, AFSingleScreenTestState state, AFScreenTestID selectedTestId, Function onEnd) async {
    final dispatcher = context.d;
    //final screenUpdateCount = AFibF.testOnlyScreenUpdateCount(screenId);
    final testContext = prepareRun(dispatcher, prevContext, selectedTestId);

    final buildContext = AFibF.g.testOnlyShowBuildContext(AFUIType.bottomSheet);
    assert(buildContext != null);

    // show the dialog, but don't wait it, because it won't return until the dialog is closed.
    AFContextShowMixin.showModalBottomSheetStatic(
        dispatch: dispatcher.dispatch,
        navigate: createNavigatePush(),
        flutterContext: buildContext,
        executeBefore: null,
        executeDuring: null,
    );
   
    // instead, wait for the dialog to be displayed, then run the test.
    Future.delayed(const Duration(milliseconds: 500), () {
      run(testContext, onEnd: onEnd);
    });
  }
}

class AFDrawerPrototype extends AFScreenLikePrototype {

  AFDrawerPrototype({
    required super.id,
    required dynamic models,
    super.navigate,
    super.navigateWithEventContext,
    required super.body,
    required super.timeHandling,
  }): super(
    stateView: models,
    uiType: AFUIType.drawer
  );

  AFScreenID get screenId {
    return AFUIScreenID.screenPrototypeDrawer;
  }

  @override
  void startScreen(AFDispatcher dispatcher, BuildContext? flutterContext, AFDefineTestDataContext registry, { AFRouteParam? routeParam, List<Object>? stateView }) {
    final ms = stateView ?? this.stateView;
    final rpp = routeParam ?? this.createNavigatePush().param;

    final actualModels = registry.find(ms);
    final rp = registry.find(rpp);
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(this, 
      models: actualModels, 
      navigate: AFNavigatePushAction(launchParam: AFRouteParamWrapper(screenId: AFUIScreenID.screenPrototypeWidget, original: rp)),
    ));
    dispatcher.dispatch(AFUIPrototypeDrawerScreen.navigatePush(this, id: this.id));    
  }

  @override
  void onDrawerReset(AFDispatcher dispatcher) {
  }

  @override
  Future<void> onDrawerRun(AFBuildContext context, AFScreenTestContextSimulator? prevContext, AFSingleScreenTestState state, AFScreenTestID selectedTestId, Function onEnd) async {
    final dispatcher = context.d;
    //final screenUpdateCount = AFibF.testOnlyScreenUpdateCount(screenId);
    final testContext = prepareRun(dispatcher, prevContext, selectedTestId);

    final buildContext = AFibF.g.testOnlyShowBuildContext(AFUIType.drawer);
    assert(buildContext != null);

    // show the dialog, but don't wait it, because it won't return until the dialog is closed.
    AFContextShowMixin.showDrawerStatic(
        dispatch: dispatcher.dispatch,
        navigate: navigate,
        flutterContext: buildContext,
    );
   
    // instead, wait for the dialog to be displayed, then run the test.
    Future.delayed(const Duration(milliseconds: 500), () {
      run(testContext, onEnd: onEnd);
    });
    return;
  }
}

/// The information necessary to start a test with a baseline state
/// (determined by a state test) and an initial screen/route.
class AFWorkflowStatePrototype extends AFScreenPrototype {
  final AFStateTestID stateTestId;
  final AFWorkflowStateTestPrototype body;
  final AFID? actualDisplayId;

  AFWorkflowStatePrototype({
    required super.id,
    required this.stateTestId,
    required this.body,
    this.actualDisplayId,
  }): super(uiType: AFUIType.screen);

  @override
  List<AFScreenTestDescription> get smokeTests { return List<AFScreenTestDescription>.from(body.smokeTests); }
  @override
  List<AFScreenTestDescription> get reusableTests { return  List<AFScreenTestDescription>.from(body.reusableTests); }
  @override
  List<AFScreenTestDescription> get regressionTests { return  List<AFScreenTestDescription>.from(body.regressionTests); }
  
  @override
  AFTestTimeHandling get timeHandling { return AFTestTimeHandling.running; }

  @override
  AFSingleScreenPrototypeBody get singleScreenBody {
    throw UnimplementedError();
  }

  @override
  AFID get displayId {
    return actualDisplayId ?? id;
  }

  @override
  dynamic get stateView { return null; }
  dynamic get routeParam { return null; }
  @override
  AFNavigatePushAction get navigate { return AFNavigatePushAction(launchParam: AFRouteParamUnused.unused); }
  @override
  AFNavigateWithOnEventContextDelegate? get navigateWithEventContext { return null; }


  @override
  void openTestDrawer(AFScreenTestID id) {
    body.openTestDrawer(id);
  }

  /*
  AFScreenID get screenId {
    return body.initialScreenId;
  }
  */

  AFSingleScreenTests get screenTests {
    return AFibF.g.screenTests;
  }

  @override
  void startScreen(AFDispatcher dispatcher, BuildContext? flutterContext, AFDefineTestDataContext registry, { AFRouteParam? routeParam, List<Object>? stateView }) {
    initializeMultiscreenPrototype(dispatcher, this);
  }

  static void initializeMultiscreenPrototype(AFDispatcher dispatcher, AFWorkflowStatePrototype test) {
    AFibF.g.isInteractiveStateTestContext = false;
    dispatcher.dispatch(AFResetToInitialStateAction());
    dispatcher.dispatch(AFUpdateActivePrototypeAction(prototypeId: test.id));

    final screenMap = AFibF.g.screenMap;
    dispatcher.dispatch(AFNavigatePushAction(
      launchParam: screenMap.trueCreateStartupScreenParam!.call()
    ));
    dispatcher.dispatch(AFStartPrototypeScreenTestAction(test, navigate: test.navigate));

    // lookup the test.
    final testImpl = AFibF.g.stateTests.findById(test.stateTestId);
    if(testImpl == null) throw AFException("Test with ID ${test.stateTestId} not found");
    
    // then, execute the desired state test to bring us to our desired state.
    final store = AFibF.g.internalOnlyActiveStore;
    //final mainDispatcher = AFStoreDispatcher(store);    
    //final stateDispatcher = AFStateScreenTestDispatcher(mainDispatcher);

    final stateTestContext = AFStateTestContextForState(testImpl,  AFConceptualStore.appStore, isTrueTestContext: false);
    testImpl.execute(stateTestContext);
    //stateTestContext.dispatcher = mainDispatcher;


    if(stateTestContext.errors.hasErrors) {
      // TODO: this has errors, need to investigate why!
    }

    // now, perform an action that navigates to the specified path, only in flutter.
    final route = store.state.public.route;
    dispatcher.dispatch(AFNavigateSyncNavigatorStateWithRoute(route));
    final showingScreens = route.activeShowingScreens;
    if(showingScreens.length > 1) {
      throw AFException("Currently, you cannot jump into a state test at a point where more than one transient UI element (dialog, drawer, bottomsheet) is simultaneously showing");
    }
    if(showingScreens.isNotEmpty) {
      final showingScreen = showingScreens.first;
      // this occurs when a dialog, bottomsheet, or drawer is actively displayed 
      // in the current route.   In this scenario, we have already executed the 
      // state part of opening the dialog, etc, but we haven't actually done the open
      // because we didn't have a BuildContext at the time.   So, below, we do the 
      // actual open, then make sure to route the result through the expected code-path
      // as though it had been opened the normal way.
      Future.delayed(const Duration(seconds: 1), () async {
        final uiType = showingScreen.kind;
        final showScreenId = showingScreen.screenId;

        final builder = AFibF.g.screenMap.findBy(showScreenId);
        final ctx = AFibF.g.testOnlyScreenBuildContextMap[route.activeScreenId];
        assert(builder != null && ctx != null);
        if(builder != null && ctx != null) {
          var result;
          if(uiType == AFUIType.dialog) {          
            result = await material.showDialog(
              context: ctx,
              builder: builder
            );
          } else if(uiType == AFUIType.bottomSheet) {
            result = await material.showModalBottomSheet(
              context: ctx, 
              builder: builder
            );
          } else if(uiType == AFUIType.drawer) {
            final scaffold = material.Scaffold.of(ctx);
            scaffold.openDrawer();
          } else {
            assert(false, "Unsupposed UI type");
          }

          if(uiType == AFUIType.dialog || uiType == AFUIType.bottomSheet) {
            AFibF.g.testOnlySimulateCloseDialogOrSheet(showScreenId, result);
          }
        }
      });   
    }
    AFibF.g.isInteractiveStateTestContext = true;
  }


  @override
  Future<void> run(AFScreenTestContext context, { Function? onEnd}) {
    return body.run(context, onEnd: onEnd);
  }

  @override
  void onDrawerReset(AFDispatcher dispatcher) {
    dispatcher.dispatch(AFNavigateExitTestAction());
    initializeMultiscreenPrototype(dispatcher, this);
  }

  @override
  Future<void> onDrawerRun(AFBuildContext context, AFScreenTestContextSimulator? prevContext, AFSingleScreenTestState state, AFScreenTestID selectedTestId, Function onEnd) async {
    final testContext = prepareRun(context.d, prevContext, selectedTestId);
    return run(testContext, onEnd: onEnd);
  }
}

abstract class AFScreenKindTests<TState, TPrototype extends AFScreenPrototype> {
  final _connectedTests = <TPrototype>[];
  
  AFSingleScreenPrototypeBody addConnectedPrototype({
    required AFPrototypeID   id,
    Object? models,
    required AFNavigatePushAction navigate,
    AFTestTimeHandling timeHandling = AFTestTimeHandling.paused,
  }) {
    final sv = AFibF.g.testData.resolveStateViewModels(models);    
    final instance = createPrototype(
      id: id,
      models: sv,
      navigate: navigate,
      body: AFSingleScreenPrototypeBody(id),
      timeHandling: timeHandling,
    );
    _connectedTests.add(instance);
    return instance.singleScreenBody;
  }

  TPrototype createPrototype({
    required AFPrototypeID   id,
    required Object? models,
    required AFNavigatePushAction navigate,
    required AFTestTimeHandling timeHandling,
    required AFSingleScreenPrototypeBody body,
  });

  TPrototype? findById(AFBaseTestID id) {
    return _connectedTests.firstWhereOrNull( (test) => test.id == id);
  }

  void findByTokens(List<String> tokens, List<AFScreenPrototype> results) {
    results.addAll(_connectedTests.where((test) {
      return AFSingleScreenTests.matchesTokens(test.id, tokens);
    }));
  }


  List<TPrototype> get all {
    return _connectedTests;
  }
}


/// Used to register connected or unconnected widget tests.
class AFWidgetTests<TState> {
  final _connectedTests = <AFWidgetPrototype>[];
  
  AFSingleScreenPrototypeBody addConnectedPrototype({
    required AFPrototypeID   id,
    required AFRenderConnectedChildDelegate render,
    dynamic models,
    List<AFRouteParam>? children,
    required AFRouteParam routeParam,
    AFNavigatePushAction? navigate,
    AFTestTimeHandling timeHandling = AFTestTimeHandling.paused,
  }) {
    final sv = AFibF.g.testData.resolveStateViewModels(models);    
    final instance = AFConnectedWidgetPrototype(
      id: id,
      models: sv,
      routeParam: routeParam,
      children: children,
      render: render,
      body: AFSingleScreenPrototypeBody(id),
      timeHandling: timeHandling,
    );
    _connectedTests.add(instance);
    return instance.body;
  }

  AFWidgetPrototype? findById(AFBaseTestID id) {
    return _connectedTests.firstWhereOrNull( (test) => test.id == id);
  }

  void findByTokens(List<String> tokens, List<AFScreenPrototype> results) {
    results.addAll(_connectedTests.where((test) {
      return AFSingleScreenTests.matchesTokens(test.id, tokens);
    }));
  }
  

  List<AFWidgetPrototype> get all {
    return _connectedTests;
  }
}

/// Used to register connected or unconnected widget tests.
class AFDialogTests<TState> extends AFScreenKindTests<TState, AFDialogPrototype> {
  
  @override
  AFDialogPrototype createPrototype({
    required AFPrototypeID   id,
    Object? models,
    required AFNavigatePushAction navigate,
    required AFTestTimeHandling timeHandling,
    required AFSingleScreenPrototypeBody body,
  }) {
    return AFDialogPrototype(
      id: id,
      models: models,
      navigate: navigate,
      timeHandling: timeHandling,
      body: body
    );
  }

}

/// Used to register connected or unconnected widget tests.
class AFBottomSheetTests<TState> extends AFScreenKindTests<TState, AFBottomSheetPrototype> {

  @override
  AFBottomSheetPrototype createPrototype({
    required AFPrototypeID   id,
    Object? models,
    required AFNavigatePushAction navigate,
    required AFTestTimeHandling timeHandling,
    required AFSingleScreenPrototypeBody body,
  }) {
    return AFBottomSheetPrototype(
      id: id,
      models: models,
      navigate: navigate,
      timeHandling: timeHandling,
      body: body
    );
  }
}

/// Used to register connected or unconnected widget tests.
class AFDrawerTests<TState> extends AFScreenKindTests<TState, AFDrawerPrototype> {
  @override
  AFDrawerPrototype createPrototype({
    required AFPrototypeID   id,
    Object? models,
    required AFNavigatePushAction navigate,
    required AFTestTimeHandling timeHandling,
    required AFSingleScreenPrototypeBody body,
  }) {
    return AFDrawerPrototype(
      id: id,
      models: models,
      navigate: navigate,
      timeHandling: timeHandling,
      body: body
    );
  }
}


@immutable
class AFSingleScreenReusableBody {
  final AFScreenTestID id;
  final AFSingleScreenPrototypeBody prototype;
  final AFReusableScreenTestBodyExecuteDelegate body;

  const AFSingleScreenReusableBody({
    required this.id,
    required this.prototype, 
    required this.body,
  });

  List<String> get paramDescriptions {
    final result = <String>[];
    return result;
  }
  }

/// This class is used to create canned versions of screens and widget populated
/// with specific data for testing and prototyping purposes.
class AFSingleScreenTests<TState> {
  
  final _singleScreenTests = <AFSingleScreenPrototype>[];
  final reusable = <AFScreenTestID, AFSingleScreenReusableBody>{};

  AFSingleScreenTests();

  List<AFSingleScreenPrototype> get all {
    return _singleScreenTests;
  }

  void defineReusableTest({
    required AFScreenTestID id, 
    required AFSingleScreenPrototypeBody prototype, 
    required AFReusableScreenTestBodyExecuteDelegate body,
    required List<Object?> params
  }) {
    if(reusable.containsKey(id)) {
      throw AFException("Duplicate definition for $id");
    }

    reusable[id] = AFSingleScreenReusableBody(
      id: id,
      prototype: prototype,
      body: (sse, params) async {
        await body(sse, params);
      }
    );
  }

  AFSingleScreenReusableBody? findReusable(AFScreenTestID id) {
    return reusable[id];
  }

  AFExtractWidgetAction? findExtractor(String actionType, Element elem) {
    for(final extractor in AFibF.g.sharedTestContext.extractors) {
      if(extractor.matches(actionType, elem)) {
        return extractor;
      }
    }
    return null;
  }

  AFApplyWidgetAction? findApplicator(String actionType, Element elem) {
    for(final apply in AFibF.g.sharedTestContext.applicators) {
      if(apply.matches(actionType, elem)) {
        return apply;
      }
    }
    return null;
  }

  AFScrollerAction? findScroller(Element elem) {
    for(final scroller in AFibF.g.sharedTestContext.scrollers) {
      if(scroller.matches(elem)) {
        return scroller;
      }
    }
    return null;
  }

  /// Add a prototype of a particular screen with the specified [stateView]
  /// and an initial route parameter from [navigate].  
  /// 
  /// Returns an [AFSingleScreenPrototypeBody], which can be used to create a 
  /// test for the screen.
  AFSingleScreenPrototypeBody addPrototype({
    required AFPrototypeID   id,
    required dynamic stateView,
    required AFNavigatePushAction? navigate,
    required AFNavigateWithOnEventContextDelegate? navigateWithEventContext,
    required AFTestTimeHandling timeHandling
  }) {
    final instance = AFSingleScreenPrototype(
      id: id,
      stateView: stateView,
      navigate: navigate,
      navigateWithEventContext: navigateWithEventContext,
      body: AFSingleScreenPrototypeBody(id, screenIdCreator: () {
        final nav = AFScreenPrototype.createNavigatePushStatic(
          navigate: navigate, 
          navigateWithEventContext: navigateWithEventContext, 
          stateView: stateView
        );

        return nav.screenId;
      }),
      timeHandling: timeHandling
    );
    _singleScreenTests.add(instance);
    return instance.body;
  }

  AFSingleScreenPrototype? findById(AFBaseTestID id) {
    return _singleScreenTests.firstWhereOrNull((test) => test.id == id);
  }

  void findByTokens(List<String> tokens, List<AFScreenPrototype> results) {
    results.addAll(_singleScreenTests.where((test) {
      return AFSingleScreenTests.matchesTokens(test.id, tokens);
    }));
  }

  static bool matchesTokens(AFBaseTestID id, List<String> tokens) {
    final idLower = id.code.toLowerCase();
    for(final token in tokens) {
      if(!idLower.contains(token)) {
        return false;
      }
    }
    return true;
  }


  void registerData(dynamic id, dynamic data) {
    AFibF.g.testData.define(id, data);
  }

  dynamic findData(dynamic id) {
    return AFibF.g.testData.find(id);
  }

  bool addPassIf({required bool test}) {
    if(test) {
      
    }
    return test;
  }
}

abstract class AFWorkflowTestExecute {
  Future<void> tapNavigateFromTo({
    required dynamic tap,
    required AFScreenID startScreen,
    dynamic tapData,
    AFScreenID? endScreen,
    bool verifyScreen = true
  });

  Future<void> expectState<TState extends AFComponentState>( Future<void> Function(TState, AFRouteState) withState) async {
    assert(TState != AFComponentState, "You must specify the state type as a type parameter");
    final public = AFibF.g.internalOnlyActiveStore.state.public;
    return withState(public.componentState<TState>(), public.route);
  }

  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.test);
  }

  void expect(dynamic value, ft.Matcher matcher, {int extraFrames = 0});

  Future<void> runScreenTest(AFScreenTestID screenTestId, AFWorkflowTestDefinitionContext definitions, {AFScreenID? terminalScreen, List<Object?>? params, AFBaseTestID? queryResults});
  Future<void> runWidgetTest(AFBaseTestID widgetTestId, AFScreenID originScreen, {AFScreenID? terminalScreen, AFBaseTestID? queryResults});
  Future<void> onScreen({
    required AFScreenID startScreen, 
    AFScreenID? endScreen, 
    AFBaseTestID? queryResults, 
    required Function(AFScreenTestExecute) body,
    bool verifyScreen = true });
  Future<void> tapOpenDrawer({
    required dynamic tap,
    required AFScreenID startScreen,
    required AFScreenID drawerId
  });
  Future<void> onDrawer({
    required AFScreenID drawerId, 
    AFScreenID? endScreen, 
    AFBaseTestID? queryResults, 
    required Function(AFScreenTestExecute) body,
  });
  
  Future<void> pushQueryListener<TQueryResponse>(AFAsyncListenerQuery specifier, AFWorkflowTestDefinitionContext definitions, dynamic testData);
}



class AFWorkflowTestContext extends AFWorkflowTestExecute {
  final AFScreenTestContext screenContext;

  AFWorkflowTestContext(this.screenContext);  

  @override
  void expect(dynamic value, ft.Matcher matcher, {int extraFrames = 0}) {
    screenContext.expect(value, matcher, extraFrames: extraFrames+1);
  }

  /// Execute the specified screen tests, with query-responses provided by the specified state test.
  @override
  Future<void> runScreenTest(AFScreenTestID screenTestId, AFWorkflowTestDefinitionContext definitions, {AFScreenID? terminalScreen, List<Object?>? params, AFBaseTestID? queryResults}) async {
    _installQueryResults(queryResults);
    final paramsFull = params?.map<Object?>( (e) => definitions.td(e)).toList();
    final originalScreenId = await internalRunScreenTest(screenTestId, screenContext, paramsFull);

    if(terminalScreen != null && originalScreenId != terminalScreen) {
      await screenContext.pauseForRender();
    } 
  }

  @override
  Future<void> pushQueryListener<TQueryResponse>(AFAsyncListenerQuery query, AFWorkflowTestDefinitionContext definitions, dynamic testData) async {
    assert(TQueryResponse != dynamic, "You need to specify a type for the query response");
    final td = definitions.td(testData);
    final successContext = AFFinishQuerySuccessContext<TQueryResponse>(
      conceptualStore: AFibF.g.activeConceptualStore,
      response: td,
      isPreExecute: false,
    );
    query.finishAsyncWithResponseAF(successContext);
  }


  static Future<AFScreenID> internalRunScreenTest(AFScreenTestID screenTestId, AFSingleScreenTestExecute sse, List<Object?>? params ) async {
    final screenTest = AFibF.g.screenTests.findById(screenTestId);
    var screenId;
    var testId;
    var body;
    if(screenTest != null) {
      screenId = screenTest.createNavigatePush().screenId;
      body = screenTest.body;
      testId = body.screenId;
    } else {
      // this might be a re-usable screen test.
      var reusable = AFibF.g.screenTests.findReusable(screenTestId);
      if(reusable == null) {
        for(final uiTests in AFibF.g.thirdPartyUITests.values) {
          reusable = uiTests.afScreenTests.findReusable(screenTestId);
          if(reusable != null) {
            break;
          }
        }

        if(reusable == null) {
          throw AFException("Screen test $screenTestId is not defined");
        }
      }
      screenId = reusable.prototype.screenIdCreator!();
      testId = reusable.id;
      body = AFSingleScreenPrototypeBody.createReusable(screenTestId, body: reusable.body, params: params ?? <Object>[]);
    }

    sse.pushScreen(screenId);
    sse.startSection(testId);
    await body.run(sse);
    sse.endSection();
    sse.popScreen();
    return screenId;
  }


  @override
  Future<void> runWidgetTest(AFBaseTestID widgetTestId, AFScreenID originScreen, {AFScreenID? terminalScreen, AFBaseTestID? queryResults}) async {
    _installQueryResults(queryResults);
    final widgetTest = AFibF.g.widgetTests.findById(widgetTestId);
    screenContext.pushScreen(originScreen);
    if(widgetTest != null) {
      await widgetTest.run(screenContext);  
    }
    screenContext.popScreen();    
  }

  @override
  Future<void> tapNavigateFromTo({
    required dynamic tap,
    required AFScreenID startScreen,
    dynamic tapData,
    AFScreenID? endScreen,
    bool verifyScreen = true
  }) async {
    await onScreen(startScreen: startScreen, endScreen: endScreen, verifyScreen: verifyScreen, printResults: false, body: (ste) async {
      await ste.applyTap(tap, tapData: tapData);
      if(!AFibD.config.isWidgetTesterContext) {
        await Future.delayed(AFibF.g.testDelayOnNewScreen);
      }
    });
  }

  @override
  Future<void> tapOpenDrawer({
    required dynamic tap,
    required AFScreenID startScreen,
    required AFScreenID drawerId
  }) {
    return tapNavigateFromTo(tap: tap, startScreen: startScreen, endScreen: drawerId, verifyScreen: false);
  }

  @override
  Future<void> onDrawer({
    required AFScreenID drawerId, 
    AFScreenID? endScreen, 
    AFBaseTestID? queryResults, 
    required Function(AFScreenTestExecute) body,
  }) {
    return onScreen(
      startScreen: drawerId,
      endScreen: endScreen,
      queryResults: queryResults,
      body: body,
      verifyScreen: false
    );
  }

  @override
  Future<void> onScreen({
    required AFScreenID startScreen, 
    AFScreenID? endScreen, 
    AFBaseTestID? queryResults, 
    required Function(AFScreenTestExecute) body,
    bool verifyScreen = true,
    bool printResults = true
  }) async {
    if(verifyScreen) {
      AFibF.g.testOnlyVerifyActiveScreen(startScreen);
    }
    endScreen ??= startScreen;
    screenContext.startSection(startScreen, resetSection: true);
    if(printResults) {
      screenContext.printStartTest(startScreen);
    }
    _installQueryResults(queryResults);
    await screenContext.underScreen(startScreen, () async {
      AFibD.logTestAF?.d("Starting underScreen");

      final fut = body(screenContext);
      await fut;
    });

    screenContext.endSection();
    if(printResults) {
      screenContext.printFinishTest(startScreen);
    }
    AFibD.logTestAF?.d("Finished underscreen");

    await screenContext.pauseForRender();
    if(verifyScreen) {
      AFibF.g.testOnlyVerifyActiveScreen(endScreen);
    }
  }

  void _installQueryResults(AFBaseTestID? queryResults) {
    if(queryResults == null) {
      return;
    }
    final stateTest = AFibF.g.stateTests.findById(queryResults as AFStateTestID);

    // This causes the query middleware to return results specified in the state test.
    if(stateTest != null) {
      final stateTestContext = AFStateTestContextForState(stateTest, AFConceptualStore.appStore, isTrueTestContext: false);
      AFStateTestContext.currentTest = stateTestContext;    
    } else {
      assert(false);
    }
  }
}

class AFWorkflowStateTestUI extends AFScreenTestDescription {
  final AFStateTestID uiStartsWith;
  AFWorkflowStateTestUI(
    AFScreenTestID super.id,
    super.description,
    super.disabled,
    this.uiStartsWith);

}

class AFWorkflowStateTestBodyWithParam extends AFScreenTestDescription {
  final AFWorkflowTestBodyExecuteDelegate body;
  AFWorkflowStateTestBodyWithParam(
    AFScreenTestID super.id,
    super.description,
    super.disabled,
    this.body);

}

class AFWorkflowStateTestPrototype {
  final AFWorkflowStateTests tests;
  final smokeTests = <AFWorkflowStateTestBodyWithParam>[];
  final reusableTests = <AFWorkflowStateTestBodyWithParam>[];
  final regressionTests = <AFWorkflowStateTestBodyWithParam>[];
  final uiStateTests = <AFWorkflowStateTestUI>[];

  AFWorkflowStateTestPrototype(this.tests);

  factory AFWorkflowStateTestPrototype.create(AFWorkflowStateTests tests, AFBaseTestID testId) {
    return AFWorkflowStateTestPrototype(tests);
  }

  void defineSmokeTest({
    required AFWorkflowTestBodyExecuteDelegate body, 
    AFScreenTestID id = AFUIScreenTestID.smoke,
    String? description,
    String? disabled 
  }) async {
    smokeTests.add(AFWorkflowStateTestBodyWithParam(id, description, disabled, body));
  }  

  void defineRunStateTestInUI({
    required AFScreenTestID id,
    required String? description,
    required String? disabled,
    required AFStateTestID runExtensionInUI,
  }) async {
    uiStateTests.add(AFWorkflowStateTestUI(id, description, disabled, runExtensionInUI));
  }  

  void openTestDrawer(AFScreenTestID id) {
    final info = AFibF.g.testOnlyMostRecentScreen;
    final scaffoldState = AFSingleScreenPrototypeBody.findScaffoldState(info?.element as Element, underScaffold: false);
    scaffoldState?.openEndDrawer();
  }

  Future<void> run(AFScreenTestContext context, { Function? onEnd }) async {
    final e = AFWorkflowTestContext(context);
    for(final section in smokeTests) {
      final disabled = section.disabled;
      if(disabled != null) {
        context.markDisabledSimple(disabled);
        context.printStartTest(section.id);
        context.printFinishTestDisabled(section.id, disabled);
        continue; 
      }
      context.startSection(section.id);
      context.printTestTitle(section.id);
      context.indentOutput();
      await section.body(e);
      context.endSection();
      context.outdentOutput();
    }

    if(onEnd != null) {
      onEnd();
    }
  }
}


/// Workflow tests have been superceded by state tests.
class AFWorkflowStateTests {
  final stateTests = <AFWorkflowStatePrototype>[];

  AFWorkflowStateTestPrototype addPrototype({
    required AFPrototypeID id,
    required AFBaseTestID stateTestId,
    AFID? actualDisplayId
  }) {
    final instance = createPrototype(tests: this, id: id, stateTestId: stateTestId, actualDisplayId: actualDisplayId);
    stateTests.add(instance);
    return instance.body;
  }

  static AFWorkflowStatePrototype createPrototype({
    required AFWorkflowStateTests tests,
    required AFPrototypeID id,
    required AFBaseTestID stateTestId,
    required AFID? actualDisplayId,
  }) {
    final instance = AFWorkflowStatePrototype(
      id: id,
      actualDisplayId: actualDisplayId,
      stateTestId: stateTestId as AFStateTestID,
      body: AFWorkflowStateTestPrototype.create(tests, id)
    );
    return instance;
  }

  List<AFWorkflowStatePrototype> get all {
    return stateTests;
  }

  AFWorkflowStatePrototype? findById(AFBaseTestID id) {
    for(final test in stateTests) {
      if(test.id == id || test.actualDisplayId == id) {
        return test;
      }
    }
    return null;
  }

  AFWorkflowStatePrototype? findByStateTestId(AFStateTestID id) {
    for(final test in stateTests) {
      if(test.stateTestId == id) {
        return test;
      }
    }
    return null;
  }

  void findByTokens(List<String> tokens, List<AFScreenPrototype> results) {
    results.addAll(stateTests.where((test) {
      return AFSingleScreenTests.matchesTokens(test.id, tokens);
    }));
  }

  

}


/// Base test definition wrapper, with access to test data.
/// 
class AFBaseTestDefinitionContext {
  final AFDefineTestDataContext registry;
  AFBaseTestDefinitionContext(this.registry);

  /// Looks up the test data defined in your test_data.dart file for a particular
  /// test data id.
  TData td<TData>(dynamic testDataId) {
    return registry.find(testDataId) as TData;
  }

  TResult td2<TResult extends Object>(dynamic testDataId) {
    return registry.find(testDataId) as TResult;
  }

  // DOC_TODO: This is a way to create a state view in a UI test so you can 
  // use it in navigatePush as well as passing it as the stateView param.
  TStateView createStateView<TStateView extends AFFlexibleStateView>({
    required dynamic stateView,
    required AFCreateStateViewDelegate<TStateView> creator,
  }) {
    final models = registry.resolveStateViewModels(stateView);
    return creator(models);
  }

  AFTimeState currentTime() {
    return registry.currentTime();
  }

  TResult find<TResult extends Object>(dynamic testDataId) {
    return registry.find(testDataId) as TResult;
  }

  /// Looks up the test data defined in your test_data.dart file for a particular
  /// test data id.
  T testData<T extends Object>(dynamic testDataId) {
    final value = registry.find(testDataId);
    if(value == null) {
      throw AFException("Missing test value for id $testDataId");
    }
    if(value is! T) {
      throw AFException("Test value with id $testDataId had type ${value.runtimeType.toString()} when ${T.toString()} was required.");
    }
    return value;
  }

  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.test);
  }

}

class AFUnitTestDefinitionContext extends AFBaseTestDefinitionContext {
  final AFUnitTests tests;

  AFUnitTestDefinitionContext({
    required this.tests,
    required AFDefineTestDataContext testData
  }): super(testData);

  void defineTest(AFBaseTestID id, AFUnitTestBodyExecuteDelegate fnTest) {
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
    required this.tests,
    required AFDefineTestDataContext testData
  }): super(testData);

  /// Define a state test. 
  /// 
  /// The state test should define one or more query results, and then
  /// execute a query.  Note that state tests are usually built in a 
  /// kind of tree, with a cumulative state being build from
  /// a series of query/response cycles across multiple tests.
  void addTest(AFStateTestID id, {
    required AFStateTestID? extendTest,
    required AFStateTestDefinitionDelegate body,
    String? description,
    String? disabled,
  }) {
    tests.addTest(
      id: id, 
      extendTest: extendTest, 
      definitions: this, 
      body: body,
      description: description,
      disabled: disabled);
  }
}

/// A context wrapper for defining single screen test. 
/// 
/// This class is intended to provide a quick start for the most common
/// methods in defining single screen tests, and to enable extensions
/// later without changing the test definition function profile.
class AFUIPrototypeDefinitionContext extends AFBaseTestDefinitionContext {
  final AFSingleScreenTests screenTests; 
  final AFWidgetTests widgetTests;
  final AFDialogTests dialogTests;
  final AFBottomSheetTests bottomSheetTests;
  final AFDrawerTests drawerTests;
  
  AFUIPrototypeDefinitionContext({
    required this.screenTests,
    required this.widgetTests,
    required this.dialogTests,
    required this.drawerTests,
    required this.bottomSheetTests,
    required AFDefineTestDataContext testData
  }): super(testData);


  /// Define a prototype which shows a  single screen in a particular 
  /// screen view state/route param state.
  AFSingleScreenPrototypeBody defineScreenPrototype({
    required AFPrototypeID   id,
    required Object? stateView,
    AFNavigatePushAction? navigate,
    AFNavigateWithOnEventContextDelegate? navigateWithEventContext,
    AFTestTimeHandling timeHandling = AFTestTimeHandling.paused,
    String? title,
  }) {
    final stateViewActual = stateView ?? <Object>[];
    return screenTests.addPrototype(
      id: id,
      stateView: stateViewActual,
      navigate: navigate,
      navigateWithEventContext: navigateWithEventContext,
      timeHandling: timeHandling,
    );
  }

  /// Define a prototype which shows a  single screen in a particular 
  /// screen view state/route param state.
  AFSingleScreenPrototypeBody defineDialogPrototype({
    required AFPrototypeID   id,
    required Object? stateView,
    required AFNavigatePushAction navigate,
    AFTestTimeHandling timeHandling = AFTestTimeHandling.paused,
    String? title,
  }) {
    final modelsActual = stateView ?? <Object>[];
    return dialogTests.addConnectedPrototype(
      id: id,
      models: modelsActual,
      navigate: navigate,
      timeHandling: timeHandling,
    );
  }

  AFSingleScreenPrototypeBody defineBottomSheetPrototype({
    required AFPrototypeID   id,
    required Object? stateView,
    required AFNavigatePushAction navigate,
    AFTestTimeHandling timeHandling = AFTestTimeHandling.paused,
    String? title,
  }) {
    final modelsActual = stateView ?? <Object>[];
    return bottomSheetTests.addConnectedPrototype(
      id: id,
      models: modelsActual,
      navigate: navigate,
      timeHandling: timeHandling,
    );
  }

  AFSingleScreenPrototypeBody defineDrawerPrototype({
    required AFPrototypeID   id,
    required Object? stateView,
    required AFNavigatePushAction navigate,
    AFTestTimeHandling timeHandling = AFTestTimeHandling.paused,
    String? title,
  }) {
    final modelsActual = stateView ?? <Object>[];
    return drawerTests.addConnectedPrototype(
      id: id,
      models: modelsActual,
      navigate: navigate,
      timeHandling: timeHandling,
    );
  }


  AFSingleScreenPrototypeBody defineWidgetPrototype({
    required AFPrototypeID id,
    required AFRenderConnectedChildDelegate render,
    List<AFRouteParam>? children,
    dynamic stateView,
    required AFCreateWidgetLaunchParamDelegate createLaunchParam,
  }) {
    final launchParam = createLaunchParam(AFUIScreenID.screenPrototypeWidget, AFUIWidgetID.widgetPrototypeTest, AFRouteLocation.screenHierarchy);
    return widgetTests.addConnectedPrototype(
      id: id,
      render: render,
      models: stateView,
      routeParam: launchParam,
      children: children,
    );
  }

  @Deprecated("Superceded by state tests")
  void defineReusableTest({
    required AFScreenTestID id, 
    required AFSingleScreenPrototypeBody prototype, 
    required AFReusableScreenTestBodyExecuteDelegate body,
    required List<Object> params,
    String? disabled,
  }) {
    screenTests.defineReusableTest(
      id: id, 
      prototype: prototype,
      body: body,
      params: params,
    );

    executeReusableTest(prototype, id, params: params, disabled: disabled);
  }

  /// This is obsolete, do not use.
  void executeReusableTest(AFSingleScreenPrototypeBody body, AFScreenTestID bodyId, {
    List<Object> params = const <Object>[],
    String? disabled,
  }) {
    final paramsFull = params.map<Object>((e) => td(e)).toList();
    body.executeReusable(screenTests, bodyId, params: paramsFull, disabled: disabled);
  }
}

class AFWorkflowTestDefinitionContext extends AFBaseTestDefinitionContext {
  final AFWorkflowStateTests tests;

  AFWorkflowTestDefinitionContext({
    required this.tests,
    required AFDefineTestDataContext testData
  }): super(testData);

  AFWorkflowStateTestPrototype definePrototype({
    required AFPrototypeID id,
    required AFBaseTestID stateTestId,
  }) {
    return tests.addPrototype(
      id: id,
      stateTestId: stateTestId
    );
  }
  
  void defineSmokeTest(AFWorkflowStateTestPrototype prototype, { 
    String? description,
    AFScreenTestID id = AFUIScreenTestID.smoke,
    required AFWorkflowTestBodyExecuteDelegate body, 
    String? disabled }) {
    prototype.defineSmokeTest(body: body, id: id, description: description, disabled: disabled);
  }

}

