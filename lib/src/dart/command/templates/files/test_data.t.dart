



import 'package:afib/src/dart/command/af_source_template.dart';

class AFTestDataT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state.dart';

void defineTestData(AFCompositeTestDataRegistry testData) {
  defineStates(testData);
}

void defineStates(AFCompositeTestDataRegistry testData) {
  testData.register([!af_app_namespace(upper)]TestDataID.stateFullLogin, [!af_app_namespace(upper)]State.fromList(const [

  ]));
}

''';

}

