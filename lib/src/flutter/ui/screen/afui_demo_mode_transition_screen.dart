
import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:flutter/material.dart';


class AFUIDemoModeTransitionScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFRouteParamUnused> {
  AFUIDemoModeTransitionScreenSPI(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFStandardSPIData standard): super(context, standard);
  
  factory AFUIDemoModeTransitionScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFStandardSPIData standard) {
    return AFUIDemoModeTransitionScreenSPI(context, standard,
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIDemoModeTransitionScreen extends AFUIConnectedScreen<AFUIDemoModeTransitionScreenSPI, AFUIDefaultStateView, AFRouteParamUnused>{
  final String transitionTitle;

  static final config = AFUIDefaultScreenConfig<AFUIDemoModeTransitionScreenSPI, AFRouteParamUnused> (
    spiCreator: AFUIDemoModeTransitionScreenSPI.create,
  );

  AFUIDemoModeTransitionScreen({ 
    required AFScreenID screenId,
    required this.transitionTitle
  }): super(screenId: screenId, config: config);

  @override
  Widget buildWithSPI(AFUIDemoModeTransitionScreenSPI spi) {    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    final t = spi.t;
    return t.childScaffold(
      spi: spi,
      appBar: AppBar(
        title: t.childText(text: '$transitionTitle Demo Mode'), 
      ),
      body: Center(
        child: t.childText(text: "$transitionTitle demonstration mode")
      ),
    );
  }
}

class AFUIDemoModeEnterScreen extends AFUIDemoModeTransitionScreen {

  AFUIDemoModeEnterScreen(): super(
    screenId: AFUIScreenID.screenDemoModeEnter,
    transitionTitle: "Entering"
  );

  static AFNavigatePushAction navigatePush() {
    return AFNavigatePushAction(
      id: AFUIScreenID.screenDemoModeEnter,
      launchParam: AFRouteParamUnused.unused,
    );
  }
}


class AFUIDemoModeExitScreen extends AFUIDemoModeTransitionScreen {

  AFUIDemoModeExitScreen(): super(
    screenId: AFUIScreenID.screenDemoModeExit,
    transitionTitle: "Exiting"
  );

  static AFNavigatePushAction navigatePush() {
    return AFNavigatePushAction(
      id: AFUIScreenID.screenDemoModeExit,
      launchParam: AFRouteParamUnused.unused,
    );
  }
}