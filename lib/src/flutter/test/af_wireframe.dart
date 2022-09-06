import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:logger/logger.dart';

class AFWireframes {
  final wireframes = <AFWireframe>[];

  void add(AFWireframe wf) {
    wireframes.add(wf);
  }  

  AFWireframe find(AFPrototypeID id) {
    for(final wireframe in wireframes) { 
      if(wireframe.id == id) {
        return wireframe;
      }
    }
    throw AFException("Unknown wireframe $id");
  }
}

class AFWireframeExecutionContext<TStateView extends AFFlexibleStateView> {
  final AFStateProgrammingInterface spi;
  final AFScreenID screen;
  final AFID widget;
  final dynamic eventParam;
  final AFWireframe wireframe;
  Map<String, Object> models;
  TStateView stateView;
  final AFCreateStateViewDelegate<TStateView> stateViewCreator;


  AFWireframeExecutionContext({
    required this.spi,
    required this.screen,
    required this.widget,
    required this.eventParam,
    required this.wireframe,
    required this.models,
    required this.stateView,
    required this.stateViewCreator,
  });

  TStateView get s { 
    return stateView;
  }

  bool isScreen(AFScreenID screenId) {
    return this.screen == screenId;
  }

  TResult getEventParam<TResult>() {
    return eventParam as TResult;
  }

  bool isWidget(AFWidgetID widgetId) {
    return this.widget == widgetId;
  }

  void navigatePop() {
    _dispatch(AFNavigatePopAction());
    _dispatch(AFStartWireframePopTestAction());
  }

  void updateModel(dynamic source) {
    updateModels([source]);
  }

  void updateModels(dynamic sourceModels) {
    final resolved = wireframe.testData.resolveStateViewModels(sourceModels);
    models = AFComponentState.integrate(models, resolved.values);
    stateView = stateViewCreator(models);
  }

  void navigateTo(AFPrototypeID testId, { AFRouteParam? routeParam, List<Object>? models }) {
    final test = AFibF.g.findScreenTestById(testId);
    final dispatcher = AFibF.g.internalOnlyActiveDispatcher;
    assert(test != null);
    if(test != null) {
      test.startScreen(dispatcher, spi.context.flutterContext, wireframe.testData, routeParam: routeParam, stateView: models);
    }
  }

  dynamic td(dynamic id) {
    return wireframe.testData.find(id);
  }

  void _dispatch(dynamic action) {
    AFibF.g.internalOnlyActiveDispatcher.dispatch(action);
  }
}

class AFWireframe<TStateView extends AFFlexibleStateView> {
  final AFPrototypeID id;
  final AFNavigatePushAction navigate;
  final AFWireframeExecutionDelegate<TStateView> body;
  final AFDefineTestDataContext testData;
  final dynamic models;
  final AFCreateStateViewDelegate<TStateView> stateViewCreator;

  AFWireframe({
    required this.id,
    required this.navigate, 
    required this.body,
    required this.testData,
    required this.models,
    required this.stateViewCreator,
  });

  factory AFWireframe.create({
    required AFPrototypeID id,
    required AFNavigatePushAction navigate,
    required AFWireframeExecutionDelegate body,
    required dynamic models,
    required AFCreateStateViewDelegate<TStateView> stateViewCreator,
  }) {
    final testData = AFibF.g.testData;
    return AFWireframe<TStateView>(id: id, navigate: navigate, body: body, testData: testData, models: models, stateViewCreator: stateViewCreator);
  }


  void onEvent(AFStateProgrammingInterface spi, AFScreenID screen, AFID widget, dynamic param, Map<String, Object> models) {
    final modelsCopy = Map<String, Object>.from(models);
    final stateViewOrig = stateViewCreator(modelsCopy);
    final context = AFWireframeExecutionContext(
      spi: spi,
      screen: screen,
      widget: widget,
      eventParam: param,
      wireframe: this,
      models: modelsCopy,
      stateView: stateViewOrig,
      stateViewCreator: this.stateViewCreator
    );

    body(context);

    // if the state view changed, then we need to update the models
    // in the test data state.
    if(stateViewOrig != context.stateView) {
      AFibF.g.internalOnlyActiveStore.dispatch(AFUpdatePrototypeScreenTestModelsAction(
        AFUIScreenTestID.wireframe,
        context.models 
      ));
    }


  }
}

class AFWireframeDefinitionContext {
  final AFWireframes wireframes;
  final AFDefineTestDataContext testData;

  AFWireframeDefinitionContext({
    required this.wireframes,
    required this.testData,
  });


  AFWireframe defineWireframe<TStateView extends AFFlexibleStateView>({
    required AFPrototypeID id,
    required AFNavigatePushAction navigate,
    required AFWireframeExecutionDelegate<TStateView> body,
    required dynamic models,
    required AFCreateStateViewDelegate<TStateView> stateViewCreator,
  }) {
    final wf = AFWireframe<TStateView>(
      id: id,
      navigate: navigate, 
      body: body,
      testData: AFibF.g.testData,
      models: models,
      stateViewCreator: stateViewCreator,
    );
    wireframes.add(wf);
    return wf;
  }

  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.test);
  }

}