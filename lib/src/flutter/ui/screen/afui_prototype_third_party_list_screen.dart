

import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_third_party_home_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_prototype_state_view.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';


/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeThirdPartyListScreen extends AFUIDefaultConnectedScreen<AFRouteParam>{
  AFUIPrototypeThirdPartyListScreen(): super(AFUIScreenID.screenPrototypeThirdPartyList);

  static AFNavigatePushAction navigatePush() {
    return AFNavigatePushAction(
      routeParam: AFRouteParamUnused.create(id: AFUIScreenID.screenPrototypeThirdPartyList));
  }

  @override
  Widget buildWithContext(AFUIBuildContext<AFUIPrototypeStateView, AFRouteParam> context) {
    return _buildThirdParty(context);
  }

  /// 
  Widget _buildThirdParty(AFUIBuildContext<AFUIPrototypeStateView, AFRouteParam> context) {
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
            context.dispatchNavigatePush(AFUIPrototypeThirdPartyHomeScreen.navigatePush(thirdParty));
          }
      ));
    }

    final rows = t.column();
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardThirdParty, "Third Party", rowsCard));
    final leading = t.childButtonStandardBack(context, screen: screenId);
    return t.buildPrototypeScaffold("AFib Third Party", rows, leading: leading);

  }
}
