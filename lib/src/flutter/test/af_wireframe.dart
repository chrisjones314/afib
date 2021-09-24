import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/afib_flutter.dart';

class AFWireframes {
  final wireframes = <AFWireframe>[];

  void add(AFWireframe wf) {
    wireframes.add(wf);
  }  
}

class AFWireframeExecutionContext {
  final AFScreenID screen;
  final AFID widget;
  final dynamic eventParam;
  final AFWireframe wireframe;

  AFWireframeExecutionContext({
    required this.screen,
    required this.widget,
    required this.eventParam,
    required this.wireframe,
  });

  void navigatePop() {
    _dispatch(AFNavigatePopAction());
    _dispatch(AFStartWireframePopTestAction());
  }

  void navigateTo(AFPrototypeID testId, { AFRouteParam? routeParam, AFStateView? stateView }) {
    final test = AFibF.g.findScreenTestById(testId);
    final dispatcher = AFibF.g.storeDispatcherInternalOnly;
    assert(dispatcher != null && test != null);
    if(dispatcher != null && test != null) {
      test.startScreen(dispatcher, wireframe.registry, routeParam: routeParam, stateView: stateView);
    }
  }

  dynamic td(dynamic id) {
    return wireframe.registry.f(id);
  }

  void updateTestData(dynamic objectId, dynamic value, { bool updateStates = true }) {
    wireframe.updateTestData(objectId, value);
    if(!updateStates) {
      return;
    }
    // now, regenerate the composite objects.
    wireframe.registry.regenerate();

    // then, go through all active screens in the hierarchy, and update their stateViews.
    _dispatch(AFTestUpdateWireframeStateViews(wireframe.registry));

  }

  void _dispatch(dynamic action) {
    assert(AFibF.g.storeDispatcherInternalOnly != null);
    AFibF.g.storeDispatcherInternalOnly?.dispatch(action);
  }
}

class AFWireframe {
  final String name;
  final AFPrototypeID initialScreen;
  final AFWireframeExecutionDelegate body;
  final AFCompositeTestDataRegistry registry;

  AFWireframe({
    required this.name, 
    required this.initialScreen, 
    required this.body,
    required this.registry
  });

  factory AFWireframe.create({
    required String name,
    required AFPrototypeID initialScreen,
    required AFWireframeExecutionDelegate body
  }) {
    final registry = AFibF.g.testData.cloneForWireframe();
    return AFWireframe(name: name, initialScreen: initialScreen, body: body, registry: registry);
  }

  void updateTestData(dynamic objectId, dynamic value) {
    registry.registerAtomic(objectId, value);
  }


  void updateState(AFScreenID screen, AFID widget, dynamic param) {
    final context = AFWireframeExecutionContext(
      screen: screen,
      widget: widget,
      eventParam: param,
      wireframe: this,
    );
    body(context);
  }
}

class AFWireframeDefinitionContext {
  final AFWireframes wireframes;
  final AFCompositeTestDataRegistry testData;

  AFWireframeDefinitionContext({
    required this.wireframes,
    required this.testData,
  });


  AFWireframe defineWireframe({
    required String name,
    required AFPrototypeID initialScreen,
    required AFWireframeExecutionDelegate body,
  }) {
    final wf = AFWireframe(
      name: name, 
      initialScreen: initialScreen, 
      body: body,
      registry: AFibF.g.testData
    );
    wireframes.add(wf);
    return wf;
  }
}