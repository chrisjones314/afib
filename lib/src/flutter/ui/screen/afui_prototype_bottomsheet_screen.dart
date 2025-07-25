import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

/// Parameter uses to filter the tests shown on the screen.
@immutable
class AFUIPrototypeBottomSheetRouteParam extends AFScreenRouteParam {
  final AFBottomSheetPrototype test;
  final AFRouteParam? routeParam;

  AFUIPrototypeBottomSheetRouteParam({
    required this.test, 
    required this.routeParam
  }): super(screenId: AFUIScreenID.screenPrototypeBottomSheet);

  AFUIPrototypeBottomSheetRouteParam copyWith({
    AFBottomSheetPrototype? test,
    AFRouteParam? param
  }) {
    return AFUIPrototypeBottomSheetRouteParam(
      test: test ?? this.test,
      routeParam: param ?? this.routeParam
    );
  }
}

class AFUIPrototypeBottomSheetScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIPrototypeBottomSheetRouteParam> {
  const AFUIPrototypeBottomSheetScreenSPI(super.context, super.standard);
  
  factory AFUIPrototypeBottomSheetScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeBottomSheetRouteParam> context, AFStandardSPIData standard) {
    return AFUIPrototypeBottomSheetScreenSPI(context, standard,
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeBottomSheetScreen extends AFUIConnectedScreen<AFUIPrototypeBottomSheetScreenSPI, AFUIDefaultStateView, AFUIPrototypeBottomSheetRouteParam>{

  static final config = AFUIDefaultScreenConfig<AFUIPrototypeBottomSheetScreenSPI, AFUIPrototypeBottomSheetRouteParam> (
    spiCreator: AFUIPrototypeBottomSheetScreenSPI.create,
  );

  AFUIPrototypeBottomSheetScreen(): super(screenId: AFUIScreenID.screenPrototypeBottomSheet, config: config);

  static AFNavigateAction navigatePush(AFBottomSheetPrototype test, {AFID? id}) {
    return AFNavigatePushAction(
      id: id,
      launchParam: AFUIPrototypeBottomSheetRouteParam(test: test, routeParam: AFRouteParamUnused.unused),
    );
  }

  @override
  Widget buildWithSPI(AFUIPrototypeBottomSheetScreenSPI spi) {    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    return _buildScreen(spi);
  }

  Widget _buildScreen(AFUIPrototypeBottomSheetScreenSPI spi) {
    final context = spi.context;
    AFibF.g.setTestOnlyShowBuildContext(AFUIType.bottomSheet, context.c);

    return _createScaffold(spi);
  }

  Widget _childShowButton(AFUIPrototypeBottomSheetScreenSPI spi) {
    final t = spi.t;
    final test = spi.context.p.test;
    //final sourceWidget = test.render(screenId, AFUIWidgetID.widgetPrototypeTest);
    return Center(
      child: t.childButtonPrimaryText(
        text: "Show Bottom Sheet",
        onPressed: () {
          spi.context.showBottomSheet(navigate: test.createNavigatePush());
        }
    ));
  }

  Widget _createScaffold(AFUIPrototypeBottomSheetScreenSPI spi) {
    final t = spi.t;
    return t.childScaffold(
      spi: spi,
      appBar: AppBar(title: t.childText(text: 'Bottom Sheet Test Screen')),
      body: AFBuilder<AFUIPrototypeBottomSheetScreenSPI>(
        spiParent: spi,
        config: config,
        builder: (spiUnder) {
          return _childShowButton(spiUnder);
        }
      )
    );
  }
}