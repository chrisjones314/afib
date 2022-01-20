

import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_prototype_state_view.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

class AFUIPrototypeWireframesListScreenSPI extends AFUIDefaultSPI<AFUIPrototypeStateView, AFRouteParam> {
  AFUIPrototypeWireframesListScreenSPI(AFUIBuildContext<AFUIPrototypeStateView, AFRouteParam> context, AFConnectedUIBase screen): super(context, screen);
  factory AFUIPrototypeWireframesListScreenSPI.create(AFUIBuildContext<AFUIPrototypeStateView, AFRouteParam> context, AFConnectedUIBase screen) {
    return AFUIPrototypeWireframesListScreenSPI(context, screen);
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeWireframesListScreen extends AFUIDefaultConnectedScreen<AFUIPrototypeWireframesListScreenSPI, AFRouteParam>{
  AFUIPrototypeWireframesListScreen(): super(AFUIScreenID.screenPrototypeWireframesList, AFUIPrototypeWireframesListScreenSPI.create);

  static AFNavigatePushAction navigateTo() {
    return AFNavigatePushAction(
      routeParam: AFRouteParamUnused.create(id: AFUIScreenID.screenPrototypeWireframesList)
    );
  }

  @override
  Widget buildWithContext(AFUIPrototypeWireframesListScreenSPI spi) {
    return _buildWireframes(spi.context);
  }

  /// 
  Widget _buildWireframes(AFUIBuildContext<AFUIPrototypeStateView, AFRouteParam> context) {
    final t = context.t;
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
