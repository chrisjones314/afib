import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareCreateScreenPrototypeT extends AFSourceTemplate {
  final String template = '''
  var prototype = definitions.define[!af_control_type_suffix]Prototype(
    id: [!af_app_namespace(upper)]PrototypeID.[!af_screen_test_id],
    navigate: [!af_screen_name].navigatePush(),
    models: [!af_app_namespace(upper)]TestDataID.[!af_full_test_data_id],
  );
  ''';
}
