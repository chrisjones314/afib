

import 'package:meta/meta.dart';
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
  final dynamic wireframeParam;

  AFWireframeExecutionContext({
    this.screen,
    this.widget,
    this.wireframeParam,
  });


  void navigateTo(AFSingleScreenTestID testId) {
    final test = AFibF.g.findScreenTestById(testId);
    test.startScreen(AFibF.g.storeDispatcherInternalOnly);
  }
}

class AFWireframe {
  final String name;
  final AFSingleScreenTestID initialScreen;
  final AFWireframeExecutionDelegate body;

  AFWireframe({
    @required this.name, 
    @required this.initialScreen, 
    @required this.body});

  void updateState(AFScreenID screen, AFID widget, dynamic param) {
    final context = AFWireframeExecutionContext(
      screen: screen,
      widget: widget,
      wireframeParam: param,
    );
    body(context);
  }
}

class AFWireframeDefinitionContext {
  final AFWireframes wireframes;
  final AFTestDataRegistry testData;

  AFWireframeDefinitionContext({
    this.wireframes,
    this.testData,
  });


  AFWireframe defineWireframe({
    @required String name,
    @required AFSingleScreenTestID initialScreen,
    @required AFWireframeExecutionDelegate body,
  }) {
    final wf = AFWireframe(name: name, initialScreen: initialScreen, body: body);
    wireframes.add(wf);
    return wf;
  }
}