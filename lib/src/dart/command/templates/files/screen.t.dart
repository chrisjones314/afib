

import 'package:afib/src/dart/command/af_source_template.dart';

class AFScreenT extends AFSourceTemplate {

  final String template = '''
import 'package:flutter/material.dart';
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/id.dart';
import 'package:[!af_package_name]/state/[!af_app_namespace]_state.dart';
import 'package:[!af_package_name]/ui/[!af_app_namespace]_connected_base.dart';

[!af_declare_route_param]

[!af_declare_state_view]

class [!af_screen_name]Screen extends [!af_app_namespace(upper)]ConnectedScreen<[!af_screen_name]StateView, [!af_screen_name]RouteParam> {

  //--------------------------------------------------------------------------------------
  [!af_screen_name]Screen(): super([!af_app_namespace(upper)]ScreenID.[!af_screen_name(lower)]);

  //--------------------------------------------------------------------------------------
  static AFNavigatePushAction navigatePush(String exampleParam) {      
    return AFNavigatePushAction(
      screen: [!af_app_namespace(upper)]ScreenID.[!af_screen_name(lower)],
      routeParam: [!af_screen_name]RouteParam(exampleParam: exampleParam)
    );
  }

  //--------------------------------------------------------------------------------------
  @override
  [!af_screen_name]StateView createStateView([!af_app_namespace(upper)]State state, [!af_screen_name]RouteParam param) {
    return [!af_screen_name]StateView("Pass a value from your state");
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget buildWithContext([!af_app_namespace(upper)]BuildContext<[!af_screen_name]StateView, [!af_screen_name]RouteParam> context) {
    return context.t.childScaffoldStandard<DFBuildContext<[!af_screen_name]StateView, [!af_screen_name]RouteParam>>(
      context: context, 
      screenId: screenId,
      bodyUnderScaffold: _buildBody, 
      contextSource: this,
      title: "[!af_screen_name]"
    );
  }

  //--------------------------------------------------------------------------------------
  Widget _buildBody([!af_app_namespace(upper)]BuildContext<[!af_screen_name]StateView, [!af_screen_name]RouteParam> context) {
    final t = context.t;
    final rows = t.column();
    rows.add(t.childText("Screen [!af_screen_name]"));
    rows.add(t.childText("Example route param: \$\{context.p.exampleParam\}"));
    rows.add(t.childText("Example state view: \$\{context.s.exampleState\}"));
    return Center(
      child: t.childColumn(rows)
    );
  }
}
''';
}
