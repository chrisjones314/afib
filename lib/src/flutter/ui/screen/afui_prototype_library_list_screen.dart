

import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_library_home_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

class AFUIPrototypeLibraryListScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFRouteParam> {
  AFUIPrototypeLibraryListScreenSPI(AFBuildContext<AFUIDefaultStateView, AFRouteParam> context, AFStandardSPIData standard): super(context, standard);
  
  factory AFUIPrototypeLibraryListScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParam> context, AFStandardSPIData standard) {
    return AFUIPrototypeLibraryListScreenSPI(context, standard,
    );
  }

}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeLibraryListScreen extends AFUIConnectedScreen<AFUIPrototypeLibraryListScreenSPI, AFUIDefaultStateView, AFRouteParam>{
  
  static final config =  AFUIDefaultScreenConfig<AFUIPrototypeLibraryListScreenSPI, AFRouteParam> (
    spiCreator: AFUIPrototypeLibraryListScreenSPI.create,
  );


  AFUIPrototypeLibraryListScreen(): super(screenId: AFUIScreenID.screenPrototypeLibraryList, config: config);

  static AFNavigatePushAction navigatePush() {
    return AFNavigatePushAction(
      launchParam: AFRouteParamUnused.unused);
  }

  @override
  Widget buildWithSPI(AFUIPrototypeLibraryListScreenSPI spi) {
    return _buildLibrary(spi);
  }

  /// 
  Widget _buildLibrary(AFUIPrototypeLibraryListScreenSPI spi) {
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
            spi.context.navigatePush(AFUIPrototypeLibraryHomeScreen.navigatePush(thirdParty));
          }
      ));
    }

    final rows = t.column();
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardLibrary, "Libraries", rowsCard));
    final leading = t.childButtonStandardBack(spi, screen: screenId);
    final main = ListView(children: rows);
    return t.buildPrototypeScaffold(spi, "AFib Libraries", main, leading: leading);

  }
}
