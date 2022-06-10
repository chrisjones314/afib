import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareDefineDefineTestDataT extends AFSourceTemplate {
  final String template = '''

void _define[!af_model_name](AFDefineTestDataContext context) {
  context.define([!af_app_namespace(upper)]TestDataID.stateFullLogin[!af_model_name], [!af_model_name]());
}

  ''';
}
