

import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/ui/af_prototype_base.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

/// Data used to render the screen
class AFPrototypeWireframesStateView extends AFStateView1<AFSingleScreenTests> {
  AFPrototypeWireframesStateView(AFSingleScreenTests tests): 
    super(first: tests);
  
  AFSingleScreenTests get tests { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeWireframesListScreen extends AFUIConnectedScreen<AFPrototypeWireframesStateView, AFRouteParam>{
  AFPrototypeWireframesListScreen(): super(AFUIScreenID.screenPrototypeWireframesList);

  static AFNavigatePushAction navigateTo() {
    return AFNavigatePushAction(screen: AFUIScreenID.screenPrototypeWireframesList,
      routeParam: AFRouteParam.unused());
  }

  @override
  AFPrototypeWireframesStateView createStateViewAF(AFState state, AFRouteParam param, AFRouteParamWithChildren withChildren) {
    final tests = AFibF.g.screenTests;
    return AFPrototypeWireframesStateView(tests);
  }

  @override
  AFPrototypeWireframesStateView createStateView(AFAppStateArea state, AFRouteParam param) {
    // this should never be called, because createStateViewAF replaces it.
    throw UnimplementedError();
  }

  @override
  Widget buildWithContext(AFUIBuildContext<AFPrototypeWireframesStateView, AFRouteParam> context) {
    return _buildWireframes(context);
  }

  /// 
  Widget _buildWireframes(AFUIBuildContext<AFPrototypeWireframesStateView, AFRouteParam> context) {
    final t = context.t;
    final rowsCard = t.column();

    for(final wireframe in AFibF.g.wireframes.wireframes) {
      final test = AFibF.g.findScreenTestById(wireframe.initialScreen);
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
