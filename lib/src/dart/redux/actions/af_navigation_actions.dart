import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:meta/meta.dart';

typedef void AFReturnFunc<T>(T returnData);

/// Base class for action that manipulates the route (pushing, popping, replacing)
/// and determines which screen is showing, and what data is visible.
@immutable
class AFNavigateAction extends AFActionWithKey {
  final AFID screen;
  final AFRouteParam param;

  AFNavigateAction({
    @required AFID id,
    @required this.screen,
    this.param
  }): super(id: id);
}

/// Action that replaces the current leaf screen with a new screen.
class AFNavigateReplaceAction extends AFNavigateAction {  
  AFNavigateReplaceAction({AFID id, AFScreenID screen, AFRouteParam param}): super(id: id, screen: screen, param: param);
}

/// Action that removes all screens in the route, and replaces them with
/// a single new screen at the root.
class AFNavigateReplaceAllAction extends AFNavigateAction {
  AFNavigateReplaceAllAction({AFID id, AFScreenID screen, AFRouteParam param}): super(id: id, screen: screen, param: param);
}

/// Action that changes the data associated with the current screen, but 
/// does not change the screen itself.
class AFNavigateSetParamAction extends AFNavigateAction {
  AFNavigateSetParamAction({AFID id, AFScreenID screen, AFRouteParam param}): super(id: id, screen: screen, param: param);
}

/// Action that adds a new screen after the current screen in the route.
/// 
/// Subsequently, [AFNavigatePopAction] will return you to the parent screen.
class AFNavigatePushAction extends AFNavigateAction {
  final AFReturnFunc<dynamic> onReturn;

  AFNavigatePushAction({AFID id, AFScreenID screen, AFRouteParam param, this.onReturn}): super(id: id, screen: screen, param: param);
}

/// Action that navigates on screen up in the route, discarding the current leaf route.
class AFNavigatePopAction extends AFNavigateAction {
  final dynamic returnData;
  
  AFNavigatePopAction({AFID id, this.returnData}): super(id: id, screen: null, param: null);
}

/// Action that causes us to navigate up from a prototype/test screen to the main prototype/test
/// list. 
/// 
/// This is necessary because the testing infrastructure catches all normal actions and records 
/// them for testing/logging purposes.
class AFNavigatePopInTestAction extends AFNavigatePopAction {
  AFNavigatePopInTestAction({AFID id, dynamic returnData}): super(id: id, returnData: returnData);
}