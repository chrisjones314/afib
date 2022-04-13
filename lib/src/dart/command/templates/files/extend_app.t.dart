

import 'package:afib/src/dart/command/af_source_template.dart';

class AFExtendAppT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/app.dart';
import 'package:[!af_package_path]/ui/screen_map.dart';
import 'package:[!af_package_path]/query/startup_query.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state.dart';
import 'package:[!af_package_path]/ui/themes/[!af_app_namespace]_default_theme.dart';
import 'package:[!af_package_path]/ui/themes/[!af_app_namespace]_fundamental_theme.dart';

void queryErrorHandler(AFFinishQueryErrorContext<AFFlexibleState> context) {

}

void extendApp(AFAppExtensionContext extend) {

    extend.initializeAppFundamentals<[!af_app_namespace(upper)]State>(
      defineScreenMap: defineScreenMap, 
      defineFundamentalThemeArea: defineFundamentalThemeArea, 
      initializeAppState: () => [!af_app_namespace(upper)]State.initial(), 
      createStartupQueryAction: () => StartupQuery(),
      createApp: () => [!af_app_namespace(upper)]App(),
      defineFunctionalThemes: defineFunctionalThemes,
      queryErrorHandler: queryErrorHandler
    );

    // you can add queries to run at startup.
    // extend.addPluginStartupQuery();

    // you can add queries which respond to app lifecycle events
    // extend.addLifecycleQueryAction((state) => UpdateLifecycleStateQuery(state: state));
    
    // you can add a callback which gets notified anytime a query successfully finishes.
    // extend.addQuerySuccessListener();
}
''';
}
