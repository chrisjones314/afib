import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:flutter/material.dart';

class AFPrototypeLoadingScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFRouteParam> {
  const AFPrototypeLoadingScreenSPI(super.context, super.standard);
  
  factory AFPrototypeLoadingScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParam> context, AFStandardSPIData standard) {
    return AFPrototypeLoadingScreenSPI(context, standard,
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeLoadingScreen extends AFUIConnectedScreen<AFPrototypeLoadingScreenSPI, AFUIDefaultStateView, AFRouteParam>{
  static const runWidgetTestsId = "run_widget_tests";
  static const runScreenTestsId = "run_screen_tests";
  static const runWorkflowTestsId = "run_workflow_tests";
  static final config =  AFUIDefaultScreenConfig<AFPrototypeLoadingScreenSPI, AFRouteParam> (
    spiCreator: AFPrototypeLoadingScreenSPI.create,
  );

  AFPrototypeLoadingScreen(): super(screenId: AFUIScreenID.screenPrototypeLoading, config: config);

  @override
  Widget buildWithSPI(AFPrototypeLoadingScreenSPI spi) {
    return _buildLoading(spi);
  }

  /// 
  Widget _buildLoading(AFPrototypeLoadingScreenSPI spi) {
    final t = spi.t;

    final startupId = AFibD.config.startupPrototypeId;
    final rows = t.column();
    rows.add(t.childText(text: "Loading Prototype"));
    rows.add(t.childText(text: startupId.toString()));
    
    return Scaffold(
      appBar: AppBar(        
        automaticallyImplyLeading: false,
        title: t.childText(text: AFUITranslationID.afibPrototypeLoading)
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: rows)
      )
    );
  }


}