import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetCreateScreenPrototypeT extends AFSourceTemplate {
  static const insertFullTestDataID = AFSourceTemplateInsertion("full_test_data_id");
  static const insertNavigatePushParams = AFSourceTemplateInsertion("push_params");

  SnippetCreateScreenPrototypeT();

  factory SnippetCreateScreenPrototypeT.noPushParams() {
    return SnippetCreateScreenPrototypeT();
  }


  @override
  String get template => '''
var prototype = context.define${ScreenT.insertControlTypeSuffix}Prototype(
  id: ${insertAppNamespaceUpper}PrototypeID.${ScreenT.insertScreenID},
  stateView: ${insertAppNamespaceUpper}TestDataID.$insertFullTestDataID,
  navigate: $insertMainType.navigatePush($insertNavigatePushParams),
);
''';
}
