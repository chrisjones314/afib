import 'package:afib/id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_prototype_state_view.dart';
import 'package:flutter/material.dart';

class AFPrototypeLoadingScreenSPI extends AFUIDefaultSPI<AFUIPrototypeStateView, AFRouteParam> {
  AFPrototypeLoadingScreenSPI(AFUIBuildContext<AFUIPrototypeStateView, AFRouteParam> context, AFConnectedUIBase screen): super(context, screen);
  factory AFPrototypeLoadingScreenSPI.create(AFUIBuildContext<AFUIPrototypeStateView, AFRouteParam> context, AFConnectedUIBase screen) {
    return AFPrototypeLoadingScreenSPI(context, screen);
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeLoadingScreen extends AFUIDefaultConnectedScreen<AFPrototypeLoadingScreenSPI, AFRouteParam>{
  static const runWidgetTestsId = "run_widget_tests";
  static const runScreenTestsId = "run_screen_tests";
  static const runWorkflowTestsId = "run_workflow_tests";
  AFPrototypeLoadingScreen(): super(AFUIScreenID.screenPrototypeLoading, AFPrototypeLoadingScreenSPI.create);

  @override
  Widget buildWithContext(AFPrototypeLoadingScreenSPI spi) {
    return _buildLoading(spi);
  }

  /// 
  Widget _buildLoading(AFPrototypeLoadingScreenSPI spi) {
    final context = spi.context;
    final t = context.t;

    final protoId = AFibD.config.startupPrototypeId;
    final rows = t.column();
    rows.add(t.childText("Loading Prototype"));
    rows.add(t.childText(protoId.toString()));
    
    return Scaffold(
      appBar: AppBar(        
        automaticallyImplyLeading: false,
        title: t.childText(AFUITranslationID.afibPrototypeLoading)
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: rows)
      )
    );
  }


}