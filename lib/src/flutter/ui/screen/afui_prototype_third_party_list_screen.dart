

import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_third_party_home_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

class AFUIPrototypeThirdPartyListScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFRouteParam> {
  AFUIPrototypeThirdPartyListScreenSPI(AFBuildContext<AFUIDefaultStateView, AFRouteParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme, );
  
  factory AFUIPrototypeThirdPartyListScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParam> context, AFUIDefaultTheme theme, AFScreenID screenId) {
    return AFUIPrototypeThirdPartyListScreenSPI(context, screenId, theme,
    );
  }

}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeThirdPartyListScreen extends AFUIConnectedScreen<AFUIPrototypeThirdPartyListScreenSPI, AFUIDefaultStateView, AFRouteParam>{
  
  static final config =  AFUIDefaultScreenConfig<AFUIPrototypeThirdPartyListScreenSPI, AFRouteParam> (
    spiCreator: AFUIPrototypeThirdPartyListScreenSPI.create,
  );


  AFUIPrototypeThirdPartyListScreen(): super(screenId: AFUIScreenID.screenPrototypeThirdPartyList, config: config);

  static AFNavigatePushAction navigatePush() {
    return AFNavigatePushAction(
      routeParam: AFRouteParamUnused.create(id: AFUIScreenID.screenPrototypeThirdPartyList));
  }

  @override
  Widget buildWithSPI(AFUIPrototypeThirdPartyListScreenSPI spi) {
    return _buildThirdParty(spi);
  }

  /// 
  Widget _buildThirdParty(AFUIPrototypeThirdPartyListScreenSPI spi) {
    final t = spi.t;
    final context = spi.context;
    final rowsCard = t.column();

    for(final thirdParty in AFibF.g.appContext.thirdParty.libraries.values) {
      final subtitle = "${thirdParty.id}";
      rowsCard.add(
        t.childListTileNavDown(
          wid: thirdParty.id,
          title: t.childText(thirdParty.id.name),
          subtitle: t.childText(subtitle),
          onTap: () {
            spi.dispatch(AFUIPrototypeThirdPartyHomeScreen.navigatePush(thirdParty));
          }
      ));
    }

    final rows = t.column();
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardThirdParty, "Third Party", rowsCard));
    final leading = t.childButtonStandardBack(context, screen: screenId);
    return t.buildPrototypeScaffold("AFib Third Party", rows, leading: leading);

  }
}
