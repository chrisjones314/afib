import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:meta/meta.dart';

typedef void AFReturnFunc<T>(T returnData);

/// Base class for action that manipulates the route (pushing, popping, replacing)
/// and determines which screen is showing, and what data is visible.
@immutable
class AFNavigateAction {
  final String screen;
  final AFRouteParam param;

  AFNavigateAction({
    @required this.screen,
    this.param
  });
}

/// Action that replaces the current leaf screen with a new screen.
class AFNavigateReplaceAction extends AFNavigateAction {  
  AFNavigateReplaceAction({String screen, AFRouteParam param}): super(screen: screen, param: param);
}

/// Action that removes all screens in the route, and replaces them with
/// a single new screen at the root.
class AFNavigateReplaceAllAction extends AFNavigateAction {
  AFNavigateReplaceAllAction({String screen, AFRouteParam param}): super(screen: screen, param: param);
}

/// Action that changes the data associated with the current screen, but 
/// does not change the screen itself.
class AFNavigateSetParamAction extends AFNavigateAction {
  AFNavigateSetParamAction({String screen, AFRouteParam param}): super(screen: screen, param: param);
}

/// Action that adds a new screen after the current screen in the route.
/// 
/// Subsequently, [AFNavigatePopAction] will return you to the parent screen.
class AFNavigatePushAction extends AFNavigateAction {
  final AFReturnFunc<dynamic> onReturn;

  AFNavigatePushAction({String screen, AFRouteParam param, this.onReturn}): super(screen: screen, param: param);
}

/// Action that navigates on screen up in the route, discarding the current leaf route.
class AFNavigatePopAction extends AFNavigateAction {
  final dynamic returnData;
  
  AFNavigatePopAction({this.returnData}): super(screen: null, param: null);
}