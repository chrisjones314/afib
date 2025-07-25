import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:flutter/material.dart';

/// Parameter uses to filter the tests shown on the screen.
@immutable
class AFUIPrototypeWidgetRouteParam extends AFScreenRouteParam {
  final AFWidgetPrototype test;

  AFUIPrototypeWidgetRouteParam({
    required this.test, 
    required super.wid,
  }): super(screenId: AFUIScreenID.screenPrototypeWidget);

  AFUIPrototypeWidgetRouteParam copyWith({
    AFWidgetPrototype? test,
    AFWidgetID? wid,
  }) {
    return AFUIPrototypeWidgetRouteParam(
      test: test ?? this.test,
      wid: wid ?? this.wid,
    );
  }
}

class AFUIPrototypeWidgetScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIPrototypeWidgetRouteParam> {
  const AFUIPrototypeWidgetScreenSPI(super.context, super.standard);
  
  factory AFUIPrototypeWidgetScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeWidgetRouteParam> context, AFStandardSPIData standard) {
    return AFUIPrototypeWidgetScreenSPI(context, standard,
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeWidgetScreen extends AFUIConnectedScreen<AFUIPrototypeWidgetScreenSPI, AFUIDefaultStateView, AFUIPrototypeWidgetRouteParam>{

  static final config = AFUIDefaultScreenConfig<AFUIPrototypeWidgetScreenSPI, AFUIPrototypeWidgetRouteParam> (
    spiCreator: AFUIPrototypeWidgetScreenSPI.create,
  );

  AFUIPrototypeWidgetScreen(): super(screenId: AFUIScreenID.screenPrototypeWidget, config: config);

  static AFNavigatePushAction navigatePush(AFWidgetPrototype test, {AFID? id}) {
    List<AFRouteParam>? children;
    AFWidgetID wid = AFUIWidgetID.widgetPrototypeTest;

    if(test is AFConnectedWidgetPrototype) {
      children = <AFRouteParam>[];
      children.add(test.routeParam);
      final childWid = test.routeParam.wid;
      if(!childWid.isKindOf(AFUIWidgetID.useScreenParam)) {
        wid = childWid;
      }
      final testChildren = test.children;
      if(testChildren != null) {
        children.addAll(testChildren);
      }
    }

    return AFNavigatePushAction(
      id: id,
      launchParam: AFUIPrototypeWidgetRouteParam(test: test, wid: wid),
      children: children,
    );
  }

  @override
  Widget buildWithSPI(AFUIPrototypeWidgetScreenSPI spi) {    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    return _buildScreen(spi);
  }

  Widget _buildScreen(AFUIPrototypeWidgetScreenSPI spi) {
    final context = spi.context;
    final test = context.p.test;
 
    final sourceWidget = test.render(context.p);
    return _createScaffold(spi, sourceWidget);
  }

  Widget _createScaffold(AFUIPrototypeWidgetScreenSPI spi, Widget resultWidget) {
    final context = spi.context;
    final createWidget = context.p.test.createWidgetWrapperDelegate;
    if(createWidget != null) {
      return createWidget(context, resultWidget);
    }

    final t = spi.t;

    return t.childScaffold(
      spi: spi,
      //key: _mainScaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: t.childButtonStandardBack(spi.context, screen: screenId),
        title: t.childText(text: 'Widget Test Screen',
          style: t.styleOnPrimary.titleLarge,
        ),
      ),
      body: resultWidget
    );

  }
}