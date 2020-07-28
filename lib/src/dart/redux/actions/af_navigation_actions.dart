import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/utils/af_bottom_popup_theme.dart';
import 'package:afib/src/flutter/utils/af_custom_popup_route.dart';
import 'package:flutter/widgets.dart';
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

/// Pushes a popup with a custom route.
class AFNavigatePushPopupAction extends AFNavigateAction {
  
  final BuildContext context;
  final AFBottomPopupTheme theme;
  final AFReturnFunc<dynamic> onReturn;
  final AFRouteWidgetBuilder popupBuilder;
  
  AFNavigatePushPopupAction({
    AFID id, 
    @required this.context,
    @required AFScreenID screen, 
    @required AFRouteParam param,
    @required this.theme,
    @required this.popupBuilder,
    this.onReturn}): super(id: id, screen: screen, param: param);
}


/// Action that navigates on screen up in the route, discarding the current leaf route.
/// 
/// IF you want to test for the presence of a pop action in response to an event in 
/// prototype mode, you can make [worksInPrototypeMode] false.   By default, pop actions
/// navigate you out of a prototype screen in test mode.
class AFNavigatePopAction extends AFNavigateAction {
  final dynamic returnData;
  final bool worksInPrototypeMode;
  
  AFNavigatePopAction({AFID id, this.returnData, this.worksInPrototypeMode = true}): super(id: id, screen: null, param: null);
}

