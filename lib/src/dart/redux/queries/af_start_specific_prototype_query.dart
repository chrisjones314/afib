
import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';

class AFStartSpecificPrototypeQuery extends AFDeferredQuery {
  AFStartSpecificPrototypeQuery():
    super(const Duration(milliseconds: 500));

  @override
  Duration? finishAsyncExecute(AFFinishQuerySuccessContext<AFUnused> context) {
    // Basically, for each different type of test, look it up, then update the state to properly, 
    // then redirect to the test.
    final config = AFibD.config;
    final env = config.environment;

    final startupId = config.startupPrototypeId;
    final protoId = AFibF.g.prototypeIdForStartupId(startupId);
    if(env == AFEnvironment.startupInWireframe) {
      _startWireframe(context, protoId);
    } else {
      _startScreenPrototype(context, protoId);
    }
    return null;
  }

  void _startWireframe(AFFinishQuerySuccessContext<AFUnused> context, AFPrototypeID protoId) {
    final wireframe = AFibF.g.wireframes.find(protoId);
    
    final body = AFSingleScreenPrototypeBody(wireframe.id);
    final test = AFSingleScreenPrototype(
      id: wireframe.id,
      navigate: wireframe.navigate,
      stateView: wireframe.stateView,
      body: body,
      timeHandling: AFTestTimeHandling.running
    );
    context.dispatch(AFStartWireframeAction(wireframe: wireframe));
    test.startScreen(context.dispatcher, null, wireframe.testData);
  }

  void _startScreenPrototype(AFFinishQuerySuccessContext<AFUnused> context, AFPrototypeID protoId) {
    final prototype = AFibF.g.findScreenTestById(protoId);
    if(prototype == null) {
      throw AFException("Could not find prototype $protoId");
    }
    context.dispatch(AFNavigateSetParamAction(
      param: AFUIPrototypeDrawerRouteParam.createOncePerScreen(AFUIPrototypeDrawerRouteParam.viewTest),
      children: null
    ));
    context.dispatch(AFUpdateActivePrototypeAction(prototypeId: prototype.id));
    prototype.startScreen(context.dispatcher, null, AFibF.g.testData);

  }

  @override
  void shutdown() {}
}
