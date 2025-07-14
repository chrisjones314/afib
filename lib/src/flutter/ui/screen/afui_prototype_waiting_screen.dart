import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:flutter/material.dart';


class AFUIPrototypeWaitingScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFRouteParam> {
  const AFUIPrototypeWaitingScreenSPI(super.context, super.standard);
  
  factory AFUIPrototypeWaitingScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParam> context, AFStandardSPIData standard) {
    return AFUIPrototypeWaitingScreenSPI(context, standard,
    );
  }

}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeWaitingScreen extends AFUIConnectedScreen<AFUIPrototypeWaitingScreenSPI, AFUIDefaultStateView, AFRouteParam>{
  
  static final config =  AFUIDefaultScreenConfig<AFUIPrototypeWaitingScreenSPI, AFRouteParam> (
    spiCreator: AFUIPrototypeWaitingScreenSPI.create,
  );


  AFUIPrototypeWaitingScreen(): super(screenId: AFUIScreenID.screenPrototypeWaiting, config: config);

  static AFNavigatePushAction navigatePush() {
    return AFNavigatePushAction(
      launchParam: AFRouteParamUnused.unused);
  }

  @override
  Widget buildWithSPI(AFUIPrototypeWaitingScreenSPI spi) {
    final t = spi.t;
    
    return Scaffold(
      appBar: AppBar(title: t.childText(text: "Loading"), automaticallyImplyLeading: false),
      body: Center(child: t.childText(text: "Loading..."))
    );    

  }
}
