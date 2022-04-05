import 'package:afib/src/dart/command/af_source_template.dart';

class AFScreenTestT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';

void define[!af_screen_name]Prototypes(AFScreenTestDefinitionContext definitions) {
  _define[!af_screen_name]PrototypeInitial(definitions);
}

void _define[!af_screen_name]PrototypeInitial(AFScreenTestDefinitionContext definitions) {  
  var prototype = definitions.define[!af_control_type_suffix]Prototype(
    id: [!af_app_namespace(upper)]PrototypeID.[!af_screen_test_id],
    navigate: [!af_screen_name].navigatePush(),
    models: [!af_app_namespace(upper)]TestDataID.[!af_full_test_data_id],
  );

  prototype.defineSmokeTest( 
    body: (e) async {
  });
}
''';
}