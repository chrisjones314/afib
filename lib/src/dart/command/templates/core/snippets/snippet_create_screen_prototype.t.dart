import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetCreateScreenPrototypeT extends AFSourceTemplate {
  static const insertFullTestDataID = AFSourceTemplateInsertion("full_test_data_id");

  final String pushParams;
  SnippetCreateScreenPrototypeT({
    required this.pushParams
  });

  factory SnippetCreateScreenPrototypeT.noPushParams() {
    return SnippetCreateScreenPrototypeT(pushParams: '');
  }


  String get template => '''
var prototype = context.define${ScreenT.insertControlTypeSuffix}Prototype(
  id: ${insertAppNamespaceUpper}PrototypeID.${ScreenT.insertScreenID},
  stateView: ${insertAppNamespaceUpper}TestDataID.$insertFullTestDataID,
  navigate: $insertMainType.navigatePush($pushParams),
);
''';
}
