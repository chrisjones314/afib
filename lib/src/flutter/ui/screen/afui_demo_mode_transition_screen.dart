
import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:flutter/material.dart';


class AFUIDemoModeTransitionScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFRouteParamUnused> {
  AFUIDemoModeTransitionScreenSPI(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme, );
  
  factory AFUIDemoModeTransitionScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFUIDefaultTheme theme, AFScreenID screenId) {
    return AFUIDemoModeTransitionScreenSPI(context, screenId, theme,
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
        title: t.childText('$transitionTitle Demo Mode'), 
      ),
      body: Center(
        child: t.childText("$transitionTitle demonstration mode")
      ),
    );
  }
}

class AFUIDemoModeEnterScreen extends AFUIDemoModeTransitionScreen {

  AFUIDemoModeEnterScreen(): super(
    screenId: AFUIScreenID.screenDemoModeEnter,
    transitionTitle: "Entering"
  );

  static AFNavigateReplaceAllAction navigateReplaceAll() {
    return AFNavigateReplaceAllAction(
      id: AFUIScreenID.screenDemoModeEnter,
      param: AFRouteParamUnused.create(id: AFUIScreenID.screenDemoModeEnter),
    );
  }
}


class AFUIDemoModeExitScreen extends AFUIDemoModeTransitionScreen {

  AFUIDemoModeExitScreen(): super(
    screenId: AFUIScreenID.screenDemoModeExit,
    transitionTitle: "Exiting"
  );

  static AFNavigateReplaceAllAction navigateReplaceAll() {
    return AFNavigateReplaceAllAction(
      id: AFUIScreenID.screenDemoModeExit,
      param: AFRouteParamUnused.create(id: AFUIScreenID.screenDemoModeExit),
    );
  }
}