

import 'package:afib/afib_flutter.dart';
import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/af_prototype_base.dart';
import 'package:afib/src/flutter/ui/screen/af_prototype_third_party_home_screen.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

/// Data used to render the screen
class AFPrototypeThirdPartyStateView extends AFStateView1<AFSingleScreenTests> {
  AFPrototypeThirdPartyStateView(AFSingleScreenTests tests): 
    super(first: tests);
  
  AFSingleScreenTests? get tests { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeThirdPartyListScreen extends AFUIConnectedScreen<AFPrototypeThirdPartyStateView, AFRouteParam>{
  AFPrototypeThirdPartyListScreen(): super(AFUIScreenID.screenPrototypeThirdPartyList);

  static AFNavigatePushAction navigatePush() {
    return AFNavigatePushAction(
      routeParam: AFRouteParamUnused.create(id: AFUIScreenID.screenPrototypeThirdPartyList));
  }

  @override
  AFPrototypeThirdPartyStateView createStateViewAF(AFState state, AFRouteParam param, AFRouteSegmentChildren? children) {
    final tests = AFibF.g.screenTests;
    return AFPrototypeThirdPartyStateView(tests);
  }

  @override
  AFPrototypeThirdPartyStateView createStateView(AFAppStateArea? state, AFRouteParam param) {
    // this should never be called, because createStateViewAF replaces it.
    throw UnimplementedError();
  }

  @override
  Widget buildWithContext(AFUIBuildContext<AFPrototypeThirdPartyStateView, AFRouteParam> context) {
    return _buildThirdParty(context);
  }

  /// 
  Widget _buildThirdParty(AFUIBuildContext<AFPrototypeThirdPartyStateView, AFRouteParam> context) {
    final t = context.t;
    final rowsCard = t.column();

    for(final thirdParty in AFibF.g.appContext.thirdParty.libraries.values) {
      final subtitle = "${thirdParty.id}";
      rowsCard.add(
        t.childListTileNavDown(
          wid: thirdParty.id,
          title: t.childText(thirdParty.id.name),
          subtitle: t.childText(subtitle),
          onTap: () {
            context.dispatchNavigatePush(AFPrototypeThirdPartyHomeScreen.navigatePush(thirdParty));
          }
      ));
    }

    final rows = t.column();
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardThirdParty, "Third Party", rowsCard));
    final leading = t.childButtonStandardBack(context, screen: screenId);
    return t.buildPrototypeScaffold("AFib Third Party", rows, leading: leading);

  }
}
