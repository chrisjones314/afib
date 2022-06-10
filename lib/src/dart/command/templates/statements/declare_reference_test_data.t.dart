import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareReferenceTestDataT extends AFSourceTemplate {
  final String template = '    context.find([!af_app_namespace(upper)]TestDataID.stateFullLogin[!af_model_name]),';
}
