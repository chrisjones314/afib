

import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

class AFUIPrototypeWireframesListScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFRouteParam> {
  AFUIPrototypeWireframesListScreenSPI(AFBuildContext<AFUIDefaultStateView, AFRouteParam> context, AFStandardSPIData standard): super(context, standard );
  
  factory AFUIPrototypeWireframesListScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParam> context, AFStandardSPIData standard) {
    return AFUIPrototypeWireframesListScreenSPI(context, standard,
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

  static AFNavigatePushAction navigatePush() {
    return AFNavigatePushAction(
      launchParam: AFRouteParamUnused.unused
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
        t.createTestListTile(spi, test,
          title: wireframe.id.toString(),
          onTap: () {               
            context.dispatch(AFStartWireframeAction(wireframe: wireframe));
            test.startScreen(spi.context.d, spi.flutterContext, wireframe.testData);
          }
        )
      );
    }

    final rows = t.column();
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardWireframes, "Wireframes", rowsCard));
    final main = ListView(children: rows);
    final leading = t.childButtonStandardBack(spi, screen: screenId);
    return t.buildPrototypeScaffold(spi, "AFib Wireframes", main, leading: leading);

  }
}
