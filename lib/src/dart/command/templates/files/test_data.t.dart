



import 'package:afib/src/dart/command/af_source_template.dart';

class AFTestDataT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state.dart';

void defineTestData(AFDefineTestDataContext context) {
  defineStates(context);
}

void defineStates(AFDefineTestDataContext context) {
  final stateFullLogin = <Object>[

  ];


  context.define([!af_app_namespace(upper)]TestDataID.[!af_app_namespace]StateFullLogin, [!af_app_namespace(upper)]State.fromList(stateFullLogin));
}

''';

}

