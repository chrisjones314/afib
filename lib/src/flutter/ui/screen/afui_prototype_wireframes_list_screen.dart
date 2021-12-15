

import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/stateviews/afui_prototype_state_view.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';


/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeWireframesListScreen extends AFUIConnectedScreen<AFRouteParam>{
  AFUIPrototypeWireframesListScreen(): super(AFUIScreenID.screenPrototypeWireframesList);

  static AFNavigatePushAction navigateTo() {
    return AFNavigatePushAction(
      routeParam: AFRouteParamUnused.create(id: AFUIScreenID.screenPrototypeWireframesList)
    );
  }

  @override
  Widget buildWithContext(AFUIBuildContext<AFUIPrototypeStateView, AFRouteParam> context) {
    return _buildWireframes(context);
  }

  /// 
  Widget _buildWireframes(AFUIBuildContext<AFUIPrototypeStateView, AFRouteParam> context) {
    final t = context.t;
    final rowsCard = t.column();

    for(final wireframe in AFibF.g.wireframes.wireframes) {
      final test = AFibF.g.findScreenTestById(wireframe.initialScreen);
      if(test == null) {
        assert(false);
        continue;
      }
      rowsCard.add(
        t.createTestListTile(context.d, test,
          title: wireframe.name,
          subtitle: test.id.toString(),
          onTap: () {
            context.dispatch(AFStartWireframeAction(wireframe: wireframe));
            test.startScreen(context.d, wireframe.registry);
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
