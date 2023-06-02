import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/utils/af_api_mixins.dart';
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

class AFWireframeExecutionContext with AFStandardNavigateMixin {
  final AFScreenID screen;
  final AFID widget;
  final dynamic eventParam;
  final AFWireframe wireframe;
  final AFFlexibleStateView? stateView;

  AFWireframeExecutionContext({
    required this.screen,
    required this.widget,
    required this.eventParam,
    required this.wireframe,
    required this.stateView,
  });

  bool isScreen(AFScreenID screenId) {
    return this.screen == screenId;
  }

  bool isScreenAndWidget(AFScreenID screenId, AFWidgetID widgetId) {
    return isScreen(screenId) && isWidget(widgetId);
  }

  TResult accessEventParam<TResult>() {
    return eventParam as TResult;
  }

  TStateView accessStateView<TStateView extends AFFlexibleStateView>() {
    final sv = stateView;
    if(sv is TStateView) {
      return sv;
    }
    throw AFException("Currently, you can only access the kind of state view that caused the event");
  }

  bool isWidget(AFWidgetID widgetId) {
    return this.widget == widgetId;
  }

  /*
  void navigatePop() {
    _dispatch(AFNavigatePopAction());
    _dispatch(AFStartWireframePopTestAction());
  }
  */

  void updateStateViewRootOne(Object source) {
    updateStateViewRootN([source]);
  }

  void updateStateViewRootN(List<Object> source) {
    final sv = AFibF.g.testData.resolveStateViewModels(source);

    // preserve what already exists.
    final models = stateView?.models;
    if(models != null) {
      for(final key in models.keys) {
        if(!sv.containsKey(key)) {
          final model = models[key];
          if(model != null) {
            sv[key] = model;
          }
        }
      }
    }
    dispatch(AFUpdatePrototypeScreenTestModelsAction(AFUIScreenTestID.wireframe, sv));
  }


  dynamic td(dynamic id) {
    return wireframe.testData.find(id);
  }

  @override
  void dispatch(dynamic action) {
    AFibF.g.internalOnlyActiveDispatcher.dispatch(action);
  }
}

class AFWireframe {
  final AFWireframeID id;
  final AFNavigatePushAction navigate;
  final AFWireframeExecutionDelegate body;
  final AFDefineTestDataContext testData;
  final dynamic stateView;
  final bool enableUINavigation;
  final AFTestTimeHandling timeHandling;

  AFWireframe({
    required this.id,
    required this.navigate, 
    required this.body,
    required this.testData,
    required this.stateView,
    required this.enableUINavigation,
    required this.timeHandling,
  });

  factory AFWireframe.create({
    required AFWireframeID id,
    required AFNavigatePushAction navigate,
    required AFWireframeExecutionDelegate body,
    required dynamic models,
    required AFTestTimeHandling timeHandling,
    bool enableUINavigation = true,
  }) {
    final testData = AFibF.g.testData;
    return AFWireframe(
      id: id, 
      navigate: navigate, 
      body: body, 
      testData: testData, 
      stateView: models, 
      enableUINavigation: enableUINavigation,
      timeHandling: timeHandling,
    );
  }


  void onEvent(AFScreenID screen, AFID widget, dynamic param, AFFlexibleStateView? stateView, AFPressedDelegate? onSuccess) {
    final context = AFWireframeExecutionContext(
      screen: screen,
      widget: widget,
      eventParam: param,
      wireframe: this,
      stateView: stateView
    );

    final handled = body(context);
    if(!handled && !enableUINavigation) {
      if(context.isWidget(AFUIWidgetID.buttonBack)) {
        context.navigatePop();
      }
    }

    if(onSuccess != null) {
      onSuccess();
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


  AFWireframe defineWireframe({
    required AFWireframeID id,
    required AFNavigatePushAction navigate,
    required AFWireframeExecutionDelegate body,
    required Object stateView,
    bool enableUINavigation = true,
    required AFTestTimeHandling timeHandling,
  }) {
    final wf = AFWireframe(
      id: id,
      navigate: navigate, 
      body: body,
      testData: AFibF.g.testData,
      stateView: stateView,
      enableUINavigation: enableUINavigation,
      timeHandling: timeHandling,
    );
    wireframes.add(wf);
    return wf;
  }

  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.test);
  }

}