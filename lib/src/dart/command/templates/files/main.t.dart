



import 'package:afib/src/dart/command/af_source_template.dart';

class AFMainT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_path]/initialization/create_dart_params.dart';
import 'package:[!af_package_path]/initialization/extend/extend_app.dart';
import 'package:[!af_package_path]/initialization/extend/extend_base.dart';
import 'package:[!af_package_path]/initialization/extend/extend_third_party_base.dart';
import 'package:[!af_package_path]/initialization/extend/extend_test.dart';
import 'package:[!af_package_path]/initialization/extend/extend_third_party_ui.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state.dart';

void main() {  
  afMainWrapper(() {
    final paramsD = createDartParams();
    afMain<[!af_app_namespace(upper)]State>(
      paramsD: paramsD, 
      extendBase: extendBase, 
      extendApp: extendApp, 
      extendThirdPartyBase: extendThirdPartyBase, 
      extendThirdPartyUI: extendThirdPartyUI, 
      extendTest: extendTest
    );
  });
}''';

}





