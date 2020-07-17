

import 'dart:async';

import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/core/af_text_field.dart';
import 'package:afib/src/flutter/core/afui.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

abstract class AFScreenTestExecute extends AFBaseTestExecute {
  void expectOneWidget(AFWidgetID wid);
  void expectMissingWidget(AFWidgetID wid);
  void expectText(AFWidgetID wid, String text);
  void expectChipSelected(AFWidgetID wid, bool sel);
  Future<void> enterText(AFWidgetID id, String text);
  Future<void> tap(AFWidgetID wid);
  Future<void> tapWithExpectedAction(AFWidgetID wid, AFActionWithKey specifier, Function(AFActionWithKey) checkQuery) async {
    final previous = AFibF.testOnlyScreenUpdateCount;
    await tap(wid);
    expectAction(specifier, checkQuery);    
    return pauseForRender(previous);
  }

  Future<void> tapWithExpectedParam(AFWidgetID wid, Function(AFRouteParam) checkParam) async {
    final previous = AFibF.testOnlyScreenUpdateCount;
    await tap(wid);
    expectAction(AFNavigateSetParamAction(), (dynamic action) {
      AFNavigateSetParamAction paramAction = action;
      checkParam(paramAction.param);
    });    
    
    return pauseForRender(previous);
  }

  Future<void> keepSynchronous() {
    return null;
  }

  Future<void> tapWithActionType(AFWidgetID wid, AFActionWithKey action) async {
    final previous = AFibF.testOnlyScreenUpdateCount;
    await tap(wid);
    expectAction(action, (AFActionWithKey action) {

    });
    return pauseForRender(previous);
  }

  Future<void> updateScreenData(dynamic data);

  void expectAction(AFActionWithKey specifier, Function(AFActionWithKey) checkAction);
  TExpected expectType<TExpected>(dynamic obj) {
    if(obj is TExpected) {
      return obj;
    }
    addError("Unexpected type ${obj.runtimeType}", 2);
    return null;
  }

  Future<void> executeNamedSection(AFTestSectionID id, AFTestSectionParams params);

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


abstract class AFScreenTestContext extends AFScreenTestExecute {
  final recentActions = Map<String, AFActionWithKey>();
  final AFDispatcher dispatcher;

  AFScreenPrototypeTest test;
  AFScreenTestContext(this.test, this.dispatcher);
  AFTestID get testID { return this.test.id; }

  void expectOneWidget(AFWidgetID wid);

  Future<void> enterText(AFWidgetID wid, String text);

  void registerAction(AFActionWithKey action) {
    final key = action.key;
    recentActions[key] = action;
  }


  @override
  Future<void> executeNamedSection(AFTestSectionID id, AFTestSectionParams params) {
    return this.test.body.executeNamedSection(id, this, params);
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
    this.expect(selected, ft.equals(expect), stackFrames: 4);
  }

}

class AFScreenTestContextWidgetTester extends AFScreenTestContext {
  final ft.WidgetTester tester;
  final AFApp app;

  AFScreenTestContextWidgetTester(this.tester, this.app, AFScreenPrototypeTest test, AFDispatcher dispatcher): super(test, dispatcher);

  void expectOneWidget(AFWidgetID wid) {
    expect(ft.find.byKey(AFUI.testKey(wid)), ft.findsOneWidget);
  }

  void expectMissingWidget(AFWidgetID wid) {
    expect(ft.find.byKey(AFUI.testKey(wid)), ft.findsNothing);
  }

  void expectText(AFWidgetID wid, String text) {
    ft.Finder found = ft.find.byKey(AFUI.testKey(wid));
    Widget widget = _firstWidget(
      ft.find.descendant(
        of: found,
        matching: ft.find.byType(Text),
    ));
    if(widget == null) {
      widget = _firstWidget(
        ft.find.descendant(
          of: found,
          matching: ft.find.byType(TextField),
      ));
    }

    if(widget != null) {
      testText(widget, text);
    }
  }

  void expectChipSelected(AFWidgetID wid, bool expect) {
    ft.Finder found = ft.find.byKey(AFUI.testKey(wid));
    Widget widget = _firstWidget(found);
    testChipSelected(widget, expect);
  }


  Widget _firstWidget(ft.Finder found) {
    Iterable<Widget> it = tester.widgetList(found);
    if(it.isEmpty) {
      return null;
    }
    return it.first;
  }

  Future<void> enterText(AFWidgetID wid, String text) async {
    final widFinder = ft.find.byKey(AFUI.testKey(wid));
    await tester.enterText(widFinder, text);
  }

  @override
  Future<void> tap(AFWidgetID wid) async {
    final widFinder = ft.find.byKey(AFUI.testKey(wid));
    return tester.tap(widFinder);
  }
  
  @override
  void expectAction(AFActionWithKey specifier, Function(AFActionWithKey) checkAction) {
    // TODO: Fix testing here.  This doesn't work because the widgetTester.tap doesn't seem to be working (or is happening asynchronously.)
    /*
    final key = specifier.key;
    final found = recentActions[key];
    if(found == null) {
      addError("Failed to find action with key $key", 3);
      return;
    }
    addPassIf(true);
    checkAction(found);
    */
  }

  @override
  Future<void> pauseForRender(int previousCount) async {
    return tester.pumpAndSettle();
  }

  @override
  Future<void> updateScreenData(data) {
    final previous = AFibF.testOnlyScreenUpdateCount;
    dispatcher.dispatch(AFUpdatePrototypeScreenTestDataAction(this.test.id, data));
    return pauseForRender(previous);
  }
}

class _AFScreenTestElementCache {
  static const separator = "/";
  Element root;
  int previousUpdateCount;
  Map<String, List<Element>> paths;

  /// Finals the elements that have [key] as their widget key.
  List<Element> findWithKey(Key key) {
    return findWithParent(null, key);
  }

  /// Finds the elements that have [key] as their widget key,
  /// and have a parent with the key [parent].  
  /// 
  /// [parent] must be the first widget above the element that
  /// has a key, but there could be intervening elements with no 
  /// key
  List<Element> findWithParent(Key parent, Key key) {
    final searchPath = List<Key>();
    if(parent != null) {
      searchPath.add(parent);
    }
    searchPath.add(key);
    return findWithPath(searchPath);
  }

  /// Finds the element that has all the specified 
  /// keys in their path, from the root-most to the leaf-most.
  /// 
  /// Unkeyed elements are ignored, but all keyed elements
  /// in a path must be specified for their to be a match.
  List<Element> findWithPath(List<Key> pathList) {
    final sb = StringBuffer();
    pathList.forEach((key) {
      sb.write(separator);
      sb.write(key.toString());
    });
    final searchPath = sb.toString();

    // first, see if it exists in the map
    final simple = paths[searchPath];
    if(simple != null) {
      return simple;
    }

    // otherwise, go through the map looking for a path that ends with our current path.
    for(var testPath in paths.keys) {
      if(testPath.endsWith(searchPath)) {
        return paths[testPath];
      }
    }
    
    return List<Element>();
  }

  /// Rebuild our internal cache of paths to elements with keys.
  void refresh(Element currentRoot, int currentUpdateCount) {
    // nothing to do if the current root hasn't changed.
    if(currentUpdateCount == previousUpdateCount) {
      return;
    }

    previousUpdateCount = currentUpdateCount;
    paths = Map<String, List<Element>>();

    _populateChildren(currentRoot, separator);
  }

  // Go though all the children of [current], having the parent path [currentPath],
  // and add path entries for any widgets with keys.
  void _populateChildren(Element current, String currentPath) {
    var nextPath = currentPath;
    if(current.widget.key != null) {
      nextPath = currentPath + separator + current.widget.key.toString();
      _addPath(nextPath, current);
    }  

    current.visitChildren((child) {
      _populateChildren(child, nextPath);
    });
  }

  /// Add an [elem] at the specified path, creating it if necessary.
  void _addPath(String path, Element elem) {
    List<Element> current = paths[path];
    if(current == null) {
      current = List<Element>();
      paths[path] = current;
    }
    current.add(elem);
  }
}

class AFScreenTestContextSimulator extends AFScreenTestContext {
  final int runNumber;
  final elementCache = _AFScreenTestElementCache();
  final DateTime lastRun = DateTime.now();

  AFScreenTestContextSimulator(AFDispatcher dispatcher, AFScreenPrototypeTest test, this.runNumber): super(test, dispatcher);

  @override
  Future<void> keepSynchronous() {
    return Future<void>.delayed(Duration(milliseconds: 10), () {});
  }

  void expectOneWidget(AFWidgetID wid) {
    Element elem = _findOneElement(wid);
    addPassIf(elem != null);
  }

  void expectMissingWidget(AFWidgetID wid) {
    Element elem = _findOneElement(wid, errorIfMissing: false);
    addPassIf(elem == null);
  }

  void expectText(AFWidgetID wid, String expect) {
    Element elem = _findTextUnder(wid);
    if(elem == null) {
      return;
    }

    testText(elem.widget, expect);
  }

  void expectChipSelected(AFWidgetID wid, bool expect) {
    Element elem = _findOneElement(wid);
    if(elem == null) {
      return;
    }
    Element elemType = _findChildMatching(elem, (Element test) {
      final widget = test.widget;
      return widget is ChoiceChip || widget is InputChip || widget is FilterChip;
    });

    if(elemType == null) {
      addError("Could not find a widget under ${wid.code} of type ChoiceChip, InputChip, or FilterChip", 3);
      return;
    }
    
    final widget = elemType.widget;
    testChipSelected(widget, expect);
  }



  Element _findTextUnder(AFWidgetID wid, { bool errorIfMissing = true}) {
    Element parent = _findOneElement(wid);
    if(parent.widget is Text) {
      return parent;
    }
    Element text = _findChildMatching(parent, (Element test) {
      return test.widget is Text;
    });

    if(text != null) {
      return text;
    }
    
    Element textField = _findChildMatching(parent, (Element test) {
      return test.widget is TextField;
    });
    
    if(textField == null) {
      addError("Expected 1 widget with type Text under ${wid.code}", 3);
    }
    
    return textField;
  }

  Element _findChildMatching(Element current, bool Function(Element) testElement) {
    if(testElement(current)) {
      return current;
    }
    final children = List<Element>();
    current.visitChildren((child) {
      children.add(child);
    });

    for(final child in children) {
      if(testElement(child)) {
        return child;
      }
    }

    for(final child in children) {
      Element e = _findChildMatching(child, testElement);
      if(e != null) {
        return e;
      }
    }
    return null;
  }

  @override
  void expectAction(AFActionWithKey specifier, Function(AFActionWithKey) checkAction) {
    final key = specifier.key;
    final found = recentActions[key];
    if(found == null) {
      addError("Failed to find action with key $key", 3);
      return;
    }
    addPassIf(true);
    checkAction(found);
  }

  
  Future<void> enterText(AFWidgetID wid, String text) async {
    final previous = AFibF.testOnlyScreenUpdateCount;
    Element elem = _findOneElement(wid);
    if(elem == null) {
      return;
    }
    final widget = elem.widget;
    if(widget is TextField) {
      widget.onChanged(text);
    } else if(widget is AFTextField) {
      widget.onChanged(text);
    } else {
      addError("enterText called on widget ${widget.key} of unsupported type ${widget.runtimeType}", 2);
      return null;
    }

    // give redux a chance to rebuild the UI after this change.
    return pauseForRender(previous);
  }

  Element _findOneElement(AFWidgetID wid, { bool errorIfMissing = true }) {
    _updateCache();
    List<Element> elems = elementCache.findWithKey(AFUI.testKey(wid));
    if(elems?.length != 1) {
      if(errorIfMissing) {
        addError("Expected 1 widget with code ${wid.code}, found ${elems.length}", 3);
      }
      return null;
    }
    return elems.first;
  }

  @override
  Future<void> tap(AFWidgetID wid) async {
    final previous = AFibF.testOnlyScreenUpdateCount;
    Element elem = _findOneElement(wid);
    if(elem == null) {
      return null;
    }
    /*
    final render = elem.findRenderObject();
    if (render is RenderBox) {
      final hitTestResult = BoxHitTestResult();
      if (render.hitTest(hitTestResult, position: elem.size.center(Offset.zero))) {
        render.handleEvent(PointerDownEvent(), hitTestResult.path.first);
        render.handleEvent(PointerUpEvent(), hitTestResult.path.first);
        //AFibD.fine("Tapped $wid");
      }
    }
    */

    final widget = elem.widget;
    if(widget is FlatButton) {
      widget.onPressed();
    } else if(widget is ChoiceChip) {
      widget.onSelected(!widget.selected);      
    }

    return pauseForRender(previous);
  }
  
  @override
  Future<void> updateScreenData(dynamic data) {
    final previous = AFibF.testOnlyScreenUpdateCount;
    dispatcher.dispatch(AFUpdatePrototypeScreenTestDataAction(this.test.id, data));
    return pauseForRender(previous);
  }

  @override
  Future<void> executeNamedSection(AFTestSectionID id, AFTestSectionParams params) {
    return this.test.body.executeNamedSection(id, this, params);
  }

  @override
  Future<void> pauseForRender(int previousCount) async {

    /// wait for the screen element to be rebuilt.
    AFibD.logInternal?.fine("Starting _pauseForRender with $previousCount");
    var current = AFibF.testOnlyScreenUpdateCount;
    int n = 0;
    while(current == previousCount) {
      AFibD.logInternal?.fine("Pausing");
      await Future<void>.delayed(Duration(milliseconds: 100), () {});
      current = AFibF.testOnlyScreenUpdateCount;
      n++;
      if(n > 10) {
        throw new AFException("Timeout waiting for screen update.  You may need to pass noUpdate: true into one of the test manipulators if it does not produce an update.");
      }
    }
    AFibD.logInternal?.fine("Exiting _pauseForRender with count $current");
  }

  void _updateCache() {
    elementCache.refresh(AFibF.testOnlyScreenElement, AFibF.testOnlyScreenUpdateCount);
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


}