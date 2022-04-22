

import 'package:afib/src/dart/command/af_source_template.dart';

class AFExtendAppUILibraryT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_path]/ui/[!af_app_namespace]_define_ui.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state.dart';

void extendUI(AFUILibraryExtensionContext extend) {
    extend.initializeLibraryFundamentals(
      defineUI: defineUI, 
      defineFundamentalThemeArea: defineFundamentalThemeArea,
      initializeComponentState: () => [!af_app_namespace(upper)]State.initial() 
    );
}
''';
}
