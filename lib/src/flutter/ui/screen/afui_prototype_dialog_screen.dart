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
class AFUIPrototypeDialogRouteParam extends AFScreenRouteParam {
  final AFDialogPrototype test;
  final AFRouteParam? routeParam;

  AFUIPrototypeDialogRouteParam({
    required this.test, 
    required this.routeParam
  }): super(screenId: AFUIScreenID.screenPrototypeDialog);

  AFUIPrototypeDialogRouteParam copyWith({
    AFDialogPrototype? test,
    AFRouteParam? param
  }) {
    return AFUIPrototypeDialogRouteParam(
      test: test ?? this.test,
      routeParam: param ?? this.routeParam
    );
  }
}

class AFUIPrototypeDialogScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIPrototypeDialogRouteParam> {
  const AFUIPrototypeDialogScreenSPI(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeDialogRouteParam> context, AFStandardSPIData standard): super(context, standard);
  
  factory AFUIPrototypeDialogScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeDialogRouteParam> context, AFStandardSPIData standard) {
    return AFUIPrototypeDialogScreenSPI(context, standard,
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeDialogScreen extends AFUIConnectedScreen<AFUIPrototypeDialogScreenSPI, AFUIDefaultStateView, AFUIPrototypeDialogRouteParam>{

  static final config = AFUIDefaultScreenConfig<AFUIPrototypeDialogScreenSPI, AFUIPrototypeDialogRouteParam> (
    spiCreator: AFUIPrototypeDialogScreenSPI.create,
  );

  AFUIPrototypeDialogScreen(): super(screenId: AFUIScreenID.screenPrototypeDialog, config: config);

  static AFNavigateAction navigatePush(AFDialogPrototype test, {AFID? id}) {
    return AFNavigatePushAction(
      id: id,
      launchParam: AFUIPrototypeDialogRouteParam(test: test, routeParam: AFRouteParamUnused.unused),
    );
  }

  @override
  Widget buildWithSPI(AFUIPrototypeDialogScreenSPI spi) {    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    return _buildScreen(spi);
  }

  Widget _buildScreen(AFUIPrototypeDialogScreenSPI spi) {
    final context = spi.context;
    AFibF.g.setTestOnlyShowBuildContext(AFUIType.dialog, context.c);
    final t = spi.t;
    final test = context.p.test;

    //final sourceWidget = test.render(screenId, AFUIWidgetID.widgetPrototypeTest);
    Widget resultWidget = Center(
      child: t.childButtonPrimaryText(
        text: "Show Dialog",
        onPressed: () {
          spi.context.showDialogAFib(navigate: test.navigate);
        }
    ));

    return _createScaffold(spi, resultWidget);
  }

  Widget _createScaffold(AFUIPrototypeDialogScreenSPI spi, Widget resultWidget) {
    final t = spi.t;
    return t.childScaffold(
      spi: spi,
      appBar: AppBar(
        leading: t.childButtonStandardBack(spi, screen: screenId),
        title: t.childText(text: 'Dialog Test Screen'), 
      ),
      body: resultWidget,
    );

  }
}