

import 'dart:async';

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stack_trace/stack_trace.dart';

abstract class AFScreenTestExecute {
  Future<void> enterText(AFWidgetID wid, String text);
  Future<void> tap(AFWidgetID wid);
  Future<void> tapWithExpectedAction(AFActionWithKey specifier, Function(AFActionWithKey) checkQuery) async {
    final wid = specifier.wid;
    await tap(wid);
    expectAction(specifier, checkQuery);    
    return _pauseForRender();
  }

  Future<void> tapWithActionType(AFActionWithKey action) async {
    await tap(action.wid);
    expectAction(action, (AFActionWithKey action) {

    });
    return _pauseForRender();
  }

  void expectStringEquals(String l, String r);
  void expectAction(AFActionWithKey specifier, Function(AFActionWithKey) checkAction);
  TExpected expectType<TExpected>(dynamic obj) {
    if(obj is TExpected) {
      return obj;
    }
    _addError("Unexpected type ${obj.runtimeType}", 2);
    return null;
  }

  Future<void> _pauseForRender() async {
    return Future<void>.delayed(Duration(milliseconds: 500), () {});
  }

  void _addError(String error, int depth);

}

abstract class AFScreenTestVerify {
  void expectOneWidget(AFWidgetID wid);
}

typedef void AFScreenTestBodyExecuteFunc(AFScreenTestExecute exec);
typedef void AFScreenTestBodyVerifyFunc(AFScreenTestVerify verify);


class AFScreenTestBody {
  final sections = List<dynamic>();
  bool get isNotEmpty { 
    return sections.isNotEmpty;
  }


  void execute(AFScreenTestBodyExecuteFunc func) {
    sections.add(func);
  }

  void verify(AFScreenTestBodyVerifyFunc func) {
    sections.add(func);
  }  

  void run(AFScreenTestContext context) {
    for(int i = 0; i < sections.length; i++) {
      final section = sections[i];

      section(context);
    }
  }
}


abstract class AFScreenTestContext extends AFScreenTestExecute {
  AFScreenPrototypeTest test;
  AFScreenTestContext(this.test);

  void expectOneWidget(AFWidgetID wid);
  Future<void> enterText(AFWidgetID wid, String text);
}

class AFScreenTestContextWidgetTester extends AFScreenTestContext {
  WidgetTester tester;

  AFScreenTestContextWidgetTester(this.tester, AFScreenPrototypeTest test): super(test);
  
  void expectOneWidget(AFWidgetID wid) {
    final widFinder = find.byKey(Key(wid.code));
    expect(widFinder, findsOneWidget);
  }

  Future<void> enterText(AFWidgetID wid, String text) async {
    final widFinder = find.byKey(AFUI.testKey(wid));
    //await tester.enterText(widFinder, text);
  }

  @override
  Future<void> tap(AFWidgetID wid) async {
    final widFinder = find.byKey(AFUI.testKey(wid));
    await tester.tap(widFinder);
  }

  @override
  void expectQuery<TQuery extends AFAsyncQuery>(AFID id, Function(TQuery) checkQuery) {
      // TODO: implement expectQuery
  }
  
  @override
  void expectStringEquals(String l, String r) {
    // TODO: implement expectStringEquals
  }

  @override
  void expectAction(AFActionWithKey specifier, Function(AFActionWithKey) checkAction) {
    // TODO: implement expectAction
  }

  void _addError(String error, int depth) {

  }
}

class _AFScreenTestElementCache {
  static const separator = "/";
  Element root;
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
    
    return null;
  }

  /// Rebuild our internal cache of paths to elements with keys.
  void refresh(Element currentRoot) {
    // nothing to do if the current root hasn't changed.
    if(currentRoot == root) {
      return;
    }

    root = currentRoot;
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
  final errors = List<String>();
  final recentActions = Map<String, AFActionWithKey>();
  int pass = 0;

  AFScreenTestContextSimulator(AFScreenPrototypeTest test, this.runNumber): super(test);
  
  String get summaryText {
    final sb = StringBuffer();
    if(hasErrors) {
      sb.write(errors.length);
      sb.write(" failed");
      sb.write(", ");
    }    
    sb.write(pass);
    sb.write(" passed");
    return sb.toString();
  }

  bool get hasErrors {
    return errors.isNotEmpty;
  }

  void registerAction(AFActionWithKey action) {
    final key = action.key;
    recentActions[key] = action;
  }

  void expectOneWidget(AFWidgetID wid) {
    Element elem = _findOneElement(wid);
    _assert(elem != null);
  }

  @override
  void expectQuery<TQuery extends AFAsyncQuery>(AFID id, Function(TQuery) checkQuery) {
    /*
    AFAsyncQuery query = recentQueries[id.code];
    if(query == null) {
      _addError("Failed to find query with id $id", 2);
      return;
    }
    _assert(true);
    checkQuery(query);
    */
  }

  @override
  void expectAction(AFActionWithKey specifier, Function(AFActionWithKey) checkAction) {
    final key = specifier.key;
    final found = recentActions[key];
    if(found == null) {
      _addError("Failed to find action with key $key", 3);
      return;
    }
    _assert(true);
    checkAction(found);
  }

  
  @override
  void expectStringEquals(String l, String r) {
    if(!_assert(l == r)) {
      _addError("Expected $l found $r", 2);
    }
  }

  Future<void> enterText(AFWidgetID wid, String text) async {
    Element elem = _findOneElement(wid);
    if(elem == null) {
      return;
    }
    final widget = elem.widget;
    if(widget is TextField) {
      widget.onChanged(text);
    } else if(widget is AFTextField) {
      print("Updating ${widget.key} with $text");
      widget.onChanged(text);
    } else {
      _addError("enterText called on widget of unsupported type ${widget.runtimeType}", 2);
      return null;
    }

    // give redux a chance to rebuild the UI after this change.
    return _pauseForRender();
  }

  Element _findOneElement(AFWidgetID wid) {
    _updateCache();
    List<Element> elems = elementCache.findWithKey(AFUI.testKey(wid));
    if(elems.length != 1) {
      _addError("Expected 1 widget with code ${wid.code}, found ${elems.length}", 3);
      return null;
    }
    return elems.first;
  }

  @override
  Future<void> tap(AFWidgetID wid) async {
    Element elem = _findOneElement(wid);
    if(elem == null) {
      return null;
    }

    final widget = elem.widget;
    if(widget is FlatButton) {
      widget.onPressed();
    }

    return _pauseForRender();
  }
  
  void _updateCache() {
    elementCache.refresh(AF.testOnlyScreenElement);
  }

  bool _assert(bool shouldBeTrue) {
    if(shouldBeTrue) {
      pass++;
    }
    return shouldBeTrue;
  }

  void _addError(String desc, int depth) {
    final List<Frame> frames = Trace.current().frames;
    final Frame f = frames[depth];
    final loc = "${f.library}:${f.line}";

    final err = loc + ": " + desc;
    errors.add(err);
    AF.debug(err);
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
  AFScreenTestBody body;
  AFBuildableWidget widget;

  AFScreenPrototypeTest({
    @required this.id,
    @required this.data,
    @required this.param,
    @required this.widget,
    @required this.body
  });

  bool get hasBody {
    return body.isNotEmpty;
  }

  void run(AFScreenTestContext context) {
    body.run(context);
  }
}

/// All the screen tests/prototypes associated with a single screen.
class AFScreenTestGroup {
  AFBuildableWidget widget;
  List<AFScreenPrototypeTest> tests = List<AFScreenPrototypeTest>();

  AFScreenTestGroup({
    @required this.widget,
  });

  /// Add a prototype of a particular screen with the specified [data]
  /// and [param].  
  /// 
  /// Returns an [AFScreenTestBody], which can be used to create a 
  /// test for the screen.
  AFScreenTestBody addPrototype({
    @required AFTestID   id,
    @required dynamic data,
    @required dynamic param
  }) {
    AFScreenPrototypeTest instance = AFScreenPrototypeTest(
      id: id,
      data: data,
      param: param,
      widget: widget,
      body: AFScreenTestBody()
    );
    tests.add(instance);
    return instance.body;
  }
}

/// This class is used to create canned versions of screens and widget populated
/// with specific data for testing and prototyping purposes.
class AFScreenTests<TState> {
  
  List<AFScreenTestGroup> groups = List<AFScreenTestGroup>();

  /// Add a screen widget, and then in the [addInstances] callback add one or more 
  /// data states to render with that screen.
  void addScreen(AFBuildableWidget widget, Function(AFScreenTestGroup) addInstances) {
    AFScreenTestGroup group = AFScreenTestGroup(widget: widget);
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

}