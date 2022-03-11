
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';

class AFStartSpecificPrototypeQuery extends AFDeferredQuery<AFFlexibleState> {
  AFStartSpecificPrototypeQuery():
    super(const Duration(milliseconds: 500));

  @override
  Duration? finishAsyncExecute(AFFinishQuerySuccessContext<AFFlexibleState, AFUnused> context) {
    // Basically, for each different type of test, look it up, then update the state to properly, 
    // then redirect to the test.
    final config = AFibD.config;
    final env = config.environment;

    final protoId = config.startupPrototypeId;
    if(env == AFEnvironment.wireframe) {
      _startWireframe(context, protoId);
    } else {
      _startScreenPrototype(context, protoId);
    }
    return null;
  }

  void _startWireframe(AFFinishQuerySuccessContext<AFFlexibleState, AFUnused> context, AFPrototypeID protoId) {
    final wireframe = AFibF.g.wireframes.find(protoId);
    
    final body = AFSingleScreenPrototypeBody(wireframe.id);
    final test = AFSingleScreenPrototype(
      id: wireframe.id,
      navigate: wireframe.navigate,
      models: wireframe.models,
      body: body,
      timeHandling: AFTestTimeHandling.running
    );
    context.dispatch(AFStartWireframeAction(wireframe: wireframe));
    test.startScreen(context.d, null, wireframe.testData);
  }

  void _startScreenPrototype(AFFinishQuerySuccessContext<AFFlexibleState, AFUnused> context, AFPrototypeID protoId) {
    final prototype = AFibF.g.findScreenTestById(protoId);
    if(prototype == null) {
      throw AFException("Could not find prototype $protoId");
    }
    context.dispatch(AFNavigateSetParamAction(
      param: AFUIPrototypeDrawerRouteParam.createOncePerScreen(AFUIPrototypeDrawerRouteParam.viewTest),
      children: null,
      route: AFNavigateRoute.routeGlobalPool
    ));
    context.dispatch(AFUpdateActivePrototypeAction(prototypeId: prototype.id));
    prototype.startScreen(context.d, null, AFibF.g.testData);

  }

  @override
  void shutdown() {}
}
