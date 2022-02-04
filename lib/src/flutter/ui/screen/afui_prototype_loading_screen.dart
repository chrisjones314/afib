import 'package:afib/id.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:flutter/material.dart';

class AFPrototypeLoadingScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFRouteParam> {
  AFPrototypeLoadingScreenSPI(AFBuildContext<AFUIDefaultStateView, AFRouteParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme, );
  
  factory AFPrototypeLoadingScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParam> context, AFUIDefaultTheme theme, AFScreenID screenId) {
    return AFPrototypeLoadingScreenSPI(context, screenId, theme,
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