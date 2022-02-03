

import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

class AFUIPrototypeWireframesListScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFRouteParam> {
  AFUIPrototypeWireframesListScreenSPI(AFBuildContext<AFUIDefaultStateView, AFRouteParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme, );
  
  factory AFUIPrototypeWireframesListScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParam> context, AFUIDefaultTheme theme, AFScreenID screenId, AFWidgetID wid) {
    return AFUIPrototypeWireframesListScreenSPI(context, screenId, theme,
    );
  }

}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeWireframesListScreen extends AFUIConnectedScreen<AFUIPrototypeWireframesListScreenSPI, AFUIDefaultStateView, AFRouteParam>{
  
  static final config =  AFUIDefaultScreenConfig<AFUIPrototypeWireframesListScreenSPI, AFRouteParam> (
    spiCreator: AFUIPrototypeWireframesListScreenSPI.create,
  );

  AFUIPrototypeWireframesListScreen(): super(screenId: AFUIScreenID.screenPrototypeWireframesList, config: config);

  static AFNavigatePushAction navigateTo() {
    return AFNavigatePushAction(
      routeParam: AFRouteParamUnused.create(id: AFUIScreenID.screenPrototypeWireframesList)
    );
  }

  @override
  Widget buildWithSPI(AFUIPrototypeWireframesListScreenSPI spi) {
    return _buildWireframes(spi);
  }

  /// 
  Widget _buildWireframes(AFUIPrototypeWireframesListScreenSPI spi) {
    final t = spi.t;
    final context = spi.context;
    final rowsCard = t.column();

    for(final wireframe in AFibF.g.wireframes.wireframes) {

      final body = AFSingleScreenPrototypeBody(wireframe.id);
      final test = AFSingleScreenPrototype(
        id: wireframe.id,
        navigate: wireframe.navigate,
        models: wireframe.models,
        body: body,
        timeHandling: AFTestTimeHandling.running
      );

      rowsCard.add(
        t.createTestListTile(context.d, test,
          title: wireframe.id.toString(),
          onTap: () {               
            context.dispatch(AFStartWireframeAction(wireframe: wireframe));
            test.startScreen(context.d, wireframe.testData);
          }
        )
      );
    }

    final rows = t.column();
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardWireframes, "Wireframes", rowsCard));
    final leading = t.childButtonStandardBack(context, screen: screenId);
    return t.buildPrototypeScaffold("AFib Wireframes", rows, leading: leading);

  }
}
